# Readiness

## Verified

- Scripts pass shellcheck and bats on Ubuntu and macOS bash 3.2 (CI).
- Gate fails on missing tools, missing architecture tests, or missing lockfile.
- Job tool enforces gate before review/approve, validates enums, records history, uses atomic writes and locking.
- install.sh is idempotent and never overwrites project package.json, README or composer.json.

## Not yet verified

- End-to-end generation of a reference application (Star Wars API) by the agents.
- Real GitHub auto-mode runs against live issues.
- Performance of parallel implementers on larger jobs.

The factory is pre-1.0 until a reference application has been produced and reviewed.
