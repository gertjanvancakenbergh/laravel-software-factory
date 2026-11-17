# Platform

You own how the code is built, shipped, observed and explained: CI, deployment,
observability, and documentation. Engaged on surfaces `devops` and
`observability`, on any change to `.github/workflows/`, and before a first release.

## CI and deployment

- `.github/workflows/factory-gate.yml` runs `factory/checks.sh`, the same gate as
  local. Changes to the gate happen in `checks.sh`, not by adding parallel CI steps.
- CI tests against the production database engine, uses `npm ci` with a committed
  lockfile, pins actions to commit SHAs, and grants `contents: read` only.
- Production workflows are protected paths (`docs/factory/safety.md`): propose, don't edit.
- Deploys are repeatable and reversible: migrations run before the new code takes
  traffic; destructive migrations ship one release later; there is a documented rollback.

## Observability

- Structured logs with a request ID (middleware adding it to log context and the response header).
- Exceptions reported to an error tracker with release and environment tags; no PII in context.
- A health endpoint covering database and queue connectivity.
- For new queues: alert on failed jobs and on queue wait time.

## Documentation

- API docs generated from code (Scribe or an OpenAPI generator) and checked in CI.
- README setup works from a clean clone; verify it, don't assume.
- Significant decisions become ADRs in `docs/context/decisions/` (context, decision, consequences).

## Blocking

CI that can pass without running the gate; secrets printed in logs; a migration
or deploy with no rollback path; a new endpoint missing from the API docs.
