#!/usr/bin/env bash
# Usage: ci_compare.sh <run-id> [reruns] [owner/repo]
# Reruns a finished workflow run <reruns> times (default 0), then prints every
# attempt's wall clock, summed job time and per-job step times. The medians
# skip attempt 1, which may have run with cold caches. Run it inside the repo,
# or pass owner/repo.
set -euo pipefail

run_id=$1
reruns=${2:-0}
repo=${3:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}
api="repos/$repo/actions/runs/$run_id"

for ((i = 0; i < reruns; i++)); do
  next=$(($(gh api "$api" -q .run_attempt) + 1))
  gh run rerun "$run_id" -R "$repo" >/dev/null
  until [ "$(gh api "$api" -q '"\(.run_attempt) \(.status)"')" = "$next completed" ]; do
    sleep 15
  done
done

attempts=$(gh api "$api" -q .run_attempt)
walls=()
sums=()
for a in $(seq 1 "$attempts"); do
  run=$(gh api "$api/attempts/$a" -q '"\((.updated_at|fromdate)-(.run_started_at|fromdate)) \(.conclusion)"')
  wall=${run%% *}
  jobs=$(gh api --paginate "$api/attempts/$a/jobs" -q '.jobs[] | "\((.completed_at|fromdate)-(.started_at|fromdate))\t\(.name)\t" + ([.steps[] | select(.name|test("^(Post |Complete job)")|not) | "\(.name|.[0:24])=\(((.completed_at//.started_at)|fromdate)-(.started_at|fromdate))"] | join(" "))')
  sum=$(awk -F'\t' '{s+=$1} END {print s+0}' <<<"$jobs")
  echo "attempt $a: wall ${wall}s, jobs ${sum}s, ${run#* }"
  awk -F'\t' '{printf "  %-14s %4ss  %s\n", $2, $1, $3}' <<<"$jobs"
  if [ "$a" -gt 1 ]; then
    walls+=("$wall")
    sums+=("$sum")
  fi
done

if [ "${#walls[@]}" -eq 0 ]; then
  echo "only attempt 1 exists; rerun the run to get a warm median"
  exit 0
fi
median() { printf '%s\n' "$@" | sort -n | awk '{v[NR]=$1} END {print (NR%2 ? v[(NR+1)/2] : (v[NR/2]+v[NR/2+1])/2)}'; }
echo "median of attempts 2-$attempts: wall $(median "${walls[@]}")s, jobs $(median "${sums[@]}")s"
