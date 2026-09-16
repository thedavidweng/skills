---
name: wiki-quartz-publish
description: 'Publish a wiki as a private Quartz site. Triggers on ''publish wiki'', ''deploy site'', ''Quartz'', or ''Cloudflare Pages''.'
---

**Privacy first.** Before anything: explain the exposure risks in plain language, offer Cloudflare Access (recommended) / Zero Trust / IP allowlist / password, and get explicit confirmation. Never skip.

**Setup:** content repo (private vault, dispatches on `wiki/**` pushes) → site repo (Quartz fork, `sync-content.mjs` → `quartz build` → `wrangler pages deploy`). Full workflows: `references/deploy.yml`.

**Sync rules:** copy only `wiki/` (never `sources/`/`inbox/`); inject `title:` from H1 (JSON.stringify it — colons break YAML); strip PII frontmatter; honor `ExplicitPublish` (only `publish: true` builds). Homepage nav generates from `maps/*.md` with `nav: true`.

**Tokens:** dispatch needs `repo`, build-watch needs `actions:read`. `403` → fix scopes first.

**Verify:** incognito hits login; zero search results; no PII in published pages; RSS/analytics off.

**Pitfalls:** accidental `publish: true`; source leaks via sync; Quartz resolves `[[slug]]` differently — test links; assets may bypass Access — keep them in the content repo.
