[English](README.md) | [中文](README.zh-CN.md)

# David's Skills

**AI agent skills for content operations and developer workflows.**

Personal collection of skills compatible with [Hermes Agent](https://github.com/nousresearch/hermes-agent) and [OpenClaw](https://github.com/openclaw/openclaw).

---

## Installation

Works with [Hermes Agent](https://github.com/nousresearch/hermes-agent), [OpenClaw](https://github.com/openclaw/openclaw), and any [Agent Skills](https://agentskills.io/specification)-compatible tool (Amp, Cline, Codex, Cursor, Gemini CLI, Kimi Code CLI, OpenCode, Warp).

```bash
npx skills add thedavidweng/skills
```

The installer opens an interactive multi-select menu. Use `--all` to install every skill without selecting one by one:

```bash
npx skills add thedavidweng/skills --all
```

---

## Skills

### Personal Knowledge Wiki

Build and maintain a compounding knowledge base from your notes, messages, and documents.

| Skill | Description |
|-------|-------------|
| **[wiki-core](wiki/wiki-core/)** | Build the wiki. Ingest raw data, absorb into articles, query, clean up. The foundation everything else assumes. |
| **[wiki-linking](wiki/wiki-linking/)** | Add Wikipedia-style inline wikilinks, scan for unlinked mentions, verify backlinks. No more `## Related` sections. |
| **[wiki-slug-rename](wiki/wiki-slug-rename/)** | Rename page slugs without breaking links across the vault. |
| **[wiki-sources](wiki/wiki-sources/)** | Source layer: inline vs file, ingest certificates/contracts, protect `## Sources` sections. |
| **[wiki-vcf-import](wiki/wiki-vcf-import/)** | Import VCF contacts into `wiki/people/` pages. Handles Chinese name reversal and phone masking. |
| **[wiki-quartz-publish](wiki/wiki-quartz-publish/)** | Publish your wiki as a private Quartz site. Strongly recommends Cloudflare Access / Zero Trust. |

### Content Operations

Generate channel-consistent metadata for uploaded videos.

| Skill | Description |
|-------|-------------|
| **[youtube-content-ops](content-ops/youtube-content-ops/)** | Generate titles, descriptions, and tags that match your channel's brand style. |

### Document Generation

Text-as-source document workflows. Manage source files, not PDFs — generate on demand.

| Skill | Description |
|-------|-------------|
| **[cover-letter](document-generation/cover-letter/)** | Professional cover letters via Typst. Calibrated template with precise typography — one command to PDF. |
| **[cli-invoice](document-generation/cli-invoice/)** | CLI-based invoices via maaslalani/invoice. The command is the source file — store in notes, regenerate anytime. |

### Code Quality

Production-readiness review for Go codebases.

| Skill | Description |
|-------|-------------|
| **[go-production-review](code-review/go-production-review/)** | Audit Go codebases against production best practices — modules, error handling, concurrency, tests, security, CI/CD, observability. |

### Web Development

Audit and optimize websites for AI discoverability and agent experience.

| Skill | Description |
|-------|-------------|
| **[aeo-audit](web-dev/aeo-audit/)** | Audit any website for Agent Experience Optimization — llms.txt, schema.org, semantic HTML, sitemap, and cross-signal consistency. |

### Homebrew

Submit casks with the checks local audit does not run.

| Skill | Description |
|-------|-------------|
| **[homebrew-cask-submit](homebrew/homebrew-cask-submit/)** | Non-obvious checks for a new or fixed cask: signed URLs, homepage age, arch evidence, regional pairs, livecheck, zap, one-cask taps, and the PR template bot. |

### Writing

Style-guided content generation and review.

| Skill | Description |
|-------|-------------|
| **[david-weng-writing-style](writing/david-weng-writing-style/)** | Write or review text in David Weng's personal style — direct, factual, no fluff. Combines voice & structure rules with bilingual typography. |

### Maintenance

| Skill | Description |
|-------|-------------|
| **[roast-my-computer](maintenance/roast-my-computer/)** | Scan your local machine and generate a privacy-safe developer roast report — abandoned projects, dependency graveyards, git shame, AI slop, redacted secret risk. |
| **[skill-repo-maintenance](maintenance/skill-repo-maintenance/)** | Maintain and reorganize agent skills within a skills repository. Rename skills, fix installation commands, and avoid CLI pitfalls. |
| **[stale-docs-cleanup](maintenance/stale-docs-cleanup/)** | Delete stale docs, move future work into issues, preserve human-facing guides and frozen contracts. |
---

## How It Works

Once installed, prompt your agent naturally:

```
"Build a wiki from my notes and messages"
"Audit my wiki for broken links and orphan pages"
"Write a YouTube description for this video"
"Audit this Go service for production readiness"
"Write a cover letter for this job posting"
"Generate an invoice for last month's work"
```

Each skill is a `SKILL.md` the agent loads. Extra files exist only when that file is not enough.

---

## Structure

```
category/skill-name/SKILL.md    # required, agent-facing
```

`references/`, `scripts/`, and `agents/openai.yaml` are optional. Category directories may have a `README.md` listing the skills in that group. See [CONTRIBUTING.md](CONTRIBUTING.md).

The repository also includes `.claude-plugin/plugin.json`, which lists the skills that `npx skills add thedavidweng/skills` should show by default. Keep that manifest in sync when adding, moving, or renaming skills.

---

## My Third-Party Skills

Curated list of third-party agent skills I use alongside this repo → **[THIRD-PARTY-SKILLS.md](./THIRD-PARTY-SKILLS.md)**

---

## Contributing

Personal collection, but bug reports and improvements welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
