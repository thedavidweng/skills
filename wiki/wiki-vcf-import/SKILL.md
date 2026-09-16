---
name: wiki-vcf-import
description: 'Import VCF contacts into wiki people pages. Triggers on ''import contacts'', ''vcf to wiki'', or ''contacts export''.'
---

Parse with regex (`FN:`/`EMAIL`/`TEL`). **VCF order is `given surname`; wiki is `surname-givenname`** (`zhang-san`) — build a both-orders lookup. Single-char surname? Verify reading (卜 bu/jia, 吕 lyu), never trust pypinyin blindly.

**Phone masking:** sandbox may display `****` while the file is complete — hex-dump (`xxd`) to confirm, never write masked numbers (`grep -c '\*\*\*\*' wiki/people/*.md` must be 0).

**Collisions:** never match by English nickname alone (verify via QQ/email/phone). Check duplicates (aliases, emails, phones) before creating. NOTE fields may hide ID numbers, schools, addresses, relatives — extract them. `X-ABRELATEDNAMES`/`X-ABDATE` capture family relations and anniversaries for family pages. Birthday `YYYYMMDD`/`--MMDD` → `YYYY-MM-DD`. Ex-partners: `status: inactive`, note the relationship period in body.

Template: frontmatter (layer/kind/aliases with Chinese + English name/tags/status) → `# 中文名 / English` → Contact → Sources `[[...contacts.vcf]]`. Update the index; run the vault audit.
