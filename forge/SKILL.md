---
name: forge
description: "Full lifecycle workflow combining three constraint systems: Superpowers (process), GSD (environment), gstack (perspective). 7 phases: Think → Plan → Build → Review → Test → Ship → Optimize. Use when starting a new feature, product, or project from scratch. Triggers: 'forge', '/forge', 'full workflow', 'build something amazing', 'start a new feature end-to-end'."
user-invocable: true
args:
  - name: from
    description: "Phase to start from (think, plan, build, review, test, ship, optimize). Default: auto-detect."
    required: false
  - name: to
    description: "Phase to stop after. Default: ship."
    required: false
---

# Forge — Three-Constraint Development Workflow

You orchestrate the full product development lifecycle by applying three complementary constraint systems at each phase:

| Constraint | Source | What it controls | When it matters |
|------------|--------|-----------------|-----------------|
| **Process** | Superpowers | How work is done — TDD, structured steps, checkpoints | BUILD phase |
| **Environment** | GSD | Where work happens — clean contexts, isolated tasks, persistent state | BUILD phase |
| **Perspective** | gstack | Who decides — role-focused thinking, quality gates, data flow | THINK, PLAN, REVIEW, TEST, SHIP |

## Pipeline

```
 ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌──────────┐
 │  THINK  │───▶│  PLAN   │───▶│  BUILD  │───▶│ REVIEW  │───▶│  TEST   │───▶│  SHIP   │───▶│ OPTIMIZE │
 │ 视角约束 │    │视角+过程│    │过程+环境│    │ 视角约束 │    │ 视角约束 │    │过程+视角│    │ 环境约束  │
 └─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘    └──────────┘
   gstack         gstack       Superpowers      gstack         gstack        gstack        auto-research
                               + GSD                                                        loop
```

All phase docs live in `docs/forge/`.

## Phase Details

### Phase 1: THINK (Perspective Constraint)

**Goal:** Challenge assumptions, find the real problem, validate the idea before any code.

**Constraint applied:** gstack role governance — use the right perspective to think.

**Steps:**
1. Load `gstack:/office-hours` — run the full brainstorming session
   - Startup mode: 6 forcing questions (demand reality, status quo, desperate specificity, narrowest wedge, observation, future-fit)
   - Builder mode: design thinking for side projects
2. Load `gstack:/plan-ceo-review` — CEO/founder challenge
   - Pick mode: SCOPE EXPANSION, SELECTIVE EXPANSION, HOLD SCOPE, or SCOPE REDUCTION
   - Challenge premises, find the 10-star product
3. Save output to `docs/forge/think.md`

**Gate:** User confirms the direction before proceeding.

### Phase 2: PLAN (Perspective + Process Constraint)

**Goal:** Lock in architecture, data flow, edge cases, and design before touching code.

**Constraint applied:** gstack roles for perspective + Superpowers discipline for structured planning.

**Steps:**
1. Load `gstack:/plan-eng-review` — engineering review
   - Architecture decisions, data flow diagrams, edge cases, test coverage plan, performance considerations
   - Interactive walkthrough with opinionated recommendations
2. Load `gstack:/plan-design-review` — design review (if UI involved)
   - Rate each design dimension 0-10, explain what makes it a 10, fix the plan
3. Generate a **Superpowers-style implementation plan**:
   - Every file to change, expected outcome per step, verification method
   - Task decomposition into atomic units (for GSD isolation in BUILD)
   - Test specifications written BEFORE implementation begins
4. Save output to `docs/forge/plan.md`

**Gate:** User approves the plan. No code until approved.

### Phase 3: BUILD (Process + Environment Constraint)

**Goal:** Execute the plan with maximum discipline and clean contexts.

This is where the three frameworks converge. The video identified this as gstack's gap — we fill it.

**Process Constraint (Superpowers):**
- **Test-Driven Development** — write tests FIRST for each task, then implement to pass
- **Structured execution** — follow the plan step-by-step, no freelancing
- **Checkpoint verification** — verify each step before advancing

**Environment Constraint (GSD):**
- **Context isolation** — each task runs in a fresh Agent Team teammate with clean context
- **Persistent state** — all progress tracked in `docs/forge/build-log.md`, survives session restarts
- **Main session stays light** — orchestrator only dispatches, never does heavy lifting (keep under 40% context)

**Execution protocol:**

```
For each task in the plan:
  1. Create teammate with clean context (GSD: fresh instance)
  2. Pass: task spec + test spec + relevant source files only (GSD: minimal context)
  3. Teammate writes tests first (Superpowers: TDD)
  4. Teammate implements to pass tests (Superpowers: structured)
  5. Teammate runs tests + verifies (Superpowers: checkpoint)
  6. If pass → commit atomically, log to build-log.md
  7. If fail → teammate fixes in-place (no context pollution to main)
  8. Return result to orchestrator
```

**Parallel execution:** Independent tasks run simultaneously via Agent Teams. Dependent tasks run sequentially.

**Save:** `docs/forge/build-log.md` (per-task results) + `docs/forge/execute.md` (summary)

**Gate:** All tasks pass. Build log shows green across the board.

### Phase 4: REVIEW (Perspective Constraint)

**Goal:** Catch issues the builder missed, using different perspectives.

**Constraint applied:** gstack role governance — reviewer sees what the builder can't.

**Steps:**
1. Load `gstack:/review` — pre-landing PR review
   - SQL safety, LLM trust boundaries, conditional side effects, structural issues
   - Analyzes diff against base branch
2. Load `gstack:/design-review` (if UI) — visual design audit
   - Catch generic AI aesthetics, ensure design quality
3. Save findings to `docs/forge/review.md`

**Gate:** All critical/high issues resolved. Medium issues documented for follow-up.

### Phase 5: TEST (Perspective Constraint)

**Goal:** Verify from a real user's perspective — not just unit tests, but actual usage.

**Constraint applied:** gstack's QA role thinks like a user, not a developer.

**Steps:**
1. Load `gstack:/qa` — full QA test cycle
   - Opens real browser, navigates the app as a user
   - Finds bugs, takes screenshots, produces health score
   - Iteratively fixes bugs found, re-verifies
2. Save report to `docs/forge/test.md`

**Gate:** Health score meets threshold. Critical bugs fixed.

### Phase 6: SHIP (Process + Perspective Constraint)

**Goal:** Ship with confidence — version, changelog, PR, deploy, verify production.

**Constraint applied:** gstack roles + structured shipping process.

**Steps:**
1. Load `gstack:/ship` — create PR
   - Merge base branch, run tests, review diff, bump VERSION, update CHANGELOG
2. Load `gstack:/land-and-deploy` — merge and verify production
   - Wait for CI and deploy
   - Run canary health checks
3. Load `gstack:/document-release` — update docs post-ship
4. Save to `docs/forge/ship.md`

**Gate:** Production canary passes. Docs updated.

### Phase 7: OPTIMIZE (Environment Constraint — Optional)

**Goal:** Unattended, metric-driven continuous improvement after shipping.

Inspired by Karpathy's auto-research pattern: measure → modify → measure → keep or reset → loop.

**Constraint applied:** GSD-style isolation (each experiment in clean context) + quantifiable metrics (no fuzzy judgment).

**Protocol:**
```
1. Define target metric(s):
   - Test coverage % (e.g., from 72% → 90%)
   - Lighthouse score (e.g., from 68 → 90)
   - Bundle size (e.g., from 2.1MB → 1.5MB)
   - Page load time, error rate, etc.

2. Loop (N experiments, or until metric target reached):
   a. Measure current metric → save baseline
   b. Spawn teammate with clean context (GSD: isolation)
   c. Teammate makes ONE targeted change to improve metric
   d. Run tests + measure metric again
   e. If metric improved AND tests pass → commit, log improvement
   f. If metric didn't improve OR tests broke → git reset, discard
   g. Log experiment result either way

3. Output: optimization report with:
   - Starting vs final metric values
   - Each experiment attempted (pass/fail/delta)
   - Total improvement achieved
```

**Save:** `docs/forge/optimize.md`

**This phase is optional** — invoke with `/forge optimize` or runs if `to=optimize`.

## Auto-Detect Start Phase

If `from` is not specified:
1. Check which `docs/forge/*.md` files exist
2. Find the latest completed phase
3. Start from the next phase

Show status:
```
FORGE PIPELINE
══════════════════════════════════════════════
 ✅ THINK    → done (docs/forge/think.md)
 ✅ PLAN     → done (docs/forge/plan.md)
 ▶  BUILD    → starting here
 ○  REVIEW
 ○  TEST
 ○  SHIP
 ○  OPTIMIZE
══════════════════════════════════════════════
Constraints: Process ⚙️ | Environment 🧊 | Perspective 👁️
```

## Context Budget Rules (GSD Principle)

The orchestrator (this session) must stay lean:

| Role | Max context usage | What it does |
|------|------------------|-------------|
| Orchestrator (you) | < 40% | Dispatch tasks, read results, advance pipeline |
| Teammate (build) | 100% then dispose | Execute one task, return result, terminate |
| Teammate (optimize) | 100% then dispose | Run one experiment, return metric, terminate |

**Never** do heavy work in the orchestrator. Always dispatch to teammates.

**Persist everything** to `docs/forge/` — if the session dies, a new session reads the docs and resumes.

## Backward Routing

| From | Condition | Route to |
|------|-----------|----------|
| REVIEW | Critical architecture issues found | PLAN |
| TEST | Bugs require design changes | BUILD |
| SHIP | Canary fails | TEST |
| OPTIMIZE | Metric target unreachable | SHIP (accept current state) |

## Pipeline Summary

After completion, write `docs/forge/summary.md`:

```markdown
# Forge Summary

## What was built
[one paragraph]

## Constraints applied
- Process: [TDD, structured execution, N checkpoints]
- Environment: [M teammates spawned, context isolation maintained]
- Perspective: [roles used: office-hours, plan-eng-review, review, qa, ship]

## Metrics
- Tests: [pass/total]
- Coverage: [%]
- QA health: [score]
- Time: [start → ship]

## Experiments (if OPTIMIZE ran)
- [N] experiments, [M] improvements, [metric] went from [X] → [Y]
```

## Quick Start Examples

```
/forge                    — Full pipeline from THINK
/forge from=build         — Skip to BUILD (plan already approved)
/forge from=review to=ship — Review → Test → Ship only
/forge optimize           — Run optimization loop on shipped code
```
