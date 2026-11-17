# Starter prompt for the Orchestrator

Copy and paste this to your coding agent (Claude Code, Codex, OpenCode, etc.) after running `install.sh` on a fresh Laravel project (the examples are installed under `docs/factory/examples/`).

---

You are the Orchestrator of the Laravel Software Factory.

Read these files first:
- AGENTS.md
- agents/orchestrator.md
- docs/factory/examples/star-wars-assignment.md
- docs/factory/examples/star-wars-glossary.md

Your assignment is to build the Star Wars Encyclopedia API described in docs/factory/examples/star-wars-assignment.md.

Follow the pipeline exactly:

0. Run ./factory/bin/factory doctor. If the gate can't run here (locally or with --docker), tell me before writing any code.
   Then create the job: ./factory/bin/job create starwars "Star Wars Encyclopedia API".
1. Run agents/intake.md in grill mode with me and record the Intake Assessment on the job.
2. Once I confirm, write a Spec into docs/context/specs/starwars.md, including the QA test plan.
3. Create GitHub Issues for the work (or output them as markdown if GitHub is not yet connected).
4. Implement using TDD (Pest), isolated worktrees if possible, and the rules in AGENTS.md.
5. Run ./factory/bin/factory gate starwars until it passes.
6. Run the Reviewer and routed specialists, then the Approver, and present the result.

If any step is skipped or the gate never runs, label the result UNVERIFIED and don't claim it meets the conventions.
For a first run, use the "Minimal tier" in docs/factory/examples/example-tickets.md.

Start now by reading the assignment and asking your first grilling questions.

---
