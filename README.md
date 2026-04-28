[English](README.md) | [中文](README.zh-CN.md)

# David's Skills

**AI agent skills for content operations and developer workflows.**

Personal collection of skills compatible with [Hermes Agent](https://github.com/nousresearch/hermes-agent) and [OpenClaw](https://github.com/openclaw/openclaw).

---

## Installation

### Hermes Agent

```bash
git clone https://github.com/thedavidweng/skills.git ~/.hermes/skills/david-skills
```

Restart Hermes. Skills are auto-discovered from `~/.hermes/skills/` — no config changes needed.

### OpenClaw

```bash
git clone https://github.com/thedavidweng/skills.git ~/.openclaw/skills/david-skills
```

Restart OpenClaw. Skills register on the next session start.

### Other Agents

These skills also work with any [Agent Skills](https://agentskills.io/specification)-compatible tool: Amp, Cline, Codex, Cursor, Gemini CLI, Kimi Code CLI, OpenCode, Warp, and the generic `.agents/skills` path.

```bash
npx skills add thedavidweng/skills --full-depth
```

> All agents auto-discover `SKILL.md` files under their skills path. Use `--full-depth` to install nested skills (e.g. everything under `wiki/`).

---

## Skills

### Personal Knowledge Wiki

Build and maintain a compounding knowledge base from your notes, messages, and documents.

| Skill | Description |
|-------|-------------|
| **[wiki-core](wiki/wiki-core/)** | Build the wiki. Ingest raw data, absorb into articles, query, clean up. The foundation everything else assumes. |
| **[wiki-inline-linking](wiki/wiki-inline-linking/)** | Add Wikipedia-style inline wikilinks. No more `## Related` sections. |
| **[wiki-inline-link-audit](wiki/wiki-inline-link-audit/)** | Automatically find and fix unlinked mentions across the vault. |
| **[wiki-slug-rename](wiki/wiki-slug-rename/)** | Rename page slugs without breaking links across the vault. |
| **[wiki-sources-integrity](wiki/wiki-sources-integrity/)** | Protect `## Sources` sections during batch cleanup. Never lose identity document links. |
| **[wiki-source-integration](wiki/wiki-source-integration/)** | Decide whether to embed documents inline or store them in `sources/`. |
| **[wiki-source-document-ingest](wiki/wiki-source-document-ingest/)** | Ingest certificates, contracts, and official documents into sources and wiki pages. |
| **[wiki-vcf-import](wiki/wiki-vcf-import/)** | Import VCF contacts into `wiki/people/` pages. Handles Chinese name reversal and phone masking. |
| **[wiki-audit](wiki/wiki-audit/)** | Full vault audit: orphans, broken links, duplicates, stubs, tag compliance, content hygiene. |
| **[wiki-link-audit](wiki/wiki-link-audit/)** | Verify backlink legitimacy. Catch false links and same-name collisions. |
| **[wiki-quartz-publish](wiki/wiki-quartz-publish/)** | Publish your wiki as a private Quartz site. Strongly recommends Cloudflare Access / Zero Trust. |

### YouTube Content Operations

Generate channel-consistent metadata for uploaded videos.

| Skill | Description |
|-------|-------------|
| **[youtube-content-ops](youtube-content-ops/)** | Generate titles, descriptions, and tags that match your channel's brand style. |

### Document Generation

Text-as-source document workflows. Manage source files, not PDFs — generate on demand.

| Skill | Description |
|-------|-------------|
| **[cover-letter](document-generation/cover-letter/)** | Professional cover letters via Typst. Calibrated template with precise typography — one command to PDF. |
| **[json-resume](document-generation/json-resume/)** | Structured resumes via JSON Resume standard. Data/style separation, themed rendering, auto-publish to registry. |
| **[cli-invoice](document-generation/cli-invoice/)** | CLI-based invoices via maaslalani/invoice. The command is the source file — store in notes, regenerate anytime. |

### Code Quality

Systematic codebase maintenance for AI-first and vibe-coding teams.

| Skill | Description |
|-------|-------------|
| **[entropy-reduction](code-review/entropy-reduction/)** | Identify and fix structural, semantic, behavioral, and evolutionary disorder through safe, incremental refactoring. |

---

## How It Works

Once installed, prompt your agent naturally:

```
"Build a wiki from my notes and messages"
"Audit my wiki for broken links and orphan pages"
"Write a YouTube description for this video"
"Refactor this codebase to reduce tech debt"
"Write a cover letter for this job posting"
"Render my resume as PDF"
"Generate an invoice for last month's work"
```

Each skill auto-detects the appropriate workflow, fetches context from your data or codebase, and produces results. Agent Skills follow the standard format: each skill directory contains a `SKILL.md` with the full workflow spec, and optional `references/` with templates, cheatsheets, and examples.

---

## Structure

Each skill follows the standard Agent Skills format:

```
skill-name/
├── SKILL.md           # Full workflow spec for the agent
├── agents/
│   └── openai.yaml    # UI metadata
└── references/        # Templates, cheatsheets, examples
```

- `SKILL.md` — commands, decision trees, pitfalls, pre-publish checklist
- `agents/openai.yaml` — skill name and description for agent UI discovery
- `references/` — brand guide templates, CLI command references, supporting docs

Category directories (e.g. `wiki/`, `code-review/`) contain a `README.md` summarizing all skills in that group.

---

## Contributing

Personal collection, but bug reports and improvements welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
