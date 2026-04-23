# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

WordPress management and integration suite for **bellanico.com**. Enables remote site management, content operations, audits, and database access via SSH + WP-CLI and the WP REST API.

**Site**: https://bellanico.com (WordPress 6.9.4 on SiteGround)  
**Theme**: agroly-child 1.0  
**Plugins**: 31 installed (28 active) — Elementor Pro, ACF Pro, AIOSEO, WPForms, SG CachePress, CF7  
**GitHub**: `msakin-fds/bellanico.com`

## Environment Setup

**Platform**: Windows 11 Pro, bash (Git Bash)  
**SSH Key**: `~/.ssh/bellanico_ed25519` (ED25519)  
**SSH Access**: `u1376-vacs9qwmwnvs@giowm1081.siteground.biz:18765`  
**WP Path**: `/home/u1376-vacs9qwmwnvs/www/bellanico.com/public_html`  

All credentials live in `.env` (copy from `.env.example`). Never commit `.env`.

## Quick Start

```bash
pip install -r requirements.txt
cp .env.example .env
# Fill in .env values (see "Credentials Needed" section in README)
python wp_manager.py       # Test SSH + WP-CLI connection
```

## Tools & Scripts

### `wp_manager.py` — Core Python Interface

```python
from wp_manager import WordPressManager
wp = WordPressManager()

wp.get_site_info()                              # Test connection + WP version
wp.list_plugins()                               # All plugins (JSON)
wp.list_posts(limit=10)                         # Recent posts
wp.get_theme_info()                             # Active theme
wp.create_post(title, content, status='draft')  # Create post
wp.db_query("SELECT * FROM wp_posts LIMIT 5")  # Raw SQL
wp.db_export()                                  # Backup DB to server
wp.run_audit(audit_type='full|security|performance')
wp.run_rest_api('posts', method='GET')          # Direct REST API calls
wp.run_ssh_command('any shell command')         # Raw SSH
wp.run_wp_cli('any wp-cli command')             # Raw WP-CLI
```

### `scripts/site_audit.py` — Full Site Audit

```bash
python scripts/site_audit.py
```

### `scripts/wp.sh` — Bash Shortcuts

```bash
source scripts/wp.sh

wp core version          # Any WP-CLI command
wp_info                  # WP version + site URL
wp_plugins               # List plugins
wp_posts                 # Recent published posts
wp_backup                # DB backup to server
wp_update_all            # Update plugins + core
wp_activate <plugin>     # Activate plugin
wp_deactivate <plugin>   # Deactivate plugin
wp_users                 # List users
```

## Architecture

```
wp_manager.py            # Core manager class (SSH + REST API)
scripts/
  site_audit.py          # Comprehensive audit runner
  wp.sh                  # Bash shortcuts (source to use)
reports/                 # Audit outputs (gitignored)
.env                     # Credentials (never committed)
.env.example             # Template for .env
```

**Two access paths:**
- **SSH + WP-CLI** — full server access, database ops, plugin/theme management
- **WP REST API + Application Password** — content CRUD without SSH

## SSH Key Setup

Generate and upload the key to SiteGround:
```bash
# Generate key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/bellanico_rsa -N ""

# Test connection (after uploading public key in SiteGround -> SSH Keys & Access)
ssh -i ~/.ssh/bellanico_rsa -p 18765 YOUR_SSH_USER@ssh.bellanico.com "wp --version"
```

## Troubleshooting

**SSH fails**: Verify `SSH_KEY_PATH` in `.env`; confirm public key is added in SiteGround -> Site Tools -> Devs -> SSH Keys & Access.

**WP-CLI not found**: Run `which wp` over SSH — SiteGround ships WP-CLI at `/usr/local/bin/wp`.

**REST API 401**: Regenerate application password at WP Admin -> Users -> Profile -> Application Passwords.

**DB connection**: `DB_PASSWORD` comes from SiteGround -> Site Tools -> Site -> MySQL -> Databases (not the WP admin password).
