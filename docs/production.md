# Production-Grade Checklist

This factory is considered production-grade when the following are true:

- [x] Clear roles and subagent protocol
- [x] Intake with risk and surfaces
- [x] Deterministic gate (local + CI)
- [x] Risk-based specialist routing
- [x] Job state that can be created, updated, and listed
- [x] Approver recommendation step
- [x] Safety rules for protected paths
- [x] Documented recovery paths
- [x] Manual and auto modes with a CLI
- [x] Learning log and shared context
- [x] Model-agnostic design
- [x] GitHub-centric (issues, PRs, Actions)

## Remaining human responsibilities

- Final merge approval
- Answering NEEDS-INFO intake results
- Confirming high-risk changes
- Periodically reviewing the learning log

## Operational notes

- Make scripts executable: `chmod +x factory/bin/* factory/checks.sh`
- Require the CI gate status check on `main` in branch protection rules.
- Label issues `factory` when you want auto mode to consider them.
