# Deterministic Gate

Before any specialist review (Reviewer, Security, Performance, etc.) the work must pass the deterministic gate.

## Required checks

Run these in the worktree (or ensure CI is green):

```bash
# Tests
vendor/bin/pest --parallel

# Style
vendor/bin/pint --test

# Static analysis
vendor/bin/phpstan analyse --memory-limit=2G

# Architecture tests (if present)
vendor/bin/pest --filter=Architecture
```

Frontend (when in scope):

```bash
npm run typecheck   # or tsc --noEmit
npm run lint
npm run build       # optional but recommended
```

## Rules

- Gate must be green before reviewers are engaged.
- Failed gate → return to Implementer. Do not run specialist review on a failing build.
- Record the gate result in the job state or ticket comment.
- The Orchestrator enforces this.

This keeps expensive or high-judgment reviews focused on code that already meets baseline quality.
