# Gate

The gate is `factory/checks.sh`. It must pass before any specialist review or Approver recommendation.

It runs:

- Architecture tests (Pest, `tests/Architecture/`)
- Pest (parallel)
- Pint
- PHPStan / Larastan
- composer audit
- Frontend typecheck, lint, test, build and npm audit (when present)

CI runs the same script. The job tool refuses to move a job to review or set APPROVE until the gate is `pass`.
