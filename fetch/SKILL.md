---
name: fetch
description: "General-purpose router for fetching ANY data from the internet or external sources. Use when the user needs to pull data from Reddit, YouTube, newsletters, NotebookLM, web articles, APIs, GitHub trending, or any external platform. Handles transcripts, threads, articles, notebooks, trends, deep research, market research, and raw web fetching. Also handles NotebookLM content synthesis — mind maps, knowledge hubs, Obsidian Canvas visualizations, and section-level deep summaries (replaces the old notebooklm-synthesizer skill). Triggers: 'fetch', 'pull from', 'get from', 'download from', 'grab', 'scrape', 'extract from', 'what does Reddit say', 'get the transcript', 'fetch newsletter', 'research this', 'summarize notebooklm', 'create mind map', 'turn into notes', any URL the user wants data from."
user-invocable: true
args:
  - name: source
    description: Optional source to route directly (e.g., 'reddit', 'yt', 'newsletter', 'notebooklm', 'article', 'trends', 'deep', 'market')
    required: false
  - name: query
    description: Optional topic, URL, or search terms
    required: false
---

# Fetch — Get Data from the Internet

You are a general-purpose data-fetching router. Your job is to get data from external sources and deliver it in a usable format.

## If the user specifies a source

Route directly to the matching guide:

| Source keyword | Read this guide |
|---|---|
| reddit, r/, subreddit, threads, comments | `~/.claude/skills/archive/reddit-fetch/GUIDE.md` |
| youtube, yt, transcript, video, captions | `~/.claude/skills/archive/yt-transcript-download/GUIDE.md` |
| newsletter, curate, digest, email roundup | `~/.claude/skills/archive/newsletter-curation/GUIDE.md` |
| notebooklm, notebook, nlm, audio overview, synthesize, mind map, knowledge hub | `~/.claude/skills/archive/notebooklm/GUIDE.md` |
| article, blog, extract, readability | `~/.claude/skills/archive/article-extractor/GUIDE.md` |
| trends, trending, github trending, emerging | `~/.claude/skills/archive/trend-watcher/GUIDE.md` |
| deep, research, multi-source, comprehensive | `~/.claude/skills/content-research/deep-research/GUIDE.md` |
| market, TAM, SAM, competitive, landscape | `~/.claude/skills/content-research/market-research/GUIDE.md` |

Read the matched guide, then follow its full instructions.

## If a URL is provided — Auto-detect source

Match the domain to the right fetcher:

| URL pattern | Route to |
|---|---|
| `reddit.com`, `old.reddit.com` | reddit-fetch |
| `youtube.com`, `youtu.be` | yt-transcript-download |
| `notebooklm.google.com` | notebooklm |
| `github.com/trending` | trend-watcher |
| Any other URL | article-extractor |

## If no source or URL — Detect intent from context

1. **Look for platform keywords** in the user's message and match against the source table
2. **If asking for research/analysis** (not just raw data) → route to deep-research or market-research
3. **If asking to monitor/track** → route to trend-watcher
4. **If ambiguous** — ask: "Where should I fetch from?" and list the available sources

## General web fetch (no specialized guide matches)

When the user wants raw data from a URL or API that doesn't match any specialized guide:

1. **Web page content** → Use `defuddle parse URL --md` as the **default**. It extracts clean markdown, strips nav/ads/clutter, and saves tokens. Do NOT use defuddle for URLs ending in `.md` — those are already markdown, use `WebFetch` directly.
2. **API endpoint** → Use `curl` via Bash to hit the endpoint, parse the JSON/XML response
3. **File download** → Use `curl -O` or `wget` to download the file
4. **Multiple pages** → Use `crwl URL --deep-crawl bfs --max-pages N -o md` for multi-page crawls. Fall back to firecrawl MCP or sequential WebFetch if unavailable.

### Fallback chain for web pages
If defuddle fails or returns empty content, fall back in order:
1. `crwl URL -o md` (crawl4ai) — handles 403s, JS-rendered pages, bot-detection
2. `WebFetch` — built-in tool
3. `/browse` — full headless browser

### 403 Error Recovery
If defuddle or `WebFetch` returns a 403 error, **automatically retry with crawl4ai**:
```bash
crwl "URL" -o md
```
crawl4ai uses headless browser automation with stealth mode, which bypasses most bot-detection and corporate firewalls that block simple HTTP clients.

## Multi-source fetch

When the request spans multiple platforms (e.g., "research X on Reddit and YouTube"):

1. Read all matching guides
2. Execute fetches in parallel where possible (use Agent Teams for 3+ sources)
3. Combine and synthesize results into a single structured output

## Rules

- **Always read the full guide** before executing — don't improvise fetch logic
- **Pass the query/URL through** to the sub-skill's workflow
- **Return structured output** — raw dumps are useless; organize what you fetch
- **Respect rate limits** — back off on 429s, don't hammer endpoints
- **Clean the data** — strip ads, nav, boilerplate before presenting results
