---
name: wiki-quartz-publish
description: "USE THIS SKILL whenever the user wants to: publish a wiki as a website, deploy Obsidian notes to the web, set up Quartz, or create a static site from markdown. Triggers on 'publish wiki', 'deploy site', 'Quartz', 'Obsidian website', 'static site', or 'Cloudflare Pages'."
---

# Quartz Publish — Private Wiki Site

Publish a personal knowledge wiki as a fast, searchable static site using [Quartz 4](https://quartz.jzhao.xyz/). Deployed to Cloudflare Pages with identity-aware access control.

**Privacy is not optional.** This skill enforces a mandatory confirmation workflow before any deployment.

---

## Privacy Confirmation (Mandatory)

Before doing ANYTHING related to publishing, the agent MUST:

1. **Explain the risks** in plain language:
   - Your wiki contains names, relationships, locations, conversations, and possibly identity documents
   - Public deployment means anyone on the internet can read everything
   - Search engines index public pages; cached copies persist after deletion
   - You may expose other people's private information without their consent
   - Screenshots, scrapers, and archives may copy your content permanently

2. **Present protection options:**
   - **Cloudflare Access** (RECOMMENDED): Requires Google/Microsoft/GitHub login. You control the allowed email list. Free for up to 50 users.
   - **Cloudflare Zero Trust**: Full identity provider, device posture, audit logs. More complex but more powerful.
   - **IP allowlisting**: Only specific IPs can access. Good for personal use from known locations.
   - **Password protection**: Simple shared password. Better than nothing, but passwords leak.
   - **Public**: No protection. NOT RECOMMENDED.

3. **Get explicit confirmation:**
   - Ask: "Do you understand that publishing your wiki exposes personal information to the internet?"
   - Ask: "Which protection method do you want to use?"
   - If the user chooses "public" or no protection: ask again. "Are you absolutely sure? This cannot be undone once search engines index it."
   - If the user confirms public deployment: document the confirmation in the response and proceed with warnings.

**Do not skip this step. Do not assume the user understands. Do not proceed without a clear answer.**

---

## Prerequisites

- A personal knowledge wiki in markdown format (Obsidian vault recommended)
- GitHub account (for repository hosting and Actions)
- Cloudflare account (for Pages and Access)
- Domain name (optional; `*.pages.dev` subdomain works too)

---

## Architecture

Two-repo model separates content from site:

```
content-repo/                   # Your wiki vault (private)
  wiki/                         # Compiled knowledge pages
  system/                       # Rules and indexes
  .github/workflows/
    publish-site.yml            # Triggers site build on wiki changes

site-repo/                      # Quartz site (can be private)
  quartz.config.ts              # Quartz configuration
  scripts/sync-content.mjs      # Pulls wiki, injects titles, builds homepage
  .github/workflows/
    deploy.yml                  # Sync → Build → Deploy
```

### Why two repos?

- Content repo remains focused on knowledge management
- Site repo can be forked/upgraded independently when Quartz releases updates
- Site repo can be made public (it only contains config + build scripts) while content stays private
- Content repo dispatches to site repo; site repo pulls content at build time

---

## Step 1: Scaffold the Quartz Site

### 1.1 Fork/Clone Quartz

```bash
# Option A: Fork jackyzha0/quartz on GitHub, then clone your fork
git clone https://github.com/YOU/quartz.git your-wiki-site
cd your-wiki-site

# Option B: Clone and remove upstream remote
git clone https://github.com/jackyzha0/quartz.git your-wiki-site
cd your-wiki-site
git remote remove origin
git remote add origin https://github.com/YOU/your-wiki-site.git
```

### 1.2 Configure quartz.config.ts

Key settings:
- `pageTitle`: Your wiki name
- `baseUrl`: Your Cloudflare Pages domain
- `ignorePatterns`: `["private", "templates", ".obsidian", "inbox", "sources"]`
- `analytics: null`, `enableRSS: false` (privacy)
- `filters: [Plugin.ExplicitPublish()]` — **only pages with `publish: true` are built**

*(See `references/quartz-config.ts` for full example)*
### Important: ExplicitPublish Plugin

The `Plugin.ExplicitPublish()` filter means **only pages with `publish: true` in frontmatter are published**. This is your safety net.

```yaml
---
layer: wiki
kind: person
publish: true   # Only this page goes to the site
---
```

Never add `publish: true` to pages with sensitive information.

---

## Step 2: Content Sync Script

Create `scripts/sync-content.mjs` that:

1. Pulls the content repository
2. Copies only `wiki/` pages (not `sources/`, not `inbox/`)
3. Injects `title:` into frontmatter from H1 headings
4. Builds a homepage with section counts
5. Strips or redacts sensitive fields

### Key sync rules:

```javascript
const SAFE_KINDS = ["person", "project", "place", "concept", "topic", "map", "period"]
const STRIP_FIELDS = ["phone", "email", "address", "id_number", "passport", "ssn"]

function sanitizeFrontmatter(fm) {
  // Remove sensitive fields before publishing
  for (const field of STRIP_FIELDS) {
    delete fm[field]
  }
  return fm
}

function shouldPublish(filePath, frontmatter) {
  // Only publish if explicitly marked
  if (frontmatter.publish !== true) return false
  // Only publish safe kinds
  if (!SAFE_KINDS.includes(frontmatter.kind)) return false
  return true
}
```

### Homepage builder:

Build an `index.md` that links to all published sections:

```markdown
---
title: Your Wiki
---

# Your Wiki

A personal knowledge base.

## Sections

- [[people/|People]] (42)
- [[projects/|Projects]] (12)
- [[places/|Places]] (8)
- [[concepts/|Concepts]] (15)
```

---

## Step 3: CI/CD Pipeline

Two workflows:

**Content repo** (`.github/workflows/publish-site.yml`):
On push to `wiki/` or `system/`, dispatch `repository_dispatch` event to site repo.

**Site repo** (`.github/workflows/deploy.yml`):
On `repository_dispatch` or push: checkout content → run `sync-content.mjs` → `npx quartz build` → `wrangler pages deploy`.

*(See `references/deploy.yml` for full workflow files)*
### Content repo workflow (`.github/workflows/publish-site.yml`):

```yaml
name: Publish Quartz Site

on:
  push:
    branches: [main]
    paths: ["wiki/**", "system/**"]
  workflow_dispatch:

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Dispatch site build
        env:
          GH_TOKEN: ${{ secrets.SITE_REPO_DISPATCH_TOKEN }}
        run: |
          jq -n \
            --arg repo "${{ github.repository }}" \
            --arg sha "${{ github.sha }}" \
            '{event_type: "content-updated", client_payload: {content_repo: $repo, content_sha: $sha}}' \
            > dispatch.json

          gh api repos/YOU/your-wiki-site/dispatches \
            --method POST --input dispatch.json
```

### Site repo workflow (`.github/workflows/deploy.yml`):

```yaml
name: Deploy Quartz Site

on:
  repository_dispatch:
    types: [content-updated]
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Checkout content
        uses: actions/checkout@v4
        with:
          repository: ${{ github.event.client_payload.content_repo || 'YOUR_USERNAME/your-wiki' }}
          ref: ${{ github.event.client_payload.content_sha || 'main' }}
          token: ${{ secrets.CONTENT_REPO_READ_TOKEN }}
          path: external/content

      - uses: actions/setup-node@v4
        with:
          node-version: "22"
          cache: "npm"

      - run: npm ci
      - run: node scripts/sync-content.mjs --source external/content --target content

      - name: Build Quartz
        env:
          QUARTZ_BASE_URL: ${{ vars.QUARTZ_BASE_URL }}
        run: npx quartz build

      - name: Deploy to Cloudflare Pages
        env:
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_PAGES_API_TOKEN }}
        run: |
          npx wrangler pages deploy public \
            --project-name "${{ vars.CLOUDFLARE_PAGES_PROJECT }}"
```

---

## Step 4: Cloudflare Access (Strongly Recommended)

After the site is deployed, enable Cloudflare Access:

1. Go to Cloudflare Dashboard → Zero Trust → Access → Applications
2. Add an application → Self-hosted
3. Enter your Pages domain (`your-wiki.pages.dev`)
4. Configure identity providers: Google, GitHub, or Microsoft
5. Add policies:
   - **Allow**: Emails ending with `@yourdomain.com` OR specific email addresses
   - **Block**: Everyone else
6. Save

### Zero Trust (Advanced)

For stronger control:
- Require device posture (corporate device, up-to-date OS)
- Add time-based restrictions
- Enable audit logs to see who accessed what and when
- Set session duration (e.g., 8 hours)

---

## Step 5: Verification

After deployment:

1. **Test access control**: Open the site in an incognito window. You should be redirected to a login page, not see your wiki.
2. **Test from allowed account**: Log in with an allowed email. You should see the wiki.
3. **Check for leaks**: Search your domain on Google with `site:your-wiki.pages.dev`. There should be zero results (Access blocks crawlers).
4. **Verify sensitive pages**: Confirm no pages with `publish: true` contain phone numbers, addresses, or ID numbers.

---

## Publishing Checklist

Before going live:

- [ ] Privacy confirmation documented (user explicitly confirmed understanding)
- [ ] Access control enabled (Cloudflare Access or equivalent)
- [ ] `publish: true` only on safe pages
- [ ] Sensitive fields stripped by sync script
- [ ] `sources/` and `inbox/` excluded from sync
- [ ] RSS disabled
- [ ] Analytics disabled or self-hosted
- [ ] No search engine indexing (blocked by Access, or `noindex` meta tag)
- [ ] Tested in incognito mode — login required
- [ ] Audit log enabled (Cloudflare Zero Trust)

---

## Pitfalls

- **Accidental `publish: true`** on sensitive pages. Always review the diff before pushing.
- **Source files leaking** — `sync-content.mjs` must never copy `sources/` or `inbox/`.
- **Wikilink breakage** — Quartz resolves `[[slug]]` differently than Obsidian. Test all links after build.
- **Frontmatter title injection** — Titles with colons break YAML. Always quote with JSON.stringify.
- **Cloudflare Access bypass** — Direct asset URLs (images, PDFs) may bypass Access policies. Keep assets in the private content repo, not the site repo.

---

## Output Format

After setup, present: domain, protection method, content source, ExplicitPublish status, published section counts, sensitive content exclusions, and next steps (review `publish: true` pages, test incognito, share allowed emails).
