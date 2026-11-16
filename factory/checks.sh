#!/usr/bin/env bash
# Deterministic gate. Runs every check, prints a summary, exits non-zero if
# anything failed or a required tool is missing. CI runs this same script.
#
# Options (environment):
#   FACTORY_GATE_REPORT=<file>   also write a JSON report (used by `factory gate`)
#   FACTORY_GATE_ONLY="pest pint" run a subset (step names below)
set -uo pipefail
# shellcheck source=lib/common.sh
. "$(cd "$(dirname "$0")/lib" && pwd)/common.sh"
require_jq
cd "$ROOT" || die "cannot cd to $ROOT"

RESULTS=""      # lines of "name<TAB>status<TAB>seconds<TAB>detail"
FAILED=0

record() {
  RESULTS="${RESULTS}$1	$2	$3	$4
"
  [ "$2" = "pass" ] || FAILED=1
}

run_step() {
  local name="$1"; shift
  local start end
  start=$(date +%s)
  if "$@" >/tmp/gate.out 2>&1; then
    end=$(date +%s)
    record "$name" pass $((end - start)) "ok"
  else
    end=$(date +%s)
    local detail
    detail=$(tail -5 /tmp/gate.out | tr '\n' ' ' | sed 's/  */ /g')
    record "$name" fail $((end - start)) "$detail"
  fi
}

missing() {
  record "$1" missing 0 "$2"
}

has_script() {
  jq -e ".scripts[\"$1\"]" package.json >/dev/null 2>&1
}

# ---------- Backend ----------
if [ ! -f composer.json ]; then
  missing composer "composer.json not found"
else
  for tool in pest pint phpstan; do
    if [ ! -x vendor/bin/$tool ]; then
      missing "$tool" "vendor/bin/$tool missing (run composer install)"
    fi
  done

  if [ -d tests/Architecture ] && [ -n "$(find tests/Architecture -name '*.php' -print -quit)" ]; then
    run_step "pest-architecture" vendor/bin/pest tests/Architecture --parallel
  else
    missing "pest-architecture" "no tests in tests/Architecture"
  fi

  run_step pest vendor/bin/pest --parallel
  run_step pint vendor/bin/pint --test
  run_step phpstan vendor/bin/phpstan analyse --memory-limit=2G
  run_step composer-audit composer audit
fi

# ---------- Frontend (when present) ----------
if [ -f package.json ]; then
  if [ ! -f package-lock.json ]; then
    missing npm-lock "package-lock.json missing"
  fi
  if [ -f tsconfig.json ]; then
    for s in typecheck lint; do
      if has_script "$s"; then run_step "npm-$s" npm run --silent "$s"
      else missing "npm-$s" "package.json has no '$s' script (required for TypeScript projects)"; fi
    done
  else
    for s in typecheck lint; do has_script "$s" && run_step "npm-$s" npm run --silent "$s"; done
  fi
  has_script test && run_step npm-test env CI=true npm run --silent test
  has_script build && run_step npm-build npm run --silent build
  run_step npm-audit npm audit --audit-level=high
fi

# ---------- Summary ----------
echo ""
echo "=== Gate summary ==="
if [ -z "$RESULTS" ]; then
  echo "no checks ran"
  record gate missing 0 "no checks ran"
fi
printf '%s' "$RESULTS" | while IFS="$(printf '\t')" read -r name status secs detail; do
  printf '  %-16s %-8s %4ss  %s\n' "$name" "$status" "$secs" "$detail"
done

if [ -n "${FACTORY_GATE_REPORT:-}" ]; then
  printf '%s' "$RESULTS" | jq -R -s --arg at "$(now_utc)" --argjson failed "$FAILED" '
    { at: $at, result: (if $failed == 0 then "pass" else "fail" end),
      steps: [split("\n")[] | select(length > 0) | split("\t")
              | {name: .[0], status: .[1], seconds: (.[2] | tonumber), detail: .[3]}] }' \
    > "$FACTORY_GATE_REPORT"
fi

if [ "$FAILED" -eq 0 ]; then
  echo "=== Gate passed ==="
else
  echo "=== Gate FAILED ==="
fi
exit "$FAILED"
