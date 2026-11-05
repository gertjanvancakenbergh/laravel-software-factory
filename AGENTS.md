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

## Frontend conventions (when a React frontend is in scope)

- React + TypeScript + Vite + Tailwind CSS.
- TanStack Query for server state.
- Design system and visual decisions owned by the UX/UI Specialist.
- Implementation owned by the React Frontend Specialist.
- Components must be accessible and handle loading/empty/error states.
- Tailwind utilities (or a consistent token-based system on top of Tailwind) are the default styling approach.

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
