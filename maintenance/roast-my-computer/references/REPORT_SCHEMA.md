# Report Schema

## Contents

- Top-level fields
- Finding shape
- Scan scope
- Scan budgets and truncation
- HTML contract
- Share card data

`scan_dev_environment.py` writes `schema_version: 1.6.0`.

## Top-level fields

- `schema_version`: string
- `generated_at`: ISO timestamp
- `host`: platform metadata with hashed hostname
- `scan_policy`: local-only, scope, project root, content-scan, sensitive-content-scan, redaction, depth, size limits, entry/time budgets, repository scan limit metadata, and truncation status
- `scan_roots`: absolute paths scanned (empty directories are filtered out before scanning)
- `root_summaries`: per-root counts, including `installer_archive_count` so installers can be attributed to the root that actually holds them
- `totals`: aggregate counts
- `examples`: bounded path examples, including `ai_markers` (each entry: `detector`, `sample`, `path`, `count`)
- `findings`: redacted structured risks
- `repositories`: Git repository summaries
- `scores`: overall and six dimensions

## Finding shape

Sensitive directory findings may include redacted detector findings from small text files; raw values remain excluded. In conservative mode (`--metadata-only-sensitive-dirs`), those paths produce metadata-only findings. Private-key-like files such as `id_rsa`, `id_ed25519`, `private_key.pem`, or suspicious `.key`/`.pem` names are always detected by path metadata.

Each `secret_chaos` finding carries a `source` tag so cleanup copy can branch on the *kind* of risk rather than treating every critical identically:

| `source` | Meaning | Cleanup action |
|----------|---------|----------------|
| `user_config` | A file the user wrote or tracked (`.ssh`, `.aws`, `opencode.json`, `.env`, a real private key under a developer's `.app` project, etc.) | Rotate / move to a secret store |
| `editor_cache` | Editor undo-history or auto-backup that captured a key (directory named `History`, `.backups`, `User Data`, or `Local History`) | Clear editor history, then rotate the source key |
| `test_fixture` | A fake key in `tests/`, `__tests__/`, `fixtures/`, `*_test.*`, `*.test.*` | No action — these are redaction verification fixtures; severity is capped at medium |
| `public_key` | A file whose name contains `public`/`pubkey`/`publickey` | No action — public keys are not secrets; severity is capped at low |
| `app_bundle_public_key` | A public-key-name file that also lives under a `*.app` path | No action — app-bundle public keys are not user secrets; severity is capped at low. A real private key under a developer's `.app` project directory is NOT downgraded (only the public-key-name signal triggers the cap). |

Repo-scoped secrets in `repositories[].secret_findings[]` additionally carry `tracked_in_git` (true when the path appears in `git ls-files` output), which reconciles the previous overlap between `tracked_sensitive_config_files` and `secret_findings`: a tracked file now shows up once as a `secret_findings` entry with `tracked_in_git: true`, rather than as two separate concepts the agent had to merge by hand.

```json
{
  "category": "secret_chaos",
  "severity": "critical",
  "title": "redacted secret-like pattern detected: github_token",
  "evidence": {
    "matches": 1,
    "redacted": true,
    "path_hash": "..."
  },
  "paths": ["/local/path/.env"],
  "detector": "github_token",
  "source": "user_config"
}
```

## Scan scope

`scan_policy.scope` is one of:

- `project`: current working directory, plus explicit extra paths if supplied.
- `global`: common platform roots plus memory/context roots and explicit paths. More accurate; may require permission approval.

`scan_policy.project_root` records the current working directory at scan time.
`scan_policy.provided_root_count` records how many supplied roots existed on disk.
`scan_policy.repository_discovered_count`, `repository_scanned_count`, `repository_scan_truncated`, and `repository_scan_limit` make repository sampling explicit. Scores use the scanned repository subset when truncation is true.

## Scan budgets and truncation

The scanner has hard limits so it never runs forever. When a limit is hit, the scan stops, writes partial results, and sets truncation fields in `scan_policy`:

- `entry_count`: total entries actually scanned
- `entry_limit`: the `--max-entries` cap (default 200000)
- `entries_truncated`: true if `entry_count` hit the cap
- `dirs_truncated_count`: number of directories whose listing was capped by `--max-entries-per-dir`
- `wall_clock_seconds`: actual scan duration
- `wall_clock_limit_seconds`: the `--max-seconds` cap (default 60)
- `wall_clock_truncated`: true if the wall-clock budget was hit
- `truncated`: true if any limit was hit
- `truncation_reason`: `time_limit`, `entry_limit`, or null

When `truncated` is true, the HTML report should display a truncation notice so the roast reflects incomplete coverage rather than implying the machine was fully scanned.

## HTML contract

The branded HTML format belongs in `references/HTML_REPORT_FORMAT.md`. Agents should render that format directly from scan JSON. They may change prose through the optional writer prompt, but deterministic values must still come from the scan JSON.

Required visual markers:

- classic Macintosh menu bar: `File Edit View Report Tools Help`
- large `ROAST MY COMPUTER` title
- local-only subtitle
- one screenshot-worthy summary roast
- four score cards: digital landfill, abandoned projects, secret chaos, git shame
- flexible `DIAGNOSIS` text pane
- simple `HOTSPOTS` table with no size column
- compact `RED FLAGS` list with redacted secret-risk findings
- four-step `REDEMPTION` checklist
- bottom status bar with `Roast Complete` button

## Share card data

Only aggregate fields are suitable for sharing:

- title
- overall score
- repository count
- redacted secret risk count
- dependency graveyard count
- top roast line

Do not include full paths, usernames, hostnames, source snippets, or secret detectors in public share cards unless the user explicitly reviews and approves them.
