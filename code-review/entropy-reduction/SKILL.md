---
name: entropy-reduction
description: "USE THIS SKILL whenever the user wants to: refactor a codebase, clean up tech debt, improve code consistency, reduce complexity, make a codebase more maintainable, or when the user mentions entropy, code quality, code health, or asks to clean up or simplify a module, directory, or entire repo. Especially valuable for AI-first and vibe coding teams where code accumulates disorder quickly."
---

Systematically reduce codebase disorder without breaking existing behavior. Your job is not to add features — it is to identify high-entropy areas and make them lower-entropy through safe, incremental refactoring.

## Philosophy

Entropy in a codebase is the accumulation of inconsistency, unnecessary complexity, and structural disorder that makes future changes harder. It comes from four axes:

| Axis | What it means | Typical symptoms |
|------|--------------|------------------|
| **Structural** | Layering, dependencies, topology | Oversized files/functions, util black holes, circular deps, layer violations |
| **Semantic** | Naming, concepts, state representation | Same concept with multiple names, scattered state machines, ad-hoc data models |
| **Behavioral** | API contracts, error handling, boundary behavior | Inconsistent error responses, different status codes for the same error class, env-dependent behavior |
| **Evolutionary** | Change patterns, ownership, understandability | Giant mixed-purpose PRs, no clear module ownership, design intent buried in chat history |

Prioritize: **obviously high-entropy areas >> minor style issues**. Never rewrite stable, well-functioning code just for aesthetics.

## Workflow

When given a codebase scope (file, directory, module, or repo), follow these four phases:

### Phase 1: Diagnose

Scan the target scope and identify high-entropy symptoms. For each finding, note:
- **What**: the specific symptom (e.g., "5 different names for the user concept across 3 modules")
- **Which axis**: structural / semantic / behavioral / evolutionary
- **Severity**: how much disorder this creates for future maintainers

Concrete things to look for:

**Structural entropy**
- Files over ~500 lines or functions over ~50 lines
- `util/`, `common/`, `helpers/` directories that have become catch-all dumping grounds with business logic mixed in
- Circular dependencies between modules (A→B→C→A)
- UI code directly importing from infrastructure/database layers, skipping service layers
- God objects or god modules that everything depends on

**Semantic entropy**
- The same domain concept referred to by multiple names (e.g., `user` / `member` / `account` / `customer` / `profile` all meaning the same thing)
- The same business state represented differently in different places (enum in one module, string in another, integer in a third)
- State transition logic scattered across handlers, services, frontend, and batch jobs instead of living in one place
- Ad-hoc structs/dicts/maps used where a proper domain model would clarify intent

**Behavioral entropy**
- The same type of error returning different HTTP status codes or payload shapes in different endpoints
- Boundary cases (empty data, missing params, permission denied) handled inconsistently across similar APIs
- Behavior that diverges significantly between local/test/production environments

**Evolutionary entropy**
- Recent PRs that mix feature work, refactoring, and formatting in a single changeset
- Modules with no clear ownership — multiple authors, no consistent patterns
- Design decisions whose rationale exists only in chat logs or memories, not in code or docs

Present findings as a concise list — developer-readable, no jargon overload.

### Phase 2: Plan

Design an incremental entropy reduction plan:

1. **Propose 1–3 small, safe changes** that can be done immediately. For each:
   - State the goal (what entropy it reduces)
   - State the risk (what could break)
   - Label the entropy axes it addresses
   - Estimate scope: is this local (single file/module) or cross-cutting?

2. **Prioritize** by: highest entropy reduction per unit of risk. Do the safe, high-impact changes first.

3. **Flag anything that needs human input** — if you're unsure about a naming convention, an architectural boundary, or whether a behavior change is acceptable, ask rather than guess.

### Phase 3: Refactor

Execute the planned changes:

- **Preserve external behavior.** Every refactor must be behavior-preserving unless explicitly approved otherwise.
- **Work in small steps.** Each change should be independently committable and reversible.
- **When renaming or moving code**, ensure all references are updated. Check imports, type references, tests, and config files.
- **For risky changes** (anything that touches shared interfaces or public APIs):
  - List the callers/consumers that could be affected
  - Suggest specific test cases to verify the change is safe
- **In commit messages**, briefly explain the entropy reduction intent (e.g., "Consolidate user/member/account naming to 'user' — reduces semantic entropy across auth and billing modules").

### Phase 4: Verify

After making changes:

- Run existing tests if available. All must pass.
- If no tests exist for the changed code, note which test cases should be added to protect the refactored behavior.
- Confirm that no new cross-layer dependencies, naming variants, or util dumping has been introduced.

## Constraints

These are hard rules — do not violate them:

1. **No large rewrites of stable code.** If it works and isn't causing maintenance pain, leave it alone.
2. **No new util/common black holes.** Do not create new catch-all modules. Move business logic into the domain it belongs to.
3. **No new naming variants.** If the codebase calls it `user`, don't introduce `member` or `account` as an alternative name for the same concept.
4. **No new cross-layer dependencies.** Respect the dependency direction: UI → Service → Domain → Repository → Infrastructure.
5. **Reuse existing abstractions.** Before creating a new helper, check if one already exists. Three similar lines of code is better than a premature abstraction.
6. **When uncertain, ask.** Do not force an abstraction or rename you're unsure about. State your assumption and ask the human to confirm.

## Output Format

Structure your output as:

1. **Diagnosis** — Brief list of high-entropy findings with axis labels and severity
2. **Plan** — Numbered list of proposed changes with goals, risks, and axis labels
3. **Changes** — The actual code modifications (complete, compilable/runnable)
4. **Test suggestions** — Any tests that should be added to protect refactored behavior
5. **Follow-up** — Larger entropy reduction opportunities that need more planning or human input

Keep the diagnosis and plan sections concise. The code changes are the main deliverable.
