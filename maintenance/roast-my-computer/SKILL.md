---
name: roast-my-computer
description: 'Scans a local dev machine and writes a privacy-safe roast report on clutter, stale repos, git hygiene, and secret risk. Use when the user asks to roast or audit their machine.'
---

Local-only. Memory, paths, credentials, and reports stay private; secrets redacted. Hard rules: `references/PRIVACY_RULES.md`.

1. **Scope.** **project** (cwd, safe to run) or **global** (memory roots + platform defaults from `references/DIRECTORY_TARGETS.md`; needs approval). `/Applications` is excluded unless the user adds it.
2. **Scan.** `python3 scripts/scan_dev_environment.py --scope <project|global> --output "${TMPDIR:-/tmp}/roast-my-computer/scan.json"`. Other flags and budgets: `--help`. The JSON (`references/REPORT_SCHEMA.md`) is the source of truth for every count, path, and score (`references/SCORING.md`).
3. **Write.** Roast copy per `references/ROAST_WRITER_PROMPT.md` and `references/ROAST_STYLE.md`; never change a number from the scan.
4. **Render.** One static HTML file per `references/HTML_REPORT_FORMAT.md` in the same directory, then open it. Note scan truncation in the report.

Triage: public-key names drop to low, test fixtures cap at medium, editor caches keep severity but get tagged, because cleanup differs per kind.

Cleanup: propose exact commands, require confirmation, quarantine over deletion. Never auto-remove repos, password stores, browser profiles, `.ssh`/`.aws`/`.kube`.
