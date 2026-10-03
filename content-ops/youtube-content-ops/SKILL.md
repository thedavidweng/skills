---
name: youtube-content-ops
description: 'Drafts on-brand YouTube titles, descriptions, and tags from a channel brand guide. Use when the user wants metadata for a YouTube video.'
---

Detect mode: `yutu channel list --for mine --output json` works → FULL, else `youtube_transcript_api` imports → READ_ONLY, else point the user to `references/prerequisites.md`. Auth error from yutu → stop and tell the user to re-auth; never work around with scrapers.

Brand guide (`./[channel]-brand-guide.md`; if missing, generate from recent videos per `references/brand-guide-generation.md` into the shape of `references/brand-guide-template.md`) → transcript (`yutu caption download` / `youtube_transcript_api ID --languages en zh --format text`) → a few titles + description (hook/highlights/CTA/footer) + a handful of tags → check against `references/pre-publish-checklist.md` → **user reviews (never publish unconfirmed)** → `yutu video update` (or manual Studio paste in READ_ONLY).

Brand-guide fields that drive output: `title_format`, `title_separator`, `tone`, `banned_phrases`, `primary_tags`, `footer_full`. Exact yutu commands: `references/yutu-commands.md`.
