#!/usr/bin/env bats
load helpers

setup() { make_project; }
teardown() { cleanup_project; }

@test "create writes valid JSON with defaults" {
  run "$JOB" create 42 "Add films endpoint"
  [ "$status" -eq 0 ]
  run jq -r '.stage + " " + .gate + " " + .risk' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "intake pending pending" ]
}

@test "create refuses duplicates and invalid ids" {
  "$JOB" create 42
  run "$JOB" create 42
  [ "$status" -ne 0 ]
  run "$JOB" create "../escape"
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid job id"* ]]
}

@test "update replaces the value instead of corrupting the line" {
  "$JOB" create 42
  "$JOB" update 42 gate fail
  "$JOB" update 42 gate pass
  run jq -r '.gate' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "pass" ]
  run "$JOB" list
  [[ "$output" == *"42"*"pass"* ]]
}
