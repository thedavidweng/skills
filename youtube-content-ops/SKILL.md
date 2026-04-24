---
name: youtube-content-ops
description: |
  YouTube Content Operations — generate titles, descriptions, and tags for already-uploaded videos.
  TRIGGER when user wants to: generate video description, optimize title, write YouTube description,
  batch-process video metadata, unify channel style, or automate YouTube content ops.
  Also triggers on: "this video intro", "video description", "title for this video",
  "channel style guide", "update my video", "YouTube content workflow".
---

# YouTube Content Operations

Generate channel-consistent titles, descriptions, and tags for videos already uploaded to YouTube.
**All publish decisions require mandatory user review.**

## Operation Modes

| Mode | Requirements | Capabilities |
|------|--------------|--------------|
| **Full Access** | yutu CLI + OAuth | Fetch captions, generate content, apply changes via YouTube API |
| **Read-Only** | youtube-transcript-api | Fetch transcripts, generate content for user to copy-paste manually |

Auto-detect available mode at session start.
See `references/prerequisites.md` for setup.

---

## Workflow

### Step 0 — Brand Guide Setup

1. Check for existing brand guide file
2. If none: auto-generate from recent channel videos
3. Save to `./[channel-name]-brand-guide.md`, present for confirmation

See `references/brand-guide-generation.md` for auto-generation process.
Template format: `references/brand-guide-template.md`.

### Step 1 — Identify the Video

Extract `videoId` from user input (URL or direct mention).
Use `scripts/fetch_transcript.py` for robust URL parsing (supports youtube.com, youtu.be, shorts, embed, live, raw ID).

### Step 2 — Fetch Video Captions

**Full Access Mode:**
```bash
# List captions (prefer standard over asr)
yutu caption list --videoId VIDEO_ID --output json

# Download primary caption
yutu caption download --id CAPTION_ID --file /tmp/caption.txt --tfmt srt
```

**Read-Only Mode:**
```bash
python3 scripts/fetch_transcript.py "URL_OR_ID" [--language en,zh]
```

The script handles URL parsing, language fallback, and categorized errors.
See `references/yutu-commands.md` for full yutu command reference.

**Fallback chain:** yutu caption → youtube-transcript-api → ask user for transcript.

### Step 3 — Analyze Video Content

Read caption and extract:
```
Topic: [one-sentence summary]
Key Topics: [topic 1], [topic 2], [topic 3]
Highlights:
  - [highlight 1]
  - [highlight 2]
Target Audience: [description]
Keywords: [keyword 1], [keyword 2], [keyword 3]
```

### Step 4 — Apply Brand Guide

Load brand guide (`./[channel]-brand-guide.md`), parse YAML front matter tokens:

| Token | How to Use |
|-------|------------|
| `title_format` | Match title structure to this template |
| `title_separator` | Use correct separator character |
| `title_patterns` | Select pattern based on content type |
| `footer_full` / `footer_compact` | Use for description footer |
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

Style consistency check:
- [ ] Title length ≤ `title_max_length`
- [ ] No banned phrases in description
- [ ] Footer matches template
- [ ] Primary tags included
- [ ] Tone matches brand characteristics

### Step 5 — Generate Content

**Title suggestions (3 options):**
```
Option 1: [Title] — [reason]
Option 2: [Title] — [reason]
Option 3: [Title] — [reason]
```

**Description:**
- Opening hook that captures attention
- Key information and highlights
- Channel-consistent tone and vocabulary
- Required CTA
- Natural keyword integration for SEO

**Tags (5–10):**
```
[tag1], [tag2], [tag3], ...
```

### Step 6 — User Review (MANDATORY)

Present full generated content using the review template.
See `references/pre-publish-checklist.md`.

**All publish decisions must be reviewed by the user before execution.**

### Step 7 — Apply Changes

**Full Access Mode** (after user confirmation):
```bash
yutu video update \
  --id VIDEO_ID \
  --title "User-confirmed title" \
  --description "User-confirmed description" \
  --tags "tag1,tag2,tag3"
```

**Read-Only Mode:**
User manually copies content to YouTube Studio.

See `references/yutu-commands.md` for all yutu commands.

---

## Pitfalls

| Issue | Fix |
|-------|-----|
| No captions available | Ask user for transcript or notes |
| Poor caption quality | Use judgment when interpreting auto-generated captions |
| Language mismatch | Retry with `--language` flag |
| OAuth token expiry | Re-run `yutu auth` |
| Editor role insufficient | Fall back to read-only mode |
| API quota exceeded | Reduce request frequency |
| New channel, no history | Ask user for brand guidelines |

---

## Example

**User:** "Write a description for this video: https://www.youtube.com/watch?v=dQw4w9WgXcQ"

**Agent:**
1. Extract videoId via `scripts/fetch_transcript.py`
2. Fetch captions (yutu or transcript API)
3. Analyze caption content
4. Check for brand guide → none provided
5. Fetch recent channel videos and learn style
6. Generate title options, description, and tags
7. Present to user for review
8. Apply changes after user confirmation

---

## References

- `references/prerequisites.md` — Setup instructions for yutu and youtube-transcript-api
- `references/yutu-commands.md` — Complete yutu CLI command reference
- `references/brand-guide-template.md` — Brand guide format specification
- `references/brand-guide-generation.md` — Auto-generation process from channel history
- `references/pre-publish-checklist.md` — User review checklist and template
- `scripts/fetch_transcript.py` — Transcript fetching with URL parsing and error handling
