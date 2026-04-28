---
name: youtube-content-ops
description: |
  Generate channel-consistent titles, descriptions, and tags for YouTube videos.
  Triggers on: "video description", "YouTube title", "content ops", "channel style".
---

# YouTube Content Operations

Generate titles, descriptions, and tags matching channel brand style.
**All publish actions require user confirmation.**

## Prerequisites

- **Full Access:** `yutu` CLI ([eat-pray-ai/yutu](https://github.com/eat-pray-ai/yutu)) — read + write via YouTube API
- **Read-Only:** `youtube_transcript_api` CLI (`pip install youtube-transcript-api`) — transcript fetch only

At session start, detect mode:
```bash
yutu channel list --output json 2>/dev/null && echo "FULL" || \
  (youtube_transcript_api --help >/dev/null 2>&1 && echo "READ_ONLY" || echo "NONE")
```

## Workflow

### 1. Brand Guide

Check for `./[channel-name]-brand-guide.md`. If missing, generate from recent videos and confirm with user. Template: `references/brand-guide-template.md`.

### 2. Fetch Transcript

**Full Access:**
```bash
yutu caption list --videoId VIDEO_ID --output json
yutu caption download --id CAPTION_ID --file /tmp/caption.txt --tfmt srt
```

**Read-Only** (extract video ID from URL yourself — supports youtube.com/watch?v=, youtu.be/, shorts/, embed/):
```bash
youtube_transcript_api VIDEO_ID --languages en zh --format text
```

Fallback: ask user for transcript.

### 3. Analyze & Generate

From transcript, extract topic, key highlights, target audience, keywords.

Apply brand guide tokens: `title_format`, `title_separator`, `tone`, `banned_phrases`, `primary_tags`, `footer_full`.

Generate:
- 3 title options with rationale
- Description (hook + highlights + CTA + footer)
- 5–10 tags

### 4. User Review (MANDATORY)

Present content. **Never publish without explicit user confirmation.**

### 5. Apply

**Full Access** (after confirmation):
```bash
yutu video update --id VIDEO_ID --title "Title" --description "Description" --tags "t1,t2,t3"
```

**Read-Only:** User copies to YouTube Studio manually.

## References

- `references/brand-guide-template.md` — Brand guide format
- `references/brand-guide-generation.md` — Auto-generation from channel history
- `references/yutu-commands.md` — Full yutu CLI reference
- `references/pre-publish-checklist.md` — Review checklist
