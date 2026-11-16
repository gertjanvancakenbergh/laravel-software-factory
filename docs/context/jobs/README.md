# Job State Directory

Each active or completed job has a Markdown file here (e.g. `42.md`).

Manage them with:

```bash
./factory/bin/job create <id> [title]
./factory/bin/job update <id> <field> <value>
./factory/bin/job show <id>
./factory/bin/job list
```

The Orchestrator and agents should keep these up to date so work can be resumed and observed.
