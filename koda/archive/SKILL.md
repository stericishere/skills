---
name: video-production
description: "Router for video production and short-form content creation pipeline. Use when the user needs help with video briefs, creative concepts, scriptwriting, art direction, storyboarding, AI image/video generation, reel assembly, publishing strategy, content repurposing, trend research for video, or any step in a video content pipeline (Instagram Reels, TikTok, YouTube Shorts)."
---

# Video Production Router

Routes to the **Koda workflow** for all video production tasks.

## Default Route

For any video production request, read and follow: `~/.claude/skills/koda/SKILL.md`

The Koda workflow orchestrates 10 specialized roles across 4 phases:

| Phase | Steps | Use when |
|-------|-------|----------|
| DISCOVER | trends, brief | Starting from an idea or looking for ideas |
| CREATE | concept, script, art-direction | Developing the creative |
| PRODUCE | storyboard, generate, assemble | Building the visual assets |
| DISTRIBUTE | publish, repurpose | Shipping to platforms |

## Quick Access

- Full pipeline: `/koda [idea]`
- Single step: `/koda [step-name]` (e.g., `/koda script`)
- Phase: `/koda [phase]` (e.g., `/koda create`)

Source: [koda-stack](https://github.com/timkoda/koda-stack) by Tim Koda
