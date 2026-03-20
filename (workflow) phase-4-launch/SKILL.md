---
name: (workflow) phase-4-launch
description: Phase 4 LAUNCH — marketing launch strategy, copy, multi-channel content, analytics, A/B testing, CRO, /ship deployment, platform pipelines
---

## Design Pattern
**Pipeline** (sequential launch preparation with sub-stage checkpoints) + **Generator** (content creation across channels)

## Upstream reads
- `docs/ideate/prd.md`
- `docs/ideate/design-doc.md`
- `docs/ideate/positioning.md`
- `docs/ideate/competitive-analysis.md`
- `docs/design/adr/` (stack decisions for deployment)
- `docs/design/claude.md` (deployment targets)
- `docs/build/claude.md` (includes review findings)
- Own memory: `docs/launch/memory/MEMORY.md`
- Own checkpoints: `docs/launch/memory/checkpoints/` (resume from last sub-stage)

## Testing Boundaries
- **Phase 3 (Build)** = TDD + functional QA + code review + PR merge
- **Phase 4 (Launch)** = conversion testing ONLY — analytics, A/B tests, CRO

## Steps

### Sub-stage A: Marketing

On resume: check `docs/launch/memory/checkpoints/launch-marketing.md` — skip completed steps.

---

#### Step 1 — Launch Strategy
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md`
**Skill:** `marketing/launch-strategy` — Read `~/.claude/skills/marketing/launch-strategy/GUIDE.md`

Design 5-phase launch using ORB Framework (Owned . Rented . Borrowed channels):
1. Internal (team/close circle)
2. Alpha (controlled access, 10-50 users)
3. Beta (broader buzz, 50-500 users)
4. Early access (scale-up, waitlist)
5. Full launch

**Output:** `docs/launch/launch-plan.md`

---

#### Step 2 — Copy
**SADD:** `do-competitively` — Read `~/.claude/skills/archive/do-competitively/GUIDE.md`
**Skill:** `marketing/copywriting` — Read `~/.claude/skills/marketing/copywriting/GUIDE.md`

3 agents write competing versions of:
- Landing page headline + subheadline
- Value proposition statement
- CTA button text
- Tagline

Judge on: clarity . conversion principles . brand voice . positioning alignment
Winner -> proceed

**Output:** `docs/launch/copy.md`

---

#### Step 3 — Multi-channel Content
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (all independent)
**Skills:**
- `marketing/seo-audit` (Read `~/.claude/skills/marketing/seo-audit/GUIDE.md`) + `marketing/ai-seo` -> SEO strategy
- `marketing/content-strategy` -> content calendar
- `marketing/social-content` -> social media content
- `twitter-algorithm-optimizer` (Read `~/.claude/skills/archive/twitter-algorithm-optimizer/GUIDE.md`) -> Twitter/X optimization

**Output:** `docs/launch/seo-audit.md`, `content-calendar.md`, `social-strategy.md`

---

**Checkpoint:** Write `docs/launch/memory/checkpoints/launch-marketing.md`
Record: what was completed, what remains, key decisions made.

---

### Sub-stage B: Testing

On resume: check `docs/launch/memory/checkpoints/launch-testing.md` — skip completed steps.

---

#### Step 4 — Analytics Setup
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` (sequential — layers depend on each other)
**Skill:** `marketing/analytics-tracking` — Read `~/.claude/skills/marketing/analytics-tracking/GUIDE.md`

1. Event taxonomy design (naming conventions)
2. GA4 custom events implementation
3. UTM strategy + campaign tagging
4. Conversion tracking (primary + secondary + guardrail metrics)

Must be complete before running any A/B tests.
**Output:** `docs/launch/analytics-setup.md`

---

#### Step 5 — A/B Test Design
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (each test is independent)
**Skill:** `marketing/ab-test-setup` — Read `~/.claude/skills/marketing/ab-test-setup/GUIDE.md`

For each hypothesis:
- State hypothesis clearly
- Calculate required sample size
- Design control vs variant
- Define primary metric . secondary metrics . guardrail metrics
- Set minimum detectable effect

**Output:** `docs/launch/ab-tests/[test-name].md` per test

---

#### Step 6 — CRO Audit
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md`
**Skills (run simultaneously):**
- `marketing/page-cro` — landing page conversion
- `marketing/onboarding-cro` — onboarding flow
- `marketing/signup-flow-cro` — signup funnel
- `marketing/form-cro` — form optimization
- `marketing/popup-cro` — modal/popup optimization
- `marketing/paywall-upgrade-cro` — upgrade flow

**Output:** `docs/launch/cro-audit.md`

---

#### Step 7 — Results Analysis (after tests run with real data)
**SADD:** `judge` — Read `~/.claude/skills/archive/judge/GUIDE.md`
**Skills:** `finance/saas-metrics-coach` (Read `~/.claude/skills/archive/saas-metrics-coach/GUIDE.md`) + `pm/saas-revenue-growth-metrics`

Score winning variants — data-backed, no debate needed.
Calculate: conversion lift . statistical significance . revenue impact

**Output:** `docs/launch/results.md`

---

**Checkpoint:** Write `docs/launch/memory/checkpoints/launch-testing.md`
Record: what was completed, what remains, key decisions made.

---

### Sub-stage C: Deploy

On resume: check `docs/launch/memory/checkpoints/launch-deploy.md` — skip completed steps.

---

#### Step 8 — Ship
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` (sequential — each step depends on previous)
**Skill:** `/ship`

1. Pre-flight checks (lint, types, tests)
2. Merge origin/main
3. Run test suites (parallel within this step)
4. Version bump
5. Changelog generation
6. Bisectable commits
7. Push + create PR

**Output:** Merged PR, version tagged

---

#### Step 9 — Platform Pipelines
**SADD:** `do-in-parallel` — Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` (platforms are independent)

Enable based on project stack (check `docs/design/adr/`):

**Web (Next.js -> Vercel):**
- `deployment-patterns` — Read `~/.claude/skills/implementation-toolkit/backend/deployment-patterns/GUIDE.md`
- Env vars, preview deploys, production promotion
- Health checks + rollback config

**Mobile (Expo -> EAS):**
- `expo` — Read `~/.claude/skills/implementation-toolkit/frontend/expo/GUIDE.md`
- EAS Build for iOS + Android
- EAS Update for OTA updates
- TestFlight / Play Store submission

**iOS Native (SwiftUI -> TestFlight):**
- `ios` — Read `~/.claude/skills/implementation-toolkit/frontend/ios/GUIDE.md`
- Xcode Cloud or manual Xcode Archive
- TestFlight -> App Store

**Containerized:**
- `docker-patterns` — Read `~/.claude/skills/implementation-toolkit/backend/docker-patterns/GUIDE.md`
- Build, tag, push images
- Orchestration config

**Output:** `docs/launch/pipeline-config.md`

---

#### Step 10 — Post-Ship Documentation
**Skill:** `/document-release`

Update all project docs to match what shipped:
- README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md
- Polish CHANGELOG voice
- Clean up TODOs
- Optionally bump VERSION

---

**Checkpoint:** Write `docs/launch/memory/checkpoints/launch-deploy.md`
Record: what was completed, what remains, key decisions made.

---

### Step 11 — Phase Journal
Write `docs/launch/claude.md`:
- Launch timeline and phase gates
- Channel strategy and budget allocation
- KPIs per channel
- Analytics baseline established
- Pipeline configuration per platform
- Rollback procedure documented

> **DECISION GATE:** "Product live -> `/phase-5-iterate`"

---

## Escape Protocol
If marketing reveals positioning is wrong (e.g., copy doesn't resonate, SEO shows no demand):
1. PAUSE and document the finding in phase journal
2. Route back to `/phase-1-ideate` to re-validate positioning
3. Re-run Phase 4 with updated positioning

If CRO audit reveals fundamental UX issues:
1. PAUSE and document findings in phase journal
2. Route back to `/phase-2-design` for design fixes
3. Route through Phase 3 for implementation + review
4. Re-run Phase 4

If deployment reveals environment issues:
1. PAUSE and document in phase journal
2. If infra architecture issue -> route to `/phase-2-design` to update ADRs
3. If code issue -> route to `/phase-3-build`

## Supporting skills (use as needed)
- `doc-coauthoring` — structured co-authoring for launch plans, copy docs, strategy docs — Read `~/.claude/skills/doc-coauthoring/SKILL.md`
- `marketing/email-sequence` — onboarding + nurture email flows
- `marketing/paid-ads` + `marketing/ad-creative` — paid acquisition
- `marketing/lead-magnets` — lead generation assets
- `marketing/referral-program` — viral loop design
- `marketing/pricing-strategy` — pricing page optimization
- `marketing/schema-markup` + `marketing/site-architecture` — technical SEO
- `marketing/free-tool-strategy` — freemium/free tool strategy
- `marketing/product-marketing-context` — PMM context before writing
- `content-research-writer` — long-form content — Read `~/.claude/skills/archive/content-research-writer/GUIDE.md`
- `pm/press-release` — Amazon-style working backwards press release
- `marketing/churn-prevention` — retention analysis
- `pm/saas-economics-efficiency-metrics` — efficiency metrics
- `n8n` — workflow automation for recurring processes

## Output contract
**Required for Phase 5:**
- `docs/launch/launch-plan.md`
- `docs/launch/copy.md`
- `docs/launch/analytics-setup.md`
- `docs/launch/pipeline-config.md`
- `docs/launch/claude.md`
- `docs/launch/memory/checkpoints/launch-marketing.md`
- `docs/launch/memory/checkpoints/launch-testing.md`
- `docs/launch/memory/checkpoints/launch-deploy.md`

## Next phase
`/phase-5-iterate`
