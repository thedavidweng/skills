# Prerequisites

## Option A: Full Access Mode (yutu CLI)

For users with channel ownership or manager permissions.

**Official Repository:** https://github.com/eat-pray-ai/yutu

**Install yutu:**
```bash
# macOS
brew install yutu

# Linux
curl -sSfL https://raw.githubusercontent.com/eat-pray-ai/yutu/main/scripts/install.sh | bash

# Windows
winget install yutu
```

**Configure OAuth credentials:**

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **YouTube Data API v3**
3. Create an **OAuth Client ID** (Web Application); set redirect URI to `http://localhost:8080`
4. Download the credentials file as `client_secret.json`
5. Authorize:
   ```bash
   yutu auth --credential client_secret.json
   ```
6. A `token.json` will be generated upon success.

## Option B: Read-Only Mode (youtube-transcript-api)

For users who only have editor permissions or don't want to set up OAuth.

**Official Repository:** https://github.com/jdepoix/youtube-transcript-api

**Install:**
```bash
pip install youtube-transcript-api
```

This mode can only **read** transcripts — all generated content must be manually copied by the user.

## Mode Detection

At the start of each session, check which tools are available:

```bash
# Check yutu
yutu channel list --output json 2>/dev/null

# Check youtube-transcript-api
python3 -c "from youtube_transcript_api import YouTubeTranscriptApi; print('available')" 2>/dev/null
```

**Decision logic:**
1. yutu works → **Full Access Mode**
2. yutu fails, youtube-transcript-api works → **Read-Only Mode**
3. Both fail → Prompt user to install one of them
