# Laravel Software Factory

A Matt Pocock-style software factory specialized for professional Laravel API applications, with optional React frontend, UX/UI, database, QA, and security support.

## What this is

A complete set of agent definitions, conventions, and GitHub workflows that turn an idea into a tested, reviewable Laravel API (and frontend when needed). Built around the Grill → Spec → Tickets → Implement (TDD) → Review pipeline.

## Quick start

1. Create a new Laravel project:
   ```bash
   composer create-project laravel/laravel star-wars-api
   cd star-wars-api
   composer require pestphp/pest --dev --with-all-dependencies
   php artisan pest:install
   composer require laravel/pao --dev
   ```

2. Copy the contents of this folder into the root of your Laravel project (or merge).

3. Install Matt Pocock skills (recommended):
   ```bash
   npx skills@latest add mattpocock/skills
   ```
   Then run `/setup-matt-pocock-skills` and choose GitHub as the issue tracker.

4. Give the factory the assignment:
   - Open `examples/star-wars-assignment.md`
   - Hand it to the Orchestrator agent (or paste into Claude Code / Codex / OpenCode)
   - Follow the agent flow

5. GitHub Actions will run Pest, Pint, and PHPStan on every PR.

## Agent team

| File | Role |
|------|------|
| `agents/orchestrator.md` | Routes the full pipeline, owns the map |
| `agents/grill.md` | Interrogates intent, builds domain language |
| `agents/implementer.md` | TDD worker for a single ticket (isolated worktree) |
| `agents/laravel-specialist.md` | Enforces Laravel conventions and architecture tests |
| `agents/reviewer.md` | Fresh dual-axis code review |
| `agents/react-frontend-specialist.md` | Builds the React + TypeScript + Tailwind frontend |
| `agents/typescript-specialist.md` | Owns TypeScript strictness, type contracts, and API type sync |
| `agents/ux-ui-specialist.md` | Owns UX, visual design, and the Tailwind-based design system |
| `agents/database-specialist.md` | MySQL/MariaDB schema, migrations, indexes, and query performance |
| `agents/qa-test-lead.md` | Devises the test strategy and coordinates testing |
| `agents/playwright-specialist.md` | Implements Playwright E2E / browser tests |
| `agents/unit-testing-specialist.md` | Implements Pest unit and Feature tests |
| `agents/head-of-security.md` | Overall OWASP API Security Top 10 review and coordination |
| `agents/security-auth-access-control.md` | Auth, BOLA, Policies, Sanctum, mass assignment |
| `agents/security-injection-secure-coding.md` | Injection, XSS, secure coding, input/output safety |
| `agents/security-config-secrets.md` | Configuration, secrets, security headers, debug mode |
| `agents/security-supply-chain.md` | Dependency audits, Composer/npm vulnerabilities |
| `agents/security-api-abuse-threat-modeling.md` | Rate limiting, SSRF, resource exhaustion, threat modeling |

## Conventions

See `AGENTS.md` for the full set of Laravel and factory rules that every agent must follow.

## Assignment included

`examples/star-wars-assignment.md` is a complete, professional-grade assignment for a Star Wars encyclopedia API. It is written so the factory can take it and produce a working, tested application. Frontend, database, QA, and security specialists can be engaged as needed.
