---
name: cover-letter
description: "Generate professional cover letters as PDF using Typst. Use this skill when the user needs to create, edit, or regenerate a cover letter for a job application. Covers drafting content, formatting in Typst markup, and compiling to PDF. Outputs a .typ source file that can be version-controlled and compiled on demand."
compatibility: "Requires typst CLI. Install: brew install typst (macOS), winget install Typst.Typst (Windows), or cargo install --locked typst-cli (Rust). Also requires Times New Roman font (pre-installed on macOS/Windows)."
metadata:
  author: thedavidweng
  version: "1.0"
---

# Cover Letter — Typst-based PDF Generation

> Tool: [Typst](https://typst.app/) ([GitHub](https://github.com/typst/typst)) — A markup-based typesetting system. Modern, lightweight alternative to LaTeX.

## Philosophy

- **Only save the `.typ` source file.** Never persist the PDF — generate it on demand with `typst compile`.
- The `.typ` file is the single source of truth. It should be human-readable and editable.
- When creating a new cover letter, always start from the template below. Do NOT deviate from the typographic settings.

## Prerequisites & Installation

Check that `typst` is available:

```bash
command -v typst >/dev/null 2>&1 || { echo "ERROR: typst not installed"; exit 1; }
typst --version
```

### Install methods (pick one)

| Method | Command | Size |
|--------|---------|------|
| **Homebrew** (recommended on macOS) | `brew install typst` | ~40 MB |
| **Cargo** (Rust) | `cargo install --locked typst-cli` | Builds from source |
| **Binary download** | Download from [GitHub Releases](https://github.com/typst/typst/releases) | ~40 MB |

> **Note:** Typst is a single binary (~40 MB). No texlive, no multi-GB downloads. This is the whole point of choosing Typst over LaTeX for cover letters.

### Font requirement

The template uses **Times New Roman**, which is pre-installed on macOS. On Linux, install it via `ttf-mscorefonts-installer` or substitute with a compatible serif font.

## Paper Size — ASK THE USER

Before creating a cover letter, **ask the user which paper size to use**:

| Option | Typst value | When to use |
|--------|-------------|-------------|
| **US Letter** | `"us-letter"` | North American employers (US, Canada) |
| **A4** | `"a4"` | International / European employers |

Do NOT assume. If the user doesn't specify, ask. This is the only parameter that varies per letter.

## Template — MANDATORY FORMAT

Every cover letter MUST use this exact preamble. Only `paper:` changes based on user choice — everything else is fixed:

```typ
#set page(paper: "us-letter", margin: (top: 1in, bottom: 0.75in, left: 1in, right: 1in))  // or "a4"
#set text(font: "Times New Roman", size: 11pt, hyphenate: false)
#set par(justify: true, leading: 0.75em, spacing: 1.18em)
```

### Typographic Constraints (NON-NEGOTIABLE)

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Paper | `"us-letter"` or `"a4"` — **ask user** | Depends on target country |
| Top margin | 1 inch | Standard business letter |
| Bottom margin | 0.75 inch | Slightly tighter for single-page fit |
| Left/Right margins | 1 inch | Standard |
| Font | Times New Roman, 11pt | Professional serif |
| Hyphenation | OFF | Prevents ugly word breaks |
| Line leading | 0.75em | Matches ~15.4pt actual spacing |
| Paragraph spacing | 1.18em | ~20.5pt between paragraphs |

### Document Structure

```typ
// ── Sender address (right-aligned) ──
#align(right)[
  {{SENDER_NAME}} \
  {{SENDER_EMAIL}} \
  {{SENDER_CITY}}, {{SENDER_REGION}}, {{SENDER_COUNTRY}}
  #v(0.6em)
  {{DATE}}
]

#v(1.6em)

// ── Recipient ──
{{RECIPIENT_NAME_OR_TITLE}} \
{{RECIPIENT_ORG}} \
{{RECIPIENT_DEPT}} \
{{RECIPIENT_FACULTY_OR_DIVISION}}

#v(1.5em)

// ── Salutation ──
Dear {{SALUTATION}},

// ── Body paragraphs ──
{{PARAGRAPH_1}}

{{PARAGRAPH_2}}

{{PARAGRAPH_3}}

{{PARAGRAPH_4}}

// ── Closing ──
#v(0.8em)
#align(right)[
  Sincerely,
  #v(0.55em)
  {{SENDER_NAME}}
]
```

### Spacing Rules — Critical Details

These exact `#v()` values produce correct visual spacing. DO NOT MODIFY:

| Location | Value | Purpose |
|----------|-------|---------|
| After address, before date | `#v(0.6em)` | Small gap between address lines and date |
| After date, before recipient | `#v(1.6em)` | Section separator |
| After recipient, before salutation | `#v(1.5em)` | Section separator |
| After last body paragraph, before closing | `#v(0.8em)` | Slightly larger than paragraph gap |
| Between "Sincerely," and name | `#v(0.55em)` | Tight — electronic letter, no signature space |

### Typst Syntax Reminders

- Line breaks within a block: use `\` (backslash + space after)
- The `@` symbol must be escaped: `\@`
- Comments: `// text`
- Do NOT use `#parbreak()` between body paragraphs — just leave a blank line
- Do NOT add `#v()` between body paragraphs — `par(spacing: 1.18em)` handles it

## Workflow

### Creating a new cover letter

1. Ask the user for:
   - **Paper size**: US Letter or A4?
   - Target role, company, department
   - Key qualifications to highlight
2. Draft 3-4 body paragraphs tailored to the job description
3. Fill in the template with the content (set `paper:` per user choice)
4. Save as `cover-letter-{slug}.typ` (slug = lowercase, hyphenated short name for the role)
5. Compile: `typst compile cover-letter-{slug}.typ`
6. Open for review: `open cover-letter-{slug}.pdf` (macOS)

### Editing an existing cover letter

1. Read the `.typ` file
2. Make changes to the content (NOT the preamble or spacing)
3. Recompile: `typst compile <filename>.typ`

### Regenerating PDF

```bash
typst compile cover-letter-{slug}.typ
```

That's it. One command. No need to save the PDF permanently.

## File Naming Convention

```
cover-letter-{target-slug}.typ
```

Examples:
- `cover-letter-ubc-cel.typ`
- `cover-letter-amazon-sde.typ`
- `cover-letter-stripe-pm.typ`

## Common Mistakes to Avoid

**Do NOT enable hyphenation** — it creates ugly word breaks like "coordi-nating"
**Do NOT add extra `#v()` between body paragraphs** — paragraph spacing is already set
**Do NOT leave a large gap between Sincerely and the name** — this is electronic, not hand-signed
**Do NOT save the PDF to version control** — only the `.typ` file matters
