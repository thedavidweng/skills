# Wiki Pitfalls

> Load this when encountering unexpected broken links or index drift.

## Slug Convention Drift

The most common cause of "broken" wikilinks is not missing files — it is **index entries using a different slug convention than the actual filenames**.

Example discovered in the wild:
- Index entry: `[[cai-yiran]]`
- Actual file: `cai-yi-ran.md`
- Result: Link appears in the graph but resolves to nothing

**Detection:** Run a programmatic scan comparing all `[[wikilinks]]` in `index.md` against the actual filesystem basenames in `wiki/`.

**Prevention:** After any bulk rename or schema change, immediately rebuild `index.md` and verify every link resolves.

## Source Frontmatter Backfill

Sources created before the `sha256` field was added will silently fail drift detection. A source without `sha256` cannot be checked for re-ingest drift.

**Fix:** Batch-compute and append `sha256` to all pre-schema sources. This is a one-time operation.

## Orphan Maps

Map pages (`kind: map`) often become orphans because no other page links to them. This defeats their purpose as navigation hubs.

**Fix:** Every hub map should be linked from at least one other map or from `index.md`. Do not assume users will find them by browsing directories.

## Tag Taxonomy Sprawl

Non-taxonomy tags (`cssa`, `ra`, `style-guide`) accumulate quickly and fragment filtering. If a tag appears on 3+ pages, add it to the schema taxonomy. If it appears once, remove it and describe the concept in body text instead.
