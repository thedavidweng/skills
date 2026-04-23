---
name: wiki-slug-rename
description: 'Rename wiki page slugs while maintaining referential integrity across
  the vault.

  USE THIS SKILL whenever the user wants to: rename a wiki page, change a slug,

  bulk rename files, normalize filenames, fix naming conventions, or move pages

  between folders. Also triggers on "rename page", "change slug", "rename file",

  "bulk rename", or "normalize names" in a wiki context.

  '
---

# Wiki Slug Rename

Rename wiki page slugs while updating all cross-references, source files, and indexes.

## Prerequisites

- An Obsidian vault or markdown wiki with `[[wikilink]]` syntax
- `grep` and `sed` (or `patch` tool) available in the environment
- A slug naming convention (e.g., `kebab-case`)

## Workflow

### Step 1 — Rename the wiki page file

```bash
mv wiki/{section}/{old-slug}.md wiki/{section}/{new-slug}.md
```

### Step 2 — Rename associated source files

Source files (images, attachments, exports) often embed the slug in their filename.
Find and rename them to prevent broken links.

```bash
# Find all source files matching the old slug
find sources/ -name "*{old-slug}*"

# Rename each to use the new slug
mv sources/identity/{old-slug}-passport.pdf sources/identity/{new-slug}-passport.pdf
```

### Step 3 — Update wikilinks across all pages

Search for all references to the old slug:

```bash
grep -rn "\[\[{old-slug}" wiki/ --include="*.md"
```

Replace every occurrence:
- `[[old-slug]]` → `[[new-slug]]`
- `[[old-slug|Display Name]]` → `[[new-slug|Display Name]]`
- `![[sources/identity/old-slug-*.pdf]]` — embedded media references

### Step 4 — Update the vault index

If the vault maintains an index page (`index.md` or similar):
- Replace `[[old-slug]]` with `[[new-slug]]`
- Update the total page count if it is tracked in the index

### Step 5 — Verify and commit

Run the vault's audit script or check for broken links:

```bash
# Option A: if you have an audit script
node scripts/vault-audit.mjs

# Option B: manual grep for remaining old-slug references
grep -rn "{old-slug}" wiki/ sources/ --include="*.md"
```

If the audit passes with zero broken links, commit the change atomically:

```bash
git add -A && git commit -m "rename: {old-slug} → {new-slug}"
```

> **Atomic commits only.** Do not split a rename across multiple commits. A partial rename leaves the vault in a broken state.

## Batch Rename

For bulk changes (e.g., normalizing 100+ slugs):

1. **Generate a rename map** — old slug → new slug for every affected page
2. **Batch rename wiki files** using a script (see `references/batch-script-template.py`)
3. **Batch rename source files** to match the new slugs
4. **Search for stragglers** with `grep` — catch any missed references
5. **Update the index** page count
6. **Run the audit** — must pass before committing
7. **Commit as one atomic commit**

## Output Format

After renaming, present a summary:

```
Renamed: {old-slug} → {new-slug}
Updated:
  - 1 wiki page file
  - 3 source files
  - 14 wikilink references across 7 pages
  - 1 index entry
Audit: PASSED (0 broken links)
```

## Pitfalls

- **Chat and export files** (`sources/chats/*.txt`, `sources/notes-import/`) may also embed slugs in filenames — search broadly, not just `.md` files.
- **Pinyin and transliteration edge cases:** Multi-reading characters (e.g., 卜 as surname `bu` vs. name `jia`, 吕 as `lyu`) cannot be resolved by generic pinyin libraries. Always verify character context manually.
- **The `name-` prefix pattern:** If source files use `name-{slug}.md`, the prefix must follow the new slug exactly or links break.
- **External site sync:** If the wiki feeds a static site generator, update any hardcoded nav or sync scripts that reference the old slug.

## References

- `references/batch-script-template.py` — Python template for bulk slug renaming
