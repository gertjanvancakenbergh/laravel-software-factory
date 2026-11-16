# Error Recovery

When something fails, follow this path. The Orchestrator owns recovery decisions.

## Gate failure

1. Record the failure in the job state (`gate: fail`).
2. Return the ticket to the Implementer with the exact command output.
3. Do not engage review specialists until the gate is green.

## Specialist conflict

1. Record both findings in the job state.
2. Orchestrator issues a Decision that resolves the conflict.
3. If the conflict is high-risk (security, data loss), escalate to the human.

## Intake returns NEEDS-INFO

1. Stop the pipeline.
2. Present the open questions to the human.
3. Resume only after answers are recorded.

## Session or agent interruption

1. Job state is the source of truth.
2. On restart, read the job state and continue from the recorded stage.
3. Re-run the gate if the stage is past implementation and the gate status is not `pass`.

## High-risk change

Always require human review before merge, even if the Approver says APPROVE.
