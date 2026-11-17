# Safety and Protected Paths

Agents must not modify the following without explicit human approval:

## Protected paths

- `.env`, `.env.*` (except `.env.example`)
- `config/app.php` key generation or secret-related config
- `storage/oauth-*.key`, `storage/*.pem`
- Any file containing real secrets or credentials
- Production deployment configs (`deploy/`, `.github/workflows/` that touch production)
- Database dumps or real data files
- The gate itself: `factory/checks.sh`, `factory/config.json` (`gate_required`, `gate`),
  the PHPStan level/baseline, and deleting tests in `tests/Architecture/`. Weakening the
  gate to get green needs the human.

## Rules

1. Never commit secrets.
2. Prefer `.env.example` updates over real `.env` changes.
3. Schema migrations that drop columns or tables require explicit human confirmation.
4. The Security specialist must be engaged for any change that touches auth, authorization, or data access.
5. If an agent is unsure whether a path is protected, escalate to the Orchestrator.

## Worktrees

All implementation happens in isolated worktrees. Never commit directly to `main`.
