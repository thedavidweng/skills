#!/usr/bin/env python3
"""Flag [[slug|FirstName]] links whose display name is shared by several people pages.

Usage: python3 detect_same_name.py [VAULT_ROOT]   (default: current directory)

People pages are wiki/people/*.md with an H1 like "# 中文名 / English Name".
Each hit prints file:line, the link, and every slug that shares the name, so the
link can be checked against the surrounding context by hand.
"""
import re
import sys
from collections import defaultdict
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else ".")
people = root / "wiki" / "people"
if not people.is_dir():
    sys.exit(f"no {people} directory; pass the vault root as the first argument")

name_to_slugs = defaultdict(list)
for page in sorted(people.glob("*.md")):
    h1 = re.search(r"^# (.+)$", page.read_text(encoding="utf-8"), re.MULTILINE)
    eng = h1 and re.search(r"/\s*([A-Z][a-z]+)", h1.group(1))
    if eng:
        name_to_slugs[eng.group(1)].append(page.stem)

shared = {name: slugs for name, slugs in name_to_slugs.items() if len(slugs) > 1}
link = re.compile(r"\[\[([^\]|]+)\|([A-Z][a-z]+)\]\]")

hits = 0
for md in sorted((root / "wiki").rglob("*.md")):
    for lineno, line in enumerate(md.read_text(encoding="utf-8").splitlines(), 1):
        for m in link.finditer(line):
            slug, display = m.group(1).strip(), m.group(2)
            if display in shared:
                hits += 1
                others = ", ".join(shared[display])
                print(f"{md.relative_to(root)}:{lineno}: [[{slug}|{display}]] (shared by: {others})")

print(f"{hits} link(s) to check; {len(shared)} shared first name(s)", file=sys.stderr)
