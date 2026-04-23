# Brand Guide Auto-Generation

When no brand guide is provided, the skill auto-generates one from recent videos.


## Auto-Generation Process

When no brand guide is provided, the skill will:

### Step 1: Fetch Recent Videos

```bash
# Get last 10-15 video titles and descriptions
# Get last 10-15 video titles and descriptions
yutu search --channelId CHANNEL_ID --type video --maxResults 15 --output json
```

### Step 2: Analyze Patterns

**Title Analysis:**
- Detect separator character (`|`, `｜`, `-`, `:`)
- Identify suffix patterns (series name, month/year)
- Categorize title types (announcement, speaker, theme, provocative)
- Extract title length statistics

**Description Analysis:**
- Identify opening hook style (question, statement, context)
- Count paragraph/bullet structure
- Extract footer template
- Identify organization name and URLs

**Voice Analysis:**
- Detect common phrases and patterns
- Identify banned phrases (generic intros)
- Extract tone characteristics

### Step 3: Generate Brand Guide

Fill the template with extracted patterns:

```yaml
---
name: [Extracted channel name]
channel_id: [Provided or extracted]

title_format: "[Detected format]"
title_separator: "[Detected separator]"
title_suffixes:
  - "[Detected suffix 1]"
  - "[Detected suffix 2]"

title_patterns:
  announcement: "[Derived pattern]"
  speaker: "[Derived pattern]"
  # ... based on detected types

description_sections:
  - hook
  - context
  - content
  - footer

footer_full: |
  [Extracted footer template]

footer_compact: |
  [Extracted compact footer if different]

tone:
  - [Detected tone 1]
  - [Detected tone 2]

banned_phrases:
  - "In this video"
  - [Other detected banned phrases]

primary_tags:
  - [Extracted tag 1]
  - [Extracted tag 2]

topic_tags:
  - [Extracted topic tags]

title_max_length: 60
title_full_max_length: [Calculated max]
description_max_length: 5000
hashtags_max: [Detected average]
---

## Overview

[Generated from channel description or common themes]

## Title Patterns

### Examples from channel:

[Real extracted examples]

## Voice Guidelines

### DO:
- [Generated from positive patterns]

### DON'T:
- [Generated from banned phrases]

## Pre-Publish Checklist

[Standard checklist items]
```

### Step 4: Save and Confirm

- Save to `./[channel-name]-brand-guide.md`
- Present to user for review
- User can edit or approve

---

## Token Reference

| Token | Type | Description |
|-------|------|-------------|
| `name` | string | Channel/brand name |
| `channel_id` | string | YouTube channel ID |
| `title_format` | string | Template for title structure |
| `title_separator` | string | Character separating title from suffix |
| `title_suffixes` | array | List of allowed suffixes |
| `title_patterns` | object | Patterns keyed by content type |
| `description_sections` | array | Ordered list of description sections |
| `footer_full` | string | Full footer template (multi-line) |
| `footer_compact` | string | Compact footer template |
| `tone` | array | Tone characteristics |
| `banned_phrases` | array | Phrases to avoid |
| `primary_tags` | array | Always-include hashtags |
| `topic_tags` | array | Topic-specific hashtags |
| `title_max_length` | number | Max chars for title portion |
| `title_full_max_length` | number | Max chars for full title |
| `description_max_length` | number | Max chars for description |
| `hashtags_max` | number | Maximum hashtags to use |
