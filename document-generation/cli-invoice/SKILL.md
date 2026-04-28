---
name: cli-invoice
description: "Generate professional invoices as PDF using the maaslalani/invoice CLI. Use this skill when the user needs to create, regenerate, or manage invoices. The invoice is defined entirely by its CLI command — no files to save except the command itself. Store commands in Obsidian or any note-taking app for on-demand regeneration."
compatibility: "Requires the invoice CLI. Install: brew install invoice (macOS) or go install github.com/maaslalani/invoice@main (requires Go)."
metadata:
  author: thedavidweng
  version: "1.0"
---

# CLI Invoice — Command-as-Source Invoice Management

> Tool: [maaslalani/invoice](https://github.com/maaslalani/invoice) — Command line invoice generator

## Philosophy

- **The CLI command IS the source file.** No JSON, no YAML, no template file — just the command.
- **Store the command, not the PDF.** Keep each invoice's generate command in a note (e.g., Obsidian code block). Regenerate on demand.
- **One command = one invoice.** Each invocation produces a self-contained PDF.

## Prerequisites & Installation

Check that `invoice` is available:

```bash
command -v invoice >/dev/null 2>&1 || { echo "ERROR: invoice CLI not installed"; exit 1; }
```

### Install methods (pick one)

| Method | Command | Requires |
|--------|---------|----------|
| **Homebrew** (recommended on macOS) | `brew install invoice` | Homebrew |
| **Go install** | `go install github.com/maaslalani/invoice@main` | Go 1.19+ |
| **Binary download** | Download from [GitHub Releases](https://github.com/maaslalani/invoice/releases) | — |

> **Note:** The Go install path uses `@main`, not `@latest`. This is per the upstream README.

### Verify installation

```bash
invoice --help
```

## Command Syntax

```bash
invoice generate \
  --from "Sender Name" \
  --to "Recipient Name/Company" \
  --item "Description" --quantity <N> --rate <PRICE> \
  [--item "Another item" --quantity <N> --rate <PRICE>] \
  [--tax <DECIMAL>] \
  [--discount <DECIMAL>] \
  [--note "Additional notes"] \
  [--output <path.pdf>]
```

### Parameters

| Flag | Required | Description |
|------|----------|-------------|
| `--from` | Yes | Sender name or business |
| `--to` | Yes | Recipient name or business |
| `--item` | Yes (1+) | Line item description. Repeat with `--quantity` and `--rate` for each item |
| `--quantity` | Yes | Quantity for the preceding `--item` |
| `--rate` | Yes | Unit price for the preceding `--item` |
| `--tax` | No | Tax rate as decimal (e.g., `0.13` for 13%) |
| `--discount` | No | Discount rate as decimal (e.g., `0.15` for 15%) |
| `--note` | No | Footer note (e.g., payment terms) |
| `--output` | No | Output path (default: `invoice.pdf` in current directory) |
| `--import` | No | Import data from a JSON or YAML file (see [Import from file](#import-from-file)) |

### Example

```bash
invoice generate \
  --from "Jane Smith" \
  --to "Acme Corp" \
  --item "Web Development" --quantity 40 --rate 75 \
  --item "Design Consultation" --quantity 8 --rate 100 \
  --tax 0.05 \
  --note "Payment due within 30 days. E-transfer preferred."
```

### Import from file

For complex invoices, use `--import` with a JSON or YAML config:

```bash
invoice generate --import data.json --output my-invoice.pdf
```

Example `data.json`:

```json
{
  "from": "Jane Smith",
  "to": "Acme Corp",
  "tax": 0.05,
  "items": ["Web Development", "Design Consultation"],
  "quantities": [40, 8],
  "rates": [75, 100]
}
```

## Workflow

### Creating a new invoice

1. Gather invoice details from the user: sender, recipient, line items, tax, notes
2. Construct the `invoice generate` command
3. Run the command to produce the PDF
4. Open for review: `open invoice.pdf` (macOS)
5. **Store the command** — the user should save this command in their notes for future regeneration

### Regenerating an invoice

Just re-run the stored command. The PDF is recreated identically.

### Storage Pattern (Obsidian example)

The user stores invoice commands in their note-taking app. Example Obsidian note:

````markdown
## Invoices

### 2026-04 — Acme Corp

```bash
invoice generate \
  --from "Jane Smith" \
  --to "Acme Corp" \
  --item "Web Development" --quantity 40 --rate 75 \
  --item "Design Consultation" --quantity 8 --rate 100 \
  --tax 0.05 \
  --note "Payment due within 30 days."
```

### 2026-03 — Beta LLC

```bash
invoice generate \
  --from "Jane Smith" \
  --to "Beta LLC" \
  --item "Monthly Retainer" --quantity 1 --rate 2000 \
  --tax 0.12 \
  --note "March 2026 retainer."
```
````

Each code block is a complete, self-contained invoice. Copy-paste and run.

## Output

- Default output: `invoice.pdf` in the current working directory
- Use `--output` to specify a different path or filename
- The PDF is a build artifact — do not archive it, regenerate when needed

## Environment Variables

The `invoice` CLI supports environment variables for repeated sender info:

| Variable | Description |
|----------|-------------|
| `INVOICE_FROM` | Default sender name |
| `INVOICE_TO` | Default recipient name |
| `INVOICE_LOGO` | Path to logo image (PNG) to include on invoice |
| `INVOICE_TAX` | Default tax rate (decimal) |
| `INVOICE_RATE` | Default unit rate |

```bash
export INVOICE_FROM="Jane Smith"
export INVOICE_LOGO=/path/to/logo.png
export INVOICE_TAX=0.05
export INVOICE_RATE=75
```

When set, these become defaults that can be omitted from individual commands.

## Common Mistakes to Avoid

**Do NOT forget `--quantity` and `--rate` after each `--item`** — they are required per item
**Do NOT use percentage for `--tax`** — use decimal (0.13, not 13)
**Do NOT use percentage for `--discount`** — use decimal (0.15, not 15)
**Do NOT omit `--from` or `--to`** — both are required
