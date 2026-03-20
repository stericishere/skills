---
name: video-production
description: "Router for video production and short-form content creation pipeline. Use when the user needs help with video briefs, creative concepts, scriptwriting, art direction, storyboarding, AI image/video generation, reel assembly, publishing strategy, content repurposing, trend research for video, or any step in a video content pipeline (Instagram Reels, TikTok, YouTube Shorts)."
---

# Video Production Router

Full creative pipeline for short-form video content. Based on the Koda Creative Stack.

**Brand DNA:** Before creating anything, read `~/.claude/skills/koda-stack/CLAUDE.md` for brand voice, visual identity, content format, tools, audience, and rules.

## Pipeline (sequential order)

| Step | Role | When to use | Action |
|------|------|-------------|--------|
| Brief | The Planner | Turn a vague idea into a structured brief | Read `~/.claude/skills/archive/koda-brief/GUIDE.md` |
| Trends | The Scout | Find trending topics and angles in a niche | Read `~/.claude/skills/archive/koda-trends/GUIDE.md` |
| Concept | The Creative Director | Build 3 creative concepts from a brief | Read `~/.claude/skills/archive/koda-concept/GUIDE.md` |
| Script | The Scriptwriter | Write dense, punchy video scripts (91-125 words) | Read `~/.claude/skills/archive/koda-script/GUIDE.md` |
| Art Direction | The Art Director | Set visual direction — palette, mood, lighting | Read `~/.claude/skills/archive/koda-art-direction/GUIDE.md` |
| Storyboard | The Storyboarder | Map every shot with timing and descriptions | Read `~/.claude/skills/archive/koda-storyboard/GUIDE.md` |
| Generate | The Producer | Generate images via AI (fal.ai, Midjourney, Flux) | Read `~/.claude/skills/archive/koda-generate/GUIDE.md` |
| Assemble | The Editor | Assemble reel from shots + voiceover | Read `~/.claude/skills/archive/koda-assemble/GUIDE.md` |
| Publish | The Social Manager | Write captions, hashtags, posting strategy | Read `~/.claude/skills/archive/koda-publish/GUIDE.md` |
| Repurpose | The Content Multiplier | Adapt reel into threads, carousels, stories | Read `~/.claude/skills/archive/koda-repurpose/GUIDE.md` |

## Usage

Run the full pipeline in order, or pick individual steps:
```
Full pipeline:  brief → trends → concept → script → art-direction → storyboard → generate → assemble → publish → repurpose
Single step:    Read the specific GUIDE.md for the step you need
```

Source: [koda-stack](https://github.com/timkoda/koda-stack) by Tim Koda
