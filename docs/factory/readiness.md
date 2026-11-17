# Readiness

What is verified, and what still needs evidence before calling this production-ready.

## Verified by automated tests (`tests/`, CI on Linux + macOS bash 3.2)

- [x] Job state: validated fields, atomic writes, history, no corruption on values with `/`, `&`, quotes
- [x] Gate enforcement: no `review`/`approver`/`done`/`APPROVE` without a fresh, full gate pass
      (same commit as `HEAD`, clean tree); the gate result can't be set by hand
- [x] Stale locks from crashed commands are reclaimed; live locks name their holder
- [x] Scripts keep their executable bit in git (`tests/repo.bats`)
- [x] Gate fails on missing tools, missing architecture tests, missing lockfile, missing TS scripts
- [x] Gate runs every step and reports all failures; JSON report
- [x] Auto mode: claims issues via `gh`, respects `concurrency`, relabels issues
- [x] Escalation and dashboard (HTML-escaped)
- [x] Installer: never overwrites `package.json`/`README.md`/`composer.json` or project state; idempotent
- [x] API route checks: unloaded `routes/api.php`, unthrottled routes, routes no test references
- [x] Unregistered seeders
- [x] `factory doctor` and `factory gate --docker` (Docker invocation tested with a stub)

## Not yet verified

- [ ] Gate and CI workflow run against a real `laravel new` project (Larastan level 6, Pest arch presets, MySQL service)
- [ ] `factory gate --docker` against a real Docker daemon
- [ ] One reference run: the Star Wars assignment taken from Intake to merged PRs. Evidence:
      job JSON with `gate_report.result == "pass"`, the Review and Approver blocks, and the PRs.
      A run that skips Intake, job state or the gate doesn't count, however good the code looks.
- [ ] Agent prompts evaluated: the golden defects below are caught by the gate, Reviewer or Security
- [ ] Two consecutive reference runs with comparable results

Only claim production-ready once every box is checked.

## Golden defects

Real defects from an unverified Star Wars run (16 Nov 2026) where the agent skipped
Intake, job state and the gate, then rated its own code as convention-compliant.
Each must be caught on a golden-ticket run; the "caught by" column says where.

| Defect | Caught by |
|--------|-----------|
| `when($request->string('gender'), …)`: filter always applies, so the unfiltered list returns nothing | QA baseline "no filters" test; Reviewer; Backend |
| Raw `Request` in controllers; `?name[]=x` causes a 500 | Architecture test (no `Illuminate\Http\Request` in controllers) |
| No rate limiting on public routes | Gate: api-routes |
| `routes/api.php` never loaded (`install:api` not run) | Gate: api-routes; `factory doctor`; installer note |
| Seeder never called from `DatabaseSeeder` | Gate: seeders |
| Whole resource (characters) without tests | Gate: api-routes |
| Unused import; untyped `array` returns | Gate: Pint; PHPStan level 6 |
| No unique constraint on natural keys (episode number) | Backend; Reviewer |
| Agent summary claims compliance without a gate run | Orchestrator/Implementer "UNVERIFIED" rule; Reviewer returns `unverified` |

## Human responsibilities

Final merge; answering NEEDS-INFO; reviewing high-risk changes; reviewing the learning log.
