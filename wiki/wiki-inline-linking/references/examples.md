# Inline Linking Examples

## Example 1: Basic inline link

**Before:**
```markdown
# Alice Smith

Alice studied at Harvard and later joined OpenAI.
```

**After:**
```markdown
# Alice Smith

[[alice-smith|Alice]] studied at [[harvard-university|Harvard]] and later joined [[openai|OpenAI]].
```

## Example 2: Table with shared names

**Before:**
```markdown
| Name    | University | Company |
|---------|------------|---------|
| Alice   | Harvard    | OpenAI  |
| Bob     | MIT        | Google  |
```

**After:** (link only the unique full-name column, not first names)
```markdown
| Name | University | Company |
|------|------------|---------|
| [[alice-smith|Alice Smith]] | [[harvard-university|Harvard]] | [[openai|OpenAI]] |
| [[bob-jones|Bob Jones]] | [[mit|MIT]] | [[google|Google]] |
```

## Example 3: Removing a Related section

**Before:**
```markdown
# Project Alpha

Project Alpha is a research initiative.

## Related
- [[alice-smith|Alice Smith]]
- [[openai|OpenAI]]
```

**After:**
```markdown
# Project Alpha

[[project-alpha|Project Alpha]] is a research initiative led by [[alice-smith|Alice Smith]] at [[openai|OpenAI]].
```

## Example 4: YAML title quoting

**Before:**
```yaml
---
title: Beacon: Journal of Science
---
```

**After:**
```yaml
---
title: "Beacon: Journal of Science"
---
```
