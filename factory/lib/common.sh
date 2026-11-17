# shellcheck shell=bash
# Shared helpers for factory scripts. Sourced, not executed.
# Compatible with bash 3.2 (macOS default).
# shellcheck disable=SC2034

# Project root: override with FACTORY_ROOT (used by tests), otherwise two
# levels up from factory/bin or one level up from factory/.
factory_root() {
  if [ -n "${FACTORY_ROOT:-}" ]; then
    (cd "$FACTORY_ROOT" && pwd)
    return
  fi
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  (cd "$here/../.." && pwd)
}

ROOT="$(factory_root)"
CONFIG="$ROOT/factory/config.json"
JOBS_DIR="$ROOT/docs/context/jobs"

die() {
  echo "error: $*" >&2
  exit 1
}

warn() {
  echo "warning: $*" >&2
}

now_utc() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "'$1' is required but not installed. $2"
}

require_jq() {
  require_cmd jq "Install it with 'brew install jq' or 'apt-get install jq'."
}

# config_get <jq-filter> <default>
config_get() {
  local value
  if [ ! -f "$CONFIG" ]; then
    echo "$2"
    return
  fi
  # Not `// empty`: that would treat an explicit `false` as missing.
  value="$(jq -r "($1) as \$v | if \$v == null then empty else \$v end" "$CONFIG")" ||
    die "factory/config.json is not valid JSON"
  if [ -z "$value" ]; then echo "$2"; else echo "$value"; fi
}

# Write stdin to a file atomically (temp file in the same directory, then mv).
atomic_write() {
  local target="$1" tmp
  tmp="$(mktemp "$(dirname "$target")/.tmp.XXXXXX")" || die "cannot create temp file"
  if ! cat > "$tmp"; then rm -f "$tmp"; die "cannot write $target"; fi
  mv "$tmp" "$target"
}

# Cross-platform lock using mkdir (atomic on POSIX filesystems). The holder's
# PID is stored in the lock, so a lock left behind by a crashed or killed
# command is reclaimed instead of blocking every later command.
#   FACTORY_LOCK_TRIES  attempts at 0.1s intervals before giving up (default 50)
with_lock() {
  local lock="$JOBS_DIR/.lock" tries=0 max="${FACTORY_LOCK_TRIES:-50}" holder status
  mkdir -p "$JOBS_DIR"
  while ! mkdir "$lock" 2>/dev/null; do
    holder="$(cat "$lock/pid" 2>/dev/null || true)"
    if [ -n "$holder" ] && ! kill -0 "$holder" 2>/dev/null; then
      # Holder is gone. Re-check the PID right before removing, so we never
      # delete a lock another process has just reclaimed.
      if [ "$(cat "$lock/pid" 2>/dev/null || true)" = "$holder" ]; then
        warn "removing stale lock left by process $holder"
        rm -rf "$lock"
      fi
      continue
    fi
    tries=$((tries + 1))
    [ "$tries" -gt "$max" ] && die "could not acquire $lock (held by process ${holder:-unknown})"
    sleep 0.1
  done
  echo "$$" > "$lock/pid"
  # shellcheck disable=SC2064
  trap "rm -rf '$lock'" EXIT
  # Call plainly: `"$@" || ...` would switch off errexit inside the callee,
  # and a failing `$(job_file ...)` would then no longer abort the command.
  # On failure under set -e the EXIT trap removes the lock.
  "$@"
  status=$?
  rm -rf "$lock"
  trap - EXIT
  return "$status"
}

# --- git helpers (gate freshness) ---
in_git_repo() { git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; }
git_head() { git -C "$ROOT" rev-parse HEAD 2>/dev/null || true; }
# Uncommitted changes outside docs/context/ (job state changes all the time
# and is not part of what the gate verifies).
git_dirty() {
  [ -n "$(git -C "$ROOT" status --porcelain -- . ':(exclude)docs/context' 2>/dev/null)" ]
}

# gate_fresh <job-file>: succeeds when the job holds a full, passing gate
# report for the code as it is now. Prints the reason on failure.
gate_fresh() {
  local file="$1" gate result partial commit dirty head
  gate="$(jq -r '.gate' "$file")"
  result="$(jq -r '.gate_report.result // "none"' "$file")"
  partial="$(jq -r '.gate_report.partial // false' "$file")"
  if [ "$gate" != "pass" ] || [ "$result" != "pass" ]; then
    echo "gate is '$gate' (run: factory gate <id>)"; return 1
  fi
  if [ "$partial" = "true" ]; then
    echo "the recorded gate was a partial run; run the full gate"; return 1
  fi
  in_git_repo || return 0
  commit="$(jq -r '.gate_report.commit // ""' "$file")"
  dirty="$(jq -r '.gate_report.dirty // false' "$file")"
  head="$(git_head)"
  if [ "$dirty" = "true" ]; then
    echo "the gate ran on uncommitted changes; commit, then re-run the gate"; return 1
  fi
  if [ -n "$head" ] && [ "$commit" != "$head" ]; then
    echo "the gate passed on ${commit:-an unknown commit}, but HEAD is now $head; re-run the gate"; return 1
  fi
  return 0
}

valid_id() {
  case "$1" in
    ''|*[!A-Za-z0-9._-]*|.*) return 1 ;;
    *) return 0 ;;
  esac
}

# in_list <value> <space-separated allowed values>
in_list() {
  local v="$1" item
  for item in $2; do
    [ "$v" = "$item" ] && return 0
  done
  return 1
}

STAGES="intake spec tickets implement gate review approver done blocked"
RISKS="pending low medium high"
VERDICTS="pending ACCEPT NEEDS-INFO REJECT"
GATES="pending pass fail"
APPROVALS="pending APPROVE NEEDS-CHANGES ESCALATE"
SURFACES="api auth database frontend performance security privacy queue observability devops"
