#!/usr/bin/env bash
# Run an arbitrary command on the SiteGround server.
# Example: ./scripts/ssh.sh "ls -la ~/public_html"
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
set -a; source "$REPO_ROOT/.env"; set +a
: "${SSH_HOST:?SSH_HOST not set in .env}"
: "${SSH_USER:?SSH_USER not set in .env}"
exec ssh -i "$SSH_KEY" -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" "$@"
