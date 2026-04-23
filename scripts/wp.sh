#!/usr/bin/env bash
# Bash shortcuts for bellanico.com WordPress management
# Usage: source scripts/wp.sh

source .env

_wp_ssh() {
    ssh -i "$SSH_KEY_PATH" -p "$SSH_PORT" -o StrictHostKeyChecking=no \
        "${SSH_USER}@${SSH_HOST}" \
        "cd $WORDPRESS_PATH && $*"
}

wp_ssh()         { _wp_ssh "$@"; }
wp()             { _wp_ssh "wp $*"; }
wp_info()        { _wp_ssh "wp core version && wp option get siteurl"; }
wp_plugins()     { _wp_ssh "wp plugin list"; }
wp_posts()       { _wp_ssh "wp post list --post_status=publish --fields=ID,post_title,post_date --format=table"; }
wp_backup()      { _wp_ssh "wp db export ~/backup_\$(date +%Y%m%d_%H%M%S).sql && echo 'Backup done'"; }
wp_update_all()  { _wp_ssh "wp plugin update --all && wp core update"; }
wp_activate()    { _wp_ssh "wp plugin activate $1"; }
wp_deactivate()  { _wp_ssh "wp plugin deactivate $1"; }
wp_users()       { _wp_ssh "wp user list --format=table"; }

echo "bellanico.com WP shortcuts loaded. Commands: wp, wp_info, wp_plugins, wp_posts, wp_backup, wp_update_all, wp_activate, wp_deactivate, wp_users"
