#!/usr/bin/env python3
"""
Fetch a YouTube video transcript for youtube-content-ops.

Usage:
    python fetch_transcript.py <url_or_video_id> [--language en,zh]

Output: plain text (one paragraph, space-joined segments)
Errors: writes to stderr, exits 1

Install dependency: pip install youtube-transcript-api
"""

import argparse
import re
import sys


def extract_video_id(url_or_id: str) -> str:
    """Extract the 11-character video ID from any YouTube URL format."""
    url_or_id = url_or_id.strip()
    patterns = [
        r'(?:v=|youtu\.be/|shorts/|embed/|live/)([a-zA-Z0-9_-]{11})',
        r'^([a-zA-Z0-9_-]{11})$',
    ]
    for pattern in patterns:
        match = re.search(pattern, url_or_id)
        if match:
            return match.group(1)
    # If nothing matched, return as-is and let the API fail with a clear error
    return url_or_id


def fetch_transcript(video_id: str, languages: list = None) -> str:
    """Fetch transcript and return as plain text."""
    try:
        from youtube_transcript_api import YouTubeTranscriptApi
    except ImportError:
        raise RuntimeError(
            "youtube-transcript-api not installed. Run: pip install youtube-transcript-api"
        )

    api = YouTubeTranscriptApi()
    if languages:
        result = api.fetch(video_id, languages=languages)
    else:
        result = api.fetch(video_id)

    return " ".join(seg.text for seg in result)


def main():
    parser = argparse.ArgumentParser(description="Fetch YouTube transcript as plain text")
    parser.add_argument("url", help="YouTube URL or video ID")
    parser.add_argument("--language", "-l", default=None,
                        help="Comma-separated language codes (e.g. en,zh). Default: auto")
    args = parser.parse_args()

    video_id = extract_video_id(args.url)
    languages = [l.strip() for l in args.language.split(",")] if args.language else None

    try:
        text = fetch_transcript(video_id, languages)
        print(text)
    except Exception as e:
        error_msg = str(e).lower()
        if "disabled" in error_msg:
            print("Error: Transcripts are disabled for this video.", file=sys.stderr)
        elif "no transcript" in error_msg or "could not retrieve" in error_msg:
            print(
                f"Error: No transcript found for {video_id}. "
                "Try --language or check if captions exist.",
                file=sys.stderr
            )
        elif "invalid video id" in error_msg or "bad request" in error_msg:
            print(
                f"Error: Could not extract valid video ID from '{args.url}'. "
                "Provide a full YouTube URL or an 11-character video ID.",
                file=sys.stderr
            )
        else:
            print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
