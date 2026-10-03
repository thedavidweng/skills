---
name: stale-docs-cleanup
description: 'Removes stale plans, handoff notes, and agent leftovers from a repo and moves future work into issues. Use when asked to clean up stale or outdated repo docs.'
---

Git history is the archive; code is the truth. Start with `bash scripts/audit_stale_docs.sh <repo>` for the tracker, doc inventory, stale-language hits, and archive folders (signals, not verdicts).

**Delete:** completed plans, phase/checkpoint/handoff docs, `docs/archive`-style dead folders, agent-status docs, docs duplicating code, forward-looking current-state refs. **Keep:** human guides (README/setup/ops/troubleshooting), ADRs and hard-won architecture notes, frozen-interface contracts, release changelogs. **Rewrite** stale-but-useful docs to current state (facts not phases, issue links not roadmaps).

Future work goes to the tracker: GitHub → `gh issue create`, GitLab → `glab issue create`, else `.scratch/<feature>/` (shape: Problem / Scope / Acceptance criteria). Classify each doc `delete` / `move to issue` / `rewrite` / `keep`. Ambiguous calls: `references/doc-hygiene-rules.md`. Show the plan before deleting; then report with `references/report-template.md`.
