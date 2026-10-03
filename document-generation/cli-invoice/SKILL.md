---
name: cli-invoice
description: 'Generates PDF invoices with the maaslalani/invoice CLI, storing the command as the source. Use when the user wants to create or regenerate an invoice.'
---

**The command IS the source.** Store each invoice's command in your notes (one fenced block per invoice); regenerate on demand. Never persist PDFs. Needs the `invoice` CLI (`brew install invoice`).

```bash
invoice generate --from "Name" --to "Client" \
  --id "2026-001" --date "Mar 31, 2026" --due "Apr 14, 2026" \
  --item "Work" --quantity 40 --rate 75 [--tax 0.05] \
  [--note "E-transfer to addr@example.com"] [--output a.pdf]
```

Repeat `--item`/`--quantity`/`--rate` once per line item. `--import file.json` takes parallel arrays (`items`/`quantities`/`rates`), not objects.

**Pin `--id`, `--date`, `--due`.** They default to today's date, so an unpinned command regenerates a different invoice. **Always pass `--from`/`--to`**: the defaults are placeholder company names. The CLI reads no environment variables.

**Don't:** floats in `--quantity` (the tool fails with `strconv.Atoi`; scale first: `qty×10^d` as an int, `rate/10^d`, then check the total); percentages for tax/discount (use decimals, `0.05`); separate payment sections (embed in `--note`, since per-client payment details differ).
