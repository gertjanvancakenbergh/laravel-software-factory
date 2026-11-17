# Deterministic Gate

`factory/checks.sh` is the gate. CI (`.github/workflows/factory-gate.yml`) runs the
same script, so local and CI results match. Run it from anywhere in the project;
record it on a job with `./factory/bin/factory gate <job-id>`.

## What it runs

| Step | Command | Fails when |
|------|---------|-----------|
| architecture | `vendor/bin/pest tests/Architecture` | tests fail, or `tests/Architecture/` has no tests |
| pest | `vendor/bin/pest --parallel` | any test fails |
| pint | `vendor/bin/pint --test` | style violations |
| phpstan | `vendor/bin/phpstan analyse` | errors at the configured level (Larastan, level 6 by default) |
| composer-audit | `composer audit --locked` | known advisories in locked dependencies |
| api-routes | `php artisan route:list --json --path=api` | no api routes registered (`install:api` not run); a route without throttle middleware; a route no test file references |
| seeders | scans `database/seeders/` | a seeder isn't called from `DatabaseSeeder` |
| npm-typecheck, npm-lint | `npm run typecheck` / `lint` | failures; **missing scripts fail** when `tsconfig.json` exists |
| npm-test | `CI=true npm run test` | failures (only if a `test` script exists) |
| npm-build | `npm run build` | build failure (only if a `build` script exists) |
| npm-audit | `npm audit --audit-level=high` | high or critical advisories |

A missing tool (`vendor/bin/pest`, `composer.json`, `node_modules`, a lockfile) is a
**failure**, not a skip. The gate runs every step and lists all failures at the end.

Frontend checks run when `package.json` exists. Set `gate.frontend` in
`factory/config.json` to `required` (fail if there's no frontend) or `off`.

### API route checks

The route-test check is a heuristic: it looks for the route's static prefix
(`api/v1/films` for `api/v1/films/{film}`), or a `route('<name>'` call for named
routes, in any file under `tests/`. It proves a
route isn't completely untested, not that it's well tested; QA and the Reviewer cover the rest.

The `/api/user` route that `install:api` scaffolds needs a test, throttling, or removal.

| `factory/config.json` key | Default | Effect |
|---|---|---|
| `gate.api` | `required` | `off` for projects without an API |
| `gate.require_throttle` | `true` | fail on unthrottled api routes |
| `gate.require_route_tests` | `true` | fail on api routes no test references |
| `gate.api_route_ignore` | `[]` | URIs to skip, e.g. `["api/user"]` |
| `gate.seeders_ignore` | `[]` | seeders deliberately run on demand |

Changing these weakens the gate, so it needs the human (`docs/factory/safety.md`).

## Without local PHP

```bash
./factory/bin/factory doctor           # what's missing locally
./factory/bin/factory gate 42 --docker # same gate in a container (needs Docker)
```

The container (`factory/docker/`) installs dependencies into its own volumes, so
your host `vendor/` and `node_modules/` are left alone, and records the result on the job like a local run.

## Options

- `FACTORY_GATE_ONLY="pest pint" ./factory/checks.sh` runs a subset while iterating.
  A subset run is never recorded as the job's gate.
- `FACTORY_GATE_REPORT=report.json` writes a JSON report (used by `factory gate`).

## What a recorded pass means

`factory gate <id>` is the only writer of the job's `gate` field; `job update <id> gate`
is refused. The report stores what was verified:

| Report field | Meaning |
|---|---|
| `result` | `pass` or `fail` |
| `commit` | `git rev-parse HEAD` when the gate started (null outside git) |
| `dirty` | `true` if there were uncommitted changes outside `docs/context/` |
| `partial` | `true` if `FACTORY_GATE_ONLY` limited the run |
| `steps` | name, status, seconds and detail per step |

A pass unlocks review only while it is **fresh**: full run, clean tree, and
`commit` equal to the current `HEAD`. Commit, gate, then move on; any later commit
needs a new gate run. Job state under `docs/context/` doesn't count as a change.

This is a guardrail against mistakes and drifting agents, not a security boundary:
someone who edits the job JSON by hand can still fake a pass. CI running the same
gate on the PR is the check that can't be skipped.

## Rules

- Green gate before any reviewer runs. Failed gate → back to the Implementer with the report.
- The job tool refuses `stage review|approver|done` and `approver APPROVE` until the gate
  passed freshly (disable only by setting `gate_required: false`, which you shouldn't).
- Don't weaken the gate to get green: no lowering the PHPStan level, no new baseline
  entries or `@phpstan-ignore` without a reason in the handoff.
