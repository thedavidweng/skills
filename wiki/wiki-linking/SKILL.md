---
name: wiki-linking
description: 'Adds inline wikilinks to a markdown wiki, finds unlinked mentions, and checks backlink targets. Use when asked to link wiki pages or audit wiki links.'
---

Inline only — never `## Related`/`## See also`. First mention per section, `[[slug|Display Name]]`. In tables, link the identifier column; shared first names stay plain text. Before/after examples: `references/examples.md`.

**Find missing links:** index `term → slug` (longest first) → scan body (skip frontmatter, headings, existing links, Sources) → replace end-to-start. Chinese: exact match. English: word boundaries. Skip self-links, trivially short terms, generic words.

**Verify from target:** rank by backlink count, substantiate each inbound link. Same-name collisions (`[[wrong|John]]`): run `python3 scripts/detect_same_name.py <vault-root>` and check each hit in context. Ask before deleting anything.

**Pitfalls:** split links (`[[s|Jane]] [[s|Doe]]` → merge); batch first-name replaces hit the wrong person; nicknames never go in `aliases`; whitespace inside brackets breaks the graph.
