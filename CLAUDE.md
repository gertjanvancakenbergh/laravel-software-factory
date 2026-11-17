# CLAUDE.md

This repo is the Laravel Software Factory itself: agent prompts, docs, and the
bash scripts that install it into Laravel projects.

- **Git workflow and commit rules: [CONTRIBUTING.md](CONTRIBUTING.md). Follow it.**
  In short: branch off `main`, make small Conventional Commits, open a PR,
  CI must be green, and the human merges. Never push to `main`.
- `AGENTS.md` holds the rules for agents working in a project the factory is
  installed into. It doesn't describe how to change this repo.
- Scripts must stay bash 3.2 compatible. Before pushing, run shellcheck and
  `bats tests/` as listed in CONTRIBUTING.md.
