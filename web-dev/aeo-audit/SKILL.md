---
name: aeo-audit
description: 'Audits a deployed website for AI-agent discoverability (llms.txt, robots, sitemap, schema.org, Open Graph). Use when asked for an AEO audit or agent-readable site.'
---

Classify the site first (docs, app, store, blog, portfolio); depth varies by type. Run `bash scripts/aeo-check.sh https://deployed.example` (needs `curl`, `jq`), then the manual checks in `references/CHECKLIST.md`. Always audit the deployed URL, never localhost.

Rank: **critical** (blocks agents: no server-rendered content, robots.txt blocks everything, broken sitemap) / **warning** / **skip with reason**. Opt-in conventions (`?mode=agent`, `/agent`, `/index.md`, custom `Link` relations) are never critical; audit them only when the site already advertises them. Every finding gets a fix and a `curl` command that verifies it.

**Pitfalls:** a 404 in a Link header is worse than no header; sitemap URLs must return 200; schema.org must match visible content; `llms.txt` must sit at the root and follow llmstxt.org.
