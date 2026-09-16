---
name: skill-repo-maintenance
description: 'Rename, reorganize, or fix skills in a skills repo. Triggers on ''rename skill'', ''reorganize skills'', or ''fix skill install''.'
---

**Rename in sync:** folder, frontmatter `name`, and cross-refs + `plugin.json`. Bulk: map → script (`references/rename-checklist.md`) → verify → one commit.

**Install-verify:** exact-match `--skill` names (`--skill "wiki*"` fails with "No matching skills found" — list names individually, or `--all`); remove old copy → commit+push → verify from remote (never trust local state). Nested layouts need `.claude-plugin/plugin.json` with `./`-relative paths, each with a valid `SKILL.md`.

Details live in `references/`: `troubleshooting.md`, `pii-audit.md`, `hermes-migration.md`, `compression.md`.
