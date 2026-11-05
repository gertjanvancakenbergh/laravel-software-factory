# Conventions

Shared conventions that all agents must follow. Changes require an ADR and Orchestrator approval.

## API
- Versioned routes (`/api/v1`)
- Consistent error shape
- Pagination on list endpoints
- API Resources for all responses

## Laravel
- Thin controllers
- Form Requests for input
- Policies for authorization
- Pest for tests

## Frontend (when present)
- TypeScript strict
- TanStack Query for server state
- Tailwind utility-first

## Security
- OWASP API Top 10 baseline
- No secrets in git
- Rate limiting on public/write endpoints
