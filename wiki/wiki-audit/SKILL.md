---
name: wiki-audit
description: "USE THIS SKILL whenever the user wants to: audit a wiki vault, check for broken links, find orphan pages, review tag compliance, detect duplicate pages, or assess content hygiene. Triggers on 'wiki audit', 'check links', 'find orphans', 'tag audit', or 'vault review'."
---

# Wiki Audit

Audit an Obsidian wiki vault following Wikipedia-style conventions. Covers inline linking, tag compliance, duplicate detection, orphan pages, stub tracking, and content hygiene.

## Prerequisites

Read these before starting:
- `system/wiki/schema.md` — linking rules, tag taxonomy, article format
- `system/wiki/workflows.md` — lint checks
- `system/wiki/index.md` — page catalog

## Audit Steps

### 1. Build Index

Scan all `.md` files under `wiki/`. For each page, extract:
- slug (filename without .md), title (H1), kind, aliases, tags, line count
- outbound wikilinks (excluding `sources/` links)
- inbound links (reverse index)

### 2. Inline Link Audit

**Goal**: Find terms in body text that reference other wiki pages but aren't wikilinked.

Process:
1. Build term→slug mapping from all titles + aliases
2. For each page, scan body text (excluding frontmatter, headings, `## Sources` sections)
3. Find mentions of other pages' terms that are NOT inside `[[wikilinks]]`
4. Filter out generic terms (media, development, research, etc.)
5. Report per-page with context snippets

**Fix pattern**: `[[slug|matched text]]` — use display text matching what's in the body.

**Pitfall**: Watch for split links like `[[slug|David]] [[slug|Weng]]` — should be `[[slug|David Weng]]`. Detect by checking adjacent wikilinks to same target.

### 3. Prohibited Pattern Scan

Check for:
- `## Related` or `## See also` sections (must be inline instead)
- `inbox/` references in `## Sources` sections (inbox is temporary)
- Date-based headings (`## 2024-01`) in non-timeline pages
- Tags not in the taxonomy defined in `schema.md`

### 4. Structural Checks

- **Orphan pages**: pages with zero inbound wikilinks (excluding maps). Resolution: create tag-based index pages in `maps/` (e.g., `all-family.md`, `all-teachers.md`, `all-university.md`).
- **Broken links**: `[[target]]` where target doesn't exist as a page
- **Duplicate slugs**: same filename in different directories
- **Duplicate H1 titles**: two pages with identical H1 headings
- **Stub pages**: < 10 body lines (maintain `stub-index.md` for tracking)
- **Bloated pages**: > 150 body lines (candidates for splitting)
- **Isolated pages**: zero outbound AND zero inbound links
- **Misplaced index pages**: topic pages with >15 links and <10 prose lines → likely map/index pages, should move to `maps/` and change `kind: map`

#### Fixing Orphans with Tag Index Pages

Group orphan pages by their tags, then create index pages in `maps/` that link to all pages sharing a tag. This fixes orphans in bulk and provides browsable navigation.

```
maps/all-family.md   → all `family` tagged pages
maps/all-teachers.md → all `teacher` tagged pages
maps/all-university.md      → all `university` tagged pages
```

**Pattern**: Index pages are `kind: map`, grouped by relationship or context. Each entry is a `[[slug|Display Name]]` wikilink. Include a `## Sources` section (even if empty) for schema compliance.

**Batch count**: Check orphan count before and after to measure impact.

### Misplaced index pages

Topic pages with >15 outbound links and <10 prose lines are likely index/map pages. Move them to `maps/` and change `kind: map`. This keeps `topics/` for substantive content and `maps/` for navigation.

**Also**: When moving files, update `kind` in frontmatter. Slug stays the same so existing wikilinks don't break.

## Merging Duplicate Pages

When two files represent the same entity (same person/project/place), merge into one canonical file and delete the other.

### Merge Workflow

1. **Read both files fully** — compare line by line.
2. **Identify the richer page** — more content, more history, better structured. This becomes the base.
3. **Diff unique content** — what does the shorter file have that the longer one doesn't? (IDs, emails, aliases, notes, timeline entries)
4. **Write merged file** — start from the richer page, insert unique items from the shorter file into appropriate sections. Use `write_file` to overwrite the canonical file entirely.
5. **Verify no data loss** — re-read the merged file and confirm every unique item from both originals is present.
6. **Delete the duplicate** — `rm` the non-canonical file.

### Pitfalls

- **git checkout confusion**: After reverting changes, tracked vs untracked file status may swap. Always check `git ls-files` to know which file is tracked before deciding which to keep as canonical.
- **Frontmatter conflicts**: Use the more complete frontmatter (better aliases, relationships, status). If aliases differ, union them — deduplicate only exact matches.
- **Sources sections**: Merge source references from both files. Deduplicate identical entries.
- **Commit the merge**: `git add` the modified canonical file + `git rm` the deleted duplicate.

### Output Format

After merge, report what was kept vs discarded:
```
Merged: li-si.md (kept)
Deleted: li-si.md
Unique items merged: ID number, 2 emails, WeChat ID
```

---

### 5. Tag Audit

- Count tag distribution
- Flag tags not in the taxonomy list (see below)
- Verify layer tags match kind field
- If an unfamiliar tag appears, report it — do NOT auto-delete, ask user

## Resolving Orphan Pages via Tag Index Maps

When many orphan pages share a tag, create a tag index page in `maps/` to link them all at once. This is faster and more maintainable than adding inline links one by one.

### Workflow

1. **List orphans by tag**: Build inbound link index, find pages with 0 inbound links, group by their tags.
2. **Create index pages**: One per tag group (e.g., `maps/all-family.md`, `maps/all-teacher.md`, `maps/all-university.md`).
3. **Format**: `kind: map` in frontmatter. Body groups entries by sub-category with `[[slug|Display Name]]` links. Include relationship or context annotations.
4. **Verify**: Re-scan inbound links to confirm all previously orphaned pages now have ≥1 inbound link.

### File path pitfall

Index pages go under `wiki/maps/`, not `maps/`. If using `write_file`, the path must include the full `wiki/` prefix (e.g., `{{vault_root}}/wiki/maps/all-family.md`).

### Example structure

```yaml
---
layer: wiki
kind: map
tags: [map]
status: active
---

# Family Index

An index of family members.

## Paternal
- [[zhang-san|张三]] — father

## Maternal
- [[li-si|李四]] — mother
```

### What counts as "compiled truth"

A tag index page IS a compiled truth: it compiles scattered individual pages into a browsable, grouped overview. The index page itself becomes the canonical reference for "all X in the vault."

## Fixing ## Related Sections

For pages with `## Related`:
1. Check which linked pages are already mentioned inline in body text
2. If all links already covered → safe to remove the section
3. If some links unique → integrate into body text where entity is naturally mentioned
4. Never leave a `## Related` section

## Fixing inbox/ References in Sources

1. Copy referenced files from `inbox/` to appropriate `sources/` subdirectory
2. Replace `inbox/` paths with `sources/` paths in `## Sources`
3. For social media exports already distilled into wiki → remove the reference line entirely

## Tag Taxonomy (reference)

Layer tags (from kind): `person` | `project` | `place` | `topic` | `concept` | `map`
Domain tags: broad domains relevant to the wiki owner (e.g., `ai`, `media`, `startup`, `writing`)
Context tags: relationship or institutional context (e.g., `family`, `teacher`, `school`)

Do NOT use: tech stack tags, one-off tags, page-name-as-tag.
If an unfamiliar tag appears, report it — do NOT auto-delete.

## Slug Rules

- **Chinese person**: surname-givenname pinyin, each syllable hyphenated (`zhang-san`, `li-si`)
- **Non-Chinese person**: English legal name (`jane-doe`, `john-smith`)
- Flag during audit if slug doesn't match these patterns

## Output

Generate a categorized report:
1. Batch-fix items (safe to auto-apply)
2. Manual review items (need judgment)
3. Structural proposals (bloated pages, missing pages)
4. Tag distribution summary

After fixes, update `system/wiki/index.md` and commit.

### Status Cleanup

Schema defines only two status values: `draft` (stub, no content) and `active` (has substantive content). If pages have non-standard values (`unknown`, `inactive`, `archived`, etc.), batch-fix:

- Body lines > 5 → `active`
- Body lines ≤ 5 → `draft`

Use sed or a Python script to replace. Always re-read the file after to verify YAML validity.
