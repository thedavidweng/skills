---
name: aeo-audit
description: 'Audit a website for agent discoverability (llms.txt, schema.org, sitemap, semantic HTML). Triggers on ''AEO audit'', ''agent-readable'', or ''site review''.'
---

Classify the site first (docs, app, store, blog — depth varies), then run `scripts/aeo-check.sh` plus manual checks from `references/CHECKLIST.md`. Rank: critical (blocks agents) / warning / skip-with-reason. Verify from the deployed URL, never localhost.

**Pitfalls:** a 404 in a Link header is worse than no header; sitemap URLs must return 200; schema.org must match visible content; `llms.txt` must exist at root and stay under model context limits.
