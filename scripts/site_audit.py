#!/usr/bin/env python3
"""Comprehensive site audit for bellanico.com"""

import sys
import json
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))
from wp_manager import WordPressManager

def run_audit():
    wp = WordPressManager()
    print("=== bellanico.com Site Audit ===\n")

    info = wp.get_site_info()
    print(f"Status: {info.get('status')}")
    print(f"WordPress version: {info.get('wp_version', 'unknown')}")

    print("\n--- Theme ---")
    theme = wp.get_theme_info()
    print(json.dumps(theme, indent=2))

    print("\n--- Plugins ---")
    plugins = wp.list_plugins()
    if isinstance(plugins, list):
        for p in plugins:
            print(f"  [{p.get('status','?')}] {p.get('name','?')} {p.get('version','')}")
    else:
        print(json.dumps(plugins, indent=2))

    print("\n--- Recent Posts ---")
    posts = wp.list_posts(5)
    if isinstance(posts, list):
        for p in posts:
            print(f"  [{p.get('post_status')}] {p.get('post_title')}")
    else:
        print(json.dumps(posts, indent=2))

if __name__ == '__main__':
    run_audit()
