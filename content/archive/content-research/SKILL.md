---
name: content-research
description: "Router for content research tasks. For fetching data from external sources (Reddit, YouTube, newsletters, NotebookLM, articles, trends), use /fetch instead — it handles all internet data fetching. This skill retains deep-research and market-research as local sub-skills."
---

# Content Research Router

**For fetching data from external sources, use `/fetch`** — it's the general-purpose router for all internet data.

This skill retains research-specific workflows that go beyond raw data fetching:

| Context | Action |
|---------|--------|
| Deep multi-source research on a topic | Read `~/.claude/skills/content-research/deep-research/GUIDE.md` |
| Market research, TAM/SAM, competitive landscape | Read `~/.claude/skills/content-research/market-research/GUIDE.md` |

For platform-specific data fetching (Reddit, YouTube, articles, etc.), `/fetch` routes to the appropriate guide automatically.
