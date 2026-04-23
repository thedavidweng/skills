---
name: youtube-content-ops
description: |
  YouTube Content Operations — generate titles, descriptions, and tags for already-uploaded videos.
  TRIGGER when user wants to: generate video description, optimize title, write YouTube description,
  batch-process video metadata, unify channel style, or automate YouTube content ops.
  Also triggers on: "this video intro", "video description", "title for this video",
  "channel style guide", "update my video", "YouTube content workflow".
  Works with yutu CLI (full access) or youtube-transcript-api (read-only fallback).
---

# YouTube Content Operations

Generate channel-consistent titles, descriptions, and tags for videos already uploaded to YouTube — with mandatory user review before any changes are applied.

## Operation Modes

| Mode | Requirements | Capabilities |
|------|--------------|--------------|
| **Full Access** | yutu CLI + OAuth | Fetch captions, generate content, apply changes via YouTube API |
| **Read-Only** | youtube-transcript-api | Fetch transcripts, generate content for user to copy-paste manually |

The skill automatically detects which mode is available and adjusts accordingly.

---

## Prerequisites

### Option A: Full Access Mode (yutu CLI)

For users with channel ownership or manager permissions.

**Official Repository:** https://github.com/eat-pray-ai/yutu

**Install yutu:**
```bash
# macOS
brew install yutu

# Linux
curl -sSfL https://raw.githubusercontent.com/eat-pray-ai/yutu/main/scripts/install.sh | bash

# Windows
winget install yutu
```

**Configure OAuth credentials:**

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **YouTube Data API v3**
3. Create an **OAuth Client ID** (Web Application); set redirect URI to `http://localhost:8080`
4. Download the credentials file as `client_secret.json`
5. Authorize:
   ```bash
   yutu auth --credential client_secret.json
   ```
6. A `token.json` will be generated upon success.

### Option B: Read-Only Mode (youtube-transcript-api)

For users who only have editor permissions or don't want to set up OAuth.

**Official Repository:** https://github.com/jdepoix/youtube-transcript-api

**Install:**
```bash
pip install youtube-transcript-api
```

**Usage:**
```python
from youtube_transcript_api import YouTubeTranscriptApi

# Get transcript for a video
api = YouTubeTranscriptApi()
transcript = api.fetch("VIDEO_ID")
text = " ".join([seg.text for seg in transcript])
```

This mode can only **read** transcripts — all generated content must be manually copied by the user.

---

## Mode Detection

At the start of each session, check which tools are available:

```bash
# Check yutu
yutu channel list --output json 2>/dev/null

# Check youtube-transcript-api
python3 -c "from youtube_transcript_api import YouTubeTranscriptApi; print('available')" 2>/dev/null
```

**Decision logic:**
1. yutu works → **Full Access Mode**
2. yutu fails, youtube-transcript-api works → **Read-Only Mode**
3. Both fail → Prompt user to install one of them

---

## Workflow

### Step 0 — Brand Guide Setup

**Check for existing brand guide:**

1. User provides a brand guide file path → Use it directly
2. No brand guide provided → **Auto-generate from channel**

**Auto-Generation Process:**

```bash
# Step 0.1: Get channel ID
yutu channel list --output json

# Step 0.2: Fetch recent 10-15 videos
yutu search --channelId CHANNEL_ID --type video --maxResults 15 --output json

# Step 0.3: Get video metadata (titles + descriptions)
yutu video list --ids VIDEO_ID1,VIDEO_ID2,... --output json
```

**Pattern Analysis:**

| Element | What to Extract |
|---------|-----------------|
| Title separator | `|`, `｜`, `-`, `:` |
| Title suffix | Series name, Month Year pattern |
| Title patterns | Announcement, Speaker, Theme, Provocative |
| Hook styles | Question, Statement, Context |
| Footer template | Full vs compact, organization name, URLs |
| Tone markers | First-person, contractions, specific vocabulary |
| Banned phrases | Generic intros ("In this video", etc.) |
| Hashtags | Primary tags, topic tags |

**Generate Brand Guide:**

Use `references/brand-guide-template.md` as the format reference. Fill with extracted patterns:

*(See `references/brand-guide-template.md` for full template)*

Save to `./[channel-name]-brand-guide.md` and present to user for confirmation.

> **Note**: Brand guide generation only happens once per channel. Subsequent runs reuse the saved guide.

---

### Step 1 — Identify the Video

Extract from the user's input:
- **videoId**: from URL or direct mention
  - `https://www.youtube.com/watch?v=VIDEO_ID`
  - `https://youtu.be/VIDEO_ID`
- **Channel ID**: via `yutu channel list`

If only a URL is given, extract the videoId immediately.

---

### Step 2 — Fetch Video Captions

**Method A: yutu (Full Access Mode)**

```bash
# List all available captions for the video
yutu caption list --videoId VIDEO_ID --output json

# Download the primary caption file (prefer "standard" over "asr")
yutu caption download --id CAPTION_ID --file /tmp/caption.srt --tfmt srt
```

| trackKind | Meaning |
|-----------|---------|
| `standard` | Manually uploaded caption (preferred) |
| `asr` | Auto-generated caption |
| `ASR` | Auto-translated caption |

Use manual captions when available; fall back to auto-generated if not.

**Method B: youtube-transcript-api (Read-Only Mode)**

```python
from youtube_transcript_api import YouTubeTranscriptApi

# Get transcript for a video
api = YouTubeTranscriptApi()
transcript = api.fetch("VIDEO_ID")

# Convert to plain text
text = " ".join([seg.text for seg in transcript])

# Optionally specify language
transcript = api.fetch("VIDEO_ID", languages=["en", "en-US"])
```

**Language preference:**
- Default: auto-detect
- If multiple languages available, prefer: `["en", "en-US", "en-GB"]`
- User can specify language via `languages=["zh-Hans", "zh-CN"]` etc.

**Fallback chain:**

1. **yutu caption list** → If works, use yutu
2. **youtube-transcript-api** → If yutu fails, use this
3. **No captions available** → Ask user for transcript or notes

---

### Step 3 — Analyze Video Content

Read the caption file and extract:

```
Topic: [one-sentence summary]
Key Topics: [topic 1], [topic 2], [topic 3]
Highlights:
  - [highlight 1]
  - [highlight 2]
Target Audience: [description]
Keywords: [keyword 1], [keyword 2], [keyword 3]
```

---

### Step 4 — Apply Brand Guide

**Load the brand guide:**

Read the brand guide file (either user-provided or auto-generated in Step 0).

**Parse the YAML front matter:**

```yaml
# Key tokens to use:
name: [Channel Name]
title_format: "[Template]"
title_separator: "|" or "｜"
title_patterns: { announcement, speaker, theme, provocative }
footer_full: |
  [Footer template]
footer_compact: |
  [Compact footer]
tone: [list of characteristics]
banned_phrases: [list to avoid]
primary_tags: [always include]
title_max_length: 60
```

**Apply to content generation:**

| Token | How to Use |
|-------|------------|
| `title_format` | Match title structure to this template |
| `title_separator` | Use correct separator character |
| `title_patterns` | Select pattern based on content type |
| `footer_full` | Use for main videos; replace placeholders |
| `footer_compact` | Use for shorter content |
| `tone` | Ensure voice matches these characteristics |
| `banned_phrases` | Scan and remove any banned phrases |
| `primary_tags` | Always include these hashtags |

**Content Type Detection:**

| Type | Indicators | Pattern Key |
|------|------------|-------------|
| Announcement | "community", "updates", "news" | `announcement` |
| Speaker | Single presenter name prominent | `speaker` |
| Theme | Multiple topics/segments | `theme` |
| Provocative | Strong hook, controversial take | `provocative` |

**Style Consistency Check:**

Before generating, verify:
- [ ] Title length ≤ `title_max_length` (portion before separator)
- [ ] No banned phrases in description
- [ ] Footer matches template (full or compact)
- [ ] Primary tags included
- [ ] Tone matches brand characteristics

---

### Step 5 — Generate Content

Produce:

**Title suggestions (3 options):**
```
Option 1: [Title] — [reason]
Option 2: [Title] — [reason]
Option 3: [Title] — [reason]
```

**Description:**
Write the description following the learned paragraph structure:
- Opening hook that captures attention
- Key information and highlights
- Channel-consistent tone and vocabulary
- Required CTA
- Natural keyword integration for SEO

**Tags (5–10):**
```
[tag1], [tag2], [tag3], ...
```

---

### Step 6 — User Review ⚠️ MANDATORY

**All publish decisions must be reviewed by the user before execution.**

Display the full generated content:

```
📋 VIDEO CONTENT SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

*(See `references/pre-publish-checklist.md` for full review template)*
### Step 7 — Apply Changes

**Full Access Mode:**

After user confirmation, apply changes via yutu:

```bash
# Update title, description, and tags
yutu video update \
  --id VIDEO_ID \
  --title "User-confirmed title" \
  --description "User-confirmed description" \
  --tags "tag1,tag2,tag3"

# Set thumbnail (optional)
yutu thumbnail set --videoId VIDEO_ID --file /path/to/thumbnail.jpg

# Add to playlist (optional)
yutu playlistItem insert --playlistId PLAYLIST_ID --videoId VIDEO_ID
```

**Read-Only Mode:**

No API actions. User manually copies content to YouTube Studio.

Confirm the user has successfully applied the changes:
> "I've generated your content above. Head to YouTube Studio → Videos → [Your Video] → Details to paste it in. Let me know if you need any adjustments!"

---

## Quick Command Reference

### yutu (Full Access Mode)

| Action | Command |
|--------|---------|
| List captions | `yutu caption list --videoId ID --output json` |
| Download caption | `yutu caption download --id ID --file out.srt` |
| Get video info | `yutu video list --ids ID --output json` |
| Update video | `yutu video update --id ID --title "..." --description "..."` |
| List channel videos | `yutu playlistItem list --playlistId ID --output json` |
| Add to playlist | `yutu playlistItem insert --playlistId PID --videoId VID` |

Full reference: `references/yutu-commands.md`

### youtube-transcript-api (Read-Only Mode)

| Action | Code |
|--------|------|
| Get transcript | `api.fetch("VIDEO_ID")` |
| Get with language | `api.fetch("VIDEO_ID", languages=["en"])` |
| List available transcripts | `api.list("VIDEO_ID")` |
| Get as plain text | `" ".join([seg.text for seg in transcript])` |

GitHub: https://github.com/jdepoix/youtube-transcript-api

---

## Pitfalls

**Caption/Transcript Issues:**
- **No captions available**: Some videos have no captions. Ask the user to provide a transcript or notes instead.
- **Poor caption quality**: Auto-generated captions may contain errors. Use judgment when interpreting.
- **Language mismatch**: youtube-transcript-api may return wrong language. Specify `languages=["en"]` if needed.
- **Multiple caption tracks**: Prefer manual (`standard`) over auto-generated (`asr`) when using yutu.

**API/Permission Issues:**
- **OAuth token expiry**: yutu tokens expire; re-run `yutu auth` when needed.
- **Insufficient permissions**: Editor role cannot use yutu API. Fall back to read-only mode.
- **Private/unlisted videos**: Metadata may be inaccessible via public APIs.
- **API quota limits**: YouTube Data API has daily quotas; batch operations may hit limits.

**Brand Guide Issues:**
- **New channel with no history**: If there are no prior videos to learn from, ask the user for brand guidelines or style preferences.
- **Inconsistent channel style**: If videos have wildly different styles, note this and ask user for guidance.

**Mode-Specific Issues:**
- **Read-only mode limitations**: Cannot apply changes automatically. Always provide copy-ready content.
- **Full access mode requires setup**: Guide user through OAuth flow if they want automation.

---

## Pre-Publish Checklist

- [ ] Title matches channel style (length, format, wording)
- [ ] Description paragraph structure matches other channel videos
- [ ] Required CTA is included (subscribe, links, etc.)
- [ ] Keywords integrated naturally — no keyword stuffing
- [ ] No spelling or grammar errors
- [ ] **User has reviewed and confirmed all changes**

---

## Example

**User:** "Write a description for this video: https://www.youtube.com/watch?v=dQw4w9WgXcQ"

**Agent:**
1. Extract videoId: `dQw4w9WgXcQ`
2. List and download captions
3. Analyze caption content
4. Check for brand guidelines → none provided
5. Fetch recent channel videos and learn style
6. Generate title options, description, and tags
7. Present to user for review
8. Apply changes after user confirmation

---

## References

- `references/yutu-commands.md` — Complete yutu CLI command reference
- `references/brand-guide-template.md` — Brand guide format specification and auto-generation template
- `references/bcai-brand-guide.md` — BCAI channel brand guide (example for BC+AI channel)

**External Resources:**
- [youtube-transcript-api](https://github.com/jdepoix/youtube-transcript-api) — Python library for fetching YouTube transcripts (no auth required)
- [yutu CLI](https://github.com/eat-pray-ai/yutu/) — YouTube Data API CLI tool (requires OAuth)
