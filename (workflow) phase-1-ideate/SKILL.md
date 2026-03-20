---
name: (workflow) phase-1-ideate
description: Phase 1 IDEATE — brainstorm with /office-hours, Reddit + App Store gap research, PRD, competitive analysis, market sizing, positioning, go/no-go
---

## Design Pattern
**Pipeline** (sequential steps with gates) + **Inversion** (/office-hours asks forcing questions before generating)

## Upstream reads
None — entry point.
If returning to this phase: read `docs/ideate/claude.md`

## Steps

### Step 0 — Office Hours
**Skill:** `/office-hours`

Run YC Office Hours first. Six forcing questions that reframe the product before research begins:
- Demand reality, status quo, desperate specificity, narrowest wedge, observation, future-fit
- Saves design doc that feeds all downstream work

**Output:** `docs/ideate/design-doc.md`

> **DECISION GATE:** "Design doc approved? Proceed to research."

---

### Step 1 — Reddit Research
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (4 concurrent queries)
**Skill:** `reddit-fetch` — Read `~/.claude/skills/archive/reddit-fetch/GUIDE.md`

Run simultaneously across r/SaaS, r/startups, r/Entrepreneur, r/smallbusiness + domain subreddits:
- `"I wish there was an app for"`
- `"alternative to [popular tool in domain]"`
- `"biggest problem with [industry/process]"`
- `"I'd pay for"` / `"shut up and take my money"`

For each hit: capture problem description, subreddit, upvote count, user quotes.
Flag recurring themes — if 3+ unrelated users mention same pain, signal is real.

**Output:** `docs/ideate/reddit-research.md`

---

### Step 2 — App Store Gap Analysis
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (one agent per target category)
**Skill:** `/browse`

For each target app category:
- Search App Store top charts in domain
- Filter: last update > 12 months ago (indicates abandoned app — stale = opportunity)
- Filter: rating >= 4 stars (popular but neglected)
- Scrape recent reviews for: "please update", "abandoned", "any updates?", "still works"
- Record: app name, download rank, last update date, review quotes, unmet requests

**Output:** Append `## App Store Signals` to `docs/ideate/reddit-research.md`

> **DECISION GATE:** "Which 3 pain points are strongest across Reddit + App Store? Pick before brainstorm."

---

### Step 3 — Brainstorm Solutions
**SADD:** `tree-of-thoughts` — Read `~/.claude/skills/archive/tree-of-thoughts/GUIDE.md`
**Skill:** `superpowers:brainstorming`

Input: design doc + top 3 pain points from Steps 1+2
Explore: problem -> solution directions -> feasibility branches -> ranked concepts
Generate 5-10 concepts, evaluate on: uniqueness, build complexity, monetization path

**Output:** `docs/ideate/brainstorm-output.md`

> **DECISION GATE:** "Which concept do you want to pursue? Pick one before PRD."

---

### Step 4 — PRD Creation
**SADD:** `do-and-judge` — Read `~/.claude/skills/archive/do-and-judge/GUIDE.md`
**Skill:** `/plan-ceo-review` (SCOPE EXPANSION mode)

Input: chosen concept from Step 3 + design doc from Step 0
Execute: generate full PRD (problem statement, personas, solution, success metrics, user stories high-level, out of scope, risks)
Judge threshold: >= 4/5 on (problem clarity . market size . differentiation . feasibility)
If below threshold: revise and re-judge (max 2 iterations)

**Output:** `docs/ideate/prd.md`

---

### Step 5 — Competitive Analysis
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (one agent per competitor)
**Skills:** `/browse` + `pm/company-research` + `marketing/competitor-alternatives`

For each direct and indirect competitor:
- Features, pricing, positioning, reviews, recent updates
- Map gaps: what do users complain about? What's missing?

**Output:** `docs/ideate/competitive-analysis.md`

---

### Step 6 — Market Sizing + Context
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` (sequential — each feeds next)
**Skills:** `pm/tam-sam-som-calculator` -> `pm/pestel-analysis` -> `pm/jobs-to-be-done`

- TAM/SAM/SOM with citation-backed estimates
- PESTEL: political, economic, social, tech, environmental, legal factors
- JTBD: functional, social, emotional jobs; pains and gains

**Output:** `docs/ideate/tam-sam-som.md`, `pestel.md`, `jtbd.md`

---

### Step 7 — Positioning
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md`
**Skills:** `pm/discovery-process` -> `pm/positioning-statement`

- Compressed discovery: validate problem, identify who to talk to, synthesize
- Positioning: "For [target], who [need], [product] is a [category] that [benefit], unlike [alternatives], we [differentiator]"

**Output:** `docs/ideate/positioning.md`

---

### Step 8 — Go / No-Go Decision
**SADD:** `judge-with-debate` — Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md`
**Skill:** `finance/financial-analyst` — Read `~/.claude/skills/finance/financial-analyst/GUIDE.md`

Agent A argues FOR: market size, pain strength, differentiation, timing
Agent B argues AGAINST: competition intensity, complexity, resource requirements
Agent C judges: synthesizes verdict with evidence

**Output:** `docs/ideate/go-no-go.md`

> **DECISION GATE:** "Go or No-Go?
> Go -> `/phase-2-design`
> No-Go -> back to Step 0 with new constraints"

---

### Step 9 — Phase Journal
Write `docs/ideate/claude.md`:
- Problem selected + top 3 evidence signals
- Solution direction chosen
- Positioning decision
- Go/no-go rationale
- Market validation summary
- Key competitive risks accepted
- Open questions for Phase 2

> **DECISION GATE:** "Go decision made? -> `/phase-2-design`"

---

## Escape Protocol
If this phase discovers the idea is fundamentally flawed:
1. PAUSE and document the finding in phase journal
2. Return to Step 0 (/office-hours) with new constraints
3. Re-run from Step 0 forward

## Supporting skills (use as needed)
- `doc-coauthoring` — structured co-authoring for PRDs, design docs, positioning docs, go/no-go docs — Read `~/.claude/skills/doc-coauthoring/SKILL.md`
- `content-research-writer` — synthesize research across multiple sources — Read `~/.claude/skills/archive/content-research-writer/GUIDE.md`
- `article-extractor` — extract content from URLs linked in Reddit threads — Read `~/.claude/skills/archive/article-extractor/GUIDE.md`
- `notebooklm` — citation-backed synthesis of uploaded research docs — Read `~/.claude/skills/archive/notebooklm/GUIDE.md`
- `yt-transcript-download` — transcribe YouTube videos found in research — Read `~/.claude/skills/archive/yt-transcript-download/GUIDE.md`
- `pm/problem-statement` — sharpen problem framing before brainstorm — Read `~/.claude/skills/pm/problem-statement/GUIDE.md`
- `pm/proto-persona` — hypothesis-driven persona creation — Read `~/.claude/skills/pm/proto-persona/GUIDE.md`
- `finance/saas-metrics-coach` — early unit economics sanity check — Read `~/.claude/skills/archive/saas-metrics-coach/GUIDE.md`
- `pm/product-strategy-session` — full strategic planning workshop
- `pm/business-health-diagnostic` — overall viability check
- `pm/finance-based-pricing-advisor` — pricing strategy
- `pm/acquisition-channel-advisor` — growth channel identification
- `pm/roadmap-planning` — initial roadmap sketch — Read `~/.claude/skills/pm/roadmap-planning/GUIDE.md`

## Output contract
**Required for all downstream phases:**
- `docs/ideate/design-doc.md`
- `docs/ideate/prd.md`
- `docs/ideate/competitive-analysis.md`
- `docs/ideate/positioning.md`
- `docs/ideate/go-no-go.md`
- `docs/ideate/claude.md`

## Next phase
`/phase-2-design`
