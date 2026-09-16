---
name: wiki-slug-rename
description: 'Rename wiki page slugs without breaking links. Triggers on ''rename page'', ''change slug'', ''bulk rename'', or ''normalize names''.'
---

1. `mv wiki/{section}/{old}.md wiki/{section}/{new}.md`.
2. Rename embedded source files too: `find sources/ -name "*{old}*"` (chats/exports also hide slugs).
3. Replace `[[old]]` / `[[old|Text]]` / embedded media refs vault-wide.
4. Update the index (entry + count).
5. Verify zero stragglers (`grep -rn "{old}" wiki/ sources/`), then ONE atomic commit.

Bulk: rename map → script (`references/batch-script-template.py`) → stragglers → index → audit → commit.

**Pitfalls:** `name-` prefixes must follow the new slug; multi-reading characters (卜/吕) need manual verification; site-generator nav may hardcode the old slug.
