---
name: wiki-inline-link-audit
description: 'USE THIS SKILL whenever the user wants to: add wikilinks to unlinked
  mentions, improve graph connectivity, clean up Related sections, or cross-reference
  pages in a markdown vault. Triggers on ''link mentions'', ''inline links'', ''connect
  pages'', or ''wiki linking''.'
---

# Wiki Inline Link Audit

## Purpose

Find terms in wiki page body text that reference other wiki pages but aren't wikilinked. Goal: Wikipedia-style inline linking where entities are naturally linked when mentioned in flowing text — not backlink sections at the bottom.

## When to Use

- After bulk imports of new wiki pages (people, projects, places)
- Periodically as wiki grows and new cross-references emerge
- When user wants to improve graph connectivity

## Steps

### 1. Build Term Index

```python
# For each wiki page, collect: slug -> {title, aliases, kind}
# Build term_to_slug: lowercase(term) -> slug for all titles + aliases
# Exclude course pages from auto-link targets if user has course indexes
```

**Course pages exclusion**: If the wiki has course-type pages (slugs matching faculty-course-number patterns like `asia-101`, `cpsc-110`), exclude them from auto-link targets. User likely wants faculty-level index pages instead of linking to individual courses. See "Course Index Pages" below.

**Process longest terms first**: Sort term_to_slug by term length descending. This prevents shorter substrings from being linked before longer complete phrases (e.g., "Jane Smith" should match before "Jane").

### 2. Scan Body Text

For each page, extract body (strip frontmatter `---...---`) and find paragraphs of flowing text. Exclude:
- Lines starting with `#`, `|`, `- `, `* `, `>`, ``  ``
- Numbered list lines (`1.`)
- Content inside existing `[[wikilinks]]` (check unclosed `[[` before match position)
- Heading lines
- `## Sources` section content

### 3. Match Terms

- Chinese terms: exact character match (no word boundaries)
- English terms: `\b` word boundary match, case-insensitive
- Skip: own page (don't self-link), terms < 3 chars, generic/common terms

**Generic terms to exclude** (too vague to link):
```
history, professional, academic, education, student, production, media, digital,
community, design, content, analysis, technology, science, management, development,
research, network, project, study, learning, writing, creative, art, film, video,
culture, language, introduction, foundation, modern, contemporary, critical, early,
global, information, society, family, environmental, geography, music, economics,
politics, singing, photography, cinema, horror, fiction, visualization, policy,
meteorology, anatomy, physiology, chemistry, program, interactive, storytelling,
audiences, industries, religions, thought, approaches, career, applied, systematic,
methods, networks, crowds, communities, arts, visual, second language, english,
new media, human, cap, seminar
```

### 4. Categorize Results

- **Batch-fix patterns**: Large groups of pages with identical unlinked terms (e.g., 100+ person pages all missing `[[wenzhou-no22-high-school]]`). Safe to auto-fix.
- **High-value inline links**: Key pages (projects, places, prominent people) with specific unlinked concepts. Review before fixing.
- **Exclusions**: Course pages linking to each other may need index pages instead. Skip auto-linking course-to-course.

### 5. Apply Fixes

Replace `term` with `[[target-slug|term]]` in body text. Use `|display` form to preserve original text.

**Precautions**:
- Process matches from end to start (preserves positions)
- **Critical — prevent split links**: When a longer match exists (e.g., "Jane Smith" matches `jane-smith`), skip shorter substrings ("Jane", "Smith") at the same position. After batch fix, scan for `[[slug|X]] [[slug|Y]]` patterns and merge to `[[slug|X Y]]`.
- Deduplicate: same (target, term) per page only once
- Chinese text before `[[` without space is correct (中文不需要空格)
- Same link appearing twice in one paragraph is fine if different context

## Pitfalls

- **Split links (critical)**: If "Jane" and "Smith" are both indexed as terms for `jane-smith`, the script may link them separately creating `[[jane-smith|Jane]] [[jane-smith|Smith]]`. Fix: when processing, skip shorter terms that are substrings of already-matched longer terms at the same position. Always run a post-fix scan: `r'\[\[([^|]+)\|([^]]+)\]\]\s*\[\[\1\|([^]]+)\]\]'` and merge to `[[slug|X Y]]`. In practice this appeared in 4 files after a 189-file batch fix.
- **Student roster space bug**: When programmatically inserting `[[slug|display]]` into table cells, trailing spaces end up inside brackets (`[[slug |display]]` or `[[slug|display ]]`). These render correctly in Obsidian but are broken links in the graph. After batch linking tables, always scan and fix: `re.sub(r'\[\[([^\]|]+?)\s+(\|[^\]]+?)?\]\]', lambda m: f'[[{m.group(1)}{m.group(2) or ""}]]', content)`. In one case this caused 109 broken links from a single roster file.
- **Surname columns in tables**: When linking names in rosters/databases, link only name columns (中文名, English). Do NOT link 姓/名 (surname/given name) columns — common surnames like Yang, Wu, Chen will match the wrong person. After initial linking, unlink these columns: `re.sub(r'\[\[([^\]|]+\|)?([^\]]+)\]\]', r'\2', cell)`.
- **Generic terms**: "history", "film", "media" etc. will match tons of false positives. Always maintain and expand the exclusion set.
- **Course pages**: Don't auto-link course names to individual courses. Create faculty/institution index pages and link there instead.
- **Table content**: Skip table rows (`|` lines) — tables are structured data, not flowing prose.
- **Aliases are broad**: Some aliases are very short or common. Filter carefully.
- **Sandbox privacy masking**: When running in sandboxed environments, phone numbers and other PII may be displayed with `****` masking. The actual file content may be correct — verify with `xxd` or `hex()` before assuming data is corrupted. The sandbox masks DISPLAY only, not file content.

## Tag Standardization

After wiki grows, tag sprawl is common (30+ unique tags). Standardize to a two-layer system.

### Layer Tags (from `kind`)
Map directly to page type: `person` | `project` | `place` | `topic` | `concept` | `map`

### Domain Tags (optional, 0-2 per page)
Broad domains relevant to the wiki owner: e.g., `ai` | `media` | `startup` | `transit` | `writing`

### Tags to Remove or Merge
- Tech stack tags (`tauri`, `rust`, `nextjs`, `react-native`, `supabase`) — belong in article body
- Redundant name tags (`owonetwork`, `citang`) — page title already identifies the entity
- One-off tags (`maintenance`, `index`, `social-circle`) — not useful for filtering
- Merge close variants: `school` → `school`, `media-studies` → `media`, `token-tracking` → `ai`
- Fix quote inconsistencies: `'person'` → `person`

### Implementation
Build tag map (old → new), apply via regex on frontmatter `tags:` line. Document the taxonomy in `system/wiki/schema.md` so future agents follow it.

## Stub Page Index

When many pages are stubs (< 10 body lines), maintain a `topics/stub-index.md` listing them with title, kind, and line count. Group by kind. This serves as a task list for future enrichment and cross-reference point when new inbox imports arrive.

## Schema Persistence

Conventions discovered during wiki work MUST be written into `system/wiki/schema.md` and `system/wiki/workflows.md`. Other agents and future sessions won't know about session-only decisions. If you discover a new convention (e.g., "no `## Related` sections"), immediately add it to schema.md. Otherwise the next agent will reintroduce the pattern you just removed.

## Removing `## Related` Sections

When the wiki has `## Related` sections at the bottom of pages (a list of wikilinks), these should be removed once inline links are in place — Wikipedia doesn't have a "related pages" section; links are woven into body text.

### Strategy

1. **Categorize Related sections by pattern** before removing:
   - Count how many links in Related are already covered in body text
   - Pages where ALL Related links are in body → safe to batch-remove
   - Pages with uncovered links → need manual integration first
   - Common patterns: person-page-only (45 pages), two-links (123 pages), multi-links (15 pages)

2. **Batch removal**: For pages where all Related links are already covered in body, remove `## Related\n...\n` block directly. Clean up triple newlines.

3. **Manual integration**: For uncovered links, add them naturally to body text before removing the section.

4. **Verify**: After removal, confirm zero `## Related` sections remain.

## Encyclopedic Wiki Review Checklist

When reviewing a wiki from an encyclopedia perspective:

1. **Inline linking**: Are entities linked when naturally mentioned in body text?
2. **No backlink sections**: `## Related` sections should not exist; links should be inline.
3. **Orphan pages**: Pages with zero inbound links (excluding maps/hubs). For person pages, check if they should link to each other or be linked from hub pages.
4. **Broken links**: `[[links]]` pointing to non-existent pages. Check for trailing spaces inside brackets (`[[slug ]]`).
5. **Stub pages**: Pages with < 10 body lines. Maintain a `stub-index.md` for tracking.
6. **Bloated pages**: Pages > 150 lines that should be split (by topic, not by time period).
7. **Isolated pages**: Pages with zero inbound AND zero outbound links — enrich and link from related pages.
8. **Missing Sources**: Core pages lacking `## Sources` section. Course index pages are exempt.
9. **Tag distribution**: Tags should have a defined taxonomy (see schema.md). One-off tags and tech stack tags should be removed.
10. **Date-based headings**: Sections named by date (`## 2024-01`) indicate chronological structure instead of thematic. Rewrite.
11. **WeChat nicknames in aliases**: Scan for emoji in aliases, parenthetical nicknames in H1, known nickname patterns.
12. **Inbox references in Sources**: No `inbox/` paths should appear in `## Sources` sections.

## Collapsible Callouts for Long Data

When a page has long data tables (email lists, phone numbers, credentials), wrap them in Obsidian collapsible callouts instead of leaving them as open tables:

```markdown
> [!info]- All emails (21)
> | Address | Purpose |
> |---------|---------|
> | ...     | ...     |
```

## Duplicate Page Merging

When the same entity exists as multiple pages (e.g., `projects/bc-ai-ecosystem.md` AND `topics/bc-ai-ecosystem.md`):
1. Identify which version is richer (more lines, more content)
2. Merge unique content from the other version (aliases, sources, descriptions)
3. Keep the richer version, update its `kind` and `tags` if needed
4. Delete the duplicate file
5. Verify: no broken links (slug is the same, so existing links still resolve)

## WeChat Nickname Convention

Social media nicknames (微信昵称, Instagram handles, etc.) must NOT go in:
- `aliases:` in frontmatter
- H1 page title (no parentheses with nickname)

Nicknames belong in body text under Contact or personal info section:
```markdown
# wang-wu

某中学同学。社交昵称"Dreamer"。
```

NOT:
```markdown
# wang-wu (社交昵称)   ← WRONG
aliases: ['wang-wu', '社交昵称']  ← WRONG
```

Aliases are for real name variants and common transliterations only (e.g., "James" for James Doe, "Alex" for Alex Lee).

When auditing person pages, scan for:
- Parentheses in H1 containing non-real-name text
- Aliases containing emoji (🐼, 🤫, 🦠, 💕)
- Aliases matching known nickname patterns (cute phrases, handles, WeChat-style names)

## Inbox Reference Rule

`## Sources` sections must NEVER reference `inbox/` paths. Inbox is a temporary staging area — all content is deleted after distillation into `sources/` and `wiki/`.

When importing data, copy raw files to `sources/` first, then reference `sources/` paths in wiki Sources sections. Common migrations:
- `inbox/identity/contacts.vcf` → `sources/identity/contacts.vcf`
- `inbox/Whatsapp/*.txt` → `sources/chats/*.txt`
- `inbox/facebook-*` → already absorbed into wiki, remove reference

## Course Index Pages

When the wiki has many course-type pages, don't link to individual courses from other pages. Instead create a hierarchy:

```
courses.md (总索引)
├── courses-university.md (university courses, grouped by Faculty)
│   ├── ASIA (9 courses)
│   ├── CHIN (4 courses)
│   └── ...
└── courses-school.md (school courses, grouped by type)
    ├── BC 省课程
    └── 中方课程
```

Each course page links to its faculty/institution index in `## 相关链接`. Other pages (people, projects) link to the index page, not individual courses.

## Flighty CSV Import

When importing Flighty flight export CSV:

1. Save raw CSV to `sources/flights/` with date slug
2. Parse CSV: extract Date, Airline, Flight number, From, To, Aircraft, Seat, Notes
3. Create a source-layer summary page with a flight table and airport code to city mapping
4. Create/update a `wiki/topics/transportation.md` page with stats (total flights, common routes, cities visited)
5. Add/update the Travel section on the person page (`some-person.md`) with city list linking to existing place pages
6. Register new pages in `system/wiki/index.md`

Airport codes should link to place pages where they exist (e.g., `[[vancouver|Vancouver]]` for YVR). Cities without place pages remain plain text.

## Schema Write Discipline

When you discover a new convention during wiki work (e.g., "no `## Related` sections", "WeChat nicknames not in aliases", "no `inbox/` in Sources"), write it into `system/wiki/schema.md` or `system/wiki/workflows.md` immediately, in the same session. Do not defer. Other agents and future sessions have no memory of session-only decisions. A convention not written down will be violated by the next agent.
