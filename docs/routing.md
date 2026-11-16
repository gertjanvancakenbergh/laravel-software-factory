# Risk- and Surface-Based Routing

The Orchestrator uses the Intake assessment to decide which specialists to engage.

## Default path

Grill → Intake → Spec → Tickets → Implementer(s) → **Gate** → Reviewer → Human merge

## Routing table

| Surface / Signal | Engage |
|------------------|--------|
| Always | Grill, Intake, Implementer, Reviewer |
| api | API Design Specialist, Laravel Specialist |
| auth or security | Head of Security + relevant security specialists |
| database | Database Specialist (+ Data Migration if existing data) |
| frontend | React Frontend, TypeScript, UX/UI, Accessibility |
| performance | Performance Specialist |
| queue or caching | Caching & Queue Specialist |
| privacy | Privacy & Compliance Specialist |
| high risk | Extra scrutiny: Security + Reviewer + relevant specialists; prefer human review |
| low risk + no surfaces | Minimal: Implementer + Reviewer only |

## Rules

- Intake sets risk and surfaces.
- Gate must pass before any review specialists run.
- Specialists run in parallel when possible after the gate.
- Orchestrator reconciles findings and has final say.
- Model choice is left to the runtime; the factory stays model-agnostic.
