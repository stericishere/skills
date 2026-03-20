---
name: (workflow) phase-5-iterate
description: Phase 5 ITERATE — triage (RICE), priority conflicts (judge-with-debate), route to correct phase, retrospective, self-improving-agent
---

## Design Pattern
**Pipeline** (sequential triage -> route -> learn) + **Reviewer** (RICE scoring + judge-with-debate for conflicts)

## Upstream reads
All previous phase `claude.md` journals:
- `docs/ideate/claude.md`
- `docs/design/claude.md`
- `docs/build/claude.md`
- `docs/launch/claude.md` (metrics baseline)
- Own memory: `docs/iterate/memory/MEMORY.md`
- Phase 4 memory: `docs/launch/memory/` (launch context)

## Context-Aware Initialization

```
IF docs/iterate/memory/MEMORY.md exists AND has entries:
  -> Resume: read existing memories, skip init, go straight to Step 1 (triage)

IF docs/iterate/memory/MEMORY.md does NOT exist or is empty (first-time init):
  -> Read ALL phase journals (docs/*/claude.md) to build initial context
  -> Write triage -> docs/iterate/memory/decisions/triage-[date].md
  -> /retro findings -> docs/iterate/memory/learnings/retro-[date].md
  -> Routing -> docs/iterate/memory/decisions/routing-[date].md
  -> self-improving-agent promotes to global CLAUDE.md/.claude/rules/
  -> Initialize docs/iterate/memory/MEMORY.md index
```

Subsequent cycles append — no full re-read.

## Steps

### Step 1 — Triage All Requests
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (score each request independently)
**Skill:** `pm/prioritization-advisor` — Read `~/.claude/skills/pm/prioritization-advisor/GUIDE.md`

Score every incoming feature request against RICE:
- Reach: how many users affected?
- Impact: how much does it move the key metric?
- Confidence: how sure are we about reach + impact?
- Effort: how many person-weeks?

**Output:** `docs/iterate/triage.md` + `docs/iterate/memory/decisions/triage-[date].md`

---

### Step 2 — Resolve Priority Conflicts
**SADD:** `judge-with-debate` — Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md` (only when top-scored features compete for same slot)
**Skill:** `pm/feature-investment-advisor` — Read `~/.claude/skills/pm/feature-investment-advisor/GUIDE.md`

Agent A: argues for Feature X (user demand, revenue)
Agent B: argues for Feature Y (strategic fit, technical debt reduction)
Agent C: judges and recommends

**Output:** Appended to `triage.md`

---

### Step 3 — Route to Correct Phase
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md`
**Skill:** `pm/recommendation-canvas` — Read `~/.claude/skills/pm/recommendation-canvas/GUIDE.md`

For each prioritized item:
```
New feature            -> /phase-3-build (create feature spec)
Enhancement/bugfix     -> /phase-3-build (directly to plan)
Architecture change    -> /phase-2-design (update ADRs first)
Market/strategy pivot  -> /phase-1-ideate (re-validate positioning)
Design overhaul        -> /phase-2-design (update design system)
```

**Output:** `docs/iterate/routing.md` + `docs/iterate/memory/decisions/routing-[date].md`

---

### Step 4 — Update Roadmap
**Skills:** `pm/roadmap-planning` (Read `~/.claude/skills/pm/roadmap-planning/GUIDE.md`) + `pm/epic-hypothesis` (Read `~/.claude/skills/pm/epic-hypothesis/GUIDE.md`)

Update the product roadmap with routed items.
Write new epic hypotheses for items going to Phase 3.

**Output:** `docs/iterate/roadmap-update.md`

---

### Step 5 — Retrospective
**Skill:** `/retro`

Assess: velocity . code quality signals . session patterns . what worked / what didn't
Track trends over time with persistent history.

**Output:** `docs/iterate/memory/learnings/retro-[date].md`

---

### Step 6 — Capture Learnings
**Skill:** `self-improving-agent`

Run in order:
1. `self-improving-agent/review` — analyze MEMORY.md for promotion candidates
2. `self-improving-agent/promote` — graduate proven patterns to CLAUDE.md / .claude/rules/
3. `self-improving-agent/extract` — extract reusable skills from successful patterns
4. `self-improving-agent/remember` — persist key learnings cross-session

---

### Step 7 — Phase Journal
Write `docs/iterate/claude.md`:
- Triage summary
- Routing decisions
- Roadmap changes
- Learnings promoted to global memory

> **DECISION GATE:** "Items routed. Start next cycle at the appropriate phase."

---

## Escape Protocol
Not applicable — this phase IS the routing mechanism. Items are routed to the correct phase based on triage.

## Supporting skills (use as needed)
- `doc-coauthoring` — structured co-authoring for triage reports, roadmap updates, phase journals — Read `~/.claude/skills/doc-coauthoring/SKILL.md`
- `marketing/churn-prevention` — retention signals informing feature decisions
- `marketing/revops` — revenue operations analysis
- `finance/saas-metrics-coach` — SaaS health metrics — Read `~/.claude/skills/archive/saas-metrics-coach/GUIDE.md`

## Output contract
- `docs/iterate/triage.md`
- `docs/iterate/routing.md`
- `docs/iterate/roadmap-update.md`
- `docs/iterate/claude.md`
- `docs/iterate/memory/decisions/triage-[date].md`
- `docs/iterate/memory/decisions/routing-[date].md`
- `docs/iterate/memory/learnings/retro-[date].md`

## Next phase
Loop back to whichever phase items were routed to.
