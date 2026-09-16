---
name: youtube-content-ops
description: 'Generate channel-consistent YouTube titles, descriptions, tags. Triggers on ''video description'', ''YouTube title'', or ''channel style''.'
---

Detect mode: `yutu channel list` works → FULL, else `youtube_transcript_api` → READ_ONLY. Auth error from yutu → abort and tell the user to re-auth; never work around with scrapers.

Brand guide (`./[channel]-brand-guide.md`, generate from recent videos if missing) → transcript (`yutu caption download` / `youtube_transcript_api ID --languages en zh --format text`) → a few titles + description (hook/highlights/CTA/footer) + a handful of tags → **user reviews (never publish unconfirmed)** → `yutu video update` (or manual Studio paste in READ_ONLY).

Tokens: `title_format`, `separator`, `tone`, `banned_phrases`, `primary_tags`, `footer_full`. References: brand template, generation, yutu commands, pre-publish checklist.
