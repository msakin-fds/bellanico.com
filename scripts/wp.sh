#!/usr/bin/env bash
# Run WP-CLI against the live site.
# Example: ./scripts/wp.sh plugin list
#          ./scripts/wp.sh post list --post_type=page
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
set -a; source "$REPO_ROOT/.env"; set +a
: "${SSH_HOST:?SSH_HOST not set in .env}"
: "${DOC_ROOT:?DOC_ROOT not set in .env}"
exec ssh -i "$SSH_KEY" -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" \
  "cd $DOC_ROOT && wp $*"
