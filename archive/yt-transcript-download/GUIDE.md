---
name: youtube-transcript
description: Download YouTube video transcripts when user provides a YouTube URL or asks to download/get/fetch a transcript from YouTube. Also use when user wants to transcribe or get captions/subtitles from a YouTube video.
allowed-tools: Bash,Read,Write
---

# YouTube Transcript Downloader

Get transcript text from a YouTube video. Falls back through multiple methods automatically.

## Priority Order

1. **yt-dlp manual subs** — highest quality, human-created
2. **yt-dlp auto-generated subs** — usually available
3. **Groq Whisper API** — near-instant cloud transcription (requires GROQ_API_KEY)
4. **mlx-whisper** — fast local transcription on Apple Silicon GPU (fallback)

## Full Workflow

### Step 1: Get video metadata

```bash
VIDEO_URL="YOUTUBE_URL"
VIDEO_TITLE=$(yt-dlp --print "%(title)s" "$VIDEO_URL" --no-warnings | tr '/:?"' '_____')
DURATION=$(yt-dlp --print "%(duration)s" "$VIDEO_URL" --no-warnings)
echo "Title: $VIDEO_TITLE | Duration: $((DURATION / 60))m"
```

### Step 2: Try subtitles (manual then auto)

```bash
# Manual subs first
yt-dlp --write-sub --sub-langs "en,zh" --skip-download -o "/tmp/yt_transcript" "$VIDEO_URL" --no-warnings 2>&1

# Check if VTT was downloaded
ls /tmp/yt_transcript*.vtt 2>/dev/null

# If no manual, try auto-generated
yt-dlp --write-auto-sub --sub-langs "en,zh" --skip-download -o "/tmp/yt_transcript" "$VIDEO_URL" --no-warnings 2>&1
ls /tmp/yt_transcript*.vtt 2>/dev/null
```

If a VTT file exists, skip to Step 5 (clean VTT to plain text).

### Step 3: Download audio (needed for Groq and mlx-whisper)

No subtitles available — download audio for transcription. **Do not ask for confirmation.**

```bash
yt-dlp -x --audio-format mp3 -o "/tmp/yt_audio.%(ext)s" "$VIDEO_URL" --no-warnings 2>&1
```

### Step 4: Transcribe audio

**Try Groq API first** (near-instant, free tier):

```bash
python3 -c "
from groq import Groq

client = Groq()
with open('/tmp/yt_audio.mp3', 'rb') as f:
    transcription = client.audio.transcriptions.create(
        file=('yt_audio.mp3', f.read()),
        model='whisper-large-v3-turbo',
        temperature=0,
        response_format='text'
    )
print(transcription)
" 2>&1
```

If Groq fails (no API key, rate limit, file >25MB), **fall back to mlx-whisper** (Apple Silicon GPU, fast local):

```bash
mlx_whisper /tmp/yt_audio.mp3 --model mlx-community/whisper-small-mlx --output-dir /tmp --output-format txt 2>&1
# Result at /tmp/yt_audio.txt
```

### Step 5: Clean VTT to plain text (if VTT route worked)

```bash
VTT_FILE=$(ls /tmp/yt_transcript*.vtt 2>/dev/null | head -1)
python3 -c "
import re
seen = set()
with open('$VTT_FILE', 'r') as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('WEBVTT') and not line.startswith('Kind:') and not line.startswith('Language:') and '-->' not in line:
            clean = re.sub('<[^>]*>', '', line).replace('&amp;', '&').replace('&gt;', '>').replace('&lt;', '<')
            if clean and clean not in seen:
                print(clean)
                seen.add(clean)
"
```

### Step 6: Cleanup temp files

```bash
rm -f /tmp/yt_transcript*.vtt /tmp/yt_audio.mp3 /tmp/yt_audio.txt
```

## Groq file size limit

Groq Whisper API has a **19.5MB limit**. Supported formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, webm.

```bash
# Check file size before sending to Groq
FILE_SIZE=$(stat -f%z /tmp/yt_audio.mp3 2>/dev/null || stat -c%s /tmp/yt_audio.mp3)
if [ "$FILE_SIZE" -gt 20447232 ]; then
    echo "File >19.5MB — using mlx-whisper instead"
fi
```

If >19.5MB, skip Groq and go straight to mlx-whisper.

## Installation

```bash
# yt-dlp (keep updated — outdated versions break often)
pip install --upgrade yt-dlp

# Groq SDK (for cloud Whisper API)
pip install groq
# Set GROQ_API_KEY in shell profile: export GROQ_API_KEY="gsk_..."

# mlx-whisper (Apple Silicon GPU — fast local fallback)
pip install mlx-whisper

# ffmpeg (required by yt-dlp and mlx-whisper)
brew install ffmpeg
```

## Notes

- yt-dlp breaks frequently as YouTube changes APIs — always use latest version
- Always pass `--no-warnings` to suppress version warnings in output
- Groq free tier has rate limits — if hit, falls back to mlx-whisper automatically
- mlx-whisper uses Apple Silicon GPU — very fast for local transcription
- Both Groq and mlx-whisper auto-detect language — no need to specify
