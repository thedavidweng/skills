---
name: wiki-core
description: 'Builds, audits, and maintains a personal markdown wiki: ingest, absorb, query, lint. Use when the user works on their knowledge wiki or asks for a wiki audit.'
---

Layers: `sources/` (immutable evidence) → `wiki/` (people, projects, places, concepts, topics, maps, periods) → `system/` (schema, index, log, workflows; you maintain these). Each session, read `schema.md`, `index.md`, and recent `log.md` first. The repo wins over this skill.

**Ingest** (idempotent script): one file per entry, `{date}-{slug}.md` or `{slug}.md`, ASCII slugs, under `sources/<kind>/`. Never edit after import; corrections go under `## Agent Notes`. sha256 over the body: skip if identical, flag drift. Excel dates are serial days from 1899-12-30; `sharedStrings` may be absent.

**Absorb** (default: last 30 days): match the index → update or create articles → inline `[[wikilinks]]`. A new page needs several sources or one central source. Extract a sub-topic that outgrows its section; no stubs; enrich existing pages, new pages only for independent identities. Conflicts: record both sides with dates, `contested: true`, never silently overwrite. Chat logs: confirm unknown contacts in one batch, skip intimate unverified material. macOS APFS case-only renames go through an intermediate name.

**Query:** index → backlinks → a few articles → answer with citations. Read-only.

**Frontmatter.** Sources: `layer: source`, `kind`, `created`/`updated`, `source_type`, `source_uri`, `sha256`, `tags`. Pages: `layer: wiki`, `kind`, `updated`, `aliases` (real names only), `tags`, `status: draft|active`, optional `confidence`, `contested` + `contradictions[]`. Chinese person slugs: hyphenated pinyin.

**Lint / audit** (commit after fixes): build a per-page table (slug, H1, kind, aliases, tags, lines, links in/out), then fix:
- orphans → tag-grouped `maps/all-<tag>.md`; broken links (resolve bare slugs by filename stem first)
- duplicates → merge into the richer page and `git rm` the other; split stubs off bloated pages
- banned patterns: `## Related`, `inbox/` in Sources, date headings, off-taxonomy tags (report tags, never auto-delete)
- sha256 drift; unreferenced sources, largest first; line-number-prefix corruption (strip the digit prefix file-wide, recheck links)
- zero new articles over many absorbs means cramming

Rebuild the index; rotate the log as it grows. Links: `wiki-linking`. Renames: `wiki-slug-rename`. New conventions go into `schema.md` at once.

References: `references/writing-standards.md` (read before writing articles), `references/cleanup-breakdown.md` (full-vault cleanup, finding missing articles), `references/pitfalls.md` (index slug drift, sha256 backfill, orphan maps, tag sprawl).
