#!/usr/bin/env bash
# Pull a timestamped DB dump + wp-content archive into ./backups/
# Run before risky changes. Requires WP-CLI on the server (SiteGround has it).
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
set -a; source "$REPO_ROOT/.env"; set +a

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$REPO_ROOT/backups"

echo "==> Dumping database"
ssh -i "$SSH_KEY" -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" \
  "cd $DOC_ROOT && wp db export - --single-transaction --quick" \
  | gzip > "$REPO_ROOT/backups/db-$stamp.sql.gz"

echo "==> Archiving wp-content (themes + plugins + uploads)"
ssh -i "$SSH_KEY" -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" \
  "cd $DOC_ROOT && tar czf - wp-content" \
  > "$REPO_ROOT/backups/wp-content-$stamp.tar.gz"

echo "==> Done: $REPO_ROOT/backups/*-$stamp.*"
