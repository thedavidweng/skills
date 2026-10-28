---
name: migrate-to-bun
description: 'Migrates a JS/TS repo from pnpm, npm or Node to Bun, measures speed before and after, and opens a PR with a faster/slower table. Use when switching a project to Bun, bun install, bun test or setup-bun in CI.'
---

Switch one repo to Bun, prove nothing changed except speed, and open a PR whose table shows what got faster and what got slower. Work on a branch. Do not merge.

**0. Use stable Bun only.** Run `bun --revision`. A `-canary` build ships commands that stable lacks (at 1.4.4: `bun lint`, `bun compile`, `--aot`, `--trim`). Check every Bun command you plan to use with `<cmd> --help` on the stable binary. Bun replaces the package manager, script runtime and test runner. `bun check` can replace `tsc --noEmit`, but switch only after both report the same errors on this repo; it still differs from `tsc` in edge cases. It does not replace Vite, Astro, `astro check`/`vue-tsc`, or Vite plugins. Leave lint and format on their current tool: `bun fmt` and oxfmt disagree on some files, and two formatters in one repo fight.

**1. Baseline.** Measure locally first: it costs nothing. On a clean clone, `time` each CI task and the install twice, and keep the second run. Record test counts. For CI, read runs that already exist; do not rerun them. Reruns use Actions minutes, which private repos pay for, and they repeat every step of the workflow, including any deploy, publish or image push. List the recent green runs on the default branch with `gh run list -w <workflow> -b <default-branch> -s success -L 3 --json databaseId -q '.[].databaseId'`, then pass them to `bash scripts/ci_compare.sh <run-id>...`. It prints wall clock, summed job time and per-step times for each run, plus medians. Rerun only when fewer than three runs exist, the workflow only checks (no deploy, publish or push), and the user agrees.

**2. Package manager.** Run `bun install` to migrate the lockfile. Then delete the old lockfile, `pnpm-workspace.yaml` and `packageManager`. Bun copies `overrides` and `workspaces` into `package.json`, including nested `a>b` overrides (check `bun.lock`). The supply-chain settings it does not copy:

| pnpm | Bun |
|---|---|
| `minimumReleaseAge` (minutes) | `[install] minimumReleaseAge` in `bunfig.toml`, in **seconds** (×60) |
| `minimumReleaseAgeExclude` | `[install] minimumReleaseAgeExcludes`. Same syntax: a bare name or `name@version`. |
| `allowBuilds` (`true` entries only) / `onlyBuiltDependencies` | `trustedDependencies` in `package.json`. A `false` entry is a denial; copying it would trust a package pnpm blocked. |
| `trustPolicy: no-downgrade` | No equivalent. Say so in the PR. |

Any other key: look it up in `bun install --help` and the bunfig docs. Anything you cannot convert goes in the PR under "Lost".

**3. Scripts.** `tsx file.ts` becomes `bun file.ts`. `pnpm --filter <pkg> exec <bin>` becomes `bun run --cwd <dir> <bin>`. For each tool (build, framework check, knip), compare `bun run` (keeps Node for a `node` shebang) with `bun --bun run`. Adopt `--bun` only if the output is identical: `diff -r` the build output. Keep the dev server on Node if anything differs, even cosmetically.

**4. Tests.** c8 does not work under Bun (it needs V8). For a hand-rolled harness, re-export `test` from `bun:test` and keep the assertions. `bun test` gives each test 5 s, and a harness had no limit, so tests that hit the network now flake. Inject the fetcher instead, or pass a timeout longer than the code's own. Drop `await` before `test(...)`: it returns void, and framework checkers report every one. On TypeScript 6+, add `@types/bun` and `"types": ["bun"]`. Prove failure still fails: break one assertion and expect exit 1.

**5. CI.** Use `oven-sh/setup-bun` pinned to a SHA with `bun-version` pinned, then `bun install --frozen-lockfile`. Keep the job matrix as it was, so the comparison is fair. Then try dropping `setup-node`. `bun run` falls back to Bun when there is no `node` on PATH, so run every CI task with `env -i HOME=$HOME PATH=<dir holding only bun>:/usr/bin:/bin zsh -f -c 'command -v node && exit 1; ...'`. The guard fails if any PATH entry still holds Node (Linux often has one in `/usr/bin`), and `zsh -f` keeps rc files from adding it back. Do not add `actions/cache` for `~/.bun/install/cache`. Measured restores take 3–8 s against 2–4 s for a plain install, and a cache miss adds 2–4 s to save.

**6. Everything else that runs the old package manager.** Read all of `.github/`, docs, `AGENTS.md`, `mise.toml` and hosting config.
- **Dependabot:** set `package-ecosystem: "bun"`. Otherwise it fails on the first run after merge, because `npm_and_yarn` cannot update `bun.lock`.
- **Hosting:** build commands set in a dashboard are not in the repo. For Cloudflare Workers Builds:
  - Find the trigger: `cf workers scripts search --name <worker>`, then `cf builds triggers list --external-script-id <id>`.
  - Update it with `cf builds triggers update <trigger-uuid> --build-command '...' --deploy-command '...' --dry-run`. Drop `--dry-run` once the body looks right.
  - Pin versions with `cf builds triggers environment-variables upsert <trigger-uuid> --body '{"BUN_VERSION":{"value":"<x>","is_secret":false},"NODE_VERSION":{"value":"<lts>","is_secret":false}}'`.
  - Change the dashboard only right before merge. Tell the user it changed.
- **Node for deploy CLIs:** a CLI with a `node` shebang (such as `cf`) still needs Node to deploy. Document the current Node LTS, not the CLI's minimum.

**7. Verify.** On both the base branch and the new branch:
- Every CI task exits 0.
- Build output is byte-identical (`diff -r`).
- Test counts match.
- `rm -rf node_modules && bun install --frozen-lockfile` succeeds.

**8. PR.** Fill `references/pr-body.md` with the local numbers and open the PR. When the PR's CI is green, run `bash scripts/ci_compare.sh <pr-run-id>` on its run (and on any later pushes' runs), then put the CI rows into the body with `gh pr edit <n> --body-file <file>`. State how many runs each side has. One run per side is noisy, so lead with the local numbers if CI has fewer than three. Keep every slower row in the table: a slower warm local install is common under Bun's isolated linker.
