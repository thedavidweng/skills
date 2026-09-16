# Format Compliance and Compression

## Compliance checklist

| Check | Rule |
|---|---|
| No README.md in skill dir | No extraneous documentation; root/category docs only |
| Frontmatter is ONLY `name` + `description` | No other fields |
| `agents/openai.yaml` exists | Recommended UI metadata |
| Description < 250 chars | Prevents budget overflow |
| SKILL.md < 500 lines | Official recommendation |
| Folder name == `name:` field | Required for CLI matching |
| No duplicate skill copies | Duplicates trigger the 2% budget warning |

## Compression

When a SKILL.md exceeds 500 lines: move code and config examples to `references/` and leave a one-line pointer; delete restated explanations; collapse multi-step prose into bullets; remove stale placeholders and deprecated commands.
