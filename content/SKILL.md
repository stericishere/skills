---
name: content
description: "Router for content writing, research, documentation, and text optimization. Use when the user needs help with blog posts, articles, social media, newsletters, copywriting, content briefs, deep research, market research, documentation co-authoring, or removing AI writing patterns."
user-invocable: true
args:
  - name: type
    description: "Optional content type: write, research, docs, humanize"
    required: false
---

# Content Router

Route to the right content skill based on intent:

| Intent | Read this guide |
|--------|----------------|
| Write blog posts, articles, social media, newsletters, copywriting, content briefs, content calendars | Read `~/.claude/skills/content/archive/content-creation/SKILL.md` |
| Deep research, market research, competitive analysis | Read `~/.claude/skills/content/archive/content-research/SKILL.md` |
| Co-author documentation, proposals, technical specs, decision docs | Read `~/.claude/skills/content/archive/doc-coauthoring/SKILL.md` |
| Remove AI writing patterns, make text sound natural and human-written | Read `~/.claude/skills/content/archive/humanizer/SKILL.md` |

## Keyword routing

| Keyword | Route to |
|---------|----------|
| write, blog, article, post, newsletter, copy, brief, calendar | content-creation |
| research, analyze, competitive, market, deep dive | content-research |
| docs, documentation, proposal, spec, RFC, decision doc | doc-coauthoring |
| humanize, natural, AI slop, rewrite, tone | humanizer |

If no keyword matches, ask the user what they need.
