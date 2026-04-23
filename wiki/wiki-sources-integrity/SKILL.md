---
name: wiki-sources-integrity
description: 'Protect wiki Sources sections during batch operations. USE THIS SKILL
  whenever the user

  is: cleaning up a wiki, running batch edits, removing inbox references, migrating
  sources,

  or auditing a vault. Also triggers on "batch cleanup", "remove inbox links",

  "fix sources", "source audit", or "wiki maintenance".

  '
---

# Wiki Sources Integrity

Maintain clean, permanent Sources sections. Never link to temporary directories.

## Prerequisites

- A markdown wiki with a two-tier storage model: `inbox/` (temporary) and `sources/` (permanent)
- Each person/entity page has a `## Sources` section linking to identity files

## Workflow

### Step 1 — Audit current Sources sections

Find all pages that link to `inbox/`:

```bash
grep -rn "inbox/" wiki/ --include="*.md"
```

Also identify pages that should have identity file links but do not:

```bash
# List all identity files in sources/
find sources/identity/ -type f

# List all pages that currently link to sources/identity/
grep -rl "sources/identity/" wiki/ --include="*.md"
```

### Step 2 — Move inbox content to sources/

For every file referenced from `inbox/`:
1. Copy the file to the appropriate `sources/` subdirectory
2. Update the page's Sources section to point to `sources/` instead of `inbox/`
3. Delete the original from `inbox/` only after verifying the copy

### Step 3 — Ensure identity files are linked

Every identity file in `sources/identity/` (passport scans, ID cards, work permits) must be linked from the corresponding entity page's `## Sources` section.

Match files to pages by filename prefix or slug:

```bash
# Example: sources/identity/alice-smith-passport.pdf
# Should be linked from wiki/people/alice-smith.md as:
# ![[sources/identity/alice-smith-passport.pdf]]
```

If a page is missing its identity link, add it:

```markdown
## Sources

- ![[sources/identity/alice-smith-passport.pdf]]
- ![[sources/identity/alice-smith-id-card.pdf]]
```

### Step 4 — Verify no orphaned Sources sections

After removing inbox links, check that no page's `## Sources` section is empty:

```bash
grep -A 5 "^## Sources$" wiki/**/*.md | grep -B 1 "^$"
```

If a Sources section is empty, either:
- Re-add the correct identity file links, or
- Remove the empty `## Sources` heading if no sources exist for that page

### Step 5 — Run audit and confirm

Check the final state:

```bash
# Count of identity files vs. pages linking to them
identity_count=$(find sources/identity/ -type f | wc -l)
linked_count=$(grep -rl "sources/identity/" wiki/ --include="*.md" | wc -l)
echo "Identity files: $identity_count | Pages with identity links: $linked_count"
```

Both counts should match (or the linked count should be ≥ identity count if some files are shared).

## Output Format

After cleanup, present a summary:

```
Sources Integrity Report
━━━━━━━━━━━━━━━━━━━━━━━━
Inbox links removed: 7
Inbox files migrated to sources/: 7
Identity links added: 3
Identity links already present: 12
Pages with empty Sources sections fixed: 1
Audit: PASSED
```

## Rules

1. **Never link to `inbox/` from Sources.** Inbox is temporary — content gets deleted after distillation. Sources must reference `sources/` paths only.
2. **Identity files belong in Sources.** Passport scans, ID cards, work permits in `sources/identity/` must be linked from the corresponding entity page.
3. **Contact exports are sources.** A `contacts.vcf` or similar export in `sources/identity/` should be linked from every person page that contains data from that file.

## Pitfalls

- **Batch cleanup can wipe Sources.** If a page's Sources section contains ONLY inbox references and you remove them, the entire section may become empty or get deleted. Always check that identity file links survive.
- **Shared identity files:** One passport scan may belong to multiple pages (e.g., a family member's ID referenced on multiple person pages). Link it from every relevant page.
- **Filename matching:** Identity files must use a consistent slug prefix (`{slug}-passport.pdf`) so they can be matched to pages automatically.

## References

- `references/cleanup-checklist.md` — Step-by-step checklist for batch source cleanup
