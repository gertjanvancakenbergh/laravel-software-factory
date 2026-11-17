#!/usr/bin/env bats
load helpers

setup() { make_project; }
teardown() { cleanup_project; }

@test "mode shows and validates" {
  run "$FACTORY" mode
  [ "$output" = "manual" ]
  run "$FACTORY" mode turbo
  [ "$status" -ne 0 ]
  "$FACTORY" mode auto
  run "$FACTORY" mode
  [ "$output" = "auto" ]
}

@test "run refuses in manual mode" {
  run "$FACTORY" run 5
  [ "$status" -ne 0 ]
  [[ "$output" == *"auto mode is not active"* ]]
}

stub_gh() {
  mkdir -p "$PROJECT/bin"
  cat > "$PROJECT/bin/gh" <<GH
#!/bin/sh
echo "gh \$*" >> "$PROJECT/gh.log"
case "\$1 \$2" in
  "issue view") echo '{"number":5,"title":"List films","body":"As a fan...","labels":[],"url":"https://example.test/5"}' ;;
  "issue list") printf '5\n6\n7\n' ;;
esac
GH
  chmod +x "$PROJECT/bin/gh"
  export PATH="$PROJECT/bin:$PATH"
}

@test "run <issue> creates the job from GitHub and relabels the issue" {
  stub_gh
  "$FACTORY" mode auto
  run "$FACTORY" run 5
  [ "$status" -eq 0 ]
  run jq -r '.title' "$PROJECT/docs/context/jobs/5.json"
  [ "$output" = "List films" ]
  grep -q "As a fan" "$PROJECT/docs/context/jobs/5.issue.md"
  grep -q "issue edit 5 --add-label factory:in-progress --remove-label factory" "$PROJECT/gh.log"
}

@test "run respects the concurrency limit" {
  stub_gh
  "$FACTORY" mode auto
  jq '.concurrency = 2' "$PROJECT/factory/config.json" > "$PROJECT/c" && mv "$PROJECT/c" "$PROJECT/factory/config.json"
  "$JOB" create 1 "Already active"
  run "$FACTORY" run
  [ "$status" -eq 0 ]
  grep -q "issue list --label factory --state open --limit 1" "$PROJECT/gh.log"
}

@test "gate records the result and report on the job" {
  make_fake_laravel
  "$JOB" create 42
  run "$FACTORY" gate 42
  [ "$status" -eq 0 ]
  run jq -r '.gate + " " + .gate_report.result' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "pass pass" ]

  export FAIL_phpstan=1
  run "$FACTORY" gate 42
  [ "$status" -ne 0 ]
  run jq -r '.gate' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "fail" ]
  run jq -r '.gate_report.steps[] | select(.name=="phpstan") | .status' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "fail" ]
}

@test "escalate blocks the job and records the reason" {
  "$JOB" create 42
  run "$FACTORY" escalate 42 "conflicting security findings"
  [ "$status" -eq 0 ]
  run jq -r '.stage + "|" + .findings[0]' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "blocked|ESCALATED: conflicting security findings" ]
}

@test "dashboard renders jobs and escapes HTML" {
  "$JOB" create 42 '<script>alert(1)</script>'
  run "$FACTORY" dashboard
  [ "$status" -eq 0 ]
  grep -q '&lt;script&gt;' "$PROJECT/docs/context/dashboard.html"
  ! grep -q '<script>alert' "$PROJECT/docs/context/dashboard.html"
}

@test "doctor reports missing setup and points to the docker gate" {
  run "$FACTORY" doctor
  [ "$status" -ne 0 ]
  [[ "$output" == *"no artisan"* ]]
  [[ "$output" == *"--docker"* ]]
}

@test "doctor passes on a complete project" {
  make_fake_laravel
  printf 'includes:\n  - vendor/larastan/larastan/extension.neon\n' > phpstan.neon
  mkdir -p "$PROJECT/realphp"
  # The fake php stub can't evaluate the version check; use a stub that succeeds.
  printf '#!/bin/sh\n[ "$1" = "-r" ] && case "$2" in *echo*) printf 8.3.6;; esac\nexit 0\n' > "$PROJECT/bin/php"
  git init -q 2>/dev/null || true
  run "$FACTORY" doctor
  [ "$status" -eq 0 ]
  [[ "$output" == *"Ready."* ]]
}

@test "gate --docker runs the container and records its report" {
  "$JOB" create 42
  mkdir -p "$PROJECT/bin"
  cat > "$PROJECT/bin/docker" <<STUB
#!/bin/sh
echo "docker \$*" >> "$PROJECT/docker.log"
[ "\$1" = "image" ] && exit 0
for a in "\$@"; do
  case "\$a" in FACTORY_GATE_REPORT=*) out="\${a#FACTORY_GATE_REPORT=}" ;; esac
done
out="$PROJECT\${out#/app}"
echo '{"result":"pass","steps":[]}' > "\$out"
STUB
  chmod +x "$PROJECT/bin/docker"
  export PATH="$PROJECT/bin:$PATH"
  run "$FACTORY" gate 42 --docker
  [ "$status" -eq 0 ]
  grep -q -- "-v /app/vendor -v /app/node_modules" "$PROJECT/docker.log"
  run jq -r '.gate' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "pass" ]
  [ ! -e "$PROJECT/docs/context/jobs/.gate-42.json" ]
}

@test "the gate report records the commit it verified" {
  make_fake_laravel
  git_commit_all initial
  "$JOB" create 42
  "$FACTORY" gate 42
  run jq -r '.gate_report.commit' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "$(git -C "$PROJECT" rev-parse HEAD)" ]
  run jq -r '.history[-1].event' "$PROJECT/docs/context/jobs/42.json"
  [ "$output" = "gate" ]
}

@test "a gate pass goes stale when HEAD moves" {
  make_fake_laravel
  git_commit_all initial
  "$JOB" create 42
  "$FACTORY" gate 42
  echo '<?php // more work' > app.php
  git_commit_all "more work"
  run "$JOB" update 42 stage review
  [ "$status" -ne 0 ]
  [[ "$output" == *"re-run the gate"* ]]
  "$FACTORY" gate 42
  run "$JOB" update 42 stage review
  [ "$status" -eq 0 ]
}

@test "a gate run on uncommitted changes doesn't unlock review" {
  make_fake_laravel
  git_commit_all initial
  "$JOB" create 42
  echo '<?php // not committed' > app.php
  "$FACTORY" gate 42
  run "$JOB" update 42 stage review
  [ "$status" -ne 0 ]
  [[ "$output" == *"uncommitted"* ]]
}

@test "job state changes don't count as uncommitted work" {
  make_fake_laravel
  git_commit_all initial
  "$JOB" create 42
  "$JOB" update 42 risk low
  "$FACTORY" gate 42
  run "$JOB" update 42 stage review
  [ "$status" -eq 0 ]
}
