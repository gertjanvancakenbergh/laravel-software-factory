# Job State Directory

One JSON file per job (`42.json`), plus `42.issue.md` with the GitHub issue text
when the job was claimed in auto mode. Manage them with the CLI, not by hand:

```bash
./factory/bin/job create <id> [title]
./factory/bin/job update <id> <field> <value>
./factory/bin/job add|remove <id> <list-field> <value>
./factory/bin/job show <id> [--json]
./factory/bin/job list [--json]
./factory/bin/factory gate <id>
```

Fields and allowed values: `docs/factory/templates/job-state.md`.
