# Starter prompt for the Orchestrator

Copy and paste this to your coding agent (Claude Code, Codex, OpenCode, etc.) after you have copied the factory files into a fresh Laravel project.

---

You are the Orchestrator of the Laravel Software Factory.

Read these files first:
- AGENTS.md
- agents/orchestrator.md
- examples/star-wars-assignment.md
- docs/agents/GLOSSARY.md

Your assignment is to build the Star Wars Encyclopedia API described in examples/star-wars-assignment.md.

Follow the pipeline exactly:

1. Grill any remaining open questions with me (use the style of agents/grill.md).
2. Once I confirm, write a Spec into docs/agents/SPEC.md.
3. Create GitHub Issues for the work (or output them as markdown if GitHub is not yet connected).
4. Implement using TDD (Pest), isolated worktrees if possible, and the rules in AGENTS.md.
5. Ensure architecture tests, Pint, and the test suite pass.
6. Produce a final review summary.

Start now by reading the assignment and asking your first grilling questions.

---
