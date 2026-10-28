---
name: wiki-quartz-publish
description: 'Publishes a personal wiki as a private Quartz site on Cloudflare Workers. Use when the user wants to publish or deploy their wiki.'
---

**Privacy first.** Before anything: explain the exposure risks in plain language, offer Cloudflare Access (recommended) / Zero Trust / IP allowlist / password, and get explicit confirmation. Never skip.

**Setup:** content repo (private vault, dispatches on `wiki/**` pushes) → site repo (Quartz fork, `sync-content.mjs` → `quartz build` → `cf deploy` to a static-assets Worker). Full workflows: `references/deploy.yml`; copy `references/sync-content.mjs` into the site repo as the sync step.

**Deploy config:** devDependencies are `cf` and `@cloudflare/vite-plugin`, the bundler `cf` requires (no Wrangler). `vite.config.ts` is `defineConfig({ plugins: [cloudflare()] })`; the plugin packages Vite's `publicDir` (`public/`, where Quartz writes) into Cloudflare Build Output, so no assets-directory setting is needed. `cloudflare.config.ts` uses `defineConfig` from `cf/config` with `worker: { name, compatibilityDate, workersDev: true, assets: { htmlHandling: "auto-trailing-slash", notFoundHandling: "404-page" } }`. Keep it assets-only (no `entrypoint`, `routes` or `runWorkerFirst`): a Worker in front of the files bills every request, while static assets are free and unlimited. Build with `quartz build` (set `QUARTZ_BASE_URL` to the Worker host), then `cf deploy`; `cf deploy --dry-run` must report no Worker script. Secrets: `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_API_TOKEN`, content-repo read token. Put the Access policy on the Worker (incl. `workers.dev`) before the first deploy.

**Sync rules:** copy only `wiki/` (never `sources/`/`inbox/`); inject `title:` from H1 (JSON.stringify it — colons break YAML); strip PII frontmatter; honor `ExplicitPublish` (only `publish: true` builds). Homepage nav generates from `maps/*.md` with `nav: true`.

**Tokens:** dispatch needs `repo`, build-watch needs `actions:read`. `403` → fix scopes first.

**Verify:** incognito hits login; zero search results; no PII in published pages; RSS/analytics off.

**Pitfalls:** accidental `publish: true`; source leaks via sync; Quartz resolves `[[slug]]` differently — test links; assets may bypass Access — keep them in the content repo.
