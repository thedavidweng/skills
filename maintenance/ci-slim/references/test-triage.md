# Test triage

A test earns CI time only if it can fail for a product bug that no cheaper test catches.

## Delete

- **Repo-file assertions.** Reads `*.md`, `package.json`, a lockfile, a workflow, `.gitignore` or a config and checks strings or counts ("the feature matrix has 129 rows", "the checklist contains id X", "effect is pinned at 4.0.0"). The file is the source of truth; the test only makes edits cost two places. The lockfile and the package manager already enforce versions.
- **Source-text greps.** Reads a `.ts`/`.py`/`.go` source file and asserts it does or does not contain a string ("no `throw new X` in file Y", "seed file does not mention customer Z"). Use a lint rule if the rule matters.
- **Tool self-tests.** Plants a bad file and runs the linter or formatter to prove an ignore pattern works. The tool's own config is the contract.
- **Constant echoes.** Asserts a constant equals its literal value, or that an exported list contains the items it was written with.
- **Mock tautologies.** Every collaborator is mocked and the assertion checks the mock was called with what the test passed in.
- **Gates scaled to pass.** Latency or size budgets multiplied for CI ("30x on CI") so they cannot fail. Measure on staging instead and write that in the testing doc.
- **Test-only code.** Delete modules, fixtures, seed endpoints and helpers that only the deleted tests used. Search for every export before you remove it.

## Move down a layer

Keep the rule; drop the browser or the process boundary.

- E2E for a business rule, a form's validation, CRUD on one entity, or a pure layout check: test the rule in the domain, application or server-function layer.
- E2E for a security header or CSRF middleware: call the middleware with a constructed request in a unit test.
- One E2E journey per critical flow stays. Generic forms that share one shell need one representative, or none if lower tests cover them.

## Park

Adapters or targets that a later phase needs but no running system uses (a second database dialect, a platform you do not ship). Comment out the test project, keep typecheck on, and write the re-enable condition in the ADR or testing doc. Delete only if no plan needs it.

## Keep

- Security boundaries: authorization, tenant isolation, sessions, invitations, CSRF.
- Money, quantities, ledger and posting arithmetic; golden-number tests.
- Repository or adapter contract tests for every adapter that runs in production.
- Browser-only features: print popups, downloads, uploads, workers, keyboard and accessibility checks.
- Regression tests that name a real past bug and still exercise current code.

## Signals of AI-written defensive tests

- `readFileSync` / `open()` on non-fixture repo files in a test.
- Test names that restate a ticket or ADR number but assert file contents.
- Several near-identical tests that differ only in the literal checked.
- Allowlists "to shrink per ticket" enforced by a test.
- Comments that explain why the test is needed longer than the test itself.
