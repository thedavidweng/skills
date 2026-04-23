# yutu Command Reference

Complete yutu CLI command reference for YouTube API operations.

## Authentication

```bash
# First-time authorization
yutu auth --credential client_secret.json

# Specify token storage location
yutu auth --credential client_secret.json --cacheToken token.json
```

## Captions

```bash
# List all captions for a video
yutu caption list --videoId VIDEO_ID --output json

# Download a caption
yutu caption download --id CAPTION_ID --file output.srt --tfmt srt

# Download as VTT format
yutu caption download --id CAPTION_ID --file output.vtt --tfmt vtt

# Download translated caption
yutu caption download --id CAPTION_ID --file output.srt --tlang zh-Hans

# Upload a caption
yutu caption insert --videoId VIDEO_ID --file subtitle.srt --language en

# Delete a caption
yutu caption delete --id CAPTION_ID
```

## Videos

```bash
# Get video info
yutu video list --ids VIDEO_ID --output json

# Get info for multiple videos
yutu video list --ids VIDEO_ID1,VIDEO_ID2,VIDEO_ID3 --output json

# Update video title
yutu video update --id VIDEO_ID --title "New Title"

# Update video description
yutu video update --id VIDEO_ID --description "New Description"

# Update video tags
yutu video update --id VIDEO_ID --tags "tag1,tag2,tag3"

# Update video category
yutu video update --id VIDEO_ID --categoryId 27

# Update privacy setting
yutu video update --id VIDEO_ID --privacy public    # public/private/unlisted

# Batch update
yutu video update --id VIDEO_ID \
  --title "Title" \
  --description "Description" \
  --tags "tag1,tag2" \
  --privacy public

# Delete a video
yutu video delete --id VIDEO_ID
```

## Channels

```bash
# List channels managed by the user
yutu channel list --output json

# Get channel details
yutu channel list --id CHANNEL_ID --output json

# Update channel info
yutu channel update --id CHANNEL_ID --title "Channel Name" --description "Channel Description"
```

## Playlists

```bash
# List channel playlists
yutu playlist list --mine --output json

# Create a playlist
yutu playlist insert --title "Playlist Name" --description "Description" --privacy public

# Update a playlist
yutu playlist update --id PLAYLIST_ID --title "New Name"

# Delete a playlist
yutu playlist delete --id PLAYLIST_ID
```

## Playlist Items

```bash
# List videos in a playlist
yutu playlistItem list --playlistId PLAYLIST_ID --output json

# Add a video to a playlist
yutu playlistItem insert --playlistId PLAYLIST_ID --videoId VIDEO_ID

# Remove a video from a playlist
yutu playlistItem delete --id PLAYLIST_ITEM_ID
```

## Thumbnails

```bash
# Set video thumbnail
yutu thumbnail set --videoId VIDEO_ID --file thumbnail.jpg
```

## Search

```bash
# Search videos
yutu search --query "search keyword" --type video --maxResults 10 --output json

# Search playlists
yutu search --query "search keyword" --type playlist --maxResults 10

# Search channels
yutu search --query "search keyword" --type channel --maxResults 10
```

## Subscriptions

```bash
# List user subscriptions
yutu subscription list --output json

# Subscribe to a channel
yutu subscription insert --channelId CHANNEL_ID

# Unsubscribe
yutu subscription delete --id SUBSCRIPTION_ID
```

## Comments

```bash
# List video comments
yutu comment list --videoId VIDEO_ID --output json

# Post a comment
yutu comment insert --videoId VIDEO_ID --text "Comment text"

# Reply to a comment
yutu comment insert --parentId COMMENT_ID --text "Reply text"

# Delete a comment
yutu comment delete --id COMMENT_ID
```

## Output Formats

All `--output` flags support:
- `table` - Table format (default)
- `json` - JSON format
- `yaml` - YAML format

## Video Category IDs

Common categories (US):

| ID | Category |
|----|----------|
| 1 | Film & Animation |
| 2 | Autos & Vehicles |
| 10 | Music |
| 15 | Pets & Animals |
| 17 | Sports |
| 20 | Gaming |
| 22 | People & Blogs |
| 23 | Comedy |
| 24 | Entertainment |
| 25 | News & Politics |
| 26 | Howto & Style |
| 27 | Education |
| 28 | Science & Technology |
| 29 | Nonprofits & Activism |

Full category list:
```bash
yutu videoCategory list --output json
```

## Environment Variables

```bash
# Credential file path
export YUTU_CREDENTIAL=/path/...json

# Token file path
export YUTU_TOKEN=/path/...json

# Working directory
export YUTU_ROOT=/path/to/workspace

# Log level
export YUTU_LOG_LEVEL=DEBUG
```

## Troubleshooting

| Error | Cause | Solution |
|-------|-------|----------|
| `dailyLimitExceeded` | API quota exhausted | Wait for next day or request higher quota |
| `authError` | Token expired or invalid | Re-run `yutu auth` |
| `forbidden` | No permission for this resource | Check OAuth scope |
| `notFound` | Video/channel does not exist | Verify the ID is correct |
| `quotaExceeded` | Request rate too high | Reduce request frequency |
