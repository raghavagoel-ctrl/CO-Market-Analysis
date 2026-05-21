#!/usr/bin/env python3
"""Push all repo files to raghavagoel-ctrl/CO-Market-Analysis via GitHub API."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path

OWNER = "raghavagoel-ctrl"
REPO = "CO-Market-Analysis"
BRANCH = "main"
ROOT = Path(__file__).resolve().parent.parent

SKIP_PARTS = {".tools", "push-payload.json", "push-batch1.json", "push-batch2.json", "__pycache__"}


def get_token() -> str:
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        return token.strip()
    try:
        out = subprocess.check_output(
            ["gh", "auth", "token"],
            stderr=subprocess.DEVNULL,
            text=True,
        )
        return out.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    raise SystemExit(
        "No GitHub token. Set GITHUB_TOKEN or run: gh auth login"
    )


def api(method: str, url: str, token: str, body: dict | None = None) -> dict:
    data = None
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            raw = resp.read().decode("utf-8")
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        err = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"HTTP {e.code} {url}\n{err}") from e


def get_head_sha(token: str) -> str:
    ref = api(
        "GET",
        f"https://api.github.com/repos/{OWNER}/{REPO}/git/ref/heads/{BRANCH}",
        token,
    )
    return ref["object"]["sha"]


def collect_files() -> list[tuple[str, str]]:
    files: list[tuple[str, str]] = []
    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(ROOT).as_posix()
        if any(part in SKIP_PARTS for part in path.parts):
            continue
        if rel == "scripts/push_to_github.py":
            continue
        content = path.read_text(encoding="utf-8")
        files.append((rel, content))
    return files


def main() -> None:
    token = get_token()
    files = collect_files()
    if not files:
        raise SystemExit("No files to push")

    head = get_head_sha(token)
    base_commit = api(
        "GET",
        f"https://api.github.com/repos/{OWNER}/{REPO}/git/commits/{head}",
        token,
    )
    base_tree = base_commit["tree"]["sha"]

    tree_entries = []
    for rel, content in files:
        blob = api(
            "POST",
            f"https://api.github.com/repos/{OWNER}/{REPO}/git/blobs",
            token,
            {"content": content, "encoding": "utf-8"},
        )
        tree_entries.append(
            {"path": rel, "mode": "100644", "type": "blob", "sha": blob["sha"]}
        )

    new_tree = api(
        "POST",
        f"https://api.github.com/repos/{OWNER}/{REPO}/git/trees",
        token,
        {"base_tree": base_tree, "tree": tree_entries},
    )

    new_commit = api(
        "POST",
        f"https://api.github.com/repos/{OWNER}/{REPO}/git/commits",
        token,
        {
            "message": "Add workflow docs, map, reports, and scripts",
            "tree": new_tree["sha"],
            "parents": [head],
        },
    )

    api(
        "PATCH",
        f"https://api.github.com/repos/{OWNER}/{REPO}/git/refs/heads/{BRANCH}",
        token,
        {"sha": new_commit["sha"], "force": False},
    )

    print(f"Pushed {len(files)} files in commit {new_commit['sha'][:12]}")
    print(f"https://github.com/{OWNER}/{REPO}")


if __name__ == "__main__":
    main()
