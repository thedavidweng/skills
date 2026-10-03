---
name: cover-letter
description: 'Writes cover letters from a calibrated Typst template and compiles them to PDF. Use when the user wants a cover letter for a job application.'
---

Save only the `.typ` source; regenerate the PDF on demand. Requires the `typst` CLI and Times New Roman (`typst fonts | grep "Times New Roman"`).

**Ask paper size first:** `"us-letter"` (North America) or `"a4"`. Nothing else varies per letter.

1. Copy `assets/template.typ` to `cover-letter-{slug}.typ`.
2. Set `paper:`, then replace every `{{PLACEHOLDER}}`. Delete recipient lines you have no value for; keep 3–4 tailored body paragraphs.
3. `typst compile cover-letter-{slug}.typ` and check that it fits one page.

Edits touch content only, never the preamble or `#v()` spacing. Typst: `\` breaks a line, escape `@` as `\@` (emails), `//` starts a comment. Body paragraphs are separated by blank lines only.

**Don't:** turn hyphenation on; add `#v()` between body paragraphs; widen the gap after `Sincerely,`; commit PDFs.
