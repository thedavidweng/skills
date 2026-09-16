---
name: go-production-review
description: 'Review a Go codebase for production readiness. Triggers on ''audit Go'', ''production readiness'', ''harden'', or ''Go best practices''.'
---

Score the repo against `references/production-go-checklist.md` (`PG-xx` IDs): modules, gofmt, types, errors, strings, concurrency, tests, benchmarks, vet/lint, security, CI/CD/observability. Accept modern equivalents scoring the same practice.

Run `scripts/collect_go_production_signals.sh` for evidence where possible (signals, not verdicts). Rank `p0`–`p3`. Every finding: checklist ID, file:line, production impact, concrete fix, verification command. `unknown` when evidence is missing — never invent infra details. Lead with the verdict; most space goes to repo-specific evidence, not generic education.
