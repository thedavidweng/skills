# CI rules

Ordered by typical savings. Each rule names the waste it removes.

## Run each thing once

- **One unit run.** Run the suite with coverage in the quality job and upload from there. A separate coverage job runs the same tests again and repeats setup.
- **No repeat on merge.** If PR checks passed on the merged code, a push to main does not need browser tests again. Keep quality (fast) on push; run E2E and other slow suites on `pull_request` only. If you allow merges of stale branches, require branches to be up to date or use a merge queue instead of re-running on main.
- **Do not rebuild for E2E.** If the quality job builds, reuse the artifact or let the E2E job be the only build. Check that the E2E web server command does not rebuild on top of a previous build step.

## Run in parallel

- Remove `needs:` edges that exist only for ordering (E2E waiting for quality). A failure in either fails the aggregate check anyway.
- One self-hosted runner runs jobs serially. Parallel jobs only help with more than one runner; otherwise merge small jobs into one to pay setup once.

## Skip coarsely

- Use one path filter: "anything outside docs and CI config changed". Per-area spec selection (filter files, decision scripts, override labels) costs more maintenance than the minutes it saves once the slow suite is small.
- Workflow-only changes run the workflow linter, not the test suite.
- Drafts run nothing.

## One required check

- An aggregate `CI` job with `if: always()` and `needs:` on every job fails unless each result is `success` or `skipped`. Branch protection requires only that job (plus workflow lint), so skipped jobs never block merges and job renames do not break protection.
- Before renaming a job, check `gh api repos/<owner>/<repo>/branches/<branch>/protection` for the required context names.

## Setup cost

- Measure the setup step. A multi-hundred-MB dependency cache downloaded in every job is often the largest fixed cost; fewer jobs is the fix, not a better cache key.
- Pin tool versions so caches hit.
- Self-hosted runner labels must be listed in `.github/actionlint.yaml`, or workflow lint fails after a runner migration.

## Flaky and slow tests

- `retries: 1` on CI hides flakes and doubles the time of every real failure. Fix or delete the flaky test.
- Long per-test timeouts (2-4 minutes) usually mark a test that waits on hydration or network idle. Wait for a specific element or response instead.

## Report

Before/after wall-clock for a PR run and a push-to-main run, the jobs removed, the tests deleted or moved with one reason each, and anything parked with its re-enable condition.
