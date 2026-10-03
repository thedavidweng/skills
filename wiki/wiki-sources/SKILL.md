---
name: wiki-sources
description: 'Files, ingests, and protects wiki source documents under sources/. Use when storing or ingesting a document into the wiki or auditing Sources sections.'
---

Two tiers: `inbox/` (temporary, deleted after distillation) vs `sources/` (permanent).

**Inline vs file:** embed (short enough to fit its section, with provenance marker) or `sources/...` file (large, legal value, fits nowhere).

**Ingest:** identity → `sources/identity/`; contracts/certificates → `sources/docs/Archive/`; low-value OCR → `sources/docs/OCR-Only/`. Name `[slug]-[descriptor].md`. Frontmatter: layer/source/kind/`created` (date on doc) /`updated` (today)/uri/tags. Body: exact text, then Metadata with wikilinks + fact bullets. Update the entity page: `source_notes` + one concise section. Skip ingesting when a path link suffices, the doc is trivial, or scans need OCR first — ingesting ≠ referencing.

**Protect:** never link `inbox/` from Sources (copy to `sources/` first, repoint, verify). Every `sources/identity/` file must be linked from its entity page. After batch edits: zero `inbox/` refs, no emptied Sources sections. Batch cleanups follow `references/cleanup-checklist.md`.

**Pitfalls:** orphaned `source_notes` pointing at deleted files; `created` vs `updated` mixup (`YYYY-MM-DD`).
