---
name: wiki-source-integration
description: 'USE THIS SKILL whenever the user wants to: decide how to store source
  documents in a wiki, embed documents inline, separate sources into files, or organize
  document references. Triggers on ''source integration'', ''embed document'', ''store
  sources'', or ''document organization''.'
---

# Wiki Source Document Integration Strategy

When adding source document content to the wiki, you must decide between two approaches:

1. **Inline content**: Embed the full document text directly in the target wiki page (e.g., in an `## Employment` or `## Documents` section)
2. **Separate source file**: Create a new file in `sources/` and reference it via wikilink

## Decision Framework

**Prefer INLINE content when:**
- Document is small (under ~30 lines of text, single page)
- Content is simple factual record (income certificates, simple letters, one-page forms)
- Document directly belongs in a specific wiki section (Employment, Identity, etc.)
- Future browsing is the primary use case; archival preservation is not critical
- No binary/image components need preservation

**Create SEPARATE source file when:**
- Document is large (multi-page contracts, lengthy records)
- Document contains important visual formatting or images that must be preserved separately
- Original file must be preserved as-is for legal/proof reasons (Archive zone)
- Document is being stored primarily for provenance, not frequent reading
- Content doesn't fit naturally into any existing wiki section

## What We Learned

From real-world usage:
- A 100,000 RMB income certificate (2015) was first created as `sources/docs/Archive/zhang-san-income-cert.md` and referenced separately.
- User corrected: "不需要新建一个...把内容放进 zhang-san.md"
- The income certificate is only 8 lines of Chinese text — clearly better inline.
- Lesson: For short text documents, skip the separate source file entirely. Embed directly in the target wiki page's relevant section, and mention in `source_notes` with a generic Archive reference path if provenance tracking is needed.

## Implementation Steps (Inline Approach)

1. Read the source document text
2. Identify the target wiki page and appropriate section (Employment, Identity, etc.)
3. Insert the full document content as a quoted block in the correct section
4. Optionally add a summary line like "**Source**: Source document archived in `sources/docs/Archive/`"
5. Update `source_notes` only if the document has unique archival value; otherwise skip to avoid dead references

## Common Pitfalls

- Creating separate source files for every small document → unnecessary fragmentation
- Removing source references entirely → lose provenance trail
- Forgetting to remove the separate file reference after switching to inline
- Leaving orphaned `source_notes` entries that point to deleted files
