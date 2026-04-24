# Cleanup & Breakdown Workflows

> Load this reference when executing `/wiki cleanup` or `/wiki breakdown`.

## Cleanup

Audit and enrich every article using parallel subagents.

### Phase 1: Build Context

Read `system/wiki/index.md`, `maps/`, and sample 10 source notes. Identify: broken links, orphan pages, missing sources, index drift, naming inconsistencies.

### Phase 2: Per-Article Subagents

For each article that needs work, spawn a subagent with full context (article + linked sources + related pages). Tasks:
- Rewrite weak sections
- Add missing links and sources
- Split oversized articles
- Merge duplicate pages
- Create new pages for themes that emerged

### Phase 3: Integration

After subagents finish, verify: all links resolve, index is accurate, no duplicate pages, maps cover all active articles.

## Breakdown

Find and create missing articles. Expands the wiki by identifying concrete entities and themes that deserve their own pages.

### Phase 1: Survey

Read `system/wiki/index.md` and all `maps/` pages. Understand current coverage. Identify gaps: what topics are missing? What articles are stubs? What relationships are unmapped?

### Phase 2: Mining

Read source notes in the scope. For each entry, extract:
- Named entities (people, places, projects, organizations)
- Themes and patterns (recurring ideas, emotional arcs, decisions)
- Temporal markers (dates, sequences, phases)
- Relationships (who introduced whom, collaborations, conflicts)
- Source quality (verified vs. inferred vs. hearsay)

Build a running list: entities, themes, and source references.

### Phase 3: Planning

For each theme: what articles exist? What should exist? What merges/splits? Plan article structure before writing.

### Phase 4: Creation

Write new articles and update existing ones. Every article should connect to at least 3 others. Every claim should cite a source.

### Reclassification

After creation, audit page types. A person page that became mostly about a project may need splitting. A concept that grew into a full project needs reclassification.
