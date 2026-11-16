# Laravel Software Factory

An agent workflow for building Laravel APIs (with an optional React frontend):
a set of agent prompts, conventions, a deterministic quality gate, and a small
CLI that tracks each job's state. In the style of Matt Pocock's software factory.

**Status: pre-1.0.** The scripts are tested (`tests/`, run in CI on Linux and on
macOS's bash 3.2), but the factory has not yet produced a reference application
end-to-end. See `docs/factory/readiness.md` for what is verified and what isn't.

## Pipeline

Intake (grill the human in manual mode) → Spec + test plan → Tickets →
Implement (TDD, one worktree per ticket) → **Gate** → Review → Approver → human merge.

The gate is `factory/checks.sh`. CI runs the same script, and the job tool will
not let a job move to review or be approved until the gate has passed.

## Install

Requirements: PHP 8.3+, Composer, `jq`, and the GitHub CLI (`gh`) for auto mode.

```bash
composer create-project laravel/laravel star-wars-api
git clone https://github.com/gertjanvancakenbergh/laravel-software-factory
./laravel-software-factory/install.sh star-wars-api --install-deps
cd star-wars-api
./factory/checks.sh
```

`install.sh` never overwrites project files. It updates factory-owned files
(`agents/`, `factory/bin`, `docs/factory/`, the gate workflow) on re-run, creates
project state (`factory/config.json`, `docs/context/`, `phpstan.neon`,
`tests/Architecture/`) only when missing, appends a pointer to an existing
`AGENTS.md`, and never touches `package.json`, `README.md` or `composer.json`
(except `composer require` with `--install-deps`). Use `--dry-run` to preview.

Then require the **Deterministic Gate** status check on `main`.

## CLI

```bash
./factory/bin/factory mode [auto|manual]   # default: manual
./factory/bin/factory grill                # manual: handoff that starts grilling
./factory/bin/factory run [issue]          # auto: claim issues labeled `factory` (up to `concurrency`)
./factory/bin/factory gate <job>           # run the gate and record the result on the job
./factory/bin/factory escalate <job> "why" # block the job and label the issue for a human
./factory/bin/factory status               # list jobs
./factory/bin/factory dashboard            # write docs/context/dashboard.html

./factory/bin/job create|update|add|remove|show|list
./factory/checks.sh
```

Job state is JSON in `docs/context/jobs/<id>.json` with validated fields and a
change history. Settings live in `factory/config.json`.

## Agents

| File | Role |
|------|------|
| `agents/orchestrator.md` | Runs the pipeline, routes specialists, owns decisions and job state |
| `agents/intake.md` | Grills the human (manual), assesses scope, risk and surfaces |
| `agents/implementer.md` | One ticket, test-first, one worktree |
| `agents/backend.md` | Laravel architecture, API design, database & migrations, performance, caching & queues |
| `agents/frontend.md` | React, TypeScript contracts, UX/UI, accessibility |
| `agents/qa.md` | Test plan; Pest, architecture and Playwright tests |
| `agents/security.md` | OWASP API Top 10, auth, injection, secrets, supply chain, abuse, privacy |
| `agents/platform.md` | CI, deployment, observability, documentation |
| `agents/reviewer.md` | Fresh dual-axis review (standards + spec) |
| `agents/approver.md` | APPROVE / NEEDS-CHANGES / ESCALATE |

## Docs

`AGENTS.md` (conventions every agent follows) and `docs/factory/`: `gate.md`,
`routing.md`, `modes.md`, `safety.md`, `recovery.md`, `communication-protocol.md`,
`learning.md`, `observability.md`, `readiness.md`, and `templates/`.

## Example

`examples/star-wars-assignment.md` is a complete assignment for a Star Wars
encyclopedia API; `examples/starter-prompt.md` starts the Orchestrator on it.

## Developing the factory

```bash
shellcheck install.sh factory/checks.sh factory/bin/* factory/lib/*.sh tests/*.bash
bats tests/
```
