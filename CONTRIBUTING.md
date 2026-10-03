# Contributing

## Add a skill

Required:

- `category/skill-name/SKILL.md`
- YAML `name` matching the directory, and a `description` in third person that says what the skill does and when to use it ("Use when ..."), with specific trigger terms, under 250 characters
- A row in `README.md` and `README.zh-CN.md`
- The path in `.claude-plugin/plugin.json`
- One line in the category `README.md` when that directory has one

`SKILL.md` is for the agent. Write the failure and the action. Leave out anything the upstream docs already say, and anything a competent agent already does. A few sentences per fact.

No per-skill `README.md`. Add `references/`, `scripts/`, or `assets/` only when the agent cannot act from `SKILL.md` alone. Name every such file in `SKILL.md` with when to read or run it, and start any reference over 100 lines with a Contents list. `agents/openai.yaml` is optional Codex UI metadata and uses the `interface:` schema (see `maintenance/skill-repo-maintenance/references/compression.md`).

## Constraints

- No personal paths, usernames, or credentials
- Every command in the skill is one you ran
- Index edits belong with the skill they describe
