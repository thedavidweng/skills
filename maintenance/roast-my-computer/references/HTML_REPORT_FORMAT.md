# HTML Report Format

## Contents

- Visual target
- Scaffold
- Data mapping
- Language
- Header
- Score cards
- Diagnosis
- Hotspots
- Red Flags
- Redemption
- Footer
- Tone
- Implementation notes for agents

The roast report is rendered as a single self-contained HTML file in the OS temp directory. Use the scan JSON as the source of truth for counts, paths, scores, severities, and redaction state. The HTML should feel like a full-screen app from a classic Macintosh System 1.x / early Finder machine: black-and-white, pixel-forward, ruled boxes, compact bitmap-style typography, and one main page.

Do not generate a modern dashboard. Do not use Tailwind, Mermaid, chart libraries, web fonts, external images, or JavaScript. The report must be static HTML + inline CSS so it is easy for low-context agents to reproduce.

## Visual target

Use the mock as the direction:

- single full-screen app view
- top Macintosh-style menu bar: `File Edit View Report Tools Help`
- black-and-white palette only
- thick black borders, rounded Macintosh-style panels, simple dotted/dithered fills
- large block title: `ROAST MY COMPUTER`
- compact score cards
- one flexible `DIAGNOSIS` narrative panel
- simple `HOTSPOTS` table with locations and lightweight item/examples notes
- compact `RED FLAGS` list
- compact `REDEMPTION` checklist
- bottom status bar with one final joke and a `Roast Complete` button
- a truncation notice line (only when `scan_policy.truncated` is true) stating the scan hit a time or entry limit and the roast reflects partial coverage, not a full audit

Keep the page sparse enough that the HTML is obvious. The report should look like an old Macintosh utility, not an analytics product pretending to be retro.

## Scaffold

Write to `$REPORT_DIR/computer-roast-report-<timestamp>.html` where `$REPORT_DIR` is `${TMPDIR:-/tmp}/roast-my-computer` on Unix or `%TEMP%\roast-my-computer` on Windows. The stable directory lets the workflow's step 1 discover and offer to recycle previous reports. Use escaped values from `computer-roast-scan.json`.

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Roast My Computer — Local Report</title>
    <style>
      :root {
        --ink: #000;
        --paper: #fff;
        --wash: #f2f2f2;
        --line: 2px solid #000;
      }

      * { box-sizing: border-box; }

      body {
        margin: 0;
        color: var(--ink);
        background: var(--paper);
        font-family: Chicago, Geneva, Monaco, ui-monospace, monospace;
        font-size: 15px;
        line-height: 1.35;
      }

      .screen {
        min-height: 100vh;
        border: 3px solid #000;
        background: #fff;
      }

      .menu-bar {
        height: 36px;
        display: flex;
        align-items: center;
        gap: 26px;
        padding: 0 18px;
        border-bottom: 3px solid #000;
        font-size: 20px;
        font-weight: 700;
      }

      .apple { font-size: 22px; line-height: 1; }
      .menu-spacer { flex: 1; }
      .menu-icon { border: 2px solid #000; width: 24px; height: 24px; display: inline-grid; place-items: center; font-size: 16px; }

      main {
        max-width: 1180px;
        margin: 0 auto;
        padding: 22px 28px 16px;
      }

      .hero {
        display: grid;
        grid-template-columns: 160px 1fr;
        gap: 24px;
        align-items: start;
      }

      .mascot {
        min-height: 142px;
        border: var(--line);
        border-radius: 12px;
        background:
          radial-gradient(circle at 2px 2px, #000 1px, transparent 1.5px) 0 0 / 8px 8px,
          #fff;
        display: grid;
        place-items: center;
        text-align: center;
        font-size: 58px;
        font-weight: 900;
      }

      h1 {
        margin: 0;
        font-size: clamp(48px, 8vw, 88px);
        line-height: 0.92;
        letter-spacing: 2px;
        text-transform: uppercase;
      }

      .subtitle { margin: 10px 0 12px; font-size: 18px; }

      .summary {
        border: var(--line);
        border-radius: 8px;
        padding: 9px 12px;
        display: flex;
        gap: 10px;
        align-items: center;
        background: var(--wash);
      }

      .face {
        width: 24px;
        height: 24px;
        border: 2px solid #000;
        display: inline-grid;
        place-items: center;
        flex: 0 0 auto;
      }

      .scores {
        display: grid;
        grid-template-columns: repeat(4, minmax(0, 1fr));
        gap: 14px;
        margin-top: 16px;
      }

      .score-card {
        border: var(--line);
        border-radius: 8px;
        padding: 14px 14px 12px;
        min-height: 116px;
      }

      .score-head { display: flex; gap: 12px; align-items: center; }
      .score-icon { font-size: 34px; width: 42px; text-align: center; }
      .score-title { font-size: 18px; }
      .score-value { font-size: 52px; font-weight: 900; line-height: 1; }
      .score-denom { font-size: 18px; }

      .meter {
        height: 16px;
        border: 2px solid #000;
        margin-top: 10px;
        background: #fff;
        padding: 2px;
      }

      .meter > span {
        display: block;
        height: 100%;
        background: repeating-linear-gradient(90deg, #000 0 10px, #fff 10px 12px);
      }

      .grid {
        display: grid;
        grid-template-columns: minmax(0, 1.15fr) minmax(360px, 0.85fr);
        gap: 14px;
        margin-top: 14px;
      }

      .panel {
        border: var(--line);
        border-radius: 8px;
        background: #fff;
        padding: 14px 16px;
      }

      .panel-title {
        margin: 0 0 12px;
        font-size: 24px;
        text-transform: uppercase;
        letter-spacing: 1px;
      }

      .diagnosis-body {
        display: grid;
        grid-template-columns: 230px 1fr;
        gap: 20px;
        min-height: 300px;
      }

      .goblin {
        border: 0;
        min-height: 240px;
        display: grid;
        place-items: center;
        font-size: 76px;
        text-align: center;
      }

      .diagnosis-copy {
        position: relative;
        border-left: 2px solid #000;
        padding: 8px 22px 8px 18px;
        white-space: pre-wrap;
        font-size: 18px;
        line-height: 1.55;
        min-height: 260px;
        max-height: 340px;
        overflow-y: auto;
        scrollbar-width: thin;
        scrollbar-color: #000 #fff;
      }

      /* Classic Macintosh B&W scrollbar — real, not decorative.
         The diagnosis pane actually scrolls when the copy overflows. */
      .diagnosis-copy::-webkit-scrollbar {
        width: 20px;
        border-left: 2px solid #000;
        background: #fff;
      }
      .diagnosis-copy::-webkit-scrollbar-track {
        background: #fff;
      }
      .diagnosis-copy::-webkit-scrollbar-thumb {
        background: repeating-linear-gradient(90deg, #000 0 8px, #fff 8px 10px);
        border: 2px solid #000;
      }
      .diagnosis-copy::-webkit-scrollbar-thumb:hover {
        background: #000;
      }
      .diagnosis-copy::-webkit-scrollbar-button:single-button {
        display: block;
        height: 20px;
        background: #fff;
        border-bottom: 2px solid #000;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 12px 12px;
      }
      .diagnosis-copy::-webkit-scrollbar-button:single-button:vertical:decrement {
        border-bottom: 2px solid #000;
        background-image: linear-gradient(45deg, transparent 55%, #000 55% 65%, transparent 65%),
                          linear-gradient(-45deg, transparent 55%, #000 55% 65%, transparent 65%);
      }
      .diagnosis-copy::-webkit-scrollbar-button:single-button:vertical:increment {
        border-top: 2px solid #000;
        border-bottom: 0;
        background-image: linear-gradient(135deg, transparent 55%, #000 55% 65%, transparent 65%),
                          linear-gradient(-135deg, transparent 55%, #000 55% 65%, transparent 65%);
      }

      table {
        width: 100%;
        border-collapse: collapse;
      }

      th, td {
        padding: 11px 8px;
        border-bottom: 2px solid #000;
        text-align: left;
        vertical-align: top;
      }

      th { text-transform: uppercase; font-size: 15px; }
      td:last-child, th:last-child { text-align: right; }

      .red-flags li {
        display: flex;
        gap: 10px;
        align-items: baseline;
        margin: 7px 0;
      }

      .leader {
        flex: 1;
        border-bottom: 2px dotted #000;
        transform: translateY(-3px);
      }

      .risk { text-transform: uppercase; }

      .redemption ol { margin: 0; padding-left: 30px; font-size: 17px; line-height: 1.7; }

      .footer {
        display: flex;
        align-items: center;
        gap: 14px;
        border: var(--line);
        border-radius: 8px;
        margin-top: 14px;
        padding: 10px 12px;
      }

      .footer p { margin: 0; flex: 1; }

      .button {
        border: 2px solid #000;
        border-radius: 12px;
        padding: 6px 18px;
        background: #fff;
        box-shadow: inset -2px -2px 0 #bbb;
        font-weight: 700;
      }

      @media (max-width: 900px) {
        .hero, .grid, .diagnosis-body { grid-template-columns: 1fr; }
        .scores { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .mascot { display: none; }
      }
    </style>
  </head>
  <body>
    <div class="screen">
      <nav class="menu-bar" aria-label="Classic Macintosh menu">
        <span class="apple">●</span>
        <span>File</span><span>Edit</span><span>View</span><span>Report</span><span>Tools</span><span>Help</span>
        <span class="menu-spacer"></span>
        <span class="menu-icon">?</span><span class="menu-icon">□</span>
      </nav>

      <main>
        <header class="hero">
          <div class="mascot" aria-hidden="true">☠</div>
          <div>
            <h1>Roast My Computer</h1>
            <div class="subtitle">Developer environment roast report</div>
            <div class="summary"><span class="face">☻</span><span>{{top_roast_summary}}</span></div>
          </div>
        </header>

        <section class="scores" aria-label="Roast scores">
          {{score_cards}}
        </section>

        <section class="grid">
          <article class="panel diagnosis">
            <h2 class="panel-title">Diagnosis</h2>
            <div class="diagnosis-body">
              <div class="goblin" aria-hidden="true">👺<br /><small>SHIP<br />NEVER</small></div>
              <div class="diagnosis-copy">{{diagnosis_copy}}</div>
            </div>
          </article>

          <article class="panel hotspots">
            <h2 class="panel-title">Hotspots <small>(Where the mess lives)</small></h2>
            <table>
              <thead><tr><th>Location</th><th>Items / Examples</th></tr></thead>
              <tbody>{{hotspot_rows}}</tbody>
            </table>
          </article>
        </section>

        <section class="grid">
          <article class="panel">
            <h2 class="panel-title">⚑ Red Flags <small>(Secret risk findings)</small></h2>
            <ul class="red-flags">{{red_flag_rows}}</ul>
          </article>

          <article class="panel redemption">
            <h2 class="panel-title">⚑ Redemption <small>(4 cleanup steps)</small></h2>
            <ol>{{redemption_items}}</ol>
          </article>
        </section>

        <footer class="footer">
          <span class="face">☻</span>
          <p>{{footer_line}}</p>
          <span class="button">Roast Complete</span>
        </footer>
      </main>
    </div>
  </body>
</html>
```

## Data mapping

Use these fields when present:

- `scores.dimensions.digital_landfill`
- `scores.dimensions.abandoned_projects`
- `scores.dimensions.secret_chaos`
- `scores.dimensions.git_shame`
- `scores.title`
- `scan_policy.scope`
- `scan_roots[]`
- `root_summaries[]` — per-root counts, including `installer_archive_count` for attributing installers to the root that actually holds them
- `repositories[]`
- `findings[]` — each secret finding carries a `source` (`user_config`, `editor_cache`, `test_fixture`, `public_key`, `app_bundle_public_key`) so cleanup copy can branch
- `repositories[].secret_findings[]` — repo-scoped secrets; each carries `source` and `tracked_in_git`
- `examples.*` — bounded path/marker examples: `heavy_dependency_dirs`, `installer_archives`, `large_files`, `tool_markers`, `ai_markers`
- `totals.*`

If a field is missing, render a graceful placeholder instead of inventing fake precision.

Never blanket-attribute `totals.installer_archive_count` to Downloads. Sum `root_summaries[].installer_archive_count` and name the roots that actually hold the installers (Downloads, `~/Library/Application Support`, etc.).

## Language

Match the user's actual language. This is a hard requirement, not a default-to-English fallback. A user typing in Chinese who receives an English report got a broken product.

Recommended language selection rule (same as `ROAST_WRITER_PROMPT.md`):

1. User explicitly requests a language: use that language.
2. Current conversation is mostly Chinese: use Chinese.
3. Current conversation is mostly English or mixed: use English.
4. No language signal is available: use English.

The English and Chinese examples below are templates for tone and structure, not source text to copy verbatim. Localize, never translate word-for-word. Both languages have their own native roast shapes — study them.

### English-native roast shape

Every line follows **fact first, jab second**: cite a real number, path, count, or observed pattern, then add a short sharp roast. No metaphor-first openers.

Native English patterns (adapt, don't copy):
- "X didn't give you Y, it gave you Z" — `Downloads didn't give you a download folder, it gave you a DMG collection — the gathering-dust kind.`
- "This isn't X, it's Y — the Z kind" — `This isn't a workspace, it's a side-project graveyard — the unvisited kind.`
- "X is your only deliverable" — `git init is your finish line. README is your only deliverable.`
- "worn X to a shine" / "X into a Y" — `You've worn git init into a finish line.`
- "riding their stars to gild yourself" — for piggybacking on big-name things

English internet vocabulary (use when the data supports it): spam PR, simp, fork graveyard, gig worker, KPI, drive-by, water weight, star cosplay, site-decorator energy, open-source business card, performative contribution, follower filter, presence farming, contribution bubble, code wasteland, dependency graveyard, token confetti, README missing-person case, vibe-coding spill.

Ban bland PM-speak: "somewhat lacking", "could improve", "decent", "has room to grow", "worth watching", "fairly average", "not ideal", "room for improvement", "technical debt exists". Replace every instance with a concrete, visual, data-grounded jab.

Short sentences. If one sentence can land the cut, don't stretch it to two.

### Chinese-native roast shape

Direct translations of English metaphors ("X 是 Y 的总和", "X 是 Y 的博物馆", "你拥有 Z 的能量") smell like machine output and are banned.

Native Chinese patterns (adapt, don't copy):
- 先落数据，再补一刀 — every line drops a real number/path/count first, then twists the knife. Never write a punchline without a receipt.
- "X 给你的不是 Y，是 Z" — `Downloads 给你的不是下载目录，是 DMG 收藏夹，吃灰那种。`
- "你这哪是 X，是 Y" — `你这哪是工作区，是开工即死的副业坟场。`
- "X 都被你按出包浆了" / "X 被你用成 Y" — `git init 被你用成了终点线。`
- "X 是你唯一的产出" — `README 是你真正的 deliverable，app 是传闻。`

中文网络梗词库（按场景选用，不要堆砌）：吃灰、包浆、贴金、刷存在感、贡献泡沫、含金量、电子榨菜、KPI 标兵、临时工、灾后现场、滤镜、人设包装、灌水、开工即死、半途而废之王、赛博垃圾场、token 彩纸、vibe coding 灾后现场、README 失踪案、DMG 收藏夹、node_modules 殖民地、终点线。

短句。一句话能戳穿的不要拉成两句。能不绕弯就不绕弯。

避免温吞词：「不错 / 还行 / 一般 / 有待提升 / 建议加强 / 值得改进」一律换成数据扎心的短句。

### Both languages

- Attack the behavior and the machine state, not the person. Never touch gender, race, looks, origin, family, health, finances, or identity.
- Scale venom to score band: 0-34 gets a backhanded compliment or suspicious-cleanliness joke; 35-59 gets teasing contempt; 60-79 gets clear shame with a practical sting; 80-100 gets brutal screenshot-worthy labels. No evidence, no roast; evidence present, no mercy.
- Don't automatically soften for low scores. You may acknowledge the one bright spot, but still jab the most obvious weakness.
- Choose exactly one output language for all prose. Mixed-language output is allowed only when the user explicitly asks for bilingual copy or a short borrowed phrase is part of the joke ("vibe coding", "token", "README", "node_modules", "Phase 1", "deliverable" are fine to keep as loanwords in Chinese copy).
- Numeric facts, paths, score values, detector names, and severity labels stay in their source form regardless of output language — only the prose around them localizes.

## Header

The header has two jobs:

1. Make the artifact instantly recognizable.
2. Deliver one screenshot-worthy roast line.

Locality and scope were already confirmed in the workflow's scope-selection step — do not re-state "local-only", "nothing uploaded", or re-litigate scope in the report copy.

Use one line only for the summary strip. Attribute installer counts to the roots that actually hold them (`root_summaries[].installer_archive_count`), never blanket-attribute the global `totals.installer_archive_count` to Downloads. Good English examples:

- `50 repos on disk, 6 never made it past git init — README is your only deliverable.`
- `119 installers gathering dust — only 8 in Downloads, the rest buried in ~/Library/Application Support. A markdown file hands out AWS keys like party flyers.`
- `739 AI-slop markers. git init is your finish line; shipping is a rumor.`

Good Chinese examples:

- `50 个 repo 躺在磁盘上，6 个 git init 完就再没动过。`
- `119 个安装包吃灰——Downloads 里只有 8 个，其余埋在 ~/Library/Application Support。还有个 md 把 AWS key 当传单撒。`
- `739 个 AI slop 标记。git init 是你的终点线，shipping 是传闻。`

## Score cards

Render exactly four score cards in the simplified Macintosh layout:

1. `Digital Landfill`
2. `Abandoned Projects`
3. `Secret Chaos`
4. `Git Shame`

Do not add the `AI Slop` and `Tool Hoarder` cards to the top row. If those scores exist, fold them into `Diagnosis`, `Red Flags`, or `Redemption` copy. Four cards keep the report reproducible and visually close to the mock.

Each score card includes:

- small icon or text glyph
- label
- large score number
- `/100`
- block meter

Use the score values from JSON. Clamp to `0..100`. The meter width equals the score.

## Diagnosis

`DIAGNOSIS` is the flexible narrative section. It may be short, long, English, Chinese, or bilingual if the user asks. This section carries the roast personality.

Layout rules:

- left side: fixed mascot area
- right side: large text pane that actually scrolls when the copy overflows the `max-height` — the B&W Macintosh scrollbar is a real styled native scrollbar, not a decorative overlay
- do not force the copy into fixed cards
- do not require exact line counts
- preserve line breaks for rhythm

The copy should be evidence-backed but looser than the tables. It can combine several signals:

- abandoned repos
- stale branches
- risky config files
- plan-era docs
- dependency graveyards
- chaotic Downloads/Desktop
- AI slop markers
- toolchain hoarding

Sourcing rules for the prose:

- Concrete AI-slop phrases ("Phase 1", "future work", "production-ready") must come from `examples.ai_markers` (each entry has `detector`, `sample`, `path`, `count`). Do not invent phrases the scanner did not surface. If `examples.ai_markers` is empty, report only the aggregate `totals.ai_marker_count` and the detector breakdown in `ai_marker_counts`.
- When citing secret counts, branch on `findings[].source`: `editor_cache` and `app_bundle_public_key` and `test_fixture` are real-but-different-cleanup findings, not the same risk as `user_config`. Say "X critical, but Y of those are editor history / public keys / test fixtures — the real action is Z" rather than treating all criticals equally.
- Attribute installer counts per root (`root_summaries[].installer_archive_count`), not to Downloads by default.

Good structure:

```txt
{{title or persona}}.

{{2-4 punchy roast paragraphs backed by observed signals}}.
```

Good English diagnosis copy:

```txt
50 repos, 6 never made it past git init. fatal-drive has no README and no future; bypass-paywalls-chrome-clean has been sitting at 584 days stale, gathering patina.

119 installers gathering dust — only 8 in Downloads, the rest buried in ~/Library/Application Support (zoom update bundles, mostly). A markdown file called kk-brain-keys.md hands out AWS and OpenAI keys like party flyers. 491 secret-like patterns surfaced; 42 are critical — but 36 of those are editor undo-history (`source: editor_cache`) and app-bundle public keys (`source: app_bundle_public_key`), so the real cleanup is "clear Antigravity's User/History and rotate the 4 keys you actually pasted," not "torch 42 files."

739 AI-slop markers across the tree. Pull concrete phrases from `examples.ai_markers` — "Phase 1", "future work", "production-ready" — the vocabulary of a thousand Codex sessions that shipped a README and a dream. Skills repo alone: 19 future-work markers, 16 phase plans, 13 ai-generated tags. Glass houses.

74 heavy dependency directories. node_modules isn't installing packages, it's colonizing the disk.
```

Good Chinese diagnosis copy:

```txt
50 个 repo，6 个 git init 完就再没动过。fatal-drive 连 README 都没有，fork/bypass-paywalls-chrome-clean 躺了 584 天，包浆了。git init 是你的终点线。

119 个安装包吃灰——Downloads 里只有 8 个，其余埋在 ~/Library/Application Support（大多是 zoom 的更新包）。还翻出一个 kk-brain-keys.md，AWS 和 OpenAI 的 key 当传单撒。一共扫出 491 个类 secret 模式，42 个是 critical——但其中 36 个是编辑器历史（`source: editor_cache`）和 app-bundle 公开 key（`source: app_bundle_public_key`），真要动手是"清 Antigravity 的 User/History 再轮换你真粘过的那 4 个 key"，不是"删 42 个文件"。

739 个 AI slop 标记。具体词从 `examples.ai_markers` 里捞——"Phase 1"、"future work"、"production-ready"——一千个 Codex 会话的词汇表，每个都 ship 了一个 README 和一个梦。光 skills 仓库自己就 19 个 future-work、16 个 phase plan、13 个 ai-generated 标签。玻璃房子。

74 个重型依赖目录。node_modules 不是装包，是殖民你的磁盘。
```

Avoid:

- exact secret values
- source snippets
- personal-document contents
- protected-trait insults
- generic productivity advice

## Hotspots

`HOTSPOTS` should be lightweight. Do not require directory size calculations. Detailed size crawling is out of scope and may be slow or permission-heavy.

Columns:

- `Location`
- `Items / Examples`

Allowed item/example values:

- observed count when already available: `327 repos`, `1,142 files`, `16 findings`
- low-precision note: `Lots of files`, `Hundreds of repos`, `Too many tweaks`, `Rarely used apps`
- category note: `Installers`, `Project roots`, `Dotfiles`, `Screenshots`, `Config sprawl`

Never fabricate byte sizes. If the scanner did not compute size cheaply, omit size.

Prefer 4-5 rows:

```html
<tr><td>▣ ~/Downloads</td><td>Lots of files</td></tr>
<tr><td>▣ ~/dev</td><td>Hundreds of repos</td></tr>
<tr><td>▣ ~/.config</td><td>Too many tweaks</td></tr>
<tr><td>▣ ~/Desktop</td><td>Old stuff</td></tr>
<tr><td>▣ ~/Library/Application Support</td><td>Installer graveyard</td></tr>
```

## Red Flags

Use a compact list with dotted leaders and right-aligned severity labels.

Rules:

- show path or filename
- show detector summary
- show severity
- never show raw secret values
- keep the list to 5 items

### Aggregation rule (deterministic Red Flags)

`findings` plus every `repositories[].secret_findings` can contain hundreds of entries, with the same path hit by multiple detectors (e.g. `id_rsa` yields both `private_key_file` and `private_key_marker`), and with mixed `source` tags (`user_config`, `editor_cache`, `test_fixture`, `public_key`, `app_bundle_public_key`). Red Flags shows 5, so the selection must be deterministic or every agent renders a different list. Apply this aggregation before rendering — it is also the reference transform for any temporary renderer, so agents stop reinventing severity ordering and hitting KeyError-class bugs.

```python
SEVERITY_RANK = {"low": 1, "medium": 2, "high": 3, "critical": 4}
# Lower number = higher priority. user_config wins ties so real leaked keys
# outrank editor history / public keys / test fixtures in the top 5.
SOURCE_PRIORITY = {"user_config": 0, "editor_cache": 1, "test_fixture": 2,
                   "public_key": 3, "app_bundle_public_key": 3}

def aggregate_for_red_flags(scan) -> list[dict]:
    # 1. Collect every secret_chaos finding from both sources.
    rows = []
    for f in scan.get("findings", []):
        if f.get("category") == "secret_chaos":
            # Defensive: paths may be empty if a future detector emits a pathless finding.
            rows.append({"path": f["paths"][0] if f.get("paths") else "",
                         "severity": f["severity"],
                         "detector": f.get("detector"), "source": f.get("source", "user_config")})
    for repo in scan.get("repositories", []):
        for sf in repo.get("secret_findings", []):
            rows.append({"path": sf.get("path", ""), "severity": sf["severity"],
                         "detector": sf.get("detector"), "source": sf.get("source", "user_config")})
    # 2. Merge by path: highest severity wins; keep all detector names; keep the
    #    highest-priority source so user_config surfaces over editor_cache etc.
    by_path: dict[str, dict] = {}
    for r in rows:
        cur = by_path.get(r["path"])
        if cur is None:
            by_path[r["path"]] = {"path": r["path"], "severity": r["severity"],
                                  "detectors": {r["detector"]} - {None}, "source": r["source"]}
        else:
            if SEVERITY_RANK[r["severity"]] > SEVERITY_RANK[cur["severity"]]:
                cur["severity"] = r["severity"]
            if r["detector"]:
                cur["detectors"].add(r["detector"])
            if SOURCE_PRIORITY.get(r["source"], 0) < SOURCE_PRIORITY.get(cur["source"], 0):
                cur["source"] = r["source"]
    # 3. Drop low-severity noise (downgraded public keys / app bundles) unless
    #    it is all we have — avoids an empty panel while still hiding the noise.
    kept = [v for v in by_path.values() if v["severity"] != "low"]
    if not kept:
        kept = list(by_path.values())
    # 4. Sort: severity desc, then source priority (user_config first), then path.
    kept.sort(key=lambda v: (-SEVERITY_RANK[v["severity"]], SOURCE_PRIORITY.get(v["source"], 0), v["path"]))
    return kept[:5]
```

Render each aggregated row as: path or filename · detector summary (join `detectors` with `/`) · severity label. Tag `editor_cache` / `test_fixture` / `public_key` rows in the copy so the reader knows they are not all "you committed a key" findings.

Example:

```html
<li><span>.env file found</span><span class="leader"></span><strong class="risk">High</strong></li>
<li><span>private_key.pem sitting unencrypted</span><span class="leader"></span><strong class="risk">Critical</strong></li>
```

If no red flags exist, still keep the panel:

```txt
No obvious secret-risk findings. This is suspiciously competent behavior.
```

## Redemption

Use exactly four cleanup steps. Keep them human-readable. Do not put destructive commands directly in the HTML unless the user explicitly asked for cleanup commands.

Default steps:

1. Remove stale archives and junk.
2. Find and secure secrets.
3. Tame abandoned repos.
4. Clean and organize ruthlessly.

If the scan is project-only, tune the copy to the repo/project:

1. Review ignored build outputs.
2. Fix tracked secrets and env files.
3. Delete plan-era docs.
4. Commit, archive, or remove stale branches.

## Footer

One short status-bar line. Funny, no reassurance, no preaching, no "ship something" / "close seven tabs" / "shame converted into tasks" closure — the user already knows what to do.

Good English examples:

- `84/100. The receipt is above.`
- `Scan: global · 50 repos · 125k entries · 52s.`
- `Roast complete. The evidence is the insult.`

Good Chinese examples:

- `84/100。证据在上面，不服自己翻。`
- `扫描：global · 50 个 repo · 12.5 万 entries · 52s。`
- `Roast 完成。再不动手就别怪数据嘴臭。`

## Tone

The visual tone is classic Macintosh. The writing tone is public roast card.

Use:

- evidence-backed shame
- playful developer-native insults
- short punchlines
- concrete filesystem behavior
- redacted security jokes

Avoid:

- generic audit language
- long explanations
- precise claims unsupported by JSON
- pure abuse without a receipt
- anything about protected attributes, health, family, finances, or identity

## Implementation notes for agents

Generate the HTML directly from scan JSON and this markdown reference. Do not keep a persistent `generate_report.py` in the skill. The executing agent may write a temporary one-off renderer in the OS temp directory if its runtime requires code to transform JSON into HTML, but the skill package's report design source of truth is this file.

Escape all user-controlled strings. Render path examples as text, not links. Do not include raw file contents. Do not include raw secrets.
