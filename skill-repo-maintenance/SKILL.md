---
name: skill-repo-maintenance
description: "Maintain and reorganize agent skills within a skills repository. USE THIS SKILL whenever the user wants to: rename skills, reorganize skill folders, fix broken skill installation commands, update skill names and cross-references, or troubleshoot 'No matching skills found' errors from the skills CLI. Triggers on 'rename skill', 'move skill', 'reorganize skills', 'skill not found', 'No matching skills found', or when updating skill metadata."
---

# Skill Repo Maintenance

Maintain an Agent Skills-compatible repository: rename skills, fix installation commands, and avoid CLI pitfalls.

---

## Pitfall: `--skill` Uses Exact Matching, Not Glob

The `npx skills add` `--skill` flag does **not** support shell globs.

```bash
# WRONG — produces "No matching skills found for: wiki*"
npx skills add thedavidweng/skills --skill "wiki*"

# CORRECT — list each skill individually
npx skills add thedavidweng/skills \
  --skill wiki-core \
  --skill wiki-inline-linking \
  --skill wiki-slug-rename
```

Use `--all` to install every skill in a repo without naming them.

```bash
npx skills add thedavidweng/skills --full-depth --all
```

---

## Renaming a Skill

A skill name appears in three places. All must stay in sync.

### 1. Folder name

```bash
mv old-name/ new-name/
```

### 2. SKILL.md frontmatter

```yaml
---
name: new-name
description: ...
---
```

### 3. Cross-references

Update every README.md that links to the skill:
- Parent README skill tables
- Sibling README "See Also" sections
- Installation command examples

### 4. Clean up old installations

```bash
npx skills remove old-name -y
```

### 5. Verify

```bash
npx skills add thedavidweng/skills --full-depth --skill new-name -y
```

---

## Adding a `wiki-` Prefix to a Skill Family

When unifying a family of skills under a common prefix:

1. Rename each folder: `slug-rename/` -> `wiki-slug-rename/`
2. Update `name:` in each SKILL.md
3. Update all README cross-references (parent + siblings)
4. Remove old skill installations
5. Test install with new names
6. Commit and push — `npx skills add` clones from remote, so local changes alone do not affect installs

---

## Migrating Skills from Hermes Agent Directory

When moving skills from `~/.hermes/skills/` (or another agent's skill directory) into the thedavidweng/skills repository:

### 1. Discover candidates

```bash
find ~/.hermes/skills -name "SKILL.md" | sort
```

### 2. Evaluate each skill for generality

Read the SKILL.md. Reject or defer if it contains:
- Specific people's names, schools, or institutions (e.g., "some-school", "some-university", "some-school")
- Hardcoded paths to the user's personal wiki or repos
- Personal data export formats specific to one individual
- Platform tokens, API keys, or PAT references tied to a specific account

Skills that ARE good candidates: those with generic rules, workflows, and decision frameworks that apply to any user with a similar setup.

### 3. Strip personal content

Before adding to the repo, scrub:
- Specific names → replace with generic examples (e.g., "某中学" instead of "some-school")
- Specific institution names → describe by type (e.g., "high school international program")
- Real contact data → use placeholder patterns
- Personal file paths → use template variables like `{{vault_root}}`

### 4. Create standard structure

Each migrated skill needs:

```
skill-name/
├── README.md    # Human-facing overview
└── SKILL.md     # Full agent workflow spec
```

If the original had a `references/` directory with templates or scripts, preserve it.

### 5. Verify naming

Ensure the folder name matches the `name:` field in SKILL.md frontmatter. If not, rename the folder or update the field.

### 6. Update catalog documentation

Add the new skill to:
- `wiki/README.md` skill table (if it's a wiki skill)
- Root `README.md` skill table
- Installation command examples

### 7. Test before pushing

```bash
# Verify the skill appears in discovery
npx skills add thedavidweng/skills --full-depth --list 2>&1 | grep new-skill-name

# Verify it installs cleanly
npx skills add thedavidweng/skills --full-depth --skill new-skill-name -y
```

**Important**: `npx skills add` clones from GitHub. Local changes are invisible until committed and pushed.

### 8. Clean up old installations after renames

When skill names change (e.g., during prefix unification), stale symlinks remain in `.agents/skills/`:

```bash
# Remove old skill installations
npx skills remove old-skill-name old-skill-name-2 -y

# Install with new names
npx skills add thedavidweng/skills --full-depth --skill new-skill-name -y
```

---

## Troubleshooting: "Exceeded skills context budget of 2%"

### Symptom

oh-my-codex prints:

```
⚠ Warning: Exceeded skills context budget of 2%. Loaded skill descriptions were truncated...
```

### Root Cause A: Duplicate Skill Directories (most common)

oh-my-codex recursively scans the entire repository. If the same skill exists in multiple places (e.g., both `.agents/skills/wiki-core/` and `wiki/wiki-core/`), every skill is loaded twice, doubling the description character count.

**Diagnose:**

```bash
# Find all SKILL.md files and show duplicate directory names
find . -name "SKILL.md" -exec dirname {} \; | sort | uniq -d

# Measure total description characters
python3 -c "
import os, re
total = 0
for root, _, files in os.walk('.'):
    if 'SKILL.md' in files:
        with open(os.path.join(root, 'SKILL.md')) as f:
            m = re.search(r'^description:\s*[\"\']?(.*?)[\"\']?\s*$', f.read(), re.M)
            if m: total += len(m.group(1).strip('\"\''))
print(f'Total description chars: {total}')
"
```

**Fix:** Remove the duplicate copy. Typically `.agents/skills/` is the stale installation directory and `wiki/` (or the canonical category folder) is the source of truth.

```bash
rm -rf .agents/skills/
# Add to .gitignore to prevent future accidental commits
echo -e ".agents/\n.claude/\n.codebuddy/\n.kiro/\n.trae/\n" >> .gitignore
# Reinstall cleanly from remote
npx skills add thedavidweng/skills --full-depth --all -y
```

### Root Cause B: Excessively Long Descriptions

The official spec recommends concise descriptions. If any single description exceeds ~300 characters, it consumes disproportionate budget.

**Diagnose:**

```bash
python3 -c "
import os, re
for root, _, files in os.walk('.'):
    if 'SKILL.md' in files:
        with open(os.path.join(root, 'SKILL.md')) as f:
            m = re.search(r'^description:\s*[\"\']?(.*?)[\"\']?\s*$', f.read(), re.M)
            if m:
                d = m.group(1).strip('\"\'')
                if len(d) > 250:
                    print(f'{len(d):4d} chars | {os.path.relpath(root)}')
"
```

**Fix:** Compress the description to under 200 characters. Move detailed trigger conditions into the SKILL.md body, not the frontmatter.

---

## PII Audit for Existing Repositories

When inheriting or reviewing a skills repo, audit for accidentally committed personal information before publishing or sharing.

### Scan patterns

Search for common PII categories:

```bash
grep -rn -E '(翁|献|琼|静雯|杨杨|冠豪|Jianshuang|Lanfei|Hui-Fen|Menglin|david-weng|weng-jia|绣山|CSW|UBC|150,000|youtube\.token|YUTU_CACHE|~/yout)' wiki/ code-review/ skill-repo-maintenance/ youtube-content-ops/
```

Typical categories to check:
- Real names in examples (e.g., `zhang-san-income-cert.md`)
- Institution abbreviations used as concrete examples
- Token file paths or API key patterns
- Specific monetary amounts
- Personal file paths (e.g., `~/youtube.token.personal.json`)

### Replace systematically

Use a scripted replacement map to ensure consistency:

```python
replacements = {
    'real-name-slug': 'zhang-san',
    'Real Name': 'Zhang San',
    'institution-abbrev': 'some-school',
    '~/personal.path.json': '~/token.json',
}
```

Then verify with the same grep pattern — it should return zero hits.

### Rewrite git history after PII cleanup

If PII existed in previous commits, deleting it from current files is not enough. The old commits still contain the data.

**Create an orphan branch and force push:**

```bash
# Stage all cleaned files
git add -A
git commit -m "clean: remove PII, fix structure, add compliance files"

# Create orphan branch to sever history
git checkout --orphan new_main
git add -A
git commit -m "Initial commit: cleaned skills repository"

# Replace main
git branch -D main
git branch -m main
git push --force origin main
```

**Caution:** This permanently erases all prior commit history. Ensure the cleaned tree is complete before forcing.

---

## Agent Skills Format Compliance Checklist

Before claiming a repo is spec-compliant, verify every skill directory:

| Check | Rule | How to verify |
|-------|------|---------------|
| No README.md in skill dir | "Do NOT create extraneous documentation" | `find . -maxdepth 2 -name 'README.md'` should only return root/category docs |
| Frontmatter has only `name` + `description` | "Do not include any other fields" | `grep -E '^[a-z-]+:' SKILL.md` in frontmatter block |
| `agents/openai.yaml` exists | Recommended by spec for UI metadata | `ls agents/openai.yaml` in each skill dir |
| Description < 250 chars | Prevents context budget overflow | `python3 -c "import re; ... print(len(desc))"` |
| SKILL.md < 500 lines | Official recommendation | `wc -l SKILL.md` |
| Folder name == `name:` field | Required for CLI matching | `basename $(dirname SKILL.md)` vs frontmatter |
| No duplicate skill copies | Causes 2% context budget warning | `find . -name 'SKILL.md' | sort` should show each skill once |

---

## SKILL.md Compression

When a SKILL.md exceeds 500 lines, compress without losing functionality:

1. **Move code examples to `references/`**
   - Long YAML config blocks → `references/config-example.yaml`
   - Detailed CLI command lists → `references/commands.md`
   - In SKILL.md, replace with a one-line reference: `*(See references/config-example.yaml)*`

2. **Remove redundant explanations**
   - If a concept is explained twice, keep the more precise version
   - Remove "In other words..." restatements

3. **Collapse multi-step sections into bullet lists**
   - 5 paragraphs describing a phase → 5 bullet points with the key actions

4. **Remove stale example artifacts**
   - Old placeholder names, outdated path examples, deprecated commands

---

## Resources

- `references/rename-checklist.md` — Step-by-step checklist for bulk skill renames
