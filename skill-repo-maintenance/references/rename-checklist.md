# Skill Rename Checklist

Use this checklist when renaming one or more skills in a repo.

## Per Skill

- [ ] Rename folder: `mv old-name/ new-name/`
- [ ] Update `name:` in `new-name/SKILL.md` frontmatter
- [ ] Update skill table entries in parent README.md
- [ ] Update "See Also" links in sibling README.md files
- [ ] Update installation command examples

## Repo-wide

- [ ] Remove old installed skill symlinks: `npx skills remove old-name-1 old-name-2 ... -y`
- [ ] Test install with new names: `npx skills add user/repo --skill new-name-1 ... -y`
- [ ] Run `npx skills add user/repo --full-depth --list` to confirm names are discoverable
- [ ] `git add -A && git commit`
- [ ] `git push` — required; `npx skills add` clones from remote
