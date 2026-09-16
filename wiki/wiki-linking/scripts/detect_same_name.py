import re, os
from collections import defaultdict

# 1. Build slug -> English name mapping
slug_to_eng = {}
eng_to_slugs = defaultdict(list)
for f in os.listdir("wiki/people"):
    if f.endswith('.md'):
        slug = f[:-3]
        with open(f"wiki/people/{f}") as fh:
            content = fh.read()
        title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
        if title_match:
            title = title_match.group(1)
            eng_match = re.search(r'/\s*([A-Z][a-z]+)', title)
            if eng_match:
                eng_name = eng_match.group(1)
                slug_to_eng[slug] = eng_name
                eng_to_slugs[eng_name].append(slug)

# 2. Filter to duplicates only
dup_eng = {k: v for k, v in eng_to_slugs.items() if len(v) > 1}

# 3. Find all [[slug|EnglishName]] links with mismatched names
for root, dirs, files in os.walk("wiki"):
    for f in files:
        if not f.endswith('.md'): continue
        with open(os.path.join(root, f)) as fh:
            content = fh.read()
        for m in re.finditer(r'\[\[[^\]|]+\|([^\]]+)\]\]', content):
            display = m.group(1).strip()
            if re.match(r'^[A-Z][a-z]+$', display) and display in dup_eng:
                # verify context to flag potential mismatches
                print(f"DUPLICATE_NAME_LINK: {f} -> [[...|{display}]]")
