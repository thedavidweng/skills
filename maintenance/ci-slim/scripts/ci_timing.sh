#!/usr/bin/env bash
# Print where CI wall-clock goes: job durations of recent green runs per event,
# step timings of the slowest job, required checks, and runner labels.
# Usage: ci_timing.sh [repo-dir] [workflow-file]   (needs gh and jq)
set -euo pipefail

REPO="${1:-.}"
WORKFLOW="${2:-}"
cd "$REPO"

if [ -z "$WORKFLOW" ]; then
  WORKFLOW=$(gh workflow list --json path,name -q '.[] | select(.name == "CI") | .path' | head -1)
  WORKFLOW="${WORKFLOW:-$(gh workflow list --json path -q '.[0].path')}"
fi
WORKFLOW=$(basename "$WORKFLOW")
printf '# CI timing: %s\n\n' "$WORKFLOW"

duration() { jq -r '(((.completedAt | fromdate) - (.startedAt | fromdate)) / 60 * 10 | floor / 10 | tostring) + "m"'; }

slowest_job=""
slowest_run=""
slowest_secs=0
for event in pull_request push; do
  run=$(gh run list --workflow "$WORKFLOW" --event "$event" --status success -L 1 \
    --json databaseId,createdAt,updatedAt,displayTitle)
  id=$(jq -r '.[0].databaseId // empty' <<<"$run")
  [ -z "$id" ] && { printf '## %s: no green run\n\n' "$event"; continue; }
  total=$(jq -r '.[0] | {startedAt: .createdAt, completedAt: .updatedAt}' <<<"$run" | duration)
  printf '## %s run %s (%s total): %s\n\n' "$event" "$id" "$total" "$(jq -r '.[0].displayTitle' <<<"$run")"
  jobs=$(gh run view "$id" --json jobs -q '.jobs')
  jq -r '.[] | select(.conclusion != "skipped") |
    "- \(.name): \((((.completedAt | fromdate) - (.startedAt | fromdate)) / 60 * 10 | floor / 10))m [\(.conclusion)] start \(.startedAt[11:19])"' <<<"$jobs"
  printf '\n'
  read -r jid secs < <(jq -r 'map(select(.conclusion == "success")) |
    map({id: .databaseId, s: ((.completedAt | fromdate) - (.startedAt | fromdate))}) |
    max_by(.s) | "\(.id) \(.s)"' <<<"$jobs")
  if [ "${secs:-0}" -gt "$slowest_secs" ]; then
    slowest_secs=$secs; slowest_job=$jid; slowest_run=$id
  fi
done

if [ -n "$slowest_job" ]; then
  printf '## Steps of slowest job %s (run %s)\n\n' "$slowest_job" "$slowest_run"
  gh api "repos/{owner}/{repo}/actions/jobs/$slowest_job" | jq -r '.steps[] |
    select(.started_at and .completed_at) |
    "- \(((.completed_at | fromdate) - (.started_at | fromdate)))s \(.name)"'
  printf '\n'
fi

printf '## Required checks on default branch\n\n'
branch=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
gh api "repos/{owner}/{repo}/branches/$branch/protection/required_status_checks" \
  -q '.contexts[] | "- \(.)"' 2>/dev/null || printf -- '- none or no access\n'

printf '\n## Runner labels in workflows\n\n'
grep -hoE 'runs-on:.*' .github/workflows/*.y*ml 2>/dev/null | sort | uniq -c | sort -rn
