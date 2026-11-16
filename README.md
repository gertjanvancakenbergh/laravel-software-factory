# Laravel Software Factory

A Matt Pocock-style software factory specialized for professional Laravel API applications, with optional React frontend, UX/UI, database, QA, security, and supporting specialists.

**Status: production-grade ready.** See `docs/production.md` for the checklist.

## What this is

A complete set of agent definitions, conventions, job-state management, safety rules, and GitHub workflows that turn an idea into a tested, reviewable Laravel API (and frontend when needed). Built around the Grill → Intake → Spec → Tickets → Implement (TDD) → Gate → Review → Approver pipeline.

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

3. Make the factory scripts executable:
   ```bash
   chmod +x factory/bin/* factory/checks.sh
   ```

4. Install Matt Pocock skills (recommended):
   ```bash
   npx skills@latest add mattpocock/skills
   ```
   Then run `/setup-matt-pocock-skills` and choose GitHub as the issue tracker.

5. Choose a mode:
   ```bash
   ./factory/bin/factory mode manual   # interactive Grill (default)
   ./factory/bin/factory mode auto     # process labeled issues
   ```

6. Give the factory the assignment:
   - Open `examples/star-wars-assignment.md`
   - Hand it to the Orchestrator agent (or paste into Claude Code / Codex / OpenCode / Grok)
   - Follow the agent flow

7. GitHub Actions runs the full deterministic gate (Pest, Pint, PHPStan, optional frontend) on every PR. Require this status check on `main`.

## Factory commands

```bash
./factory/bin/factory mode          # show / set auto|manual
./factory/bin/factory run <issue>   # prepare a job (auto mode)
./factory/bin/factory status        # list jobs
./factory/bin/factory grill         # start Grill (manual mode)
./factory/bin/job create|update|show|list
./factory/checks.sh                 # run the gate locally
```

Open `factory/dashboard.html` for a simple overview.

## Agent team

| File | Role |
|------|------|
| `agents/orchestrator.md` | Routes the full pipeline, owns the map, recovery, and learning |
| `agents/grill.md` | Interrogates intent, builds domain language (manual mode) |
| `agents/intake.md` | Scope, risk, and surfaces assessment |
| `agents/implementer.md` | TDD worker for a single ticket (isolated worktree) |
| `agents/laravel-specialist.md` | Enforces Laravel conventions and architecture tests |
| `agents/reviewer.md` | Fresh dual-axis code review |
| `agents/approver.md` | Merge recommendation (APPROVE / NEEDS-CHANGES / ESCALATE) |
| `agents/react-frontend-specialist.md` | Builds the React + TypeScript + Tailwind frontend |
| `agents/typescript-specialist.md` | Owns TypeScript strictness, type contracts, and API type sync |
| `agents/ux-ui-specialist.md` | Owns UX, visual design, and the Tailwind-based design system |
| `agents/accessibility-specialist.md` | WCAG, keyboard navigation, screen-reader, inclusive design |
| `agents/frontend-architecture-specialist.md` | Component structure, state boundaries, folder organization |
| `agents/database-specialist.md` | MySQL/MariaDB schema, migrations, indexes, and query performance |
| `agents/data-migration-specialist.md` | Safe, reversible migrations and data backfills |
| `agents/performance-specialist.md` | N+1, slow queries, heavy endpoints, frontend performance |
| `agents/caching-queue-specialist.md` | Redis caching, queue design, job idempotency |
| `agents/api-design-specialist.md` | Consistent API design, pagination, errors, versioning |
| `agents/documentation-specialist.md` | API docs, README, ADRs |
| `agents/devops-ci-specialist.md` | GitHub Actions, deployment, CI reliability |
| `agents/observability-specialist.md` | Logging, metrics, tracing, error tracking |
| `agents/privacy-compliance-specialist.md` | PII handling, retention, consent, auditability |
| `agents/qa-test-lead.md` | Devises the test strategy and coordinates testing |
| `agents/playwright-specialist.md` | Implements Playwright E2E / browser tests |
| `agents/unit-testing-specialist.md` | Implements Pest unit and Feature tests |
| `agents/head-of-security.md` | Overall OWASP API Security Top 10 review and coordination |
| `agents/security-auth-access-control.md` | Auth, BOLA, Policies, Sanctum, mass assignment |
| `agents/security-injection-secure-coding.md` | Injection, XSS, secure coding, input/output safety |
| `agents/security-config-secrets.md` | Configuration, secrets, security headers, debug mode |
| `agents/security-supply-chain.md` | Dependency audits, Composer/npm vulnerabilities |
| `agents/security-api-abuse-threat-modeling.md` | Rate limiting, SSRF, resource exhaustion, threat modeling |

## Key docs

- `docs/production.md` — production-grade checklist
- `docs/modes.md` — auto vs manual
- `docs/gate.md` + `factory/checks.sh` — deterministic gate
- `docs/routing.md` — risk- and surface-based specialist routing
- `docs/safety.md` — protected paths
- `docs/recovery.md` — what to do when something fails
- `docs/observability.md` — tracking the factory itself
- `AGENTS.md` — conventions every agent must follow

## Assignment included

`examples/star-wars-assignment.md` is a complete, professional-grade assignment for a Star Wars encyclopedia API. It is written so the factory can take it and produce a working, tested application. Frontend, database, QA, security, and supporting specialists can be engaged as needed.
