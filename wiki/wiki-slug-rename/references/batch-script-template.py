#!/usr/bin/env python3
"""
Batch wiki slug rename template.

Usage:
1. Fill in RENAME_MAP with old → new slug pairs
2. Set VAULT_ROOT to your wiki root directory
3. Run: python3 batch-script-template.py
"""

import os
import re

# === CONFIGURE ===
VAULT_ROOT = "/path/to/your/vault"

RENAME_MAP = {
    # "old-slug": "new-slug",
    # "alice-jones": "alice-smith",
}

WIKI_DIR = os.path.join(VAULT_ROOT, "wiki")
SOURCES_DIR = os.path.join(VAULT_ROOT, "sources")
INDEX_PATH = os.path.join(VAULT_ROOT, "wiki", "index.md")

# === STEP 1: Rename wiki page files ===
for old_slug, new_slug in RENAME_MAP.items():
    for root, dirs, files in os.walk(WIKI_DIR):
        for fname in files:
            if fname == f"{old_slug}.md":
                old_path = os.path.join(root, fname)
                new_path = os.path.join(root, f"{new_slug}.md")
                os.rename(old_path, new_path)
                print(f"Renamed wiki: {old_path} → {new_path}")

# === STEP 2: Rename source files ===
for old_slug, new_slug in RENAME_MAP.items():
    for root, dirs, files in os.walk(SOURCES_DIR):
        for fname in files:
            if old_slug in fname:
                old_path = os.path.join(root, fname)
                new_path = os.path.join(root, fname.replace(old_slug, new_slug))
                os.rename(old_path, new_path)
                print(f"Renamed source: {old_path} → {new_path}")

# === STEP 3: Update wikilinks in all markdown files ===
for root, dirs, files in os.walk(VAULT_ROOT):
    for fname in files:
        if not fname.endswith(".md"):
            continue
        fpath = os.path.join(root, fname)
        with open(fpath, "r") as f:
            content = f.read()
        new_content = content
        for old_slug, new_slug in RENAME_MAP.items():
            # [[old-slug]] → [[new-slug]]
            new_content = re.sub(
                rf"\[\[{re.escape(old_slug)}(\||\]\])",
                rf"[[{new_slug}\1",
                new_content,
            )
            # ![[sources/.../old-slug-...]] → ![[sources/.../new-slug-...]]
            new_content = new_content.replace(old_slug, new_slug)
        if new_content != content:
            with open(fpath, "w") as f:
                f.write(new_content)
            print(f"Updated links: {fpath}")

# === STEP 4: Update index ===
if os.path.exists(INDEX_PATH):
    with open(INDEX_PATH, "r") as f:
        content = f.read()
    new_content = content
    for old_slug, new_slug in RENAME_MAP.items():
        new_content = new_content.replace(f"[[{old_slug}]]", f"[[{new_slug}]]")
    if new_content != content:
        with open(INDEX_PATH, "w") as f:
            f.write(new_content)
        print(f"Updated index: {INDEX_PATH}")

print("\nDone. Run your vault audit to verify zero broken links.")
