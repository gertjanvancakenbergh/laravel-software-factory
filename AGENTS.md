<!-- laravel-software-factory -->
# AGENTS.md — Laravel Software Factory

These rules apply to every agent working in this repository. They are non-negotiable.

## Factory rules (Matt Pocock style)

- Non-trivial work starts with grilling. Never jump straight to code.
- Specs and tickets live in GitHub Issues. Tickets must be small enough for one agent session.
- Implementation is test-first (Pest for backend, Vitest for frontend). Red → green → refactor.
- Every change is reviewed by a fresh agent against both coding standards and the original spec.
- Agents work in isolated git worktrees. Never commit directly to main.
- Human owns intent, architecture decisions, and the final merge gate.

## Laravel API conventions

- Controllers are thin. Business logic lives in Actions or Services.
- All incoming data, including query-string filters, is validated with Form Requests.
  Controllers read `$request->validated()` and never type-hint the raw `Request`
  (enforced by an architecture test).
- Authorization uses Policies.
- API responses use Eloquent API Resources.
- Use Sanctum for authentication when required. Public read endpoints are allowed when the assignment says so.
- Database changes are migrations. Seeders are used for reference data and every
  seeder is called from `DatabaseSeeder`.
- Laravel 11+: run `php artisan install:api` so `routes/api.php` loads; enable API
  throttling (`$middleware->throttleApi()`). The gate checks both.
- Prefer Pest for all tests. Use Laravel's `RefreshDatabase` or transactions.
- Architecture tests (Pest, `tests/Architecture/`) must exist and pass; the gate fails without them. Examples:
  - Controllers do not query through the `DB` facade (route-model binding is fine).
  - Models do not depend on controllers or HTTP.
  - Actions/Services are pure enough to unit test.
- Style is enforced by Pint. Static analysis by PHPStan / Larastan.
- Use Laravel PAO so test and Artisan output is structured for agents.

## Database conventions (MySQL / MariaDB)

- Schema lives only in migrations. No ad-hoc SQL changes.
- Use InnoDB. Prefer foreign key constraints and unique indexes at the database level.
- Index foreign keys, filter columns, and common composite query patterns. Column order in composite indexes matters.
- Prefer the `mariadb` driver when targeting MariaDB (especially for vector features).
- Avoid N+1 queries; use eager loading. Review with EXPLAIN when performance matters.
- Split dangerous migrations (long locks, non-compatible changes) across deploys. Use `migrate --pretend` for review.
- Correct types: decimal for money, appropriate string lengths, timestamps with timezone awareness where needed.
- The Backend specialist (`agents/backend.md`) owns schema design, indexes, and query performance review.

## Frontend conventions (when a React frontend is in scope)

- React + TypeScript + Vite + Tailwind CSS.
- TanStack Query for server state.
- Design system, component architecture, type contracts and accessibility are owned by the Frontend specialist (`agents/frontend.md`); Implementers build.
- Components must be accessible and handle loading/empty/error states.
- Tailwind utilities (or a consistent token-based system on top of Tailwind) are the default styling approach.

## Testing conventions

- The QA specialist (`agents/qa.md`) writes the test plan and owns unit, Feature, architecture and Playwright tests (E2E: few, high-value journeys only).
- Every API endpoint needs Feature tests (happy path, validation, 404, auth when applicable).
- Critical domain logic needs unit tests.
- Architecture tests enforce structural rules.
- Tests are independent, use factories, and protect behavior rather than implementation.
- The gate (`factory/checks.sh`, also run in CI) must be green before review and merge.

## Security conventions

- The Security specialist (`agents/security.md`) owns OWASP API Security Top 10 review.
- Every endpoint that accesses user or sensitive data must have a Policy (or equivalent ownership check). No raw `findOrFail` without authorization.
- Input is validated only through Form Requests; output is shaped only through API Resources.
- Rate limiting is required on public and write endpoints.
- `APP_DEBUG=false` in production. Secrets never committed.
- Prefer Sanctum with token expiry and abilities when authentication is needed.
- `composer audit` and `npm audit --audit-level=high` run in the gate. Security findings that allow unauthorized access are blocking.

## Project layout (API)

```
app/
  Actions/          # Single-purpose application actions
  Http/
    Controllers/Api/
    Requests/
    Resources/
  Models/
  Policies/
database/
  migrations/
  seeders/
  factories/
tests/
  Feature/
  Unit/
  Architecture/
```

## Testing requirements

- Every endpoint has Feature tests covering happy path, validation failure, and authorization (if applicable).
- Models have factories.
- Critical domain logic has unit tests.
- Architecture tests enforce the rules above.
- CI must be green before a PR is considered ready.

## GitHub

- Issues are the source of truth for tickets.
- PRs require the "Deterministic Gate" check (`.github/workflows/factory-gate.yml`).
- Branch protection on main.
- Use conventional commit messages or clear ticket references.

## Verified vs unverified

Work counts as done only with a passing `factory gate <id>` recorded on the job
**for the current commit**. Commit first, then gate: a pass recorded on another
commit, or on uncommitted changes, doesn't count (the job tool refuses review).
The gate result can't be set by hand. Without a fresh pass, label the work
UNVERIFIED and don't claim it meets these conventions.
No local PHP? Use `./factory/bin/factory gate <id> --docker`.

## Definition of done for any ticket

1. Failing test written first.
2. Implementation makes the test pass.
3. Architecture tests still pass.
4. `./factory/checks.sh` green (Pest, architecture tests, Pint, PHPStan/Larastan, audits, frontend checks when present).
5. PR opened with summary, before/after, and link to the ticket.
6. Fresh review completed.
