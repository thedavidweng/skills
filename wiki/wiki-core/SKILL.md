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

---

## Command: `/wiki ingest`

Convert source data into source notes under `sources/`. Write a Python script `ingest.py` to do this. This step is mechanical, no LLM intelligence needed.

### Supported Data Formats

Auto-detect and extract: date, title, body, tags, media. Common formats:
- **Day One JSON**: `entries` array → date, location, weather, text, media
- **Apple Notes**: `.html/.txt/.md` → title, date, folder, body
- **Obsidian Vault**: `.md` → preserve frontmatter, convert `[[wikilinks]]` to plain text
- **Notion Export**: `.md/.csv` → title, properties, body, flatten nested pages
- **Chat Exports**: group by conversation+date, extract participants
- **CSV/Spreadsheet**: each row → entry, auto-detect date/content columns
- **Email Export**: `.mbox`/`.eml` → date, from, to, subject, body (strip signatures)
- **VCF Contacts**: name, phone, email, address, birthday, org, notes
- **Twitter/X Archive**: date, text, media URLs, reply context

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

**Named things get pages** if there's enough material. A person mentioned once in passing doesn't need a stub. A person who appears across multiple entries with a distinct role does. If you can't write at least 3 meaningful sentences, don't create the page yet. Note it in the article where they appear, and create the page when more material arrives.

**Patterns and themes get pages.** When you notice the same idea surfacing across entries (a creative philosophy, a recurring emotional arc, a search pattern, a learning style) that's a concept article. These are often the most valuable articles in the wiki.

### Anti-Cramming

The gravitational pull of existing articles is the enemy. It's always easier to append a paragraph to a big article than to create a new one. This produces 5 bloated articles instead of 30 focused ones.

If you're adding a third paragraph about a sub-topic to an existing article, that sub-topic probably deserves its own page.

### Anti-Thinning

Creating a page is not the win. Enriching it is. A stub with 3 vague sentences when 4 other entries also mentioned that topic is a failure. Every time you touch a page, it should get richer.

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

Audit and enrich every article in the wiki using parallel subagents.

### Phase 1: Build Context

Read `system/wiki/index.md`, `maps/`, and sample 10 source notes. Identify: broken links, orphan pages, missing sources, index drift, naming inconsistencies.
### Phase 2: Per-Article Subagents

For each article that needs work, spawn a subagent with full context (article + linked sources + related pages). Subagent tasks:
- Rewrite weak sections
- Add missing links and sources
- Split oversized articles
- Merge duplicate pages
- Create new pages for themes that emerged

### Phase 3: Integration

After subagents finish, verify: all links resolve, index is accurate, no duplicate pages, maps cover all active articles.

## Command: `/wiki breakdown`

Find and create missing articles. Expands the wiki by identifying concrete entities and themes that deserve their own pages.

### Phase 1: Survey

Read `system/wiki/index.md` and all `maps/` pages. Understand current coverage. Identify gaps: what topics are missing? What articles are stubs? What relationships are unmapped?
### Phase 2: Mining

Read source notes in the scope. For each entry, extract:
- Named entities (people, places, projects, organizations)
- Themes and patterns (recurring ideas, emotional arcs, decisions)
- Temporal markers (dates, sequences, phases)
- Relationships (who introduced whom, collaborations, conflicts)
- Source quality (verified vs. inferred vs. hearsay)

Build a running list: entities, themes, and source references.
### Phase 3: Planning

For each theme: what articles exist? What should exist? What merges/splits? Plan article structure before writing.
### Phase 4: Creation

Write new articles and update existing ones. Every article should connect to at least 3 others. Every claim should cite a source.
### Reclassification

After creation, audit page types. A person page that became mostly about a project may need splitting. A concept that grew into a full project needs reclassification.
## Command: `/wiki lint`

Periodic maintenance. Check:
- Orphan pages (no inbound links) → create `maps/` indexes or add links
- Broken wikilinks → fix or create targets
- Missing sources → add `## Sources` sections
- Index drift → rebuild `system/wiki/index.md`
- Frontmatter issues → standardize `layer`, `kind`, `status`
- Naming drift → standardize slugs and aliases

## Maintenance Commands

- `/wiki lint` — Periodic audit: orphans, broken links, missing sources, index drift, frontmatter/naming issues.
- `/wiki rebuild-index` — Rebuild `system/wiki/index.md` and update backlinks.
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

- Tech stack tags (`tauri`, `rust`, `nextjs`) — belong in article body
- Redundant name tags — page title already identifies the entity
- One-off tags — not useful for filtering

**Audit rule**: Tags not in taxonomy can be removed, but must ask the user first — never auto-delete. Report unfamiliar tags and wait for confirmation.

---

## Writing Standards

### The Golden Rule

**This is not Wikipedia about the thing. This is about the thing's role in the subject's life.**

A page about a book isn't a book review. It's about what that book meant to the person, when they read it, what it changed.

### Tone: Wikipedia, Not AI

Flat, factual, encyclopedic. State what happened. Direct quotes carry emotional weight; the article stays neutral.

**Never use:** em dashes, peacock words ("legendary", "visionary"), editorial voice ("interestingly"), rhetorical questions, progressive narrative ("would go on to"), qualifiers ("genuine", "profound").

**Do:** lead with subject, one claim per sentence, simple past/present tense, attribution over assertion ("He described it as energizing"), dates over adjectives.
### Narrative Coherence

Every article must have a point. Not "here are 4 times X appeared" but "X represented Y in the subject's life." A reader should finish feeling they understand the significance.

### Structure by Type

- **Person**: lead with identity and role, then relationships, then narrative by life phase. Use timeline for chronology.
- **Project**: problem → approach → execution → outcome → lessons. What changed because of this?
- **Place**: what happened here, not what it is. The place is a container for events and relationships.
- **Concept**: origin → development → current form → connections to other concepts. Where did this idea come from?
- **Topic**: external subject. Treat like a mini-Wikipedia article but with personal relevance.
- **Period**: major life phase. Organize by theme, not chronology.
### Quote Discipline

Maximum 2 direct quotes per article. Pick the line that hits hardest.

### Length Targets

| Page Type | Target | Minimum |
|-----------|--------|---------|
| Person / Project / Place / Period | 300-500 words | 150 words |
| Concept / Topic | 200-400 words | 100 words |
| Map page | 100-200 words | 50 words |
| Source note | No target | As needed |

Use judgment: sparse data → short page; major project → long page.
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
