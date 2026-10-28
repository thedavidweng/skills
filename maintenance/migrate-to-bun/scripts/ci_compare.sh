#!/usr/bin/env bash
# Usage: ci_compare.sh <run-id> [reruns] [owner/repo]
# Reruns a finished workflow run <reruns> times (default 0), then prints every
# attempt's wall clock, summed job time and per-job setup/install/task steps,
# followed by the medians. Run it from inside the repo, or pass owner/repo.
set -euo pipefail

run_id=$1
reruns=${2:-0}
repo=${3:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
api="repos/$repo/actions/runs/$run_id"

for _ in $(seq 1 "$reruns"); do
  gh run rerun "$run_id" -R "$repo" >/dev/null
  sleep 15
  # A failed attempt still gets measured; its conclusion is printed below.
  gh run watch "$run_id" -R "$repo" --exit-status >/dev/null 2>&1 || true
done

attempts=$(gh api "$api" -q .run_attempt)
walls=()
sums=()
for a in $(seq 1 "$attempts"); do
  run=$(gh api "$api/attempts/$a" -q '"\((.updated_at|fromdate)-(.run_started_at|fromdate)) \(.conclusion)"')
  wall=${run%% *}
  jobs=$(gh api "$api/attempts/$a/jobs" -q '.jobs[] | "\((.completed_at|fromdate)-(.started_at|fromdate))\t\(.name)\t" + ([.steps[] | select(.name|test("setup|install|cache|run ";"i")) | "\(.name|.[0:24])=\(((.completed_at//.started_at)|fromdate)-(.started_at|fromdate))"] | join(" "))')
  sum=$(awk -F'\t' '{s+=$1} END {print s+0}' <<<"$jobs")
  echo "attempt $a: wall ${wall}s, jobs ${sum}s, ${run#* }"
  awk -F'\t' '{printf "  %-14s %4ss  %s\n", $2, $1, $3}' <<<"$jobs"
  walls+=("$wall")
  sums+=("$sum")
done

median() { printf '%s\n' "$@" | sort -n | awk '{v[NR]=$1} END {print (NR%2 ? v[(NR+1)/2] : (v[NR/2]+v[NR/2+1])/2)}'; }
echo "median over $attempts attempts: wall $(median "${walls[@]}")s, jobs $(median "${sums[@]}")s"
