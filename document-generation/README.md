# Document Generation Skills

Text-as-source document workflows. Each skill produces PDF on demand from a lightweight source format — no persistent PDF files needed.

**Core principle:** Manage source files (`.typ`, `.json`, CLI commands), not build artifacts (PDF). Like code: you version-control source, not binaries.

| Skill | Source Format | CLI | Description |
|-------|--------------|-----|-------------|
| [cover-letter](cover-letter/SKILL.md) | `.typ` (Typst markup) | `typst compile` | Professional cover letters with calibrated typography. Template enforces consistent font, margins, and spacing. |
| [json-resume](json-resume/SKILL.md) | `.json` (JSON Resume standard) | `npx resumed render/export` | Structured resume management. Data/style separation, themed rendering, auto-publish to JSON Resume Registry. |
| [cli-invoice](cli-invoice/SKILL.md) | CLI command itself | `invoice generate` | Invoice generation where the command is the source file. Store commands in notes, regenerate anytime. |

## Quick Reference

```bash
# Cover letter → PDF
typst compile cover-letter-acme.typ

# Resume → HTML
npx resumed render resume.json -t @jsonresume/jsonresume-theme-consultant-polished -o out.html

# Resume → PDF
npx resumed export resume.json -t @jsonresume/jsonresume-theme-consultant-polished -o resume.pdf

# Invoice → PDF
invoice generate --from "..." --to "..." --item "..." --quantity 1 --rate 100
```

## Why Three Different Tools?

Each document type has fundamentally different needs:

| Document | Nature | Why This Tool |
|----------|--------|---------------|
| **Resume** | Structured data, multiple themes | JSON Resume separates data from presentation — swap themes without rewriting content |
| **Cover Letter** | Free-form text, precise typography | Typst gives fine layout control with readable syntax — like Markdown that can do real typesetting |
| **Invoice** | Parameterized fields, no layout decisions | A CLI flag set captures the entire invoice — the command itself is the smallest possible source |
