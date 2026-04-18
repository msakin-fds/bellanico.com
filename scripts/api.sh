#!/usr/bin/env bash
# Call the WordPress REST API using application-password auth.
# Usage: ./scripts/api.sh <METHOD> <PATH> [curl-args...]
#
# Examples:
#   ./scripts/api.sh GET  /wp/v2/users/me
#   ./scripts/api.sh GET  "/wp/v2/posts?per_page=5&_fields=id,title,status"
#   ./scripts/api.sh POST /wp/v2/posts -d '{"title":"Hi","status":"draft"}'
#   ./scripts/api.sh POST /wp/v2/posts/123 -d '{"title":"Updated"}'
#   ./scripts/api.sh DELETE /wp/v2/posts/123
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$REPO_ROOT/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "error: $ENV_FILE not found. Copy .env.example to .env and fill it in." >&2
  exit 2
fi

set -a; source "$ENV_FILE"; set +a
: "${SITE_URL:?SITE_URL not set in .env}"
: "${WP_USER:?WP_USER not set in .env}"
: "${WP_APP_PASSWORD:?WP_APP_PASSWORD not set in .env}"

method="${1:?METHOD required (GET|POST|PUT|PATCH|DELETE)}"
path="${2:?PATH required, e.g. /wp/v2/users/me}"
shift 2

# Strip spaces from app password (WP displays it with spaces for readability).
pass="${WP_APP_PASSWORD// /}"

curl -sS --fail-with-body -X "$method" \
  -u "$WP_USER:$pass" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  "$SITE_URL/wp-json$path" "$@"
