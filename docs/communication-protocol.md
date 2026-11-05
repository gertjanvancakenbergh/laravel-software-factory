# Subagent Communication Protocol

**Authority**: The Orchestrator has final decision on this protocol and any changes to it.

All agents operate as subagents under the Orchestrator. Communication is structured, asynchronous, and traceable via GitHub Issues, PRs, and the shared context files in `docs/`.

## Core principles

1. **Orchestrator owns the map and the protocol.** Specialists may propose changes; the Orchestrator decides.
2. **No direct side-channel work.** All findings, requests, and decisions go through structured messages (GitHub comments or files in `docs/context/`).
3. **Specialists propose, Orchestrator disposes.** A specialist can recommend; only the Orchestrator (or a human) can block or approve.
4. **Shared context is the single source of truth** for domain language, decisions, open findings, and conventions.
5. **Structured outputs preferred.** Use the templates in `docs/templates/` whenever possible.

## Message types

| Type | From | To | Purpose |
|------|------|----|---------|
| Request | Orchestrator | Specialist | Engage a specialist on a specific ticket or Spec |
| Finding | Specialist | Orchestrator + relevant others | Report an issue, recommendation, or observation |
| Proposal | Any specialist | Orchestrator | Suggest a change to process, architecture, or protocol |
| Decision | Orchestrator | All relevant | Final ruling on a proposal, conflict, or scope |
| Handoff | Implementer / Specialist | Next agent | Structured transfer of work or context |
| Escalation | Any | Orchestrator | Conflict, blocker, or need for human input |

## How agents communicate

### 1. Shared context (preferred for durable knowledge)
- `docs/context/domain.md` — living domain language (owned by Grill, updated by Orchestrator)
- `docs/context/decisions/` — ADRs
- `docs/context/open-findings.md` — active security, performance, or other findings
- `docs/context/conventions.md` — API, frontend, and Laravel conventions

Agents must read the relevant context files before acting.

### 2. GitHub Issues & PRs (preferred for ticket-level work)
- Orchestrator creates tickets and tags specialists.
- Specialists comment using the Finding or Proposal template.
- Implementers update tickets with status and handoff notes.
- Reviewer posts dual-axis review.

### 3. Structured templates
See `docs/templates/`. Use them for Findings, Proposals, and Handoffs so outputs are machine-checkable and consistent.

## Specialist engagement flow

1. Orchestrator decides which specialists are needed (using the roster in `agents/orchestrator.md`).
2. Orchestrator posts a **Request** (comment or new issue) with clear scope and links to Spec/ticket.
3. Specialist reads shared context + request, then posts a **Finding** or **Proposal**.
4. If specialists conflict, they escalate to the Orchestrator.
5. Orchestrator issues a **Decision** and updates shared context if needed.
6. Work continues.

## Changing this protocol

Any agent may open a Proposal (using the template) to improve communication. The Orchestrator reviews, may consult other specialists, and makes the final decision. Changes are recorded as an ADR in `docs/context/decisions/`.

## Subagent model

- Every agent except the Orchestrator is a **subagent**.
- Subagents do not own the pipeline or the final say.
- Subagents may collaborate with each other (e.g., Head of Security coordinating security specialists, QA Test Lead coordinating testers) but escalate conflicts or scope changes to the Orchestrator.
- The Orchestrator is the only agent that sees the whole map and has final authority.

This protocol is living. The Orchestrator keeps it effective.
