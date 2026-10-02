# Contributing

## Add a skill

Required:

- `category/skill-name/SKILL.md`
- YAML `name` matching the directory, and a `description` that says when to load it
- A row in `README.md` and `README.zh-CN.md`
- The path in `.claude-plugin/plugin.json`
- One line in the category `README.md` when that directory has one

`SKILL.md` is for the agent. Write the failure and the action. Leave out anything the upstream docs already say, and anything a competent agent already does. A few sentences per fact.

No per-skill `README.md`. Add `references/`, `scripts/`, or `agents/openai.yaml` only when the agent cannot act from `SKILL.md` alone.

## Constraints

- No personal paths, usernames, or credentials
- Every command in the skill is one you ran
- Index edits belong with the skill they describe
