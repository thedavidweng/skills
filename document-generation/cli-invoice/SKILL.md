---
name: cli-invoice
description: 'Generate invoices via the maaslalani/invoice CLI. Triggers on ''invoice'', ''generate invoice'', or ''billing''.'
---

**The command IS the source.** Store each invoice's command in your notes (one fenced block per invoice); regenerate on demand. Never persist PDFs. Needs the `invoice` CLI (`brew install invoice`).

```bash
invoice generate --from "Name" --to "Client" \
  --item "Work" --quantity 40 --rate 75 [--tax 0.05] \
  [--note "E-transfer to addr@example.com"] [--output a.pdf]
```

`--quantity`/`--rate` required per item. `--import` takes parallel arrays (`items`/`quantities`/`rates`), not objects. `INVOICE_FROM/TO/LOGO/TAX/RATE` env vars become defaults.

**Don't:** floats in `--quantity` (scale first: `qty×10^d` int, `rate/10^d`, assert the total — tool fails with `strconv.Atoi`); percentages for tax/discount (decimals); separate payment sections (embed in `--note`, per-client addresses differ); omit `--from`/`--to`.
