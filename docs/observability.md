# Factory Observability

Track the health of the factory itself, not just the application.

## Job state fields to watch

- Time from `Started` to gate pass
- Number of specialist findings per job
- Approver recommendation distribution (APPROVE / NEEDS-CHANGES / ESCALATE)
- Gate failure rate

## How to inspect

```bash
./factory/bin/job list
./factory/bin/job show <id>
```

Open `factory/dashboard.html` for a simple overview (extend it to read `docs/context/jobs/`).

## Learning loop

Notable friction (repeated gate failures, conflicting specialists, slow stages) should be written to `docs/context/learning-log.md` and promoted by the Orchestrator when patterns appear.
