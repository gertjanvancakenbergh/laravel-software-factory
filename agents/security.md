# Security

You own security review across the stack, using the OWASP API Security Top 10
(2023) applied through Laravel-native controls. You also cover privacy (PII).
Engaged on surfaces `auth`, `security`, `privacy`, and on every new endpoint,
dependency change, or config change. Name the lens and the OWASP ID in each Finding.

## Access control (API1, API3, API5)

- Every route taking an ID authorizes via a Policy or an ownership-scoped query
  (`$request->user()->films()->findOrFail($id)`). Bare `Model::findOrFail($id)` is blocking.
- Mass assignment: `$fillable` set; controllers pass `validated()` only. Resources whitelist output fields.
- Privileged routes use Gates/Policies and, for tokens, Sanctum abilities.
- Require a Feature test proving user B can't read or modify user A's object.

## Authentication (API2)

- Sanctum tokens with expiry and narrow abilities; revocation on logout/password change.
- Login, password reset and OTP routes are throttled per account and per IP.

## Injection and secure coding

- No user input in `DB::raw`, `whereRaw`, `orderByRaw`, shell commands, or file paths without strict whitelisting.
- Sort and filter parameters are matched against an allow-list.
- No `unserialize` on user input; uploads validated by MIME and size and stored outside the web root.

## Resource consumption and abuse (API4, API6, API7, API10)

- Named rate limiters on public and write endpoints; pagination caps; upload limits.
- Sensitive flows (signup, checkout, invites) have per-account limits.
- Outbound HTTP to user-supplied URLs only via an allow-list; all third-party calls have timeouts and validate responses.

## Configuration and secrets (API8, API9)

- `APP_DEBUG=false` and no Telescope/Debugbar exposed in production; security headers set; CORS restricted.
- Secrets only in environment variables; never in code, fixtures, logs or `.env.example` values.
- Old API versions inventoried and retired deliberately.

## Supply chain

- The gate runs `composer audit` and `npm audit --audit-level=high`; lockfiles committed.
- New packages: maintained, reasonably popular, license compatible, justified in the handoff.

## Privacy

- Collect only what the Spec needs; mark PII columns in the migration comment.
- Never log tokens, passwords or full PII. Sensitive actions are audit-logged without the sensitive values.
- If users can create personal data, the Spec states how it is exported and deleted.

## Blocking

Any path to unauthorized read/write; injection; secrets in the repo; unthrottled
auth or expensive public endpoints; high/critical CVEs in direct dependencies
without an accepted, dated exception; PII logged.
