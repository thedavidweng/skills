# Maintenance Skills

Skills for repository and developer-environment hygiene.

| Skill | Description |
|-------|-------------|
| [ci-slim](ci-slim/SKILL.md) | Cut CI time: measure, delete low-value tests, remove duplicate jobs. |
| [migrate-to-bun](migrate-to-bun/SKILL.md) | Move a repo to Bun and open a PR with a before/after speed table. |
| [roast-my-computer](roast-my-computer/SKILL.md) | Scan your local machine and generate a privacy-safe developer roast report — abandoned projects, dependency graveyards, git shame, AI slop, redacted secret risk. Local-only; nothing uploaded. |
| [skill-repo-maintenance](skill-repo-maintenance/SKILL.md) | Maintain and reorganize agent skills within a skills repository. |
| [stale-docs-cleanup](stale-docs-cleanup/SKILL.md) | Delete stale docs, move future work into issues, preserve human-facing guides. |

## roast-my-computer

Scan your own machine through your coding agent and get a classic-Macintosh-style HTML roast report. Deterministic Python scanner with hard time/entry budgets; the agent renders the HTML from `references/HTML_REPORT_FORMAT.md`. Reports go to `${TMPDIR:-/tmp}/roast-my-computer/` and are reused on the next run unless you ask to re-scan.

```bash
npx skills add thedavidweng/skills/roast-my-computer
```
