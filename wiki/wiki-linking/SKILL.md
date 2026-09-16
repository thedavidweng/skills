---
name: wiki-linking
description: 'Add Wikipedia-style inline wikilinks, find unlinked mentions, verify backlinks. Triggers on ''link mentions'', ''connect pages'', ''internal links'', ''link audit'', or ''backlinks''.'
---

Inline only — never `## Related`/`## See also`. First mention per section, `[[slug|Display Name]]`. In tables, link the identifier column; shared first names stay plain text.

**Find missing links:** index `term → slug` (longest first) → scan body (skip frontmatter, headings, existing links, Sources) → replace end-to-start. Chinese: exact match. English: word boundaries. Skip self-links, trivially short terms, generic words.

**Verify from target:** rank by backlink count, substantiate each inbound link. Same-name collisions (`[[wrong|John]]`): run `scripts/detect_same_name.py`. Ask before deleting anything.

**Pitfalls:** split links (`[[s|Jane]] [[s|Doe]]` → merge); batch first-name replaces hit the wrong person; nicknames never go in `aliases`; whitespace inside brackets breaks the graph.
