# Routing

The Orchestrator routes from the Intake surfaces and risk. Engage the smallest
set that covers the change; specialists run in parallel after the gate.

## Always

Intake → Implementer → gate → Reviewer → Approver. QA writes the test plan for every Spec.

## By surface

| Surface | Engage |
|---------|--------|
| api | Backend (API design, architecture) |
| database | Backend (schema, migrations); Security if the data is user-owned |
| performance | Backend (performance lens) |
| queue | Backend (caching & queues lens) |
| auth, security | Security |
| privacy | Security (privacy lens) |
| frontend | Frontend; QA for Playwright journeys |
| devops, observability | Platform |

Also engage Security on: any new endpoint, any dependency change, any config or middleware change.

## By risk

| Risk | Extra |
|------|-------|
| low, no surfaces | Implementer + Reviewer only |
| medium | Routed specialists review the Spec **and** the PR |
| high | Security always; human reviews before merge regardless of the Approver |
