---
name: roast-my-computer
description: 'Roast, audit, or clean up a local dev environment — clutter, abandoned repos, git shame, secret risk — without uploading anything. Triggers on ''roast'', ''audit my machine'', or ''clean up''.'
---

Local-only. Memory, paths, credentials, and reports stay private; secrets redacted. Run: `scripts/scan_dev_environment.py --scope <project|global>` → HTML report per `references/HTML_REPORT_FORMAT.md` → open it. Scope: **project** (cwd, safe runs) or **global** (memory roots + platform defaults, needs approval). `/Applications` excluded unless explicitly added. Flags/budgets: `--help`. Note scan truncation in the report. Triage: public-key names downgraded to low, test fixtures capped at medium, editor caches keep severity but tagged — cleanup differs per kind.

Cleanup: propose exact commands, require confirmation, quarantine over deletion. Never auto-remove repos, password stores, profiles, `.ssh`/`.aws`/`.kube`.
