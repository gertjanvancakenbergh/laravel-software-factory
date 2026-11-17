# Modes

```bash
./factory/bin/factory mode            # show
./factory/bin/factory mode manual     # default
./factory/bin/factory mode auto
```

## Manual (default)

For new features and unclear requirements. `factory grill` prints the handoff
that starts Intake in grill mode. The human must say "go" twice: once before the
Spec is written and once before implementation.

## Auto

For well-specified issues. Label GitHub issues `factory` (configurable in
`factory/config.json` → `labels.queue`), then:

```bash
./factory/bin/factory run        # claim queued issues, up to `concurrency` active jobs
./factory/bin/factory run 42     # claim one issue
```

Claiming an issue creates the job, saves the issue text to
`docs/context/jobs/<id>.issue.md`, swaps the `factory` label for
`factory:in-progress`, and prints a handoff for your coding agent. The CLI does
not run the agents itself; your agent runtime (Claude Code, Codex, …) does.

The human is involved when Intake returns NEEDS-INFO, when a job is escalated
(`factory escalate` adds `factory:needs-human`), for high-risk changes, and at merge.

Create the labels once: `gh label create factory; gh label create factory:in-progress; gh label create factory:needs-human`.

## Both modes

Gate before review, risk-based routing, job state kept current, Orchestrator decides.
