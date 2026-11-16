# Safety

Agents must not modify protected paths without explicit human approval:

- `.env`, `.env.*` (except `.env.example`)
- `config/app.php` key generation or secret-related config
- `storage/oauth-*.key`, `storage/*.pem`
- any file containing real secrets or credentials
- production deployment configs
- database dumps or real data files

Never commit secrets. Schema migrations that drop columns or tables require explicit human confirmation.

All implementation occurs in isolated worktrees; never commit directly to `main`.
