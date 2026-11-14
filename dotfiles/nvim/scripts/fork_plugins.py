#!/usr/bin/env python3
"""
fork_plugins.py
Automatically discovers all Neovim plugins used in this configuration and forks
any missing ones to your GitHub backup organization (default: rtm0x00).

Features:
- Dynamically validates against lua/plugins/ and lazy-lock.json.
- Idempotent: checks your org first and skips already-forked repositories.
- Preserves all git branches and tags (--default-branch-only=false).
- Avoids duplicates and rate limit spikes.

Usage:
    python3 scripts/fork_plugins.py
    python3 scripts/fork_plugins.py --org rtm0x00
    python3 scripts/fork_plugins.py --dry-run
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time

DEFAULT_ORG = "rtm0x00"

def find_gh():
    """Finds the GitHub CLI binary across common host paths."""
    candidates = [
        shutil.which("gh"),
        "/home/linuxbrew/.linuxbrew/bin/gh",
        "/opt/homebrew/bin/gh",
        "/usr/local/bin/gh",
        "/usr/bin/gh",
    ]
    for c in candidates:
        if c and os.path.isfile(c) and os.access(c, os.X_OK):
            return c
    return None

def get_configured_plugins(nvim_dir):
    """Extracts all authoritative GitHub plugin repositories configured in Neovim."""
    lock_path = os.path.join(nvim_dir, "lazy-lock.json")
    lock_keys = set()
    if os.path.isfile(lock_path):
        with open(lock_path, "r", encoding="utf-8") as fp:
            try:
                lock_keys = set(json.load(fp).keys())
            except Exception:
                pass

    pattern = re.compile(r"""["'`]?([a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+)["'`]?""")
    found_repos = set()

    # Scan lua/plugins/ directory
    plugins_dir = os.path.join(nvim_dir, "lua", "plugins")
    if os.path.isdir(plugins_dir):
        for root, _, files in os.walk(plugins_dir):
            for f in files:
                if f.endswith(".lua"):
                    try:
                        with open(os.path.join(root, f), "r", encoding="utf-8", errors="ignore") as fp:
                            for m in pattern.findall(fp.read()):
                                parts = m.split("/")
                                if (
                                    len(parts) == 2
                                    and not parts[0].isdigit()
                                    and not parts[1].isdigit()
                                    and parts[0] not in ("config", "plugins", "assets")
                                    and parts[1] not in ("Format", "Fuzzy", "Diagnostics")
                                ):
                                    found_repos.add(m)
                    except Exception:
                        pass

    # Ensure lazy.nvim bootstrap repo is included
    found_repos.add("folke/lazy.nvim")

    # Match against lockfile entries if lockfile is present
    clean_repos = set()
    for r in found_repos:
        parts = r.split("/")
        if len(parts) == 2:
            owner, repo_name = parts
            if not lock_keys:
                clean_repos.add(r)
                continue
            for lk in lock_keys:
                if (
                    repo_name.lower() == lk.lower()
                    or repo_name.lower() == (lk + ".nvim").lower()
                    or (repo_name + ".nvim").lower() == lk.lower()
                    or (lk.lower() == "catppuccin" and repo_name == "nvim")
                ):
                    clean_repos.add(r)
                    break

    return sorted(list(clean_repos))

def main():
    parser = argparse.ArgumentParser(description="Backup/fork Neovim plugins to a GitHub organization.")
    parser.add_argument("--org", default=DEFAULT_ORG, help=f"Target GitHub organization (default: {DEFAULT_ORG})")
    parser.add_argument("--dry-run", action="store_true", help="List plugins and status without actually forking")
    args = parser.parse_args()

    # Determine nvim root directory
    script_dir = os.path.dirname(os.path.abspath(__file__))
    nvim_dir = os.path.abspath(os.path.join(script_dir, ".."))
    if not os.path.isfile(os.path.join(nvim_dir, "init.lua")):
        if os.path.isfile(os.path.join(script_dir, "init.lua")):
            nvim_dir = script_dir

    gh_bin = find_gh()
    if not gh_bin:
        print("❌ Error: GitHub CLI ('gh') not found in PATH or standard directories.")
        print("   Install it via Homebrew: brew install gh")
        sys.exit(1)

    print(f"🔍 Neovim configuration: {nvim_dir}")
    print(f"🐙 GitHub CLI:          {gh_bin}")
    print(f"🏢 Target organization:  {args.org}")
    print("=" * 60)

    # 1. Discover plugins
    plugins = get_configured_plugins(nvim_dir)
    print(f"📦 Discovered {len(plugins)} plugin repositories configured in Neovim.\n")

    # 2. Fetch existing repos from GitHub Org
    print(f"🌐 Fetching existing repositories in GitHub organization '{args.org}'...")
    try:
        out = subprocess.check_output([gh_bin, "repo", "list", args.org, "--limit", "1000", "--json", "name"], text=True)
        existing = {r["name"].lower() for r in json.loads(out)}
        print(f"✅ Found {len(existing)} existing repositories in '{args.org}'.\n")
    except subprocess.CalledProcessError as e:
        print(f"❌ Error communicating with GitHub CLI: {e}")
        print("   Ensure you are logged in: gh auth login")
        sys.exit(1)

    # 3. Process forks
    success = 0
    skipped = 0
    failed = 0

    for idx, repo in enumerate(plugins, start=1):
        name = repo.split("/")[1]
        print(f"[{idx:02d}/{len(plugins):02d}] {repo} -> {args.org}/{name} ... ", end="", flush=True)

        if name.lower() in existing:
            print("SKIPPED (already backed up)", flush=True)
            skipped += 1
            continue

        if args.dry_run:
            print("WOULD FORK (--dry-run)", flush=True)
            success += 1
            continue

        cmd = [
            gh_bin, "repo", "fork", repo,
            "--org", args.org,
            "--clone=false",
            "--default-branch-only=false"
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            print("OK (forked)", flush=True)
            success += 1
            existing.add(name.lower())
        else:
            err = res.stderr.strip() or res.stdout.strip()
            print(f"FAILED: {err}", flush=True)
            failed += 1

        # Small delay to avoid API burst limits
        time.sleep(1)

    print("\n" + "=" * 60)
    print(f"🎉 Complete! Newly Forked: {success}, Already Backed Up: {skipped}, Failed: {failed}")
    print("=" * 60)

if __name__ == "__main__":
    main()
