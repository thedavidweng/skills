---
name: json-resume
description: "Manage resumes using the JSON Resume open standard with the resumed CLI. Use this skill when the user needs to create, edit, render, or export a resume. Supports multiple themed versions, job-specific customizations, and auto-publishing to the JSON Resume Registry via GitHub Actions."
compatibility: "Requires Node.js 18+ and npm. PDF export additionally requires puppeteer."
metadata:
  author: thedavidweng
  version: "1.0"
---

# JSON Resume — Structured Resume Management

> Tools:
> - [JSON Resume](https://jsonresume.org/) — Open standard for resume data
> - [resumed](https://github.com/rbardini/resumed) (v6.1.0) — Lightweight JSON Resume CLI builder
> - [puppeteer](https://pptr.dev/) — Required for PDF export only
> - Theme: user's choice — browse at https://jsonresume.org/themes

## Philosophy

- **Data and style are separate.** Resume content lives in `.json` files. Themes control appearance.
- **One generic resume + N targeted variants.** The generic version is the canonical source; targeted versions are derived copies.
- **Only the generic version gets published.** Targeted versions stay local.
- **PDF is a build artifact.** Generate on demand, never persist.

## Prerequisites & Installation

### 1. Check Node.js

```bash
command -v node >/dev/null 2>&1 || { echo "ERROR: Node.js not installed. Get it from https://nodejs.org/ or run: brew install node"; exit 1; }
node --version  # Should be v18+
```

### 2. Install project dependencies

```bash
cd <resume-directory>
npm install
```

This installs from `package.json`. Example:

```json
{
  "dependencies": {
    "resumed": "^6.1.0",
    "jsonresume-theme-even": "^0.20.0",
    "puppeteer": "^24.42.0"
  }
}
```

| Package | Purpose | Required for |
|---------|---------|-------------|
| `resumed` | CLI: render, export, validate, init | All operations |
| `jsonresume-theme-*` | Visual theme (**user's choice**) | render & export |
| `puppeteer` | Headless Chrome for PDF generation | export (PDF) only |

### 3. Verify installation

```bash
npx resumed --help
```

### Choose a theme — ASK THE USER

Resumed does **NOT** bundle any theme. The user must pick and install one.

**Browse themes:** https://jsonresume.org/themes

Install the chosen theme as a dependency:

```bash
npm install jsonresume-theme-even  # example — replace with user's choice
```

Or specify the theme in `resume.json` via the `.meta.theme` field:

```json
{
  "meta": {
    "theme": "jsonresume-theme-even"
  }
}
```

When no `.meta.theme` is set, the `-t` flag is required on every render/export command.

## Project Structure

```
resume/
├── resume.json                      # Generic version (→ published to registry)
├── resume-{target-slug}.json        # Targeted version (local only)
├── package.json                     # Dependencies: resumed + theme
├── node_modules/
└── README.md
```

## JSON Resume Schema (key fields)

Full spec: https://jsonresume.org/schema

```json
{
  "basics": {
    "name": "Full Name",
    "label": "Professional Title",
    "email": "email@example.com",
    "summary": "2-3 sentence professional summary",
    "location": { "city": "City", "countryCode": "XX", "region": "Region" },
    "profiles": [
      { "network": "LinkedIn", "username": "handle", "url": "https://..." }
    ]
  },
  "work": [
    {
      "name": "Company",
      "position": "Title",
      "startDate": "YYYY-MM-DD",
      "endDate": "YYYY-MM-DD",
      "summary": "Role summary",
      "highlights": ["Achievement 1", "Achievement 2"]
    }
  ],
  "education": [
    {
      "institution": "University",
      "area": "Major (Minor: X)",
      "studyType": "Bachelor/Master's",
      "startDate": "YYYY-MM-DD",
      "endDate": "YYYY-MM-DD"
    }
  ],
  "skills": [
    { "name": "Category", "keywords": ["Skill1", "Skill2"] }
  ],
  "volunteer": [],
  "projects": [],
  "meta": {
    "version": "v1.0.0",
    "lastModified": "ISO-8601",
    "pdfRenderOptions": {
      "margin": { "top": "0.5in", "right": "0.5in", "bottom": "0.5in", "left": "0.5in" }
    }
  }
}
```

## Commands

All commands use `npx resumed` (runs the locally-installed version).

### Render to HTML

```bash
npx resumed render "resume.json" \
  -t <theme-package-name> \
  -o out.html
```

If `.meta.theme` is set in the JSON file, `-t` can be omitted:

```bash
npx resumed render "resume.json" -o out.html
```

### Export to PDF

```bash
npx resumed export "resume.json" \
  -t <theme-package-name> \
  -o resume.pdf
```

### Validate resume JSON

```bash
npx resumed validate "resume.json"
```

### Create a sample resume

```bash
npx resumed init resume-new.json
```

### Command reference

| Command | Description | Key flags |
|---------|-------------|-----------|
| `render` | Render to HTML | `-o` output, `-t` theme |
| `export` | Export to PDF (requires puppeteer) | `-o` output, `-t` theme, `--puppeteer-arg` |
| `validate` | Validate JSON against schema | — |
| `init` | Create sample `resume.json` | — |

## Workflow

### Creating a targeted resume

1. Copy the generic resume: `cp resume.json resume-{slug}.json`
2. Modify fields to match the target job description:
   - Adjust `basics.label` to match the role title
   - Rewrite `basics.summary` to emphasize relevant experience
   - Reorder/filter `work` entries by relevance
   - Adjust `highlights` to mirror JD keywords
   - Modify `skills` categories to match JD requirements
3. Render/export to verify appearance

### Editing rules

- **Dates**: Use `YYYY-MM-DD` format (e.g., `"2023-09-01"`)
- **No end date** = current role (omit the `endDate` field entirely)
- **Highlights**: Use action verbs, quantify achievements (numbers, percentages)
- **Summary**: 2-3 sentences max, tailored to target audience

## Publishing (Generic Version Only)

The generic `resume.json` auto-publishes to the JSON Resume Registry via GitHub Actions:

```
push resume/resume.json
  → GitHub Actions (gist.yml)
    → Updates Gist
      → registry.jsonresume.org/{username} refreshes
```

**Only `resume.json` triggers the action.** Targeted versions (`resume-*.json`) do not publish.

## Naming Convention

```
resume.json                    # Generic (published)
resume-{target-slug}.json      # Targeted (local only)
```

Slug format: lowercase, hyphenated description of the role.

Examples:
- `resume-ubc-cel-coordinator.json`
- `resume-stripe-frontend-eng.json`
- `resume-amazon-pm.json`

## Common Mistakes to Avoid

1. **Do NOT edit the generic resume to target a specific job** — copy it first
2. **Do NOT switch themes without testing** — themes have different layouts and may break pagination
3. **Do NOT persist PDF files** — generate on demand
4. **Do NOT push targeted versions to the registry** — only `resume.json` should be public
5. **Do NOT use relative dates** ("3 years ago") — use absolute `YYYY-MM-DD`
6. **Do NOT exceed 2 pages** — keep highlights concise and targeted
7. **Do NOT forget to install a theme** — resumed ships with NO default theme
