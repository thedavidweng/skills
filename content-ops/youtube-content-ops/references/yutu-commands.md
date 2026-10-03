# yutu commands for this workflow

Only the commands the workflow uses. For anything else, run `yutu <resource> <verb> --help`; flags change between releases.

## Auth

```bash
yutu auth --credential client_secret.json --cacheToken youtube.token.json
```

`YUTU_CREDENTIAL` and `YUTU_CACHE_TOKEN` override both paths.

## Mode detection

```bash
yutu channel list --for mine --output json
```

## Recent videos (brand guide generation)

```bash
yutu search list --channelId CHANNEL_ID --types video --order date --maxResults 15 --output json
yutu video list --ids VIDEO_ID1,VIDEO_ID2 --output json
```

`search list` returns snippets only. Use `video list` for full descriptions and tags.

## Transcript

```bash
yutu caption list --videoId VIDEO_ID --output json
yutu caption download --id CAPTION_ID --file transcript.srt --tfmt srt
```

## Apply metadata (only after the user confirms)

```bash
yutu video update --id VIDEO_ID --title "Title" --description "Description" --tags "tag1,tag2"
```

## Errors

| Error | Action |
|-------|--------|
| `authError`, `401`, `403` | Stop. Ask the user to re-run `yutu auth`. No scraping workaround. |
| `quotaExceeded`, `dailyLimitExceeded` | Stop and report. The Data API quota resets daily. |
| `notFound` | Recheck the video or channel ID. |
