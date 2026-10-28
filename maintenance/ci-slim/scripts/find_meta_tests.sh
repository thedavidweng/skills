#!/usr/bin/env bash
# List tests that read repo files (docs, manifests, lockfiles, workflows,
# source text) instead of exercising product code. Signals, not verdicts:
# a test that reads its own fixture or a real schema file is fine.
# Usage: find_meta_tests.sh [repo-dir]
set -euo pipefail

REPO="${1:-.}"
cd "$REPO"

tests=$(git ls-files | grep -E '(\.(test|spec)\.[cm]?[jt]sx?$|_test\.(go|py)$|(^|/)test_[^/]*\.py$)' |
  grep -vE '(^|/)(node_modules|vendor|repos|third_party)/' || true)
[ -z "$tests" ] && { echo "no test files found"; exit 0; }

read_re='readFileSync|readFile\(|readdirSync|open\(|os\.ReadFile|Path\([^)]*\)\.read_text|execFileSync|execSync|subprocess\.'
target_re='\.md["'\''`]|package\.json|lock|\.ya?ml|\.gitignore|wrangler|cloudflare\.config|tsconfig|\.github|docs/|README|\.(ts|tsx|js|py|go)["'\''`]'

printf '# Meta-test candidates\n\n'
printf 'Each line: test file, then the matching lines. Review each before deleting.\n\n'
while IFS= read -r file; do
  hits=$(grep -nE "$read_re" "$file" | grep -E "$target_re|join\(|repoRoot|__dirname|import\.meta" || true)
  [ -z "$hits" ] && continue
  # shellcheck disable=SC2016 # literal Markdown fences
  printf '## %s\n\n```\n%s\n```\n\n' "$file" "$(head -8 <<<"$hits")"
done <<<"$tests"

printf '## Source-text assertions\n\n'
tr '\n' '\0' <<<"$tests" |
  xargs -0 grep -nE '\.(toContain|not\.toContain|toMatch|includes)\(["'\''`](throw new|import |export |TODO)' 2>/dev/null |
  head -40 || true
