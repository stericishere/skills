---
name: skill-installer
description: "Install, download, or add new skills and plugins into the router-based skill organization. Use when the user asks to download a skill, install a plugin, add a new skill to the system, integrate a .skill file, register a new capability, or onboard a skill/plugin into the existing router hierarchy."
---

# Skill Installer

Install new skills/plugins into the two-tier skill organization system.

## Architecture

```
~/.claude/skills/
├── <direct-skill>/SKILL.md        ← Invoked directly from command line (/qa, /ship, etc.)
├── <router>/SKILL.md              ← Routes to GUIDE.md files based on context
│   └── <skill-name>/GUIDE.md      ← Hidden from picker, loaded by router
├── (workflow) phase-*/SKILL.md    ← Workflow phases (also reference GUIDE.md files)
└── archive/<skill-name>/GUIDE.md  ← Shared skills referenced by multiple routers/workflows
```

### Key rules
- **SKILL.md** = visible in the Claude skill picker, invokable from command line
- **GUIDE.md** = hidden from picker, only loaded when another skill reads it
- **Routers** = SKILL.md files that contain routing tables pointing to GUIDE.md files
- **Archive** = flat directory of GUIDE.md skills shared across multiple routers/workflows
- A skill goes in **archive/** when it's referenced by 2+ routers/workflows OR doesn't belong to a single router
- A skill goes **under a router** when it belongs to exactly one domain

## Router Registry

Routers at `~/.claude/skills/<router>/SKILL.md` — each routes to domain-specific GUIDE.md files:

| Router | Category | Covers |
|--------|----------|--------|
| `pm` | Product management | PRDs, user stories, roadmaps, prioritization, discovery, JTBD, personas, workshops, epic breakdown |
| `marketing` | Marketing | SEO, ads, CRO, email, pricing, launch strategy, analytics, social, referrals, copywriting |
| `orchestrate` | Agent orchestration | Auto-routing multi-agent orchestrator — 4 modes: SINGLE, PARALLEL, SEQUENTIAL, COMPETITIVE (powered by Agent Teams with worktree isolation) |
| `implementation-toolkit` | Technology-specific | Frontend (Expo, iOS, caching), Backend (Supabase, Stripe, LangChain, Docker, deployment), Testing |
| `content-creation` | Writing & content | Blog posts, articles, social media, tweets, newsletters, content briefs, calendars |
| `content-research` | Research & extraction | Reddit, YouTube transcripts, web articles, notebooks, deep research, market research |
| `design-frontend` | UI/UX & frontend | UI design, UX patterns, component architecture, code review, refactoring |
| `finance` | Finance & metrics | Financial analysis, ratios, DCF, budgets, forecasting, SaaS metrics |
| `n8n` | Workflow automation | n8n workflows, code nodes, validation, automation patterns |
| `video-production` | Video & short-form content | Briefs, concepts, scripts, art direction, storyboards, AI generation, assembly, publishing, repurposing (Koda Stack) |
| `tech-stack` | (Redirects to implementation-toolkit) | Legacy — use implementation-toolkit instead |

## Direct Skills (not routers)

These have SKILL.md and are invoked directly — do NOT archive these:

| Skill | Purpose |
|-------|---------|
| `qa` | QA test a running app and fix bugs |
| `qa-only` | QA test without fixing |
| `review` | Pre-landing PR code review |
| `ship` | Ship workflow (test, version, push, PR) |
| `browse` | Headless browser for testing/dogfooding |
| `design-review` | Visual QA audit |
| `design-consultation` | Create design system / DESIGN.md |
| `investigate` | Systematic debugging |
| `office-hours` | YC-style brainstorming |
| `plan-ceo-review` | CEO-level plan review |
| `plan-eng-review` | Eng-level plan review |
| `plan-design-review` | Design-level plan review |
| `codex` | Cross-model code review via Codex |
| `retro` | Engineering retrospective |
| `careful` | Safety guardrails for destructive commands |
| `freeze` / `unfreeze` / `guard` | Edit scope restrictions |
| `document-release` | Post-ship documentation update |
| `pua` | Force exhaustive problem-solving |
| `setup-browser-cookies` | Import browser cookies |
| `hook-development` | Create Claude Code hooks |
| `software-architecture` | Architecture guidance |
| `anthropic` | Claude API / Anthropic SDK guidance |
| `skill-creator` | Create new skills |
| `skill-installer` | This skill |
| `gstack-upgrade` | Upgrade gstack |
| `humanizer` | Remove AI writing patterns from text |
| `doc-coauthoring` | Structured doc co-authoring (context → refine → reader test) |
| `fix` | Fast bug fix workflow — investigate, isolate, fix, verify, ship (no spec needed) |
| `skill-fetch` | Search & install skills from 9 registries (SkillsMP, GitHub, etc.) |
| `dbs` | dontbesilent 商业工具箱 — main router for business diagnosis toolkit |
| `dbs-diagnosis` | 商业模式诊断 — business model diagnosis, dissolve problems |
| `dbs-benchmark` | 对标分析 — competitor benchmarking with five-filter method |
| `dbs-content` | 内容创作诊断 — content creation diagnosis, five-dimension check |
| `dbs-unblock` | 执行力诊断 — execution block diagnosis (Adler framework) |
| `web-artifacts-builder` | Build multi-component claude.ai HTML artifacts (React + Tailwind + shadcn/ui) |
| `dbs-deconstruct` | 概念拆解 — concept deconstruction (Wittgenstein framework) |

## Installed Plugins

Plugins registered via `pluginDirectories` in `~/.claude/settings.json`:

| Plugin | Path | What it does |
|--------|------|-------------|
| `evolving-lite` | `~/.claude-plugins/evolving-lite` | Self-evolving system — learns from corrections, manages context budget, progressive activation (3 tiers), 10 background hooks, 15 commands, pre-warmed experiences |

## Archive Contents

Skills in `~/.claude/skills/archive/` — shared across routers/workflows:

| Skill | Referenced by |
|-------|--------------|
| ~~do-in-parallel, do-in-steps, do-and-judge, do-competitively, judge, judge-with-debate, tree-of-thoughts, launch-sub-agent, subagent-driven-development~~ | REMOVED — all absorbed into `/orchestrate` skill |
| `architecture-decision-records` | workflow phase-2, phase-3 |
| `frontend-code-review` | workflow phase-3, design-frontend |
| `component-refactoring` | workflow phase-3, design-frontend |
| `content-research-writer` | workflow phase-4-launch, content-creation |
| `twitter-algorithm-optimizer` | workflow phase-4-launch, marketing |
| `saas-metrics-coach` | workflow phase-4-launch, finance |
| `article-extractor` | content-research |
| `notebooklm` | content-research |
| `reddit-fetch` | content-research |
| `yt-transcript-download` | content-research |
| `koda-brief` | video-production |
| `koda-trends` | video-production |
| `koda-concept` | video-production |
| `koda-script` | video-production |
| `koda-art-direction` | video-production |
| `koda-storyboard` | video-production |
| `koda-generate` | video-production |
| `koda-assemble` | video-production |
| `koda-publish` | video-production |
| `koda-repurpose` | video-production |
| `newsletter-curation` | content-creation, marketing |
| `viral-hooks` | content-creation, marketing |
| `trend-watcher` | content-creation, content-research |

## Installation Workflow

### Step 1: Identify the skill

Read the new skill's SKILL.md, README, or description. Determine:
- What does it do?
- Should the user be able to invoke it as a `/command`?
- Which router(s) should reference it?

### Step 2: Place the skill file

Two questions, in order:

**Q1: Should this be a `/command`?**

```
YES → Place as SKILL.md at top level:
      ~/.claude/skills/<skill-name>/SKILL.md
      (Visible in picker, user invokes /skill-name)

NO  → Place as GUIDE.md in archive:
      ~/.claude/skills/archive/<skill-name>/GUIDE.md
      (Hidden from picker, only loaded by routers)
```

**Q2: Which router(s) should reference it?**

Every skill — whether command or archive — must be routed. Determine which routers
should surface this skill based on context, then add a path entry to each router.

### Step 3: Add router entries

For each router that should reference the skill, add a row to its routing table
pointing to the skill's actual file path:

**If the skill is a direct command** (SKILL.md at top level):
```markdown
| <trigger context> | Read `~/.claude/skills/<skill-name>/SKILL.md` |
```

**If the skill is in archive** (GUIDE.md):
```markdown
| <trigger context> | Read `~/.claude/skills/archive/<skill-name>/GUIDE.md` |
```

**If the skill is under a single router** (GUIDE.md nested under router):
```markdown
| <trigger context> | Read `~/.claude/skills/<router>/<skill-name>/GUIDE.md` |
```

Match the router's existing table format:
- Routers with `| Context | Action |` tables → add with explicit path
- Routers with `| Sub-skill | Triggers |` tables (implicit path from router name) →
  add a separate "Cross-referenced skills" section with `| Context | Action |` format
  for skills that live outside the router directory

### Step 4: Handle special cases

**Skill belongs to exactly one router and is NOT a command:**
Place under that router instead of archive:
```
~/.claude/skills/<router>/<skill-name>/GUIDE.md
```

**Skill needs a new router (no existing router fits):**
1. Create `~/.claude/skills/<new-router>/SKILL.md` with YAML frontmatter + routing table
2. Place the skill as GUIDE.md (under the router or in archive)
3. Update the Router Registry table in THIS skill (skill-installer)

**Option C — Archive (shared/cross-cutting):**
```
~/.claude/skills/archive/<skill-name>/GUIDE.md
```
1. Move/copy the skill folder into archive/
2. Rename `SKILL.md` → `GUIDE.md`
3. Keep all internal files

### Step 4: Register in routing tables

For **Option B** (router skill):
1. Read `~/.claude/skills/<router>/SKILL.md`
2. Add a row to the routing table:
   ```markdown
   | <context description> | Read `~/.claude/skills/<router>/<skill-name>/GUIDE.md` |
   ```
3. Update the router's YAML `description` if new trigger keywords are needed

For **Option C** (archive skill):
1. Add a row to EVERY router that should reference it:
   ```markdown
   | <context description> | Read `~/.claude/skills/archive/<skill-name>/GUIDE.md` |
   ```
2. Update the Archive Contents table in THIS skill (skill-installer)

For **plugin skills**, use this format instead:
```markdown
| <context description> | Invoke plugin `<plugin-name>:<skill-name>` via Skill tool |
```

### Step 5: New router (only if no existing router fits)

If the skill needs a router that doesn't exist:

1. Create `~/.claude/skills/<new-router>/SKILL.md` with:
   - YAML frontmatter: `name` + broad `description` covering the category
   - Routing table pointing to the new skill's GUIDE.md
2. Place the skill inside: `~/.claude/skills/<new-router>/<skill-name>/GUIDE.md`
3. **Update this skill**: Add the new router to the Router Registry table above

### Step 6: Verify

1. Confirm the GUIDE.md is readable at its new path
2. Confirm every router that references it has the correct table entry
3. If a new router was created, confirm it appears in the skill picker
4. If archived, confirm the Archive Contents table in this skill is updated
