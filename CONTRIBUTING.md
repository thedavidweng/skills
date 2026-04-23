# Contributing

Thanks for your interest in improving these skills.

## How to Contribute

1. **Open an issue** first for bug reports or feature requests
2. **Fork the repo** and create a feature branch
3. **Follow the skill format** — each skill needs:
   - `README.md` — human-friendly overview
   - `SKILL.md` — agent-facing workflow spec
   - `references/` — supporting docs
4. **Test commands** — all yutu/CLI commands must be verified against the actual tool
5. **Submit a PR** with a clear description of changes

## Skill Format Checklist

- [ ] YAML front matter with `name` and `description`
- [ ] `README.md` with quick start and examples
- [ ] `SKILL.md` with workflow, commands, pitfalls, and decision logic
- [ ] Commands tested against real tools (yutu v0.10+, youtube-transcript-api v2+)
- [ ] No hardcoded personal paths or credentials
