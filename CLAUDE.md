# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

This repo is the workspace for maintaining the WordPress site at **bellanico.com**, hosted on **SiteGround**. It does not yet contain the site's source — those files live on the server and are accessed via SSH. Over time, themes/custom plugins should be checked in here and deployed outward.

## Prerequisites (one-time, on a desktop machine)

The tooling assumes a persistent local environment (Claude Code desktop app, not web sessions — web sandboxes lose `~/.ssh/` between sessions, breaking key-based auth).

1. `ssh`, `curl`, `rsync`, `gzip`, `tar` available on PATH.
2. Run `./scripts/setup.sh` once. It:
   - Generates `~/.ssh/bellanico_siteground` (ed25519) if missing.
   - Adds a `~/.ssh/config` entry aliased `bellanico-siteground`.
   - Copies `.env.example` to `.env`.
   - Prints the public key to paste into SiteGround → *Devs → SSH Keys Manager → Import*.
3. Fill `.env` with values from SiteGround (host/user/port) and WordPress (application password).

## Connection architecture

Two independent channels to the live site — use whichever is simpler for the task:

| Channel | Script | Use for |
|---|---|---|
| WP REST API (HTTPS + app password) | `./scripts/api.sh METHOD /path [curl-args]` | posts, pages, users, menus, plugin/theme endpoints |
| SSH + WP-CLI | `./scripts/wp.sh <wp subcommand>` | DB queries, bulk ops, config, search-replace |
| Raw SSH | `./scripts/ssh.sh "<remote-cmd>"` | file inspection, PHP/theme edits, logs |
| Backup | `./scripts/backup.sh` | pre-change DB dump + `wp-content` archive → `./backups/` (gitignored) |

All scripts read credentials/paths from `.env` (gitignored). Never hardcode secrets in scripts or commits.

## Verification commands

After `setup.sh` and filling `.env`:

```bash
./scripts/ssh.sh "whoami && hostname && pwd"      # SSH auth works
./scripts/wp.sh core version                      # WP-CLI reachable
./scripts/api.sh GET /wp/v2/users/me              # REST API auth works
```

## Operational guardrails

- **Always `./scripts/backup.sh` before** schema changes, plugin updates, search-replace, or anything touching the DB.
- Prefer staging (SiteGround's one-click staging site) for non-trivial work; point `.env` at staging, verify, then switch back.
- Commit theme/plugin source into this repo as it's pulled down, so changes are reviewable in git before being pushed back to the server.

## Future additions to this file

As the project grows, document here:
- Build / lint / test commands (including single-test invocation).
- Deployment flow (git → SiteGround Git integration, or rsync push script).
- Any Cursor (`.cursor/rules/`, `.cursorrules`) or Copilot (`.github/copilot-instructions.md`) conventions once introduced.
