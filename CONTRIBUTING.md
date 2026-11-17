# Contributing to the factory

This file is about changing **this repo** (the factory itself).
`AGENTS.md` is different: it holds the rules for agents working in a Laravel
project the factory is installed into.

## Flow

`main` is the only long-lived branch and is always releasable. Every change
goes through a short-lived branch and a pull request.

1. Branch off an up-to-date `main`:
   ```bash
   git switch main && git pull --ff-only
   git switch -c feat/gate-route-names
   ```
   Prefixes: `feat/`, `fix/`, `docs/`, `test/`, `refactor/`, `ci/`, `chore/`.
2. Make small, focused commits (see below).
3. Run the checks locally before pushing:
   ```bash
   shellcheck install.sh factory/checks.sh factory/bin/* factory/lib/*.sh factory/docker/*.sh tests/*.bash
   bats tests/
   ```
   On macOS, `/bin/bash` is 3.2. That's the oldest bash the factory supports,
   so run the tests with it.
4. Push the branch and open a PR. The description says what changed, why, and
   what you verified, and links the issue if there is one.
5. CI ("Factory self-test") must pass on both `ubuntu-latest` and `macos-latest`.
6. **The human merges.** Use a merge commit so the focused commits stay in the
   history, and delete the branch afterwards.

## Commits

- Use [Conventional Commits](https://www.conventionalcommits.org/):
  `type(scope): summary`, for example `fix(job): keep errexit inside with_lock`.
  Types match the branch prefixes; scopes are `gate`, `job`, `cli`, `install`,
  `agents`, `docs`, `ci` or `tests`.
- One logical change per commit. Keep unrelated changes apart: moving files,
  restoring old work and new behavior go in separate commits, so each one can
  be reviewed and reverted on its own.
- A behavior change comes with its test in the same commit.
- Write the body in the imperative mood and explain why, not just what.

## Rules for agents (Claude Code and others)

- Never push to `main`, never force-push a shared branch, and never merge a PR
  unless the human asks for that specific PR in so many words.
- Don't commit or push until the human asks for it.
- Don't upload files through the GitHub web UI: it drops the executable bit.
  If a new script loses it, run `git update-index --chmod=+x <file>` and add
  the script to `SCRIPTS` in `tests/repo.bats`.
- If CI fails, fix the cause in a new commit on the same branch. Don't weaken a
  check, skip a test or lower a threshold to make CI pass.

## Branch protection on `main`

`main` is protected on GitHub. Merging needs a pull request, both
"shellcheck + bats" checks must pass on a branch that is up to date with
`main`, and force-pushes and deletion are blocked. The rules also apply to
admins, so nobody can push to `main` directly, including an agent using the
owner's credentials. Don't relax these settings without a reason written in
the PR that does it.
