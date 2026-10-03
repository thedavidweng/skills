# AEO Audit: Full Checklist

Every check is one of:

- **Standard**: a published spec or a convention agents and crawlers actually read. Missing it is a finding.
- **Opt-in**: a site-specific convention with no wide agent support. Check it only when the site already advertises it, or when the user asks for it. Never rank a missing opt-in endpoint as critical.

## Contents

- A. Discovery and crawlability
- B. LLM discovery (llms.txt)
- C. Agent views (opt-in)
- D. Structured data (schema.org)
- E. Meta and Open Graph
- F. Semantic HTML and accessibility
- G. Agent cards and APIs (conditional)
- H. Content freshness

## A. Discovery and crawlability

### A1. Sitemap (`/sitemap.xml`), standard
- Valid XML with `<urlset>` or `<sitemapindex>`
- Lists every indexable page; every listed URL returns 200
- `<lastmod>` on pages that change

### A2. robots.txt (`/robots.txt`), standard
- No blanket `Disallow: /`
- `Sitemap:` line pointing at the sitemap
- Does not block `/llms.txt` or other agent files
- AI crawler user agents (`GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`) are allowed or blocked on purpose, not by accident. Report what the file does; the policy is the owner's call.

### A3. HTTP `Link` header on `/`, opt-in
- `rel="sitemap"` is the only widely used relation here. Values such as `rel="llms.txt"` are site conventions.
- **Pitfall:** only list URLs that return 200. A 404 in a Link header is worse than no header.

## B. LLM discovery

### B1. `/llms.txt`, standard (llmstxt.org proposal)
Follow the format at https://llmstxt.org:
- One `# Name` H1, required
- Optional `> summary` blockquote
- Optional prose, then `## Section` headings containing Markdown link lists: `- [Title](url): note`
- An `## Optional` section marks links an agent can skip under a tight context budget
- Served as plain text or Markdown at the site root; keep it well under a model's context window

### B2. `/llms-full.txt`, opt-in
- The full site content in one file, generated from the same source as the pages
- Flag it when it is visibly out of date or truncated, not for its size

### B3. Per-section `llms.txt`, opt-in
- Only for sites with distinct sections (`/docs/`, `/api/`)
- No empty placeholders

### B4. `/.well-known/llms.txt`, opt-in
- Alias or redirect to `/llms.txt`; content must match

## C. Agent views (opt-in)

These are site conventions, not standards. Audit them only if the site links to them.

### C1. `?mode=agent`
- Returns content different from the marketing HTML: semantic HTML, direct `href`s, no JS-dependent content

### C2. `/agent` JSON endpoint
- `Content-Type: application/json; charset=utf-8`, valid JSON, content matching the visible site
- `X-Robots-Tag: noindex` keeps it out of search results

### C3. `/index.md`
- `Content-Type: text/markdown; charset=utf-8`, body starts with `# `, mirrors the homepage

### C4. Server-side rendering, standard
- Raw HTML (no JS) has an `<h1>` and the main content text
- Next.js App Router and most SSG frameworks do this by default; client-only SPAs need prerendering

## D. Structured data (schema.org)

Validate with https://validator.schema.org. Structured data must match visible content.

### D1. Person / Organization
- `name`, `url`, `description`, `sameAs` (external profiles); `logo` for organizations

### D2. WebSite
- `name`, `url`; `inLanguage` when the site is not English-only

### D3. Article / BlogPosting / CreativeWork
- Per page: `headline` or `name`, `datePublished`, `dateModified`, `author`, `image` when there is a cover

### D4. BreadcrumbList
- Sites with hierarchical navigation: one `ListItem` per level with `name` and `item`

### D5. Product / Service / Offer
- Only for sites that sell something; prices must match the visible page

### D6. NLWeb, opt-in
- Only when the site runs an NLWeb endpoint; skip for static sites

## E. Meta and Open Graph

### E1. `<title>`
- Unique and descriptive per page ("Home" is a finding)

### E2. `<meta name="description">`
- Unique per page, roughly 50–160 characters

### E3. Open Graph
- `og:title`, `og:description`, `og:type`, `og:url`, `og:image` (1200×630 is the common size)

### E4. Twitter / X card
- `twitter:card` (`summary_large_image` for pages with images); falls back to Open Graph for title and description

### E5. Cross-signal consistency
- `<title>`, `og:title`, and JSON-LD `name` describe the same entity
- Meta description, `og:description`, and JSON-LD `description` agree
- Report each mismatch with both values

## F. Semantic HTML and accessibility

### F1. Headings
- One `<h1>` per page; no skipped levels

### F2. Images
- Every `<img>` has `alt`; decorative images use `alt=""`; no generic "image" or "photo"

### F3. Galleries and visual content
- Containers have `role="list"` or an `aria-label`; image alt names the subject

### F4. Link text
- No bare "click here" or "read more"; link text names the destination

## G. Agent cards and APIs (conditional)

Skip this section for sites with no programmable interface.

### G1. A2A Agent Card
- Only for sites that run an A2A agent: `/.well-known/agent-card.json` per https://a2a-protocol.org

### G2. MCP server
- Only if the site actually runs one; document its URL and auth in `/llms.txt`

### G3. API documentation
- Public APIs: an OpenAPI spec or structured docs linked from `/llms.txt`, including auth requirements

### G4. Pricing
- SaaS or paid products: pricing reachable as plain HTML or Markdown, tiers and limits stated

## H. Content freshness

### H1. Human-agent sync
- Agent-facing files (`llms.txt`, JSON-LD, any opt-in endpoints) match the current visible site: counts, URLs, names, descriptions

### H2. No placeholders
- No "Lorem ipsum", "TODO", "Coming soon", stale dates, or broken links
