# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

Workspace for maintaining the WordPress site at **bellanico.com** (hosted on SiteGround). The site's PHP source currently lives on the server; this repo holds connection scaffolding and will accumulate theme/plugin source as it is pulled down.

## Connection model (Option B — Supabase HTTP proxy)

Claude Code **web sessions** cannot make outbound HTTP requests directly (the sandbox blocks them). Instead, all WordPress REST API calls go through a `wp_api()` SQL function deployed on a Supabase project. The Supabase database's `http` extension reaches bellanico.com without any restrictions.

### Supabase project

- **Project ID:** `sbnqfntfxzyryrlngzpa`
- **Region:** us-east-1
- **Function deployed:** `public.wp_api(method, path, body?)`

No per-session setup is needed — credentials are baked into the `wp_api` function on Supabase.

### Verify the connection

Run this via the Supabase MCP tool (`execute_sql`):

```sql
SELECT public.wp_api('GET', '/wp/v2/users/me');
```

Expect a JSON object with `"status": 200` and user details. A `401` means bad credentials; a `403` means the account lacks capability for that endpoint.

## Everyday operations

All calls go through `execute_sql` on project `sbnqfntfxzyryrlngzpa`:

```sql
-- Read posts
SELECT public.wp_api('GET', '/wp/v2/posts?per_page=5&_fields=id,title,status');

-- Read pages
SELECT public.wp_api('GET', '/wp/v2/pages');

-- Read plugins (requires admin)
SELECT public.wp_api('GET', '/wp/v2/plugins');

-- Create a draft post
SELECT public.wp_api('POST', '/wp/v2/posts', '{"title":"Draft title","status":"draft"}');

-- Update a post
SELECT public.wp_api('POST', '/wp/v2/posts/123', '{"title":"Updated title"}');

-- Delete a post
SELECT public.wp_api('DELETE', '/wp/v2/posts/123');
```

### Scope of the REST API

Reachable:
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

For those, flag the limitation to the user — they need WP Admin UI or a SiteGround backup-restore.

## Guardrails

- **Always read before write.** GET the current resource first, show the user the diff, confirm, then write.
- **Drafts over publishes.** For new content, use `"status":"draft"` unless the user explicitly asks to publish.
- **No bulk destructive calls without confirmation** (e.g. DELETE loops, mass status changes). State what you're about to do, ask, then act.
- **Secrets:** The WP application password lives inside the `wp_api` Supabase function — never echo or commit it.
- If an operation genuinely needs SSH/DB access, stop and tell the user — don't improvise a workaround.

## Future additions to this file

- Theme/plugin source once it's pulled into the repo, plus a deployment path (e.g. GitHub Action with a SiteGround deploy key — handled by the user, not by web sessions).
- Build / lint / test commands once tooling is introduced.
