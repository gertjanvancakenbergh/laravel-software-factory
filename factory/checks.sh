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

selected() {
  [ -z "${FACTORY_GATE_ONLY:-}" ] && return 0
  in_list "$1" "$FACTORY_GATE_ONLY"
}

# run_step <name> <command...>
run_step() {
  local name="$1" start end status
  shift
  selected "$name" || return 0
  echo ""
  echo "▶ $name: $*"
  start=$(date +%s)
  "$@"
  status=$?
  end=$(date +%s)
  if [ "$status" -eq 0 ]; then
    record "$name" pass $((end - start)) ""
  else
    record "$name" fail $((end - start)) "exit $status"
  fi
}

missing() {
  selected "$1" || return 0
  echo ""
  echo "✖ $1: $2"
  record "$1" missing 0 "$2"
}

require_bin() {
  # require_bin <step> <path> <install hint>
  if [ -x "$2" ]; then return 0; fi
  missing "$1" "$2 not found. $3"
  return 1
}

echo "=== Deterministic gate ($ROOT) ==="

# Record what is being verified before any step runs (steps may write files).
GATE_COMMIT=""; GATE_DIRTY=false
if in_git_repo; then
  GATE_COMMIT="$(git_head)"
  if git_dirty; then GATE_DIRTY=true; fi
fi
GATE_PARTIAL=false
[ -n "${FACTORY_GATE_ONLY:-}" ] && GATE_PARTIAL=true

# ---------- Backend ----------
if [ ! -f composer.json ]; then
  missing composer "composer.json not found; run the gate from a Laravel project root"
else
  if [ ! -d vendor ]; then
    missing composer "vendor/ missing; run 'composer install' first"
  fi

  if require_bin pest vendor/bin/pest "composer require --dev pestphp/pest"; then
    if [ -z "$(find tests/Architecture -name '*Test.php' 2>/dev/null | head -1)" ]; then
      missing architecture "no tests in tests/Architecture (see docs/factory/gate.md)"
    else
      run_step architecture vendor/bin/pest tests/Architecture
    fi
    run_step pest vendor/bin/pest --parallel
  fi

  require_bin pint vendor/bin/pint "composer require --dev laravel/pint" &&
    run_step pint vendor/bin/pint --test

  if require_bin phpstan vendor/bin/phpstan "composer require --dev larastan/larastan"; then
    if [ ! -f phpstan.neon ] && [ ! -f phpstan.neon.dist ]; then
      missing phpstan "phpstan.neon not found"
    else
      run_step phpstan vendor/bin/phpstan analyse --no-progress --memory-limit=2G
    fi
  fi

  if command -v composer >/dev/null 2>&1; then
    run_step composer-audit composer audit --no-interaction --locked
  else
    missing composer-audit "composer not on PATH"
  fi
fi

# ---------- API routes ----------
# Every api/ route must be registered, throttled and referenced by a test.
# gate.api: required (default) | off. See docs/factory/gate.md.
# shellcheck disable=SC2317,SC2329 # invoked via run_step
check_api_routes() {
  local json ignore problems=0 line uri name prefix
  json="$(php artisan route:list --json --path=api 2>/dev/null)" || {
    echo "php artisan route:list failed"; return 1; }
  if ! printf '%s' "$json" | jq -e 'type == "array" and length > 0' >/dev/null 2>&1; then
    echo "no api routes registered. Laravel 11+ only loads routes/api.php after 'php artisan install:api'."
    return 1
  fi
  ignore="$(config_get '.gate.api_route_ignore' '[]')"
  json="$(printf '%s' "$json" | jq -c --argjson ignore "$ignore" \
    '[.[] | select(.uri as $u | ($ignore | index($u)) | not)]')"

  if [ "$(config_get '.gate.require_throttle' true)" = "true" ]; then
    while IFS= read -r line; do
      [ -n "$line" ] || continue
      echo "not rate limited: $line (add throttle middleware, or \$middleware->throttleApi() in bootstrap/app.php)"
      problems=1
    done <<ROUTES
$(printf '%s' "$json" | jq -r '.[]
  | select((.middleware // []) | (if type == "array" then . else [.] end)
           | map(test("throttle|ThrottleRequests"; "i")) | any | not)
  | "\(.method) /\(.uri)"')
ROUTES
  fi

  if [ "$(config_get '.gate.require_route_tests' true)" = "true" ]; then
    # A test may hit the URL or use the route name: route('films.show', ...).
    while IFS="$(printf '\t')" read -r uri name; do
      [ -n "$uri" ] || continue
      # Static part of the URI before the first parameter: api/v1/films/{film} -> api/v1/films
      prefix="${uri%%\{*}"
      prefix="${prefix%/}"
      grep -rqF -- "$prefix" tests --include='*.php' 2>/dev/null && continue
      if [ -n "$name" ] && grep -rqE -- "route\\([\"']${name//./\\.}[\"']" tests --include='*.php' 2>/dev/null; then
        continue
      fi
      echo "no test references /$prefix (route /$uri${name:+, name $name})"
      problems=1
    done <<ROUTES
$(printf '%s' "$json" | jq -r '[.[] | [.uri, (.name // "")]] | unique[] | @tsv')
ROUTES
  fi
  return "$problems"
}

# Seeders other than DatabaseSeeder must be called from it, or `migrate --seed`
# silently skips them.
# shellcheck disable=SC2317,SC2329 # invoked via run_step
check_seeders() {
  local f cls ignore problems=0
  ignore="$(config_get '.gate.seeders_ignore' '[]')"
  for f in database/seeders/*.php; do
    [ -f "$f" ] || continue
    cls="$(basename "$f" .php)"
    [ "$cls" = "DatabaseSeeder" ] && continue
    printf '%s' "$ignore" | jq -e --arg c "$cls" 'index($c)' >/dev/null && continue
    if ! grep -qw -- "$cls" database/seeders/DatabaseSeeder.php; then
      echo "seeder $cls is never called from DatabaseSeeder (or list it in gate.seeders_ignore)"
      problems=1
    fi
  done
  return "$problems"
}

if [ -f composer.json ]; then
  if [ "$(config_get '.gate.api' required)" != "off" ]; then
    if [ ! -f routes/api.php ]; then
      missing api-routes "routes/api.php not found; run 'php artisan install:api' (or set gate.api to off)"
    elif ! command -v php >/dev/null 2>&1; then
      missing api-routes "php not on PATH"
    elif [ ! -f artisan ]; then
      missing api-routes "artisan not found"
    else
      run_step api-routes check_api_routes
    fi
  fi
  if [ -f database/seeders/DatabaseSeeder.php ]; then
    run_step seeders check_seeders
  fi
fi

# ---------- Frontend ----------
# frontend mode: auto (run when package.json exists), required, off
FRONTEND="$(config_get '.gate.frontend' auto)"
has_script() { jq -e --arg s "$1" '.scripts[$s]' package.json >/dev/null 2>&1; }

if [ "$FRONTEND" = "required" ] && [ ! -f package.json ]; then
  missing frontend "gate.frontend is 'required' but package.json not found"
elif [ "$FRONTEND" != "off" ] && [ -f package.json ]; then
  if [ ! -f package-lock.json ]; then
    missing npm-lockfile "package-lock.json missing; commit it so installs are reproducible"
  fi
  if [ ! -d node_modules ]; then
    missing npm "node_modules/ missing; run 'npm ci' first"
  else
    # TypeScript projects must typecheck and lint; scripts are not optional there.
    if [ -f tsconfig.json ] || [ "$FRONTEND" = "required" ]; then
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
  printf '%s' "$RESULTS" | jq -R -s --arg at "$(now_utc)" --argjson failed "$FAILED" \
    --arg commit "$GATE_COMMIT" --argjson dirty "$GATE_DIRTY" --argjson partial "$GATE_PARTIAL" '
    { at: $at, result: (if $failed == 0 then "pass" else "fail" end),
      commit: (if $commit == "" then null else $commit end), dirty: $dirty, partial: $partial,
      steps: [split("\n")[] | select(length > 0) | split("\t")
              | {name: .[0], status: .[1], seconds: (.[2] | tonumber), detail: .[3]}] }' \
    | atomic_write "$FACTORY_GATE_REPORT"
fi

if [ "$FAILED" -eq 0 ]; then
  echo "=== Gate passed ==="
else
  echo "=== Gate FAILED ==="
fi
exit "$FAILED"
