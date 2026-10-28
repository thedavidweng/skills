Copy this into the PR body and fill every `<…>`. Do not drop a row because it got slower. Write `n/a` and the reason when a row does not apply.

```markdown
## What changed

| Area | Before | After |
| --- | --- | --- |
| Package manager | <pnpm 12 / npm 11> (`<lockfile>`) | Bun <version> (`bun.lock`) |
| Script runtime | <Node 24 / tsx> | <Bun, or which scripts stay on Node and why> |
| Test runner | <tsx + c8 / vitest> | <bun test --coverage / unchanged> |
| CI toolchain | <setup-pnpm + setup-node> | <setup-bun only / + setup-node, and why> |
| Lint / format | <tool> | unchanged |
| Hosting build | <dashboard command> | <new command, or "not touched"> |
| Dependabot | `npm` | `bun` |

Supply-chain settings:

| Setting | Before | After |
| --- | --- | --- |
| <minimumReleaseAge> | <value> | <value + unit> |
| <allowBuilds> | <list> | `trustedDependencies` <list> |

**Lost:** <settings with no Bun equivalent, or "none">

## Speed

CI: `ci_compare.sh`, medians over <n> existing runs before and <n> after, same job matrix.
Local: second run on <machine>.

| Measure | Before | After | Change |
| --- | --- | --- | --- |
| CI wall clock | <s> | <s> | **<±s (±%)>** |
| CI runner time, all jobs | <s> | <s> | **<±s (±%)>** |
| Toolchain setup per job | <s–s> | <s–s> | <…> |
| Install per job | <s–s> | <s–s> | <…> |
| <each CI task> | <s> | <s> | <…> |
| Local cold install | <s> | <s> | <…> |
| Local warm install | <s> | <s> | <…> |
| Local <each task> | <s> | <s> | <…> |

Slower: <every row that got slower, one line each with the likely cause, or "nothing">

## Unchanged, verified

- Tests: <n> before, <n> after. A forced failure exits 1.
- Build output: `diff -r` of <dir>, <n> files, <identical / differences>.
- Clean `bun install --frozen-lockfile`: passes.

## Not verified

- <for example: production deploy, dev server on Linux>
```
