# Self-Learning Process

The factory improves by recording outcomes and periodically promoting durable lessons into shared context. The Orchestrator owns this process and has final say on what is promoted.

## 1. Record outcomes
After a finding is resolved, a proposal is decided, a ticket closes with notable friction, or CI/review forces changes:

- Append an entry to `docs/context/learning-log.md` using the template.
- Keep it short and factual.

Anyone can propose an entry; the Orchestrator confirms or edits it.

## 2. Distill periodically
When the log has several related entries (or on demand):

- Review for repeated patterns.
- Promote clear lessons into:
  - `docs/context/conventions.md` (rules everyone should follow)
  - `docs/context/decisions/` (ADRs for architectural choices)
  - Agent prompts (via a Proposal → Orchestrator Decision)
  - The communication protocol itself (if process-related)

Mark the learning-log entry as promoted.

## 3. Guardrails
- No silent rewrites of agent prompts or conventions.
- All promotions go through a Proposal or direct Orchestrator Decision.
- Significant changes become ADRs.
- Prefer small, evidence-based updates over large speculative ones.

## 4. Optional evaluation
Keep a few golden tickets (e.g. the Star Wars API plus planted issues). Occasionally re-run and compare results against previous runs. Differences become learning-log entries.

This keeps learning intentional, traceable, and under Orchestrator control.
