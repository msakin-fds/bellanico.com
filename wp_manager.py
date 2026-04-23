#!/usr/bin/env python3
"""WordPress Site Manager for bellanico.com"""

import os
import json
import subprocess
import requests
from pathlib import Path
from dotenv import load_dotenv

class WordPressManager:
    def __init__(self):
        load_dotenv()
        self.ssh_host = os.getenv('SSH_HOST')
        self.ssh_port = os.getenv('SSH_PORT', '18765')
        self.ssh_user = os.getenv('SSH_USER')
        self.ssh_key = os.getenv('SSH_KEY_PATH')
        self.wp_path = os.getenv('WORDPRESS_PATH')
        self.wp_url = os.getenv('WORDPRESS_URL')
        self.rest_user = os.getenv('WP_REST_USER')
        self.rest_password = os.getenv('WP_REST_PASSWORD')
        self.db_name = os.getenv('DB_NAME')
        self.db_user = os.getenv('DB_USER')
        self.db_password = os.getenv('DB_PASSWORD')
        self.db_host = os.getenv('DB_HOST')

    def run_ssh_command(self, command):
        """Execute a command on the remote server via SSH"""
        ssh_cmd = [
            'ssh',
            '-i', self.ssh_key,
            '-p', self.ssh_port,
            '-o', 'StrictHostKeyChecking=no',
            f'{self.ssh_user}@{self.ssh_host}',
            f'cd {self.wp_path} && {command}'
        ]
        try:
            result = subprocess.run(ssh_cmd, capture_output=True, text=True, timeout=30)
            return result.stdout.strip(), result.stderr, result.returncode
        except subprocess.TimeoutExpired:
            return '', 'Command timeout', 1

    def run_wp_cli(self, command):
        """Execute a WP-CLI command"""
        return self.run_ssh_command(f'wp {command}')

    def run_rest_api(self, endpoint, method='GET', data=None):
        """Call WP REST API with application password auth"""
        url = f"{self.wp_url}/wp-json/wp/v2/{endpoint}"
        auth = (self.rest_user, self.rest_password)
        try:
            if method == 'GET':
                r = requests.get(url, auth=auth, timeout=15)
            elif method == 'POST':
                r = requests.post(url, auth=auth, json=data, timeout=15)
            r.raise_for_status()
            return r.json()
        except requests.RequestException as e:
            return {'error': str(e)}

    def get_site_info(self):
        """Get WordPress site information"""
        stdout, stderr, code = self.run_wp_cli('core version')
        if code == 0:
            return {
                'url': self.wp_url,
                'wp_version': stdout,
                'path': self.wp_path,
                'status': 'connected'
            }
        return {'status': 'error', 'error': stderr}

    def list_plugins(self):
        """List all installed plugins"""
        stdout, stderr, code = self.run_wp_cli('plugin list --format=json')
        if code == 0:
            return json.loads(stdout)
        return {'error': stderr}

    def list_posts(self, limit=10):
        """List recent posts"""
        stdout, stderr, code = self.run_wp_cli(f'post list --format=json --numberposts={limit}')
        if code == 0:
            return json.loads(stdout)
        return {'error': stderr}

    def create_post(self, title, content, post_type='post', status='draft'):
        """Create a new post"""
        escaped_title = title.replace("'", "'\\''")
        escaped_content = content.replace("'", "'\\''")
        cmd = f"post create --post_title='{escaped_title}' --post_content='{escaped_content}' --post_type={post_type} --post_status={status}"
        stdout, stderr, code = self.run_wp_cli(cmd)
        return {'success': code == 0, 'output': stdout, 'error': stderr}

    def get_theme_info(self):
        """Get active theme information"""
        stdout, stderr, code = self.run_wp_cli('theme list --status=active --format=json')
        if code == 0:
            themes = json.loads(stdout)
            return themes[0] if themes else {}
        return {'error': stderr}

    def db_query(self, sql):
        """Run a raw SQL query via WP-CLI"""
        escaped = sql.replace("'", "'\\''")
        stdout, stderr, code = self.run_wp_cli(f"db query \"{sql}\"")
        return {'result': stdout, 'error': stderr, 'success': code == 0}

    def db_export(self, filename='backup.sql'):
        """Export database to file on server"""
        stdout, stderr, code = self.run_wp_cli(f'db export {filename}')
        return {'success': code == 0, 'output': stdout, 'error': stderr}

    def run_audit(self, audit_type='full'):
        """Run site audit"""
        audits = {
            'full': ['core', 'theme', 'plugins', 'posts'],
            'security': ['users', 'plugins'],
            'performance': ['plugins', 'theme'],
        }
        results = {}
        for cmd in audits.get(audit_type, audits['full']):
            if cmd == 'core':
                stdout, _, _ = self.run_wp_cli('core version')
                results['wordpress_version'] = stdout
            elif cmd == 'theme':
                results['theme'] = self.get_theme_info()
            elif cmd == 'plugins':
                results['plugins'] = self.list_plugins()
            elif cmd == 'posts':
                results['recent_posts'] = self.list_posts(5)
            elif cmd == 'users':
                stdout, _, _ = self.run_wp_cli('user list --format=json')
                try:
                    results['users'] = json.loads(stdout)
                except Exception:
                    results['users'] = stdout
        return results


if __name__ == '__main__':
    wp = WordPressManager()
    print('WordPress Manager — bellanico.com')
    print(json.dumps(wp.get_site_info(), indent=2))
