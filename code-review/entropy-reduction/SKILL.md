---
name: entropy-reduction
description: 'Refactor a codebase to reduce tech debt and disorder. Triggers on ''refactor'', ''tech debt'', ''code health'', ''clean up'', or ''simplify''.'
---

Hit obvious disorder first; leave working code alone. Axes: **structural** (layering, deps), **semantic** (naming, concepts), **behavioral** (contracts, errors), **evolutionary** (change patterns, ownership).

**Diagnose** (symptom + axis + severity) → **Plan** (a few small changes: goal, risk, scope; best reduction-per-risk first; ask when unsure) → **Refactor** (behavior-preserving, independently committable steps; list affected callers for risky changes; commit messages state the entropy intent) → **Verify** (tests pass; note missing coverage; no new violations).

**Don't:** large rewrites of stable code; new util black holes; new naming variants; new cross-layer deps (UI → Service → Domain → Repository → Infrastructure); premature abstractions; forcing renames you're unsure about — ask.
