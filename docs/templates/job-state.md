# Job State

Per-ticket or per-feature record. Can live as a comment on the GitHub issue or in `docs/context/jobs/`.

```md
## Job State

- **Ticket**: #
- **Stage**: intake | spec | tickets | implement | gate | review | approver | done
- **Verdict / Risk**: (from intake)
- **Surfaces**:
- **Worktree / Branch**:
- **Gate**: pass | fail | pending
- **Specialists engaged**:
- **Open findings**:
- **Last update**:
```

The Orchestrator updates this so work can resume cleanly.
