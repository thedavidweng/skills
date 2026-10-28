#!/usr/bin/env bash
# Usage: ci_compare.sh [-R owner/repo] <run-id>...
# Prints each run's wall clock, summed job time and per-job step times (latest
# attempt), then the medians across the runs. It reruns nothing: pass runs that
# already exist. Run it inside the repo, or pass -R owner/repo.
set -euo pipefail

repo=
if [ "${1:-}" = -R ]; then
  repo=$2
  shift 2
fi
repo=${repo:-$(gh repo view --json nameWithOwner -q .nameWithOwner)}

walls=()
sums=()
for id in "$@"; do
  api="repos/$repo/actions/runs/$id"
  run=$(gh api "$api" -q '"\((.updated_at|fromdate)-(.run_started_at|fromdate)) \(.conclusion) \(.head_branch)"')
  wall=${run%% *}
  jobs=$(gh api --paginate "$api/jobs" -q '.jobs[] | "\((.completed_at|fromdate)-(.started_at|fromdate))\t\(.name)\t" + ([.steps[] | select(.name|test("^(Post |Complete job)")|not) | "\(.name|.[0:24])=\(((.completed_at//.started_at)|fromdate)-(.started_at|fromdate))"] | join(" "))')
  sum=$(awk -F'\t' '{s+=$1} END {print s+0}' <<<"$jobs")
  echo "run $id: wall ${wall}s, jobs ${sum}s, ${run#* }"
  awk -F'\t' '{printf "  %-14s %4ss  %s\n", $2, $1, $3}' <<<"$jobs"
  walls+=("$wall")
  sums+=("$sum")
done

median() { printf '%s\n' "$@" | sort -n | awk '{v[NR]=$1} END {print (NR%2 ? v[(NR+1)/2] : (v[NR/2]+v[NR/2+1])/2)}'; }
echo "median of $# runs: wall $(median "${walls[@]}")s, jobs $(median "${sums[@]}")s"
