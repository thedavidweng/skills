# Production Go checklist

This checklist distills production-applicable practices from the book *Production Go* into audit criteria. Use it as an intent-level standard: accept modern equivalents that satisfy the same reliability, correctness, security, and operability goals.

## Table of contents

1. Repository, modules, and toolchain
2. Formatting, style, and readability
3. Package API and documentation
4. Types, data structures, and language pitfalls
5. Error handling
6. Strings, Unicode, and text processing
7. Concurrency
8. Tests and examples
9. Benchmarks and performance checks
10. Static analysis and developer tooling
11. Security
12. Production readiness, CI/CD, and observability
13. Scoring guidance

## 1. Repository, modules, and toolchain

### PG-01: Go modules are the dependency boundary
A production repository should have a `go.mod` at each module root. Dependencies should be declared and versioned there. If the project uses `vendor/`, treat it as an explicit dependency distribution choice and verify it is generated and kept consistent.

Audit checks:
- `go.mod` and `go.sum` exist for module roots.
- `go list ./...` succeeds from each module root.
- Dependency additions happen through Go module commands or an equivalent reproducible workflow.
- Multi-module repositories document which module roots are authoritative.

### PG-02: The Go version is maintained for security
The production toolchain should be kept current enough to receive security fixes. Treat an old `go` directive or toolchain as a security and maintenance risk.

Audit checks:
- `go version` in CI and local docs is explicit.
- `go.mod` `go` directive is plausible for the current project and libraries.
- The team has a documented path for Go security updates.
- Release notes or security announcements are monitored by the team or platform owners.

### PG-03: Tooling is reproducible for contributors and CI
If the build requires tools such as `staticcheck`, `goimports`, `golangci-lint`, or similar analyzers, contributors should be able to clone the repo and run the same tools locally.

Audit checks:
- Tool versions are pinned via `tools.go`, `go.mod`, a Makefile, CI config, or equivalent.
- CI and local developer commands call the same toolchain.
- The repository documents the canonical commands for format, lint, test, race, coverage, and benchmark checks.

### PG-04: CI is a required production gate
Production Go systems should run builds, tests, and correctness checks automatically when code changes.

Audit checks:
- CI configuration exists.
- CI runs at least build/compile, `go test`, and `go vet`.
- CI optionally runs linters, coverage, race checks, and benchmark comparisons when appropriate.
- Failing core correctness checks block merges or deployments.

## 2. Formatting, style, and readability

### PG-05: gofmt is non-negotiable
All Go files should be formatted by `gofmt`. `gofmt -s` simplifications are safe style improvements and should usually be accepted.

Audit checks:
- `gofmt -l` returns no files.
- `gofmt -s` returns no meaningful simplification candidates, or the team has an explicit reason.
- Formatting is automated in editors or pre-commit/CI.

### PG-06: goimports is the preferred editor/save formatter
`goimports` satisfies the `gofmt` style while adding and removing imports. Prefer it for developer workflow and import hygiene.

Audit checks:
- `goimports` or equivalent import cleanup is documented or enforced.
- Files have no unused imports and no missing imports.
- Import grouping is idiomatic.

### PG-07: Short names are used where scope is short
Go style favors short local variable names when their scope is small. Names should grow more descriptive as span and semantic weight increase.

Audit checks:
- Small loop variables and short-scope locals use concise names.
- Long-lived variables, exported identifiers, and domain concepts have descriptive names.
- Functions are kept small enough that short names remain readable.

### PG-08: Control flow uses early returns and simple shape
Go code should keep control flow straightforward. A branch that returns should generally be followed by the next statement instead of an unnecessary `else`.

Audit checks:
- No avoidable `else` after `return`, `break`, `continue`, or `panic`.
- Error paths exit quickly.
- Main logic stays at the left margin where practical.

### PG-09: Declaration style communicates intent
Use `:=` for common local declarations. Use `var` for package-level declarations and for local zero values that will be assigned later.

Audit checks:
- Package-level variables use `var`, not shorthand.
- Local zero-value declarations are idiomatic.
- Short declarations do not unintentionally shadow outer variables, especially `err`.

## 3. Package API and documentation

### PG-10: Package boundaries distinguish commands from reusable code
Executable commands belong in `package main`. Reusable functionality belongs in named packages with exported APIs.

Audit checks:
- Command packages are organized intentionally.
- Reusable business logic is not trapped in `main` without reason.
- Public packages expose focused APIs.

### PG-11: Exported names are intentional and documented
Names starting with an uppercase letter are part of the package API. Export only what users need, and document exported types, functions, variables, and constants.

Audit checks:
- Exported declarations have comments that start with the exported name when appropriate.
- Internal details remain unexported.
- Public API comments are current and useful in generated docs.

### PG-12: Package comments support godoc
Package-level docs should explain the purpose of the package. Long package docs can live in `doc.go`.

Audit checks:
- Packages intended for external or cross-team use have package comments.
- Comments immediately precede declarations without a separating blank line.
- Generated documentation and examples give a reader enough context to use the package.

### PG-13: Examples double as documentation and tests
Go examples can be executed by `go test` and rendered by docs. They are valuable for public APIs.

Audit checks:
- Important exported functions and methods have `Example...` tests when usage is subtle.
- Examples include `// Output:` when output should be verified.
- Method examples follow the `ExampleType_Method` convention.

## 4. Types, data structures, and language pitfalls

### PG-14: Prefer `int` for ordinary counts and indexes
`int` is the common choice for counts, slice indexes, and most ordinary integers because core APIs such as `len` and `cap` return `int`.

Audit checks:
- Fixed-width integers are used only when storage, protocol, or overflow semantics require them.
- `uint` is used with care and explicit justification.
- Cast-heavy code is reviewed for readability and correctness.

### PG-15: Unsigned integer underflow is treated as a risk
Unsigned integers wrap on underflow. Production code should avoid accidental unsigned arithmetic where negative intermediate values are possible.

Audit checks:
- Subtractions on `uint` values are guarded.
- Inputs from counts, lengths, and indexes are not converted to `uint` unnecessarily.
- Boundary tests cover zero and underflow-adjacent cases.

### PG-16: Struct tags and exported fields are correct for serialization
Encoding packages such as `encoding/json` only see exported struct fields. Use tags to match API/database wire names.

Audit checks:
- JSON-facing fields are exported.
- Struct tags match the desired external field names.
- Tests cover serialization and deserialization behavior.

### PG-17: Slices are the default dynamic sequence
Arrays are rarely needed in production application code. Slices should be used for variable-length collections.

Audit checks:
- Arrays appear only when fixed length is semantically required.
- Slice copies use `copy` with destination capacity allocated.
- Append operations are clear about ownership when sharing underlying arrays could matter.

### PG-18: Maps are initialized before writes
A nil map panics on writes. Map creation should use `make` or a literal before mutation.

Audit checks:
- No writes to maps that may be nil.
- Existence checks use the `value, ok := m[key]` pattern where zero value ambiguity matters.
- Code never relies on map iteration order.

### PG-19: Maps are not shared concurrently without protection
Plain maps are unsafe for concurrent reads/writes. Use locks or a concurrent-safe abstraction.

Audit checks:
- Shared maps are protected by `sync.Mutex`, `sync.RWMutex`, channel ownership, or an appropriate `sync.Map` use case.
- `sync.Map` is used intentionally for write-once/read-many or disjoint-key concurrent workloads.
- Race detector evidence exists for concurrent map paths.

### PG-20: Interfaces are narrow and purposeful
Interfaces should decouple code and improve testability. Empty interfaces should be rare and justified.

Audit checks:
- Interfaces express the methods actually needed by the consumer.
- Third-party clients, randomness, external APIs, and persistence can be mocked through interfaces where useful.
- `interface{}`/`any` usage is reviewed for type safety and clarity.

### PG-21: Nil interface behavior is understood
A typed nil stored in an interface value is not a nil interface. This can cause subtle production bugs.

Audit checks:
- Functions returning interfaces do not accidentally return typed nils.
- Nil comparisons involving interfaces are tested.
- Error-returning code avoids typed-nil error surprises.

## 5. Error handling

### PG-22: Errors are explicit return values
Functions that can fail should return an `error` as the final return value. Successful paths should return `nil` error.

Audit checks:
- Errors are returned and checked explicitly.
- Error handling is visible near the failing operation.
- API contracts make failure modes clear.

### PG-23: Errors are checked and wrapped with context
When returning an error from a lower-level operation, add useful context so callers and logs identify the failing step.

Audit checks:
- `if err != nil` checks appear after operations that can fail.
- Returned errors include operation context, input identity, or boundary information where useful.
- No high-signal ignored errors in I/O, encoding/decoding, database calls, or external command execution.

### PG-24: Error strings are log-composable
Error strings should generally start with lowercase letters unless they begin with a proper noun or acronym. This keeps caller log messages readable.

Audit checks:
- `fmt.Errorf` and `errors.New` strings are lowercase where appropriate.
- Error strings avoid decorative punctuation unless useful for clarity.
- Logs wrap errors with context at the right layer.

### PG-25: Fatal exits are limited to program edges
Use fatal exits in `main` or test setup when process termination is desired. Library code should usually return errors.

Audit checks:
- Packages intended for reuse do not call `log.Fatal` for recoverable failures.
- Tests use `t.Fatal`/`t.Fatalf` for setup failures that make later assertions meaningless.
- Service handlers return proper HTTP errors instead of terminating the process.

## 6. Strings, Unicode, and text processing

### PG-26: String building matches use case
Use `+` for simple, small concatenations. Use formatting or a builder-like approach for mixed types or hot paths.

Audit checks:
- Hot paths do not repeatedly concatenate strings without measurement.
- Mixed-type strings use `fmt.Sprintf`, `fmt.Fprintf`, or an equivalent clear formatting approach.
- Performance-sensitive string work is benchmarked.

### PG-27: Standard string helpers are preferred
The `strings` package gives clear tools for splitting, counting, finding, joining, trimming, case handling, and prefix/suffix checks.

Audit checks:
- Code uses `strings.Contains`, `HasPrefix`, `HasSuffix`, `Index`, `FieldsFunc`, `Map`, and related helpers where they simplify intent.
- Case-insensitive comparisons use `strings.EqualFold` rather than lowercasing both sides when appropriate.
- Unicode classifications use the `unicode` package rather than ASCII-only assumptions.

### PG-28: Strings are bytes; runes are Unicode code points
String indexes are byte offsets. `range` over a string yields byte offset plus rune. Code that counts or slices human text should reflect this.

Audit checks:
- Character-count logic is tested with non-ASCII input.
- Code avoids slicing in the middle of multi-byte UTF-8 sequences.
- Ranging over strings is used when rune-level processing is intended.

### PG-29: Unicode inputs are tested intentionally
Production-facing text code should include Unicode test cases, especially if inputs include user names, search text, identifiers, or internationalized content.

Audit checks:
- Tests include accented characters, CJK characters, combining characters, and mixed-width cases when relevant.
- Validation logic uses Unicode-aware predicates where the product supports non-ASCII input.
- Debug output uses formatting verbs such as `%q`, `%+q`, `% x`, or `%# x` when raw bytes matter.

### PG-30: Text normalization is applied before sensitive equality or mutation
Unicode can represent visually identical text in different byte sequences. Normalize text before comparisons, deduplication, storage, replacement, or security-sensitive identity checks when needed.

Audit checks:
- Usernames, identifiers, and matching keys consider normalization.
- Look-alike risks are acknowledged for security-sensitive names.
- Text replacement involving accents or combining characters normalizes before mutation.
- Efficient normalization via streaming writers is considered for large data.

### PG-31: Non-UTF-8 encodings are explicit
Go strings can hold arbitrary bytes. Code that consumes legacy encodings should decode intentionally.

Audit checks:
- Inputs with known non-UTF-8 encodings use `golang.org/x/text/encoding` or equivalent.
- Tests cover invalid and mixed-encoding input when relevant.

## 7. Concurrency

### PG-32: Sleep is not synchronization
`time.Sleep` is acceptable for examples, backoff, pacing, or polling intervals, and should not coordinate goroutine completion.

Audit checks:
- Goroutine completion uses `sync.WaitGroup`, channels, `errgroup`, or context-aware orchestration.
- Tests do not depend on arbitrary sleeps when deterministic coordination is possible.
- Background work has a clear lifecycle.

### PG-33: WaitGroup accounting is exact
A `sync.WaitGroup` counter must match launched goroutines.

Audit checks:
- `Add` happens before goroutine launch where possible.
- Each goroutine defers `Done` exactly once.
- `Wait` is called by the owner after launching all work.

### PG-34: errgroup is preferred when goroutines can fail
When concurrent tasks return errors, `errgroup` keeps waiting and error propagation simpler than a bare `WaitGroup`.

Audit checks:
- Concurrent tasks returning errors use `errgroup` or an equivalent error aggregation pattern.
- First or all error semantics are clear.
- Shared result aggregation is protected by atomics, locks, channels, or single-owner design.

### PG-35: Loop variables are captured safely in goroutines
Loop variables should be rebound inside loops before launching goroutines that close over them.

Audit checks:
- Patterns such as `v := v` appear before goroutine closures when required.
- Tests cover multi-item concurrent loops.
- Race/static analyzers report no closure capture issues.

### PG-36: Channel sends and receives are balanced
Channels should have clear ownership, buffering, closing, and blocking semantics.

Audit checks:
- Unbuffered and buffered channels are chosen intentionally.
- Send/receive counts cannot deadlock under expected execution paths.
- `select` with `default` is used intentionally for non-blocking operations.
- Channel close responsibility is documented by code shape.

### PG-37: Web-handler goroutines are reviewed carefully
A goroutine launched inside an HTTP handler continues after the response path returns. That can be valid, but it needs lifecycle, error handling, and shared-data safety.

Audit checks:
- Handler-spawned goroutines do not mutate request-local values that are read after launch without synchronization.
- Errors from background handler work are observed or logged.
- Request cancellation and service shutdown semantics are considered.

### PG-38: Pollers use tickers and cleanup
Background pollers should use `time.NewTicker`, stop tickers, close response bodies, handle errors, and avoid resource leaks.

Audit checks:
- Tickers are stopped where lifecycle ends.
- HTTP response bodies are closed.
- Error paths avoid nil dereferences after failed requests.
- Polling loops have an intended shutdown path for production services.

### PG-39: Shared data is protected by locks, atomics, channels, or ownership
A data race occurs when goroutines concurrently access the same memory and at least one access writes. Production code should avoid this by design and by testing.

Audit checks:
- Shared fields and maps are guarded consistently.
- Simple counters use `sync/atomic` or a lock.
- Race detector runs on relevant tests and integration flows.

## 8. Tests and examples

### PG-40: Production code has automated tests
A production-ready Go system should have automated tests that prove behavior across reasonable scenarios.

Audit checks:
- Important packages have `_test.go` files.
- `go test ./...` passes.
- Tests run in CI.
- Critical business logic, boundaries, and error paths are tested.

### PG-41: Test files follow Go conventions
Tests live beside the package code and use standard naming.

Audit checks:
- Test files end in `_test.go`.
- Test functions are named `TestX(t *testing.T)`.
- Benchmarks are named `BenchmarkX(b *testing.B)`.
- Examples are named according to `ExampleX`, `ExampleType_Method`, or `ExampleX_suffix`.

### PG-42: Table-driven tests cover edge cases
Table-driven tests reduce repetition and make it cheap to add edge cases.

Audit checks:
- Input/output cases are declared up front.
- Cases include invalid, zero, boundary, negative, long, and Unicode inputs where relevant.
- Loops report enough context to identify the failing case.

### PG-43: Test failure messages use got/want discipline
Failure messages should show the call or behavior, the actual result, and the expected result.

Audit checks:
- Assertions follow `got != want` ordering.
- Error messages include function name and inputs when helpful.
- Future maintainers can debug from the failure text.

### PG-44: HTTP handlers are tested through `httptest`
Use `net/http/httptest` to exercise handlers as HTTP components.

Audit checks:
- Tests create requests and response recorders.
- Tests call `ServeHTTP` or equivalent router handling.
- Tests assert status codes, response bodies, headers, and error paths.

### PG-45: Mocks are used to isolate unit tests
Unit tests should isolate the unit under test. Third-party APIs, databases, randomness, and network calls can be represented by narrow interfaces.

Audit checks:
- Interfaces sit at the consumer side where mocking helps.
- Unit tests avoid real external services unless they are integration tests.
- Integration tests are marked, separated, or documented when they depend on outside systems.

### PG-46: Coverage reports guide missing cases
Coverage is a diagnostic tool. Low or uneven coverage should lead to concrete missing-case analysis, not only a numeric target.

Audit checks:
- `go test -cover` or coverage profiles are available.
- `go tool cover -func` or HTML reports are used to inspect uncovered paths.
- Critical uncovered paths produce prioritized findings.

### PG-47: Fuzzing is used for input-heavy code
Parsers, decoders, validators, search, and user-input paths benefit from fuzzing.

Audit checks:
- Fuzz functions or a fuzzing workflow exist for high-risk input surfaces.
- Crashes or interesting inputs are captured as regression tests.
- Fuzzing is documented for local or CI use when applicable.

## 9. Benchmarks and performance checks

### PG-48: Benchmarks establish a baseline before optimization
Performance improvements should be measured against a benchmark baseline.

Audit checks:
- Benchmarks exist for hot paths or performance-sensitive algorithms.
- The benchmark target is behaviorally covered by tests first.
- Benchmark output is saved or compared when optimizing.

### PG-49: Benchmark functions follow testing package rules
Benchmarks should run the target code inside the `b.N` loop.

Audit checks:
- Functions are named `BenchmarkX(b *testing.B)`.
- Setup work is outside the timed loop.
- The target operation runs `b.N` times.

### PG-50: Setup cost is excluded when needed
Use `b.ResetTimer()` after setup so the measured operation reflects the code under evaluation.

Audit checks:
- Expensive setup is before `ResetTimer`.
- `b.SetBytes` is used where throughput per byte matters.

### PG-51: Memory allocations are measured
Use benchmark memory reporting to understand bytes and allocations per operation.

Audit checks:
- `go test -bench=. -benchmem` is used for allocation-sensitive paths.
- `go test -gcflags=-m` or equivalent escape analysis is used when allocation source matters.
- Implementations avoid unnecessary slices or heap allocations in hot paths.

### PG-52: Benchmark harness overhead is minimized for tiny operations
For nanosecond-scale benchmarks, even the benchmark's own indexing and setup can distort results.

Audit checks:
- Benchmark input selection does not dominate the measured operation.
- Modulo-vs-bitwise substitutions are used only when mathematically valid, such as power-of-two lengths.
- Larger realistic benchmarks supplement microbenchmarks.

## 10. Static analysis and developer tooling

### PG-53: `go vet` is required
`go vet` catches correctness issues such as wrong printf verbs. It should be part of the core build gate.

Audit checks:
- `go vet ./...` passes.
- CI fails on vet errors.
- Printf/Println formatting issues are absent.

### PG-54: Staticcheck or equivalent catches deeper issues
Static analyzers catch unused errors, ineffective assignments, simplifications, and style issues that compiler and vet may miss.

Audit checks:
- Static analysis runs locally and/or in CI.
- High-signal staticcheck findings are fixed.
- Error string capitalization, unused values, and ignored pure functions are reviewed.

### PG-55: Linter suites are tuned rather than blindly obeyed
Linter output can include false positives. Require high-signal checks in CI and treat noisy checks as review aids.

Audit checks:
- The required linter set is documented.
- `deadcode`, `ineffassign`, `staticcheck`, `misspell`, `errcheck`, and vet-equivalent checks are considered.
- The team records exceptions or local suppressions sparingly.

### PG-56: Race detector is used on concurrent code
The race detector should be run on tests and runnable service flows that exercise concurrency.

Audit checks:
- `go test -race ./...` passes where feasible.
- Services can be built or run with `-race` for integration exercises.
- Race detector findings are treated as correctness failures.

### PG-57: Code navigation tools support interface-heavy code
Tools such as godoc and Go Guru-style queries help developers understand callers, callees, referrers, and interface implementations.

Audit checks:
- Developers have an expected way to find interface implementations and references.
- Public APIs are navigable through generated docs.

## 11. Security

### PG-58: Go security updates are part of operations
Security fixes can arrive in minor Go releases. The production environment should have a process to update promptly.

Audit checks:
- Runtime/toolchain version is visible in build metadata or deployment docs.
- Security update ownership is clear.
- The project can be rebuilt and redeployed when Go security fixes land.

### PG-59: CSRF protection exists for authenticated browser POSTs
Browser-based state-changing endpoints should defend against cross-site request forgery.

Audit checks:
- Authenticated forms or unsafe HTTP methods use per-session CSRF tokens.
- Missing or mismatched tokens are rejected.
- CSRF middleware or equivalent custom enforcement is present.

### PG-60: HSTS is set for HTTPS sites
HTTP Strict Transport Security tells browsers to use HTTPS and helps prevent downgrade/cookie hijacking attacks.

Audit checks:
- `Strict-Transport-Security` is set by the Go server or front proxy.
- `max-age` is configured intentionally.
- `includeSubDomains` is used when appropriate for the domain.

### PG-61: CSP is set for browser-facing applications
Content Security Policy reduces XSS risk by constraining content origins.

Audit checks:
- `Content-Security-Policy` exists for browser responses.
- `default-src 'self'` or a stricter project-specific policy is used where practical.
- Inline scripts/styles and third-party origins are explicitly justified.

### PG-62: SQL queries never concatenate untrusted input
Use prepared statements or query placeholders rather than building SQL with user-controlled strings.

Audit checks:
- No SQL strings concatenate request input or untrusted data.
- `database/sql` calls pass parameters separately from query text.
- Rows and statements are closed.
- Error paths do not leak sensitive details to clients.

### PG-63: User-generated HTML is sanitized or avoided
When user content is rendered as HTML, sanitize it or avoid trusting it as template-safe HTML.

Audit checks:
- Sanitization libraries or strict escaping are used for user HTML.
- Direct `template.HTML` conversions are reviewed.
- CSP supplements but does not replace output sanitization.

## 12. Production readiness, CI/CD, and observability

### PG-64: Deployment is automated enough to reduce manual error
Production deployment should be repeatable. The system can choose manual approval or full automation, but the path should avoid ad hoc server changes.

Audit checks:
- Build artifacts, images, or binaries are reproducible.
- Staging/production promotion path is documented.
- Rollback or redeploy steps are known.

### PG-65: Logs are centralized for multi-server production
Once a service runs on multiple hosts or containers, logs should be accessible without SSHing into individual machines.

Audit checks:
- Logs include useful context and severity.
- Logs from all instances flow to a central system.
- Error logs support debugging without exposing secrets.

### PG-66: Metrics and dashboards exist
Logs alone do not answer whether users are experiencing issues. Production systems need high-level metrics and dashboards.

Audit checks:
- Dashboard covers server health, process uptime, memory, disk, latency, traffic, errors, and dependency health where relevant.
- Metrics are collected in a time-series system or equivalent.
- Dashboard can show whether servers stopped running or stopped sending logs.

### PG-67: Alerting closes the production feedback loop
Operators should be notified when important production behavior crosses thresholds.

Audit checks:
- Alerts exist for availability, error rate, latency, resource pressure, and missing telemetry.
- Alerts are actionable and routed to responsible owners.
- Alert fatigue is managed by focusing on user or service impact.

### PG-68: Redundancy, latency, and scale are considered
A production web application commonly runs on multiple servers or instances for redundancy, latency, or scale.

Audit checks:
- The deployment model matches expected availability needs.
- Stateless/stateful boundaries are clear.
- Dashboards aggregate per-instance and fleet-level health.

## 13. Scoring guidance

Use these labels consistently:

- `pass`: Evidence shows the practice is implemented.
- `partial`: The practice is partly implemented or applies only to some modules/packages.
- `fail`: Evidence shows the practice is absent or violated.
- `unknown`: Evidence was unavailable; list what to inspect next.
- `not applicable`: The practice does not apply to this codebase.

Severity guidance:

- `p0`: likely production outage, exploitable security flaw, data race on critical path, broken build/test gate, or data corruption risk.
- `p1`: serious correctness, security, or operability gap that should be fixed before production expansion.
- `p2`: maintainability, reliability, or testing gap that should enter the near-term backlog.
- `p3`: style, documentation, or modernization improvement with limited immediate risk.

Finding quality bar:

- Include file path and line number when possible.
- Include the checklist item ID.
- Explain runtime, security, or maintainability impact.
- Give a concrete remediation command or code-level direction.
- Mark uncertainty instead of guessing when evidence is incomplete.
