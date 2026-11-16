# Auto vs Manual Mode

The factory supports two modes. Switch with the CLI or by editing `factory/config.json`.

## Selecting a mode

```bash
# Show current mode
./factory/bin/factory mode

# Switch to auto
./factory/bin/factory mode auto

# Switch to manual
./factory/bin/factory mode manual
```

Or edit `factory/config.json` and set `"mode": "auto"` or `"manual"`.

## Manual mode (default)

- Start with the Grill agent.
- Grill asks clarifying questions and builds domain language.
- Human must confirm intent is clear before Spec is written.
- Human must explicitly approve before implementation begins.
- Best for new features, unclear requirements, or when you want tight control.

Run: `./factory/bin/factory grill`

## Auto mode

- Input: GitHub issues labeled `factory`, or a prompt given to the Orchestrator.
- Pipeline runs end-to-end: Intake → Spec → Tickets → Implement → Gate → Review.
- Human is involved mainly at the final merge gate (or when Intake returns NEEDS-INFO / high risk).
- Best for well-specified tickets or batch processing.

Run: `./factory/bin/factory run`

## Shared behavior

- Deterministic gate (`factory/checks.sh`) is always required before specialist review.
- Risk-based routing still applies.
- Learning log and shared context are updated in both modes.
- Orchestrator remains the final authority.

## Gate

```bash
./factory/checks.sh
```
