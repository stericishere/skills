---
name: (workflow) phase-2-design
description: Phase 2 DESIGN — frontend design prompt generation + architecture (ADRs, engineering review, software-architecture principles)
---

## Design Pattern
**Pipeline** (sequential steps with gates) + **Generator** (design prompt creation) + **Reviewer** (architecture evaluation via judge-with-debate)

## Upstream reads
- `docs/ideate/prd.md`
- `docs/ideate/design-doc.md`
- `docs/ideate/positioning.md`
- `docs/ideate/claude.md`

## Steps

### Part A — Frontend Design Prompt

### Step 1 — Generate Design Prompt
**Skill:** `/design-consultation` (for design system if none exists)

Generate a detailed product description + design style/feeling prompt that the user will take to an external design tool (Google Stitch, Figma, v0, etc.).

The prompt must include:
- **Product purpose:** what the product does and why it exists
- **Target users:** who will use it, their context, their sophistication
- **Brand personality:** professional/playful, minimal/rich, trustworthy/edgy, etc.
- **Visual direction:** color palette suggestions, typography style, layout approach, mood/feeling
- **Key screens/flows:** list of critical screens (landing, dashboard, onboarding, settings, etc.)
- **Interaction patterns:** navigation style, form patterns, feedback mechanisms
- **Platform considerations:** web (Next.js), mobile (Expo), iOS native (SwiftUI) — specify which

The user takes this prompt externally to produce the final design. They provide it back in Phase 3 (Build) as reference material for implementation.

**NO Figma extraction. NO do-competitively design generation. Just the prompt.**

**Output:** `docs/design/design-prompt.md`

> **DECISION GATE:** "Design prompt approved? User takes it to external tool. Proceed to architecture."

---

### Part B — Architecture

### Step 2 — Architecture Design
**SADD:** `do-competitively` — Read `~/.claude/skills/archive/do-competitively/GUIDE.md`
**Skills:** `software-architecture` + `/plan-eng-review`

Load `software-architecture` as design principles context (Clean Architecture, DDD, separation of concerns, library-first approach).

2-3 agents propose competing architectures based on PRD + design constraints.
Each covers: system diagram, data flow, component breakdown, scaling approach, security model.

Stack defaults (override per project):
- Web: Next.js + Supabase
- Mobile: Expo + Supabase
- iOS: SwiftUI + Supabase
- Auth: Supabase Auth
- Payments: Stripe

**Output:** 2-3 architecture proposals for review

---

### Step 3 — Engineering Review + Decision
**SADD:** `judge-with-debate` — Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md`
**Skill:** `/plan-eng-review`

Agent A: advocates Architecture Option A
Agent B: advocates Architecture Option B
Agent C: judges on (scalability . complexity . speed-to-ship . security . DDD alignment)

**Output:** `docs/design/eng-review.md`

> **DECISION GATE:** "Which architecture? Lock decision before writing ADRs."

---

### Step 4 — Write ADRs
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` (each ADR reads previous before writing)
**Skill:** `architecture-decision-records` — Read `~/.claude/skills/archive/architecture-decision-records/GUIDE.md`

For each major decision, use `judge-with-debate` — Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md` to resolve competing options before writing the ADR.

In order:
1. `adr/001-framework.md` — Next.js / Expo / SwiftUI choice + rationale
2. `adr/002-database.md` — Supabase + schema approach
3. `adr/003-auth.md` — Auth strategy (Supabase Auth, OAuth providers)
4. `adr/004-state-management.md` — Client state approach
5. `adr/005-api-design.md` — API patterns (Server Actions, REST, RPC)

Each ADR format: Context -> Decision Drivers -> Options Considered -> Decision -> Consequences

**ADR Governance:** ADRs are immutable once accepted. To change a decision, write a new ADR that supersedes the old one — never edit an accepted ADR.

**Output:** `docs/design/adr/001-005.md`

---

### Step 5 — Phase Journal
Write `docs/design/claude.md`:
- Design prompt summary (what was sent to external tool)
- Stack finalized
- Key trade-offs accepted
- Deployment targets confirmed
- Known technical debt accepted upfront

> **DECISION GATE:** "Architecture locked? -> `/phase-3-build`"

---

## Escape Protocol
If architecture decisions conflict with positioning from Phase 1:
1. PAUSE and document the conflict in phase journal
2. Route back to `/phase-1-ideate` to re-validate positioning
3. Re-run Phase 2 with updated constraints

## ADR Update Protocol (used in Phase 3+)
If implementation requires deviating from any ADR:
1. PAUSE implementation
2. Supersede the affected ADR (don't edit — write new ADR referencing old)
3. Log change in `docs/build/adr-changes.md`
4. Get approval before continuing

## Supporting skills (use as needed)
- `doc-coauthoring` — structured co-authoring for design prompts, ADRs, eng review docs — Read `~/.claude/skills/doc-coauthoring/SKILL.md`
- `langchain-architecture` — if building AI/LLM features — Read `~/.claude/skills/tech-stack/langchain-architecture/GUIDE.md`
- `pm/context-engineering-advisor` — if building AI context pipelines
- `docker-patterns` — containerization decisions — Read `~/.claude/skills/tech-stack/docker-patterns/GUIDE.md`
- `deployment-patterns` — deployment architecture — Read `~/.claude/skills/tech-stack/deployment-patterns/GUIDE.md`
- `component-refactoring` — if iterating on existing components — Read `~/.claude/skills/archive/component-refactoring/GUIDE.md`
- `cache-components` — Next.js-specific caching patterns — Read `~/.claude/skills/tech-stack/cache-components/GUIDE.md`

## Output contract
**Required for all downstream phases:**
- `docs/design/design-prompt.md`
- `docs/design/adr/` (all ADRs)
- `docs/design/eng-review.md`
- `docs/design/claude.md`

## Next phase
`/phase-3-build`
