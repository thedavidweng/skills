# Format Compliance and Compression

## Compliance checklist

| Check | Rule |
|---|---|
| No README.md in skill dir | Root and category docs only |
| Frontmatter is only `name` + `description` | No other fields |
| `name` | ≤64 chars, lowercase letters, digits, hyphens; equals the folder name; no "anthropic" or "claude" |
| `description` | Third person; says what the skill does and when to use it ("Use when ..."); specific trigger terms, not generic verbs like "clean up"; ≤250 chars to stay inside the Codex 2% skill-list budget (hard limit 1,024) |
| `agents/openai.yaml` (optional) | Codex schema only: `interface.display_name`, `interface.short_description` (25–64 chars), `interface.default_prompt` mentioning `$skill-name`. Quote all string values. |
| SKILL.md < 500 lines | Official recommendation |
| References one level deep | Every file in `references/`, `scripts/`, `assets/` is named in SKILL.md with when to read or run it |
| Reference files > 100 lines | Start with a Contents list |
| No duplicate skill copies | Duplicates trigger the 2% budget warning |

## Compression

When a SKILL.md exceeds 500 lines: move code and config examples to `references/` and leave a one-line pointer; delete restated explanations; collapse multi-step prose into bullets; remove stale placeholders and deprecated commands.
