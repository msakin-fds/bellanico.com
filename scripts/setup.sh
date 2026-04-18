#!/usr/bin/env bash
# One-time setup for bellanico.com connectivity.
# Run this on your local machine (Claude Code desktop), NOT in a web session.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY_PATH="$HOME/.ssh/bellanico_siteground"
SSH_CONFIG="$HOME/.ssh/config"
HOST_ALIAS="bellanico-siteground"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ ! -f "$KEY_PATH" ]]; then
  echo "==> Generating ed25519 keypair at $KEY_PATH"
  ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "claude-code@bellanico.com" -q
else
  echo "==> Key already exists at $KEY_PATH (skipping generation)"
fi
chmod 600 "$KEY_PATH"
chmod 644 "$KEY_PATH.pub"

if ! grep -q "Host $HOST_ALIAS" "$SSH_CONFIG" 2>/dev/null; then
  echo "==> Adding ~/.ssh/config entry for $HOST_ALIAS"
  {
    echo ""
    echo "Host $HOST_ALIAS"
    echo "  IdentityFile $KEY_PATH"
    echo "  IdentitiesOnly yes"
    echo "  ServerAliveInterval 60"
  } >> "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
fi

if [[ ! -f "$REPO_ROOT/.env" ]]; then
  cp "$REPO_ROOT/.env.example" "$REPO_ROOT/.env"
  echo "==> Created $REPO_ROOT/.env from template"
fi

cat <<EOF

================================================================
PUBLIC KEY — paste this into SiteGround:
  Site Tools -> Devs -> SSH Keys Manager -> Import
----------------------------------------------------------------
$(cat "$KEY_PATH.pub")
----------------------------------------------------------------

Next steps:
  1. Import the public key above into SiteGround.
  2. SiteGround shows you an SSH user + hostname + port -> fill into .env:
       SSH_HOST, SSH_USER, SSH_PORT
  3. Generate a WordPress application password (Users -> Profile)
     -> fill WP_APP_PASSWORD in .env (name it "ClaudeCode").
  4. Verify connection:
       ./scripts/ssh.sh "whoami && hostname && pwd"
       ./scripts/wp.sh core version
       ./scripts/api.sh GET /wp/v2/users/me
================================================================
EOF
