---
name: skill-repo-maintenance
description: 'Renames, moves, and validates skills in an Agent Skills repo. Use when reorganizing a skills repo, checking skill format, or when npx skills add cannot find a skill.'
---

**Rename in sync:** folder, frontmatter `name`, and cross-refs + `plugin.json`. Bulk: map → script (`references/rename-checklist.md`) → verify → one commit.

**Install-verify:** exact-match `--skill` names (`--skill "wiki*"` fails with "No matching skills found" — list names individually, or `--all`); remove old copy → commit+push → verify from remote (never trust local state). Nested layouts need `.claude-plugin/plugin.json` with `./`-relative paths, each with a valid `SKILL.md`.

References:
- `references/rename-checklist.md`: every place a rename must touch.
- `references/compression.md`: frontmatter, description, and `agents/openai.yaml` rules. Use it as the checklist after any skill edit.
- `references/troubleshooting.md`: the "Exceeded skills context budget of 2%" warning.
- `references/pii-audit.md`: scan and scrub personal data before publishing.
- `references/hermes-migration.md`: move skills in from another agent's skill directory.
