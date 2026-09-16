# Hermes Migration

Move skills from `~/.hermes/skills/` (or another agent's skill directory) into this repo.

1. Discover candidates: `find ~/.hermes/skills -name "SKILL.md" | sort`.
2. Evaluate for generality. Reject or defer skills containing specific people's names, institutions, hardcoded personal paths, single-user data-export formats, or account-bound tokens/keys. Keep generic rules, workflows, and decision frameworks.
3. Strip personal content: names become generic examples, institutions become type descriptions, real contact data becomes placeholders, personal paths become template variables like `{{vault_root}}`.
4. Create standard structure: `skill-name/SKILL.md` (preserve `references/` if the original had templates or scripts).
5. Verify the folder name matches the frontmatter `name:` field.
6. Update catalog docs: root and category README skill tables, install examples, and `.claude-plugin/plugin.json` if the skill belongs in the default menu.
7. Test from remote after pushing: `npx skills add thedavidweng/skills --list 2>&1 | grep new-skill-name`, then install with `--skill new-skill-name -y`. Local changes are invisible until pushed.
8. After renames, remove stale installs (`npx skills remove old-name -y`) and reinstall under the new names.
