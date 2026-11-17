# Factory Observability

Watching the factory itself, not the application (that's `agents/platform.md`).

```bash
./factory/bin/factory status
./factory/bin/factory dashboard          # writes docs/context/dashboard.html
./factory/bin/job list --json | jq '…'   # for anything else
```

Each job's JSON has `history` (every field change with timestamps) and
`gate_report` (per-step results of the last gate run). Useful questions:

```bash
# Gate failure rate
jq -s '[.[].history[] | select(.field=="gate")] | group_by(.to) | map({(.[0].to): length}) | add' docs/context/jobs/*.json
# Approver outcomes
jq -s 'group_by(.approver) | map({(.[0].approver): length}) | add' docs/context/jobs/*.json
# Jobs stuck: not updated in 3 days
jq -r --arg cut "$(date -u -v-3d +%FT%TZ 2>/dev/null || date -u -d '3 days ago' +%FT%TZ)" 'select(.stage!="done" and .updated < $cut) | .id' docs/context/jobs/*.json
```

Repeated gate failures on the same step, review rounds > 1, or specialist
conflicts go into `docs/context/learning-log.md`.
