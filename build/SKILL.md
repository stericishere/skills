---
name: build
description: "End-to-end build workflow orchestrator. Chains 7 stages automatically: check → brief → plan → execute → verify → simplify → review-ship. Use when the user says 'build', '/build', 'start the build', 'run the build workflow', or wants to go from idea to shipped PR in one command."
user-invocable: true
args:
  - name: from
    description: "Stage to start from (check, brief, plan, execute, verify, simplify, ship). Default: auto-detect or check."
    required: false
  - name: to
    description: "Stage to stop after (check, brief, plan, execute, verify, simplify, ship). Default: ship."
    required: false
---

# Build — End-to-End Workflow Orchestrator

You are the build pipeline controller. Your job is to drive work through **7 sequential stages**, gating each transition on the previous stage's output.

## Pipeline

```
 1. CHECK ─→ 2. BRIEF ─→ 3. PLAN ─→ 4. EXECUTE ─→ 5. VERIFY ─→ 6. SIMPLIFY ─→ 7. SHIP
    │             │            │            │              │              │            │
 check.md    brief.md     plan.md    execute.md      verify.md     simplify.md  review-ship.md
```

All stage docs live in `docs/build/`.

## Stage Map

| # | Stage | Skill to load | Gate (must exist before entry) | Output |
|---|-------|---------------|-------------------------------|--------|
| 1 | CHECK | `~/.claude/skills/build/archive/build-check/SKILL.md` | — | `docs/build/check.md` |
| 2 | BRIEF | `~/.claude/skills/build/archive/build-brief/SKILL.md` | `check.md` | `docs/build/brief.md` |
| 3 | PLAN | `~/.claude/skills/build/archive/build-plan/SKILL.md` | `brief.md` | `docs/build/plan.md` |
| 4 | EXECUTE | `~/.claude/skills/build/archive/build-execute/SKILL.md` | `plan.md` | `docs/build/execute.md` |
| 5 | VERIFY | `~/.claude/skills/build/archive/build-verify/SKILL.md` | `execute.md` | `docs/build/verify.md` |
| 6 | SIMPLIFY | `~/.claude/skills/build/archive/build-simplify/SKILL.md` | `verify.md` | `docs/build/simplify.md` |
| 7 | SHIP | `~/.claude/skills/build/archive/build-review-ship/SKILL.md` | `simplify.md` | `docs/build/review-ship.md` |

## Auto-Detect Start Stage

If `from` is not specified, detect where to resume:

1. Check which `docs/build/*.md` files already exist.
2. Find the **latest completed stage** (the highest stage whose doc exists and shows a passing status).
3. Start from the **next** stage.
4. If no docs exist, start from CHECK.

Show the user what was detected:

```
BUILD PIPELINE
══════════════════════════════════════════════
 ✅ CHECK    → done (docs/build/check.md)
 ✅ BRIEF    → done (docs/build/brief.md)
 ▶  PLAN     → starting here
 ○  EXECUTE
 ○  VERIFY
 ○  SIMPLIFY
 ○  SHIP
══════════════════════════════════════════════
```

## Running Each Stage

For each stage in sequence:

### 1. Announce

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 STAGE 3/7: PLAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 2. Load the skill

Read the stage's SKILL.md file from the table above. Follow its full instructions.

### 3. Execute the stage

Run the stage's process end-to-end. Each stage writes its output doc.

### 4. Gate check

Before advancing to the next stage, verify:
- The output doc exists and is populated
- The stage did not flag a blocker or failure
- No routing back to a previous stage is required

### 5. Advance or loop

- **If the stage passes** — announce completion and advance to the next stage.
- **If the stage fails or routes backward** — follow the routing instruction in the stage's SKILL.md (e.g., verify can route back to execute).
- **If the stage escalates** — stop the pipeline and report to the user.

## Fix Loop Integration

Between EXECUTE and VERIFY, the `fix` skill runs as an internal loop:

```
EXECUTE → fix (review → fix → simplify loop) → VERIFY
```

After EXECUTE completes, load `~/.claude/skills/fix/SKILL.md` and run its full process. Only advance to VERIFY when fix reports green.

The full effective chain is:
```
CHECK → BRIEF → PLAN → EXECUTE → [fix loop] → VERIFY → SIMPLIFY → SHIP
```

## Backward Routing

Some stages can route backward. Honor these:

| From | Condition | Route to |
|------|-----------|----------|
| VERIFY | correctness/QA/design fails | EXECUTE (then fix loop again) |
| SIMPLIFY | behavior-sensitive changes | VERIFY |

Track backward routing in `docs/build/routing-log.md`:
```
[timestamp] VERIFY → EXECUTE: QA found 2 broken flows
[timestamp] EXECUTE → fix: re-entering fix loop
[timestamp] fix → green
[timestamp] VERIFY: all checks pass
```

## Stop Conditions

The pipeline stops when:
1. The `to` stage completes (if specified)
2. SHIP completes (default end)
3. A stage escalates with an unresolvable blocker
4. The user interrupts

## Pipeline Summary

After the final stage (or after stopping), write `docs/build/claude.md`:

```markdown
# Build Summary

## Pipeline Run
- Started: [stage] at [timestamp]
- Ended: [stage] at [timestamp]
- Backward routes: [count]

## Stages
| Stage | Status | Doc |
|-------|--------|-----|
| CHECK | pass | check.md |
| BRIEF | pass | brief.md |
| ... | ... | ... |

## Outcome
[shipped / blocked / stopped at stage X]

## PR
[link if created]
```

## Execution Model — Orchestrate, Don't Code

**The main /build session never writes implementation code directly. It orchestrates.**

During EXECUTE (and any backward-routed re-execution), the main session:
1. Breaks the plan into file-level tasks (each task = one file or tightly-coupled file pair)
2. Invokes `/orchestrate` which creates an Agent Team (`TeamCreate`)
3. Dispatches tasks to teammates in parallel — check `~/.claude/agents/{domain}/` for matching `subagent_type`
4. Monitors progress via `TaskList`/`SendMessage`, unblocks teammates as needed
5. When all teammates finish, reviews the combined diff, commits the slice
6. Shuts down teammates, `TeamDelete`

The main session's job during implementation stages is:
- Decompose → Dispatch → Monitor → Integrate → Commit

Never fall back to coding in the main session. If a task is too small for a teammate, batch it with related files into one teammate's scope.

This applies to the EXECUTE stage, the fix loop, and any SIMPLIFY changes that require code edits. CHECK, BRIEF, PLAN, VERIFY, and SHIP are coordination stages that run in the main session.

## Rules

- **Main session orchestrates, never codes** — all implementation via Agent Teams + `/orchestrate`
- **Never skip a stage** — every stage must run and produce its doc
- **Never skip the fix loop** — it always runs between EXECUTE and VERIFY
- **Gate strictly** — do not advance without the previous stage's output doc
- **Announce every transition** — the user must always know which stage is active
- **Track all backward routes** — log every loop in routing-log.md
- **Respect `to` arg** — stop after the specified stage, do not continue
