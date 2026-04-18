# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

Workspace for maintaining the WordPress site at **bellanico.com** (hosted on SiteGround). The site's PHP source currently lives on the server; this repo holds connection scaffolding and will accumulate theme/plugin source as it is pulled down.

## Connection model (Option A — REST-only)

This project is deliberately set up for **Claude Code web sessions**, which are ephemeral. Everything flows through the WordPress REST API over HTTPS, authenticated with an **application password**. There is no SSH, no WP-CLI, no local file sync.

### Scope of the REST API

Reachable via the API (use it freely):
- Posts, pages, custom post types, revisions
- Taxonomies, terms, menus
- Users (read/update self; full control for admins)
- Media library (upload, update, delete)
- Settings (site title, tagline, reading/discussion options, permalinks)
- Most plugins' custom endpoints (varies by plugin)

**Not** reachable via the REST API:
- Direct PHP/theme file edits, `wp-config.php`
- Database schema or arbitrary SQL
- Server logs, cron, file system

For those, we need a different channel (SSH or SFTP), which is incompatible with web sessions. Flag the limitation to the user and surface alternatives (e.g. WP admin UI, a one-off desktop session, or a SiteGround backup-restore).

## Per-session setup

`.env` is gitignored and does not persist between web sessions. At the start of a new session:

1. The user provides the WP application password (paste in chat, or recreate `.env`).
2. If pasted: write `/home/user/bellanico.com/.env` with:
   ```
   SITE_URL=https://bellanico.com
   WP_USER=<login username>
   WP_APP_PASSWORD=<24 chars, spaces ok>
   ```
3. Verify:
   ```bash
   ./scripts/api.sh GET /wp/v2/users/me
   ```
   Expect a JSON object with the user's id/name. A 401 means bad credentials; a 403 means the app password lacks capability for that endpoint.

## Everyday operations

```bash
# Read
./scripts/api.sh GET  "/wp/v2/posts?per_page=5&_fields=id,title,status"
./scripts/api.sh GET  /wp/v2/pages
./scripts/api.sh GET  /wp/v2/plugins         # requires admin

# Write
./scripts/api.sh POST /wp/v2/posts -d '{"title":"Draft","status":"draft"}'
./scripts/api.sh POST /wp/v2/posts/123 -d '{"title":"Updated"}'
./scripts/api.sh DELETE /wp/v2/posts/123

# Media upload (multipart; pass curl flags directly)
./scripts/api.sh POST /wp/v2/media \
  -H "Content-Disposition: attachment; filename=hero.jpg" \
  -H "Content-Type: image/jpeg" \
  --data-binary @./hero.jpg
```

`api.sh` reads `.env`, strips spaces from the app password, and surfaces HTTP error bodies (`--fail-with-body`) so failures are debuggable.

## Guardrails

- **Always read before write.** GET the current resource first, show the user the diff you intend to POST, confirm, then write.
- **Drafts over publishes.** For new content, create with `"status":"draft"` unless the user explicitly asks to publish.
- **No bulk destructive calls without confirmation** (e.g. DELETE loops, mass status changes). State what you're about to do, ask, then act.
- **Secrets never leave `.env`.** Don't echo `WP_APP_PASSWORD`, don't commit `.env`, don't paste it into GitHub/PR bodies.
- If an operation genuinely needs SSH/DB access, stop and tell the user — don't improvise a workaround.

## Future additions to this file

- Theme/plugin source once it's pulled into the repo, plus a deployment path (e.g. GitHub Action with a SiteGround deploy key — handled by the user, not by web sessions).
- Build / lint / test commands once tooling is introduced.
- Any Cursor (`.cursor/rules/`) or Copilot (`.github/copilot-instructions.md`) conventions once they exist.
