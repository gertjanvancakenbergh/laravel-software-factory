# Recovery

The Orchestrator owns recovery. Job state (`docs/context/jobs/<id>.json`) is the source of truth.

## Gate failure

`factory gate <id>` has already recorded `gate: fail` and the per-step report.
Send the Implementer the failing steps from `job show <id> --json | jq .gate_report`.
No review until it passes.

## Specialist conflict

Record both Findings on the job (`job add <id> findings …`). Issue a Decision.
If security or data loss is involved: `factory escalate <id> "<summary>"`.

## Intake returns NEEDS-INFO

`factory escalate <id> "needs info: <questions>"`. Resume after the human answers:
`job update <id> stage intake`.

## Interrupted session

Read `job show <id>` and continue from `stage`. If the stage is past `implement`
and the gate isn't a fresh pass (the job tool says why), commit and re-run `factory gate <id>`.

## Stale lock

The lock (`docs/context/jobs/.lock/`) stores the holder's PID. A lock left by a
crashed or killed command is removed automatically on the next command. If a
command still reports the lock is held, that process is alive: wait for it, or
stop it.

## High-risk change

Human review before merge, even on APPROVE.
