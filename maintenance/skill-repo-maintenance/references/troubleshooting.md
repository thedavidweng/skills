# Troubleshooting: 2% Context Budget

Symptom: `Exceeded skills context budget of 2%. Loaded skill descriptions were truncated...`

## Root cause A: duplicate skill directories (most common)

The scanner loads every `SKILL.md` under the repo. If the same skill exists twice (e.g. installed copies under `.agents/skills/` alongside canonical category folders), every description counts twice.

Diagnose: list all `SKILL.md` paths and look for doubled directory names; sum frontmatter `description` lengths.

Fix: delete the stale copy (usually `.agents/skills/`), add installer dirs (`.agents/`, `.claude/`, etc.) to `.gitignore`, and reinstall cleanly from remote.

## Root cause B: long descriptions

Keep every description under 200 characters. Move trigger conditions into the SKILL.md body, never the frontmatter. Find offenders by printing each description length and compress the long ones.
