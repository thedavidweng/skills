# YouTube Content Brand Guide Template

> This template defines the format for channel brand guides. Used by youtube-content-ops skill for style-consistent content generation.

---

## The Format

A brand guide file combines **machine-readable tokens** (YAML front matter) with **human-readable guidance** (markdown prose). Tokens give agents exact patterns. Prose tells them *why* those patterns exist and how to apply them.

```
---
name: [Channel Name]
channel_id: [YouTube Channel ID]

# Title Patterns
title_format: "[Title] | [Series] [Month] [Year]"
title_separator: "|"  # or "｜" (full-width)
title_suffixes:
  - "| [Channel] [Month] [Year]"
  - "｜[Series]"

# Title Types
title_patterns:
  announcement: "Community Announcements: [Topics] | [Channel] [Month] [Year]"
  speaker: "[Speaker Name]: [Topic]｜[Series]"
  theme: "[Topic 1], [Topic 2] & [Topic 3]: [Event] [Month] [Year]"
  provocative: "[Hook statement...] | [Channel] Meetup [Month] [Year]"

# Description Structure
description_sections:
  - hook          # Opening sentence (required)
  - context       # 2-4 sentences explaining what/why
  - content       # Bullet points or paragraphs
  - footer        # Fixed CTA block (required)

# Footer Templates
footer_full: |
  --------
  💥 Join the movement
  Join [Organization]: [URL]
  Next [Event]: [URL]
  
  Smash that Subscribe & 🔔 so you don't miss future [content type].
  Drop a comment: [Question placeholder]
  Share the vid with [audience placeholder].

footer_compact: |
  —
  Join [Organization]: [URL]
  Next [Event]: [URL]
  Subscribe for more [content type]
  Comment below with your thoughts
  Share with someone who needs to hear this

# Voice & Tone
tone:
  - educational_not_patronizing
  - personal_perspective
  - pain_point_focused
  - action_oriented

banned_phrases:
  - "In conclusion"
  - "I recommend"
  - "First, second, lastly"
  - "As an AI"
  - "In this video"
  - "In this talk"
  - "I hope this helps"

# Hashtags
primary_tags:
  - #[BrandTag1]
  - #[BrandTag2]

topic_tags:
  - #[TopicTag1]
  - #[TopicTag2]

# Constraints
title_max_length: 60        # Title portion before separator
title_full_max_length: 100  # Full title with suffix
description_max_length: 5000
hashtags_max: 5
---

## Overview

[2-3 sentences describing the channel's brand positioning, target audience, and core values]

## Title Patterns

### When to use each pattern:

1. **Announcement**: For community updates, event recaps, organizational news
2. **Speaker**: For single-speaker talks, interviews, presentations
3. **Theme**: For multi-speaker events, themed compilations
4. **Provocative**: For main talks with strong hook statements

### Examples:

[Real examples from the channel]

## Description Structure

### Hook Styles:
- **Question**: "What happens when...?"
- **Provocative Statement**: "Let's be real: ..."
- **Context Statement**: "Full recording from..."

### Content Structure Options:
- **Paragraphs**: For narrative talks
- **Bullet points**: For multi-speaker events
- **Speaker + description**: For speaker-focused content

## Voice Guidelines

### DO:
- [Positive guideline 1]
- [Positive guideline 2]

### DON'T:
- [Negative guideline 1]
- [Negative guideline 2]

## Pre-Publish Checklist

- [ ] Title matches pattern for content type
- [ ] Hook is attention-grabbing (not generic)
- [ ] Footer included with correct links
- [ ] Banned phrases avoided
- [ ] Hashtags relevant and ≤ limit
```

---

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
