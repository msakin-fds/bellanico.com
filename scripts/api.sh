#!/usr/bin/env bash
# Call the WordPress REST API with application-password auth.
# Usage: ./scripts/api.sh <METHOD> <PATH> [curl-args...]
# Example: ./scripts/api.sh GET /wp/v2/posts?per_page=5
#          ./scripts/api.sh POST /wp/v2/posts -d '{"title":"Hi","status":"draft"}'
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
set -a; source "$REPO_ROOT/.env"; set +a
: "${SITE_URL:?SITE_URL not set in .env}"
: "${WP_USER:?WP_USER not set in .env}"
: "${WP_APP_PASSWORD:?WP_APP_PASSWORD not set in .env}"

method="${1:-GET}"
path="${2:?path required, e.g. /wp/v2/users/me}"
shift 2
# strip spaces from app password (WP displays them for readability)
pass="${WP_APP_PASSWORD// /}"

curl -sS -X "$method" \
  -u "$WP_USER:$pass" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  "$SITE_URL/wp-json$path" "$@"
