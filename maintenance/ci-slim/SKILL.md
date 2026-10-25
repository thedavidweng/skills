---
name: ci-slim
description: 'Cuts CI time and runner minutes by deleting low-value tests and duplicate jobs, then simplifying workflows. Use when CI is slow, Actions minutes run out, self-hosted runners are overloaded, or AI-written defensive tests pile up.'
---

Measure first, then delete, then restructure YAML. Most waste is duplicated work and tests that check the repo instead of the product, not missing caches.

**1. Measure.** Run `bash scripts/ci_timing.sh <repo>`: job durations of the last green runs per event, step timings of the slowest job, the required checks, and the runner labels. Find where wall-clock goes before changing anything. Typical finds: the same suite runs in two jobs (test + coverage), E2E repeats on push to main after it passed on the PR, jobs on one self-hosted runner queue serially, `needs:` chains force serial order, setup downloads a huge cache in every job, the E2E server rebuilds the app.

**2. Time the tests.** Run the suite with the runner's per-file JSON or durations report (for example `vitest run --reporter=json --outputFile=<file>`) and rank files by time. A few files usually own most of it.

**3. Classify every suspect test** with `references/test-triage.md`: delete, move down a layer, park, or keep. Run `bash scripts/find_meta_tests.sh <repo>` to list tests that read docs, manifests, lockfiles, workflows or source text. Those are the usual AI-written defensive tests. Before you delete a test that guards a real rule, find the lower-level test that covers the rule, or write one first and see it fail.

**4. Restructure CI** with `references/ci-rules.md`: one test run with coverage, browser tests on PRs only and in parallel, coarse path skip instead of per-area selection, no override labels, one aggregate required check.

**5. Keep the docs true.** Update the project's testing doc, ADRs that require the deleted test (amend with a dated note; do not silently contradict them), and README. Park, do not delete, adapters a future phase needs: comment out the test project with the condition to re-enable it.

**6. Verify.** Format, lint, typecheck, full unit suite, the edited E2E specs, and the workflow linter (`actionlint`) all pass. Check that the required-check names in branch protection still exist. Report before/after wall-clock per event (PR, push to main) and the deleted test list with one reason each.

Do not delete security boundaries (authz, tenant isolation, CSRF, sessions), money or ledger arithmetic, data migrations, or the one happy-path journey per critical flow. Move them down a layer if they are slow; do not drop them. Ask before deleting remote labels, changing branch protection, or touching shared runners.
