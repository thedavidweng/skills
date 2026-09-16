---
name: json-resume
description: 'Manage resumes with the JSON Resume standard + resumed CLI. Triggers on ''resume'', ''render resume'', or ''export resume''.'
---

Content in `.json`, appearance in themes. One generic `resume.json` (published) + targeted `resume-{slug}.json` copies (local). PDFs are build artifacts. Needs Node.js; PDF needs puppeteer.

Setup: `npm install` (resumed + theme + puppeteer), `npx resumed --help`. **Ask theme first** — none is bundled ([themes](https://jsonresume.org/themes)); set `.meta.theme` or pass `-t` every time. Schema: https://jsonresume.org/schema.

```bash
npx resumed render "resume.json" -t <theme> -o out.html
npx resumed export "resume.json" -t <theme> -o resume.pdf
npx resumed validate "resume.json"
```

Tailor copies (label, summary, highlights mirror the JD), render to verify, push only `resume.json` to publish.

**Don't:** edit generic for one job (copy first); switch themes untested; persist PDFs; publish targeted copies; relative dates (absolute `YYYY-MM-DD`); let highlights sprawl — keep every resume tight.
