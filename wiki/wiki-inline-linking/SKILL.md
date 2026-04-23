---
name: wiki-inline-linking
description: 'Wikipedia-style inline linking for Obsidian wiki vaults. USE THIS SKILL
  whenever the user asks to:

  link wiki pages, add wikilinks, cross-reference pages, clean up Related sections,

  or improve internal linking in a markdown vault. Also triggers on "link mentions",

  "connect pages", "wiki links", "internal links", or "Obsidian linking".

  '
---

# Wiki Inline Linking

Turn static mentions into [[wikilinks]] inside the body text — Wikipedia style. Never maintain separate "Related" or "See also" sections.

## Prerequisites

- An Obsidian vault (or any markdown wiki using `[[wikilink]]` syntax)
- A consistent slug naming convention (e.g., `kebab-case` for page filenames)

## Workflow

### Step 1 — Identify linkable mentions

Scan the body text for mentions of people, places, projects, courses, or concepts that have their own wiki page.

### Step 2 — Create inline links

For each mention, replace the plain text with a wikilink at its **first occurrence** in each section.

**Format:**
```markdown
Before: Alice studied at Harvard and later joined OpenAI.
After:  [[alice-smith|Alice]] studied at [[harvard-university|Harvard]] and later joined [[openai|OpenAI]].
```

**Rules:**
1. **Inline only.** If a link is worth having, it belongs in the body text. Never create `## Related` or `## See also` sections.
2. **First mention only.** Link once per section. Do not link every occurrence.
3. **Use display text.** Always use `[[slug|Display Name]]` so the rendered text reads naturally.
4. **Link the unique identifier.** In tables or lists, link the column that uniquely identifies the entity (e.g., full name or ID). Leave shared names (first names, surnames) as plain text.

### Step 3 — Clean up orphaned Related sections

If a page has a `## Related` or `## See also` section, inline its links into the body text, then delete the section.

### Step 4 — Verify no over-linking

Check that:
- No term is linked more than once per section
- Shared names (common first names, surnames) remain plain text in tables
- Social-media handles and nicknames are inline text, not aliases

## Output Format

After linking, present a summary:

```
Linked 12 mentions across 4 sections:
  - [[alice-smith|Alice]] → Introduction, Career
  - [[harvard-university|Harvard]] → Education
  - [[openai|OpenAI]] → Career

Removed 1 orphaned Related section.
```

## Pitfalls

- **Shared names in tables:** Common first names (Peter, Emily, Alice) and surnames (Yang, Wu) often match multiple people. Only link the unique identifier column (e.g., full name or ID).
- **Batch operations on shared terms:** Replacing `[[alice-smith|Alice]]` globally may collide with other Alices. Verify context before batch-replacing.
- **YAML frontmatter breakage:** Titles with colons (e.g., "Beacon: Journal") must be quoted in YAML frontmatter or the site generator fails. When injecting titles, always wrap with JSON.stringify or explicit quotes.
- **Aliases are for real names only:** Social-media nicknames and handles belong in the body text (e.g., `微信昵称"Daydreamer"`), never in the YAML `aliases` array.

## References

- `references/examples.md` — Before/after examples for common patterns
