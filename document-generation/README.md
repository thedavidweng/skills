# Document Generation Skills

Text-as-source document workflows: keep the source (`.typ`, a CLI command), generate the PDF on demand, never commit PDFs.

| Skill | Source | CLI | Description |
|-------|--------|-----|-------------|
| [cover-letter](cover-letter/SKILL.md) | `.typ` (Typst) | `typst compile` | Cover letters from a calibrated template with fixed font, margins, and spacing. |
| [cli-invoice](cli-invoice/SKILL.md) | The CLI command | `invoice generate` | Invoices where the command is the source. Store it in notes, regenerate anytime. |

```bash
typst compile cover-letter-acme.typ
invoice generate --from "..." --to "..." --id "..." --date "..." --due "..." --item "..." --quantity 1 --rate 100
```
