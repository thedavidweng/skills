---
name: wiki-audit
description: 'Audit a wiki vault: orphans, broken links, duplicates, tags, hygiene. Triggers on ''wiki audit'', ''check links'', ''find orphans'', or ''tag audit''.'
---

Read `schema.md`, `workflows.md`, `index.md` first. Commit after fixes.

**Index:** slug, H1, kind, aliases, tags, line count, out/in links per page.

**Links:** map titles+aliases → slugs; scan body for unlinked mentions (skip frontmatter/headings/Sources); fix as `[[slug|text]]`. Watch split links. Deep pass: `wiki-linking`.

**Patterns:** no `## Related`, no `inbox/` in Sources, no date headings, no off-taxonomy tags.

**Structure:** orphans → tag-grouped `maps/all-<tag>.md`; broken links (bare slug resolves by filename stem first); duplicates → merge into richer page (`git rm` the other); split stubs from bloated pages; `draft`/`active` only (substantive means active); stale content and sha256 drift. Line-number-prefix corruption: strip digits pattern file-wide, re-check links.

**Tags:** distribution + off-taxonomy flags (report, never auto-delete). **Slugs:** pinyin persons, legal-name others; renames → `wiki-slug-rename`.
