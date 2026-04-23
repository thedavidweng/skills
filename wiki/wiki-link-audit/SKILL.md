---
name: wiki-link-audit
description: 'USE THIS SKILL whenever the user wants to: audit wiki backlinks, verify
  link legitimacy, check for false links, or validate cross-references from heavily
  linked pages. Triggers on ''link audit'', ''backlink check'', ''verify links'',
  or ''wiki integrity''.'
---

# Wiki Link Audit — Reverse from Source

## Purpose
Audit wiki integrity by starting from heavily backlinked source pages and checking if all pages linking to them are legitimate. More efficient than checking pages randomly.

## When to Use
- After bulk data imports (social media, VCF contacts)
- Periodically for wiki quality assurance
- When user reports "很多链接是错的"

## Steps

1. **Find backlink frequency**: Scan all wiki .md files for `[[target]]`, count per slug, sort by frequency.
2. **Audit from each top target**: For each linking page, verify the link is substantiated. E.g., if person links to `student-roster`, is their name actually in the roster?
3. **Cross-reference with source data**: Check FB friends, chat exports, VCFs. Pages with no backlinks + no sources + user doesn't recognize = likely hallucinated.
4. **Fix**: Remove false links or delete pages. Update `system/wiki/index.md`.

## Common False Link Patterns
- People pages linking to `student-roster-2018-2019` when not in roster
- Pages claiming "school classmates" without verification
- "合住" claims from address-only relationships (e.g., Pittsburgh)
- FB/IG export data taken at face value without verification

## Key Source Pages to Audit
- High-backlink roster pages (100+ backlinks)
- Person hub pages (200+ backlinks)
- Social circle pages

## Pitfalls
- Don't trust social media exports at face value
- Always ask user before deleting pages
- Chinese name matching: check aliases too
- **FB Marketplace thread names**: A surname prefix in Facebook export is just the platform's naming convention for the user's threads. It does NOT mean the user was the seller. Many are inquiry conversations. Always verify with user.
- **Address ≠ residence**: Using someone's address for mail/credit cards does not mean living there. Verify residency claims with independent evidence.
- **Wiki perspective**: Don't write all pages from the wiki owner's POV. School pages describe the school, social circle pages describe the group, project pages describe the project. The owner is one participant, not the center.
- **School staff in roster**: Teachers/staff can link to student-roster even though they're not students — they're part of the school ecosystem.

## Same-English-Name Link Audit
When multiple people share the same English name (e.g., John, Peter, Jack), links using `[[slug|EnglishName]]` can accidentally point to the wrong person.

### Detection Pattern
1. Extract all people pages with English names (from titles like `zhang-san / Peter`)
2. Group by English name, find duplicates (2+ people share same name)
3. Search for all `[[slug|EnglishName]]` links where display is pure English name
4. Check if slug's English name matches the display text

### Systematic Detection Script
```python
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
```

### Common Culprits
- John (multiple people)
- Peter (4+ people in a network)
- Jack, Leo, Kiki, Alice, Chelsea, David, Eden, Emily, Sherry, Rachel

### Fix
Replace `[[wrong-slug|EnglishName]]` with `[[correct-slug|EnglishName]]`. Verify context (family relationships, social circles) to determine correct target.

### Example
`person-a.md` had `[[person-b-john|John]]` instead of `[[person-c-john|John]]` — wrong John for the spouse relationship. Fixed by changing to the correct slug.

## Memory-to-Wiki Gap Check
After building wiki, compare memory entries against wiki pages. Items that appear in memory but lack wiki pages are candidates for new entries. Prioritize: social circles, institutions, projects, conventions.
