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
  "$JOB" update 42 stage spec
  "$JOB" update 42 stage implement
  run jq -r '.stage' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "implement" ]
  run "$JOB" list
  [[ "$output" == *"42"*"implement"* ]]
}

@test "the gate can't be set by hand" {
  "$JOB" create 42
  run "$JOB" update 42 gate pass
  [ "$status" -ne 0 ]
  [[ "$output" == *"factory gate 42"* ]]
  run jq -r '.gate' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "pending" ]
}

@test "risk and other fields update in place, no duplicate keys appended" {
  "$JOB" create 42
  "$JOB" update 42 risk high
  "$JOB" update 42 verdict ACCEPT
  run jq -r '[.risk, .verdict] | join(",")' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "high,ACCEPT" ]
}

@test "enum fields reject invalid values" {
  "$JOB" create 42
  run "$JOB" update 42 risk catastrophic
  [ "$status" -ne 0 ]
  run "$JOB" update 42 stage shipping
  [ "$status" -ne 0 ]
  run "$JOB" add 42 surfaces blockchain
  [ "$status" -ne 0 ]
}

@test "values with slashes, ampersands and quotes are stored verbatim" {
  "$JOB" create 42
  "$JOB" update 42 branch 'feature/films&"planets"'
  "$JOB" add 42 findings 'BOLA in /api/v1/films/{id} & co'
  run jq -r '.branch' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = 'feature/films&"planets"' ]
  run jq -r '.findings[0]' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = 'BOLA in /api/v1/films/{id} & co' ]
}

@test "list fields de-duplicate and support removal" {
  "$JOB" create 42
  "$JOB" add 42 surfaces api
  "$JOB" add 42 surfaces api
  "$JOB" add 42 surfaces auth
  "$JOB" remove 42 surfaces api
  run jq -c '.surfaces' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = '["auth"]' ]
}

@test "moving to review requires a passing gate" {
  "$JOB" create 42
  run "$JOB" update 42 stage review
  [ "$status" -ne 0 ]
  [[ "$output" == *"gate is 'pending'"* ]]
  run "$JOB" update 42 approver APPROVE
  [ "$status" -ne 0 ]
  make_fake_laravel
  "$FACTORY" gate 42
  run "$JOB" update 42 stage review
  [ "$status" -eq 0 ]
}

@test "a partial gate report doesn't unlock review" {
  "$JOB" create 42
  f="$PROJECT/docs/context/jobs/42.json"
  jq '.gate = "pass" | .gate_report = {result: "pass", partial: true, steps: []}' "$f" > "$f.new" && mv "$f.new" "$f"
  run "$JOB" update 42 stage review
  [ "$status" -ne 0 ]
  [[ "$output" == *"partial"* ]]
}

@test "a lock left by a dead process is reclaimed" {
  dead="$(sh -c 'echo $$')"
  mkdir -p "$PROJECT/docs/context/jobs/.lock"
  echo "$dead" > "$PROJECT/docs/context/jobs/.lock/pid"
  run "$JOB" create 42
  [ "$status" -eq 0 ]
  [[ "$output" == *"stale lock"* ]]
  [ ! -e "$PROJECT/docs/context/jobs/.lock" ]
}

@test "a lock held by a live process blocks and names the holder" {
  mkdir -p "$PROJECT/docs/context/jobs/.lock"
  echo "$$" > "$PROJECT/docs/context/jobs/.lock/pid"
  FACTORY_LOCK_TRIES=2 run "$JOB" create 42
  [ "$status" -ne 0 ]
  [[ "$output" == *"held by process $$"* ]]
  [ ! -e "$PROJECT/docs/context/jobs/42.json" ]
}

@test "gate_required=false lifts the gate rule" {
  jq '.gate_required = false' "$PROJECT/factory/config.json" > "$PROJECT/c" && mv "$PROJECT/c" "$PROJECT/factory/config.json"
  "$JOB" create 42
  run "$JOB" update 42 stage review
  [ "$status" -eq 0 ]
}

@test "history records every change" {
  "$JOB" create 42
  "$JOB" update 42 stage spec
  run jq -r '.history[-1] | "\(.field):\(.from)->\(.to)"' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "stage:intake->spec" ]
}

@test "list ignores README and non-job files" {
  run "$JOB" list
  [ "$output" = "No jobs yet." ]
  "$JOB" create 7 "Seven"
  run "$JOB" list
  [[ "$output" != *"README"* ]]
  run "$JOB" list --json
  [ "$(echo "$output" | jq length)" -eq 1 ]
}
