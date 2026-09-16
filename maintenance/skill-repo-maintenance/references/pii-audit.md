# PII Audit

Audit an inherited skills repo for accidentally committed personal information before publishing or sharing.

## Scan

```bash
grep -rn -E '(person-name|example-school|api\.token|personal-token-path|99,999)' <skill-dirs>/
```

Extend the pattern with repo-specific names and institutions. Typical hits: real names in example filenames, institution abbreviations used as concrete examples, token file paths or API-key patterns, specific monetary amounts, personal file paths (e.g. `~/youtube.token.personal.json`).

## Replace

Use a scripted replacement map so results stay consistent (real-name slug to generic slug, institution to type description, personal paths to `~/token.json` templates). Re-run the grep afterwards — it must return zero hits.

## Rewrite history

Deleting PII from current files is not enough; old commits still contain it. Sever history with an orphan branch and force-push:

```bash
git add -A && git commit -m "clean: remove PII"
git checkout --orphan new_main && git add -A && git commit -m "Initial commit: cleaned skills repository"
git branch -D main && git branch -m main && git push --force origin main
```

Caution: this permanently erases prior history. Verify the cleaned tree is complete before forcing.
