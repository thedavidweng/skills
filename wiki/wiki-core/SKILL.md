---
name: wiki-core
description: 'Build a personal knowledge wiki from notes and messages. Triggers on ''wiki'', ''knowledge base'', ''compile notes'', or ''build wiki''.'
---

LLM-maintained markdown wiki compiling sources into canonical pages. Layers: `sources/` (immutable evidence) → `wiki/` (people, projects, places, concepts, topics, maps, periods) → `system/` (schema, index, log, workflows — you maintain these).

New session: read `schema.md`, `index.md`, recent `log.md` entries first. The repo wins over this skill when they disagree.

**Ingest** (mechanical, idempotent script): one file per entry, `{date}-{slug}.md` (dated) or `{slug}.md`, ASCII slugs. Sources live under `sources/` by kind: journal, meetings, docs, web, notes-import, chats, identity, flights, media, courses. Never edit after import — corrections go under `## Agent Notes`. Never link `inbox/`. Re-ingest protection: sha256 over the body, skip if identical, flag drift. Excel dates are serial days from 1899-12-30; `sharedStrings` may be absent.

**Absorb** (default: last 30 days): match index → create/update targeted articles → inline `[[wikilinks]]`. New page needs multiple sources or one central source, enough for a substantive article. Anti-Cramming (a sub-topic outgrowing its section → extract), Anti-Thinning (no stubs), Anti-Aggregation (enrich existing pages; new pages only for independent identities). Conflicts: note both sides with dates, `contested: true`, surface in lint — never silently overwrite. Chat logs: a substantial thread to mine, batch-confirm unconfirmed contacts in ONE round, skip intimate-unverified. macOS APFS: rename via intermediate name first.

**Query:** index → backlinks → a handful of articles → synthesize with citations, following links as needed. Quote sparingly. Read-only.

Frontmatter — sources: `layer: source`, `kind` (journal|meeting|document|article|import|clip|media|chat), `created`/`updated`, `source_type`, `source_uri`, body `sha256`, `tags`. Pages: `layer: wiki`, `kind`, `updated`, `aliases` (real names only), `tags`, `status: draft|active`, optional `confidence` (high|medium|low), `contested` + `contradictions[]`. Slugs: ASCII; Chinese persons hyphenated pinyin; H1 may mix languages.

**Lint:** orphans → tag-grouped `maps/` indexes; broken links (stem resolution first); merge duplicates into the richer page; split stubs from bloated pages; unreferenced sources triaged largest-first. Periodically: zero new articles means you're cramming; rewrite event-log prose in the most-updated. Rebuild index; rotate the log as it grows.

Linking rules: see `wiki-linking`. Tone: flat and factual. Session conventions go into `schema.md` immediately.
