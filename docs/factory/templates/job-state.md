# Job State

Managed by `./factory/bin/job`; stored as `docs/context/jobs/<id>.json`. Don't edit by hand.

| Field | Values |
|-------|--------|
| `stage` | intake, spec, tickets, implement, gate, review, approver, done, blocked |
| `verdict` | pending, ACCEPT, NEEDS-INFO, REJECT |
| `risk` | pending, low, medium, high |
| `surfaces` (list) | api, auth, database, frontend, performance, security, privacy, queue, observability, devops |
| `branch` | free text |
| `gate` | pending, pass, fail (written only by `factory gate <id>`) |
| `gate_report` | result, commit, dirty, partial and per-step results of the last gate run |
| `specialists` (list) | agent names engaged |
| `findings` (list) | one-line summaries of open findings |
| `approver` | pending, APPROVE, NEEDS-CHANGES, ESCALATE |
| `history` | every change with timestamp |

```bash
job update 42 stage spec
job add 42 surfaces auth
job add 42 findings "BOLA on GET /api/v1/favorites/{id}"
job remove 42 findings "BOLA on GET /api/v1/favorites/{id}"
```
