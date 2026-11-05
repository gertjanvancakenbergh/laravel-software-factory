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
- All incoming data is validated with Form Requests.
- Authorization uses Policies.
- API responses use Eloquent API Resources.
- Use Sanctum for authentication when required. Public read endpoints are allowed when the assignment says so.
- Database changes are migrations. Seeders are used for reference data.
- Prefer Pest for all tests. Use Laravel's `RefreshDatabase` or transactions.
- Architecture tests (Pest) must pass. Examples:
  - Controllers do not use Eloquent directly.
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
- Database Specialist owns schema design, indexes, and query performance review.

## Frontend conventions (when a React frontend is in scope)

- React + TypeScript + Vite + Tailwind CSS.
- TanStack Query for server state.
- Design system and visual decisions owned by the UX/UI Specialist.
- Implementation owned by the React Frontend Specialist.
- Components must be accessible and handle loading/empty/error states.
- Tailwind utilities (or a consistent token-based system on top of Tailwind) are the default styling approach.

## Testing conventions

- QA Test Lead devises the test plan and coverage requirements.
- Unit Testing Specialist implements Pest unit and Feature tests.
- Playwright Specialist implements critical E2E journeys (few, high-value only).
- Every API endpoint needs Feature tests (happy path, validation, 404, auth when applicable).
- Critical domain logic needs unit tests.
- Architecture tests enforce structural rules.
- Tests are independent, use factories, and protect behavior rather than implementation.
- CI must be green (Pest + any Playwright suite) before merge.

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
- PRs require passing checks (Pest, Pint, PHPStan).
- Branch protection on main.
- Use conventional commit messages or clear ticket references.

## Definition of done for any ticket

1. Failing test written first.
2. Implementation makes the test pass.
3. Architecture tests still pass.
4. Pint and PHPStan clean.
5. PR opened with summary, before/after, and link to the ticket.
6. Fresh review completed.
