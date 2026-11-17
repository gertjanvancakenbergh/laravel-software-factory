#!/usr/bin/env bats
load helpers

setup() { make_project; }
teardown() { cleanup_project; }

@test "fails when not in a Laravel project instead of passing vacuously" {
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"composer.json not found"* ]]
  [[ "$output" == *"Gate FAILED"* ]]
}

@test "fails when a required tool is missing" {
  make_fake_laravel
  rm vendor/bin/phpstan
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"phpstan"*"missing"* ]]
}

@test "fails when there are no architecture tests" {
  make_fake_laravel
  rm tests/Architecture/ConventionsTest.php
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no tests in tests/Architecture"* ]]
}

@test "passes and runs every backend check including composer audit" {
  make_fake_laravel
  run "$CHECKS"
  [ "$status" -eq 0 ]
  grep -q "pest tests/Architecture" calls.log
  grep -q "pest --parallel" calls.log
  grep -q "pint --test" calls.log
  grep -q "phpstan analyse" calls.log
  grep -q "composer audit" calls.log
}

@test "runs all checks and reports every failure, not just the first" {
  make_fake_laravel
  export FAIL_pint=1 FAIL_composer=1
  run "$CHECKS"
  [ "$status" -ne 0 ]
  grep -q "phpstan analyse" calls.log
  [[ "$output" == *"pint"*"fail"* ]]
  [[ "$output" == *"composer-audit"*"fail"* ]]
}

@test "TypeScript projects must define typecheck and lint scripts" {
  make_fake_laravel
  echo '{"scripts":{"build":"vite build"}}' > package.json
  touch package-lock.json tsconfig.json
  mkdir node_modules
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"no 'typecheck' script"* ]]
}

@test "frontend checks run when scripts exist" {
  make_fake_laravel
  echo '{"scripts":{"typecheck":"tsc","lint":"eslint .","test":"vitest","build":"vite build"}}' > package.json
  touch package-lock.json tsconfig.json
  mkdir node_modules
  run "$CHECKS"
  [ "$status" -eq 0 ]
  grep -q "npm run --silent typecheck" calls.log
  grep -q "npm run --silent test" calls.log
  grep -q "npm audit --audit-level=high" calls.log
}

@test "missing lockfile fails the frontend gate" {
  make_fake_laravel
  echo '{"scripts":{"build":"vite build"}}' > package.json
  mkdir node_modules
  run "$CHECKS"
  [ "$status" -ne 0 ]
  [[ "$output" == *"package-lock.json missing"* ]]
}

@test "writes a JSON report when asked" {
  make_fake_laravel
  FACTORY_GATE_REPORT="$PROJECT/r.json" run "$CHECKS"
  [ "$status" -eq 0 ]
  run jq -r '.result' "$PROJECT/r.json"
  [ "$output" = "pass" ]
}
