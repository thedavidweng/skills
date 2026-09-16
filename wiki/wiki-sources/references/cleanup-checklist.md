# Sources Cleanup Checklist

Use this checklist during every batch cleanup operation.

## Before Cleanup

- [ ] Back up the vault (`git stash` or `cp -r vault/ vault-backup/`)
- [ ] List all inbox files: `find inbox/ -type f`
- [ ] List all identity files: `find sources/identity/ -type f`
- [ ] List all pages with inbox links: `grep -rl "inbox/" wiki/ --include="*.md"`

## During Cleanup

- [ ] Move each inbox file to the correct `sources/` subdirectory
- [ ] Update every inbox link to point to `sources/`
- [ ] Match each identity file to its page by slug prefix
- [ ] Add missing identity links to `## Sources` sections
- [ ] Remove empty `## Sources` headings (only if no sources exist)

## After Cleanup

- [ ] Verify zero inbox links remain: `grep -r "inbox/" wiki/ --include="*.md"` → should return nothing
- [ ] Verify identity file count matches (or is ≤) linked page count
- [ ] Run vault audit or grep for broken links
- [ ] Commit atomically: `git add -A && git commit -m "cleanup: migrate inbox to sources"`
