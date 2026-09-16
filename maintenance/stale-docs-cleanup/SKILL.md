---
name: stale-docs-cleanup
description: 'Delete plan debris and stale docs in code repos; move future work to issues. Triggers on ''stale docs'', ''plan debris'', ''cleanup docs'', or ''agent leftovers''.'
---

Git history is the archive; code is the truth. **Delete:** completed plans, phase/checkpoint/handoff docs, `docs/archive`-style dead folders, agent-status docs, docs duplicating code, forward-looking current-state refs. **Keep:** human guides (README/setup/ops/troubleshooting), ADRs and hard-won architecture notes, frozen-interface contracts, release changelogs. **Rewrite** stale-but-useful docs to current state (facts not phases, issue links not roadmaps).

Future work goes to the tracker: GitHub → `gh issue create`, GitLab → `glab`, else `.scratch/<feature>/` (shape: Problem / Scope / Acceptance criteria). Classify each doc `delete` / `move to issue` / `rewrite` / `keep`, then report files changed + issues created. Ambiguous calls: `references/doc-hygiene-rules.md`.
