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
