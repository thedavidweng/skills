---
name: wiki-core
description: 'USE THIS SKILL whenever the user wants to: build a personal knowledge
  wiki, ingest data into a wiki, compile notes into articles, query a knowledge base,
  or clean up wiki content. Triggers on ''wiki'', ''personal wiki'', ''knowledge base'',
  ''compile notes'', or ''build wiki''.'
---

# Personal Knowledge Wiki

Inspired by [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f): a persistent, compounding knowledge base maintained by an LLM. Instead of re-discovering knowledge from raw documents on every query, the LLM incrementally compiles source material into a structured, interlinked markdown wiki at ingest time.

> "The key difference: the wiki is a persistent, compounding artifact. Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase."

You are a **writer** compiling this wiki from personal data. Not a filing clerk. A writer. Your job is to read entries, understand what they mean, and write articles that capture understanding. The wiki is a map of a mind.

The question is never "where do I put this fact?" It is: **"what does this mean, and how does it connect to what I already know?"**

---

## Three-Layer Architecture

| Layer | Directory | Purpose | Agent writes? |
|-------|-----------|---------|---------------|
| **Source** | `sources/` | Immutable raw evidence | No (append/import only) |
| **Wiki** | `wiki/` | Canonical compiled knowledge | Yes (actively maintained) |
| **System** | `system/` | Rules, indexes, schemas | Yes |

The human curates sources and directs analysis. The LLM performs all bookkeeping — summarizing, cross-referencing, updating entity pages, and maintaining consistency.

---

## Directory Structure

```
vault/
  inbox/                  # Temporary staging area (DO NOT LINK FROM SOURCES)
  sources/                # Immutable raw evidence
    journal/              # Daily notes, personal logs
    meetings/             # Meeting notes, conversations
    docs/                 # OCR'd documents, PDFs, reports
    web/                  # Clipped articles, saved web content
    notes-import/         # Apple Notes, Obsidian imports, legacy captures
    chats/                # Chat exports (WeChat, WhatsApp, iMessage)
    identity/             # Passport scans, ID cards, work permits
    flights/              # Flight exports, travel records
    media/                # Media-related notes
    courses/              # Course materials, syllabi
  wiki/                   # The compiled knowledge base
    people/               # Named individuals
    projects/             # Things built with serious commitment
    places/               # Meaningful locations
    concepts/             # Beliefs, patterns, frameworks, recurring themes
    topics/               # External subjects studied deeply
    maps/                 # Domain hub/index pages
    periods/              # Major biographical phases
  system/
    wiki/
      schema.md           # Linking rules, tag taxonomy, article format
      index.md            # Catalog of all pages with one-line summaries
      log.md              # Append-only ingest/absorb/query history
      workflows.md        # Exact procedures for ingest, absorb, query, lint
```

---

## Session Orientation

Before touching any wiki file in a new session, orient yourself:

1. Read `system/wiki/schema.md` — understand current conventions and tag taxonomy.
2. Read `system/wiki/index.md` — learn what pages exist and their summaries.
3. Scan the last 20-30 entries of `system/wiki/log.md` — understand recent activity.

Only after orientation should you ingest, absorb, query, or lint. This prevents duplicate pages, missed cross-references, and contradictions against established conventions.

For large wikis (100+ pages), also `search_files` for the topic at hand before creating anything new.

---

## Source Notes (`sources/`)

Raw evidence. The agent reads but never rewrites after initial import.

### Frontmatter

```yaml
---
layer: source
kind: journal | meeting | document | article | import | clip | media | chat
created: YYYY-MM-DD
updated: YYYY-MM-DD
source_type: obsidian-daily | apple-notes | notion | web-clip | ocr | manual | export
source_uri: ""  # original path or URL if known
sha256: <hex digest of body below frontmatter>  # detects drift on re-ingest
tags: []
---
```

### Naming

- `{date}-{slug}.md` for dated material (e.g., `2023-11-14-daily.md`)
- `{slug}.md` for undated imports (e.g., `kinship-dynamics.md`)
- Use English ASCII slugs only.

### Rules

- Never modify a source file after import.
- If a source needs correction, add a note at the bottom under `## Agent Notes` instead of editing.
- **Never link to `inbox/` from `## Sources`.** Inbox is temporary — all content is deleted after distillation into `sources/` and `wiki/`. Sources must reference `sources/` paths only.
- **Re-ingest protection:** On re-ingest of the same `source_uri`, recompute the sha256 over the body. Skip processing if identical; flag drift and append an `## Agent Notes` entry if the content has changed. This catches silent edits in exported data.

---

## Command: `/wiki ingest`

Convert source data into source notes under `sources/`. Write a Python script `ingest.py` to do this. This step is mechanical, no LLM intelligence needed.

### Supported Data Formats

Auto-detect and extract: date, title, body, tags, media. Common formats:
Day One JSON, Apple Notes, Obsidian Vault, Notion Export, Chat Exports, CSV/Spreadsheet, Email Export, VCF Contacts, Twitter/X Archive.

*(See `references/data-formats.md` for detailed extraction rules)*
### Unknown Formats

If the data doesn't match any known format, read a sample, figure out the structure, and write a custom parser. The goal is always the same: one markdown file per logical entry with date and metadata in frontmatter.

### Output Format

Each file: `{date}_{id}.md` with YAML frontmatter (`id`, `date`, `time`, `source_type`, `tags`). The script must be **idempotent**.

---

## Command: `/wiki absorb [date-range]`

The core compilation step. Date ranges: `last 30 days`, `2026-03`, `2026-03-22`, `2024`, `all`. Default (no argument): absorb last 30 days. If source notes don't exist, run ingest first.

### The Absorption Loop

Process entries chronologically. Read `system/wiki/index.md` before each entry to match against existing articles. Re-read every article before updating.

For each entry:
1. **Read** the entry (text, metadata, attached photos).
2. **Understand** what it means — not just facts, but significance.
3. **Match** against the index. What articles does this touch? What suggests a new article?
4. **Update/create articles.** Re-read before updating. Ask: "what new dimension does this entry add?" Integrate so the article reads as a coherent whole. Never just append.
5. **Connect to patterns.** Themes across entries deserve concept articles.
### What Becomes an Article

**Named things get pages** if there's enough material. A person mentioned once in passing doesn't need a stub. A person who appears across **2 or more sources** with a distinct role does. If you can't write at least 3 meaningful sentences, don't create the page yet. Note it in the article where they appear, and create the page when more material arrives.

Single-source mentions that are central to that source (e.g., a whole meeting about one project) may also qualify. Passing footnotes do not.

**Patterns and themes get pages.** When you notice the same idea surfacing across entries (a creative philosophy, a recurring emotional arc, a search pattern, a learning style) that's a concept article. These are often the most valuable articles in the wiki.

### Anti-Cramming

The gravitational pull of existing articles is the enemy. It's always easier to append a paragraph to a big article than to create a new one. This produces 5 bloated articles instead of 30 focused ones.

If you're adding a third paragraph about a sub-topic to an existing article, that sub-topic probably deserves its own page.

### Anti-Thinning

Creating a page is not the win. Enriching it is. A stub with 3 vague sentences when 4 other entries also mentioned that topic is a failure. Every time you touch a page, it should get richer.

### Update Policy

When new information conflicts with existing content:

1. **Check dates** — newer sources generally supersede older ones, but do not blindly overwrite.
2. **Note both positions** with their dates and source references in the article body.
3. **Mark the contradiction** in frontmatter: set `contested: true` and add the conflicting page/article slug to `contradictions: []`.
4. **Flag for review** — surface contested pages in the next lint report so the human can resolve.

Never silently overwrite. Contradictions between a diary entry and a chat log are common and deserve explicit handling, not burial.

### Every 15 Entries: Checkpoint

Stop and:
1. Rebuild `system/wiki/index.md`
2. **Audit new articles:** If zero new articles in the last 15, you're cramming.
3. **Quality audit:** Re-read your 3 most-updated articles. Check: coherent story (not chronological dump)? Theme-based sections? Direct quotes? Revealing connections? Non-obvious insights? Rewrite any that read like event logs.
4. Check if any articles exceed 150 lines and should be split.
5. Check directory structure; create new directories when needed.
## Wiki Pages (`wiki/`)

Canonical knowledge. The agent actively maintains these.

### Frontmatter

```yaml
---
layer: wiki
kind: person | project | place | concept | topic | map | period
updated: YYYY-MM-DD
aliases: []
tags: []
status: draft | active
confidence: high | medium | low        # optional. high = multi-source verified; medium = single source or inferred; low = hearsay
contested: false                       # set true when sources contradict
contradictions: []                     # slugs of conflicting pages
---
```

### Status

- `draft` — Stub page. Has a title and minimal frontmatter but little to no body content. Targets for future enrichment.
- `active` — Page has substantive content. Ready for ongoing maintenance.

### Page Types

| Kind | Directory | What goes here |
|------|-----------|---------------|
| person | `people/` | Named individuals, including self |
| project | `projects/` | Things built with serious commitment |
| place | `places/` | Meaningful locations |
| concept | `concepts/` | Beliefs, patterns, frameworks, recurring themes |
| topic | `topics/` | External subjects studied deeply |
| map | `maps/` | Domain hub/index pages |
| period | `periods/` | Major biographical phases |

### Naming

- English ASCII slugs only.
- **Chinese person slugs**: surname-givenname1-givenname2, each pinyin syllable hyphenated. E.g., 张三 → `zhang-san`, 李四光 → `li-si-guang`.
- **Multi-reading corrections**: Some characters have non-obvious pinyin readings. Check actual readings, don't trust pypinyin blindly.
- **Non-Chinese person slugs**: English legal name. E.g., `jane-doe`, `john-smith`.
- H1 page title can be Chinese, English, or mixed.
- Bilingual H1 format: `中文名 / English` (Chinese first, English nickname second, slash separator). For Westerners: `English Surname / 中文名`.
- One canonical subject = one canonical path. Aliases in frontmatter only.
- **Do not put social media nicknames in aliases.** Nicknames (微信昵称, Instagram handles, etc.) go in the body under Contact or personal info. Aliases are for real name variants and common transliterations only.

### Map Pages

Index pages for domains. Example structure:

```markdown
---
layer: wiki
kind: map
tags: [university]
---

# University Classmates

## Overview
Studied Computer Science at Some University (2020-2024).

## People

| Name | Slug | Relationship | Notes |
|------|------|--------------|-------|
| Li Si | [[li-si]] | Classmate, Project Partner | Co-founded Startup X |
```

Map pages are the primary navigation. Every person/project/place should be reachable from at least one map.
### Article Format

```markdown
---
layer: wiki
kind: person | project | place | concept | topic | map | period
updated: YYYY-MM-DD
aliases: []
tags: []
status: draft | active
---

# Title

## Section (theme-based, NOT date-based)
Content with [[wikilinks]] inline.

## Timeline (if relevant)
| Date | Event |
|------|-------|

## Sources
- `[[sources/journal/2024-01-15_daily.md]]` — description of relevance
```

Section titles are thematic (e.g., "Early Life", "Career", "Philosophy"). Never use event dates as section titles.

### Provenance Markers

When a page synthesizes **3 or more sources**, append paragraph-level provenance so claims remain traceable without re-reading entire raw files:

```markdown
张三于 2021 年移居温哥华。^[sources/journal/2021-07-21_landing.md]
```

Use `^[[sources/path.md]]` at the end of a paragraph whose claims come from a specific source. Optional on single-source pages where the `## Sources` section is sufficient.

### Sources Section

Every wiki page must end with a `## Sources` section listing `[[wikilinks]]` to source files. Omit if the page is self-contained.

### Language

Pages may mix Chinese and English. Follow these rules:
- Descriptive/narrative text: Chinese (summaries, chat context, personal life descriptions).
- Proper nouns, role titles, project names, technical terms: keep original (usually English).
- Timeline tables, contact info, certifications: keep original language.

### Rules

- Every page must link laterally to related wiki pages using `[[wikilinks]]`.
- Every page must link to its sources via `[[wikilinks]]` in the `## Sources` section.
- Every major page must be reachable from at least one `maps/` page or `system/wiki/index.md`.
- Organize by theme, not chronology. No diary-driven structure.
- Maximum 2 direct quotes per article.
- Re-read before editing. Never append blindly.

---

## Command: `/wiki query <question>`

Answer questions about the subject's life by navigating the wiki.

### How to Answer

1. **Read `system/wiki/index.md`.** Scan for articles relevant to the query. Each entry has aliases.
2. **Check backlinks** to find articles that reference the topic. High backlink counts indicate central topics.
3. **Read 3-8 relevant articles.** Follow `[[wikilinks]]` 2-3 links deep when relevant.
4. **Synthesize.** Lead with the answer, cite articles by name, use direct quotes sparingly, connect dots across articles, acknowledge gaps.

> Good answers can be filed back into the wiki as new pages. This ensures explorations compound rather than disappearing into chat history.

### Query Patterns

- **Factual**: "What city did Zhang San study in?" → direct answer with sources
- **Synthesis**: "What patterns emerge across my 2024 projects?" → cross-article analysis
- **Relationship**: "How do Li Si and Wang Wu know each other?" → trace through shared pages
- **Temporal**: "What happened between March and June 2023?" → timeline across entries
- **Gap**: "What do I know about X?" → summarize coverage, identify missing sources
### Rules

- Never read raw source notes (`sources/`). The wiki is the knowledge base.
- Don't guess. If the wiki doesn't cover it, say so.
- Don't read the entire wiki. Be surgical.
- Don't modify any wiki files. Query is read-only.

---

## Command: `/wiki cleanup`

Audit and enrich articles via parallel subagents. See `references/cleanup-breakdown.md` for full phase-by-phase workflow.

## Command: `/wiki breakdown`

Find and create missing articles by mining sources for unmapped entities and themes. See `references/cleanup-breakdown.md` for full workflow.
## Command: `/wiki lint`

Periodic maintenance. Check:

**Broken / Orphan**
- Broken wikilinks → fix or create targets
- Orphan pages (zero inbound links) → create `maps/` indexes or add links
- Backlink imbalance → pages that link out but receive no links back

**Completeness**
- Missing sources → add `## Sources` sections
- Index drift → rebuild `system/wiki/index.md`; verify every active page is listed
- Map coverage → every active page reachable from at least one `maps/` page or index

**Quality Signals**
- Frontmatter issues → standardize `layer`, `kind`, `status`; validate `confidence`/`contested` fields present on opinion-heavy pages
- Naming drift → standardize slugs and aliases
- Tag audit → flag tags not in taxonomy; report unfamiliar tags before deleting

**Freshness & Drift**
- Stale content → pages whose `updated` date is >90 days older than the newest source mentioning the same entity
- Source drift → recompute sha256 for each source file; mismatches indicate raw was edited (should not happen) or URL content changed
- Page size → flag pages approaching or exceeding 150 lines; candidates for splitting per Anti-Cramming rule

**Log Hygiene**
- Log rotation → if `system/wiki/log.md` exceeds 500 entries, rename to `log-YYYY.md` and start fresh

## Maintenance Commands

- `/wiki lint` — Periodic audit: orphans, broken links, missing sources, index drift, frontmatter/naming issues.
- `/wiki rebuild-index` — Rebuild `system/wiki/index.md` and update backlinks. **Scaling rules**: when any section exceeds 50 entries, split by first letter or sub-domain; when total exceeds 200 entries, create `_meta/topic-map.md` for theme-based navigation.
- `/wiki status` — Show stats: entries absorbed, articles by category, most-connected articles, orphans, pending entries.

---

## Linking Rules

### Inline Linking (Wikipedia Style)

When a wiki page body text mentions a person, project, place, course, or concept that has its own wiki page, link it inline where it is naturally mentioned:

```
张三在 [[beijing-university|北京大学]] 读书期间加入了 [[open-source-club|开源社]]。
```

NOT in a separate section at the bottom. Follow Wikipedia convention: link the term where it appears in flowing text.

### Prohibited Patterns

- **No `## Related` section.** Do not create a "Related" block at the bottom of a page with a list of wikilinks. If a link is worth having, it belongs in the body text where the entity is mentioned.
- **No "See also" section** (same reason).

### Required Links

- `[[wikilinks]]` between wiki pages — inline, where entities are mentioned in body text.
- `[[wikilinks]]` from wiki pages to sources — in the `## Sources` section only.
- Source notes may link upward to wiki pages when useful.
- Important wiki pages must be reachable from `maps/` or `system/wiki/index.md`.

---

## Tags

Two-layer tag system.

### Layer Tags (from kind, required)

`person` | `project` | `place` | `topic` | `concept` | `map` | `period`

### Domain Tags (optional, 0-2 per page)

Broad domains relevant to the wiki owner: e.g., `ai` | `media` | `startup` | `writing`

### Tags to Remove or Merge

Tech stack tags belong in body text, not tags. Redundant name tags and one-off tags should be removed. Audit rule: report unfamiliar tags before deleting — never auto-delete.

---

## Writing Standards

Load `references/writing-standards.md` before creating or rewriting articles. Core rule: **Wikipedia tone, not AI tone.** Flat, factual, encyclopedic. Every article must have a point. Theme-based sections, not chronological dumps. Max 2 direct quotes.
## Schema Persistence

Conventions discovered during wiki work MUST be written into `system/wiki/schema.md` and `system/wiki/workflows.md`. Other agents and future sessions won't know about session-only decisions. If you discover a new convention (e.g., "no `## Related` sections"), immediately add it to schema.md. Otherwise the next agent will reintroduce the pattern you just removed.

---

## Principles

- **The wiki is the memory.** Sources are raw; the wiki is canonical.
- **Never silently delete.** Deprecate with redirects and notes.
- **Prefer links over lists.** A linked mention > a list entry.
- **Sources are append-only.** Never edit a source after import.
- **The LLM is the writer.** The human curates; the agent writes.
- **Understanding over filing.** Ask "what does this mean?" not "where does this go?"
