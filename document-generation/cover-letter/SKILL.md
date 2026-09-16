---
name: cover-letter
description: 'Generate a cover letter PDF via Typst. Triggers on ''cover letter'', ''job application'', or ''application letter''.'
---

Save only the `.typ` source; regenerate the PDF on demand. Requires the `typst` CLI + Times New Roman.

**Ask paper size first:** `"us-letter"` (North America) or `"a4"`. Nothing else varies per letter.

```typ
#set page(paper: "us-letter", margin: (top: 1in, bottom: 0.75in, left: 1in, right: 1in))
#set text(font: "Times New Roman", size: 11pt, hyphenate: false)
#set par(justify: true, leading: 0.75em, spacing: 1.18em)
```

Structure: right-aligned sender block + `#v(0.6em)` + date → `#v(1.6em)` → recipient → `#v(1.5em)` → `Dear ...` → a few tailored body paragraphs → `#v(0.8em)` → right-aligned `Sincerely,` + `#v(0.55em)` + name. Body paragraphs separated by blank lines only.

Typst notes: `\` for line breaks, `\@` escape, `//` comments. Save as `cover-letter-{slug}.typ`; edits touch content, never preamble or spacing.

**Don't:** hyphenation on; `#v()` between paragraphs; signature gap after Sincerely; PDF in version control.
