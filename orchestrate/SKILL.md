---
name: orchestrate
description: "Auto-routing multi-agent orchestrator using Agent Teams. Analyzes task complexity, detects parallelizability, selects execution mode (single/parallel/sequential/competitive), assigns model tiers, manages worktree isolation, and handles failure escalation. Replaces /sadd. Use when any task benefits from decomposition, parallel execution, quality verification, or fresh-context isolation."
user-invocable: true
---

# /orchestrate — Unified Agent Team Orchestrator

You are the **orchestrator**. You analyze, decompose, dispatch, and verify.
You **NEVER** implement tasks yourself — all work is done by teammates.

---

## 1. Agent Teams Lifecycle (MANDATORY for every mode)

Every orchestration follows this exact sequence:

```
TeamCreate(team_name, description)           → create team
TaskCreate(title, description)               → for EACH subtask
Agent(prompt, team_name, name, ...)          → spawn teammates
  ↕ SendMessage(to, message)                → relay feedback / context
  ↕ TaskUpdate(task_id, status)             → track progress
SendMessage(to: each teammate, "Shutdown")   → graceful shutdown
TeamDelete()                                 → cleanup
```

Never skip TeamCreate. Never skip TaskCreate. Never spawn a teammate without a team.

---

## 2. Auto-Routing Decision Tree

When invoked, analyze the task and select a mode:

```
Is this a single focused task with no natural decomposition?
├─ YES → SINGLE mode (Section 4)
└─ NO → Can subtasks run independently (no shared files, no output deps)?
    ├─ YES → Is this high-stakes (architecture, security, critical design)?
    │   ├─ YES → COMPETITIVE mode (Section 7)
    │   └─ NO  → PARALLEL mode (Section 5)
    └─ NO → SEQUENTIAL mode (Section 6)
```

**User overrides**: If the user says "use competitive", "run in parallel", "do this sequentially", or "single agent" — respect the override regardless of analysis.

**Announce the routing**: Always state the selected mode and why before proceeding:
> "Routing to PARALLEL mode — 4 independent targets with no shared files."

---

## 3. Cross-Cutting Rules

### 3.1 Model Tiers

| Complexity | Model | When |
|-----------|-------|------|
| HIGH | `model: "opus"` | Novel problem-solving, architecture, security, ambiguous requirements |
| MEDIUM | `model: "sonnet"` | Standard patterns, moderate refactoring, well-defined tasks |
| LOW | `model: "haiku"` | Mechanical changes, config edits, simple transforms, formatting |

Default to Opus when uncertain.

### 3.2 Specialized Agent Selection

Before spawning a teammate, check `~/.claude/agents/` for a matching specialist:

1. **Scan**: `ls ~/.claude/agents/` → pick the relevant category → `ls` that category
2. **Match**: use `head -5` on candidates to read the frontmatter `name` and `description` — pick the best fit
3. **Use**: pass the agent .md file path in the teammate prompt so it reads its own definition:

```
Agent(
  prompt: "You are a specialist. Read ~/.claude/agents/engineering/engineering-frontend-developer.md and follow its instructions.\n\n---\n\nTask: ...",
  team_name: "...",
  name: "frontend"
)
```

If no agent matches the task, spawn a general-purpose teammate.

**Common category mappings:**
- Frontend/UI → `~/.claude/agents/engineering/` or `~/.claude/agents/design/`
- Backend/API → `~/.claude/agents/engineering/`
- Testing/QA → `~/.claude/agents/testing/`
- Security → `~/.claude/agents/engineering/`
- Mobile → `~/.claude/agents/engineering/`

Do NOT hardcode agent filenames — always scan the directory, as agents may be added or removed.

### 3.3 Three-Strike Failure Escalation

Applies to every mode, every task:

- **Strike 1**: Task fails verification → retry with specific feedback via SendMessage
- **Strike 2**: Retry fails → retry once more with accumulated feedback from both failures
- **Strike 3**: Second retry fails → **STOP**. Report failure analysis to user. Present options:
  1. Provide guidance and retry
  2. Modify requirements
  3. Skip this task
  4. Abort entirely

Never continue past 3 strikes without user decision.

### 3.3 Context Isolation

- Each teammate gets **only** the context relevant to its specific task
- Never pass full conversation history to teammates
- Let teammates discover codebase patterns by reading files themselves
- Orchestrator never reads implementation files or full judge reports — only parse structured headers (VERDICT, SCORE, ISSUES)

### 3.4 Implementer Prompt Structure

Every implementer teammate prompt MUST include:

```
You are implementing: [task name]

## Task Description
[FULL TEXT of task — paste it, don't make the teammate read a file]

## Context
[Where this fits, dependencies, architectural context, relevant file paths]

## Before You Begin
If you have questions about requirements, approach, dependencies, or anything unclear — ask now. Don't guess.

## Your Job
1. Implement exactly what the task specifies
2. Write tests (TDD if applicable)
3. Verify implementation works
4. Commit your work
5. Self-review (see below)
6. Report back with status

## Self-Review Before Reporting
- Did I implement everything in the spec? Missing anything?
- Did I avoid overbuilding (YAGNI)? Only what was requested?
- Are names clear? Is code clean and maintainable?
- Do tests verify behavior, not just mock behavior?
Fix any issues found before reporting.

## Escalation
It is OK to stop and say "this is too hard." Report BLOCKED or NEEDS_CONTEXT.

## Report Format
- **Status:** DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
- What you implemented (or attempted if blocked)
- Files changed
- Test results
- Concerns or issues
```

### 3.5 Implementer Status Handling

| Status | Action |
|--------|--------|
| **DONE** | Proceed to review |
| **DONE_WITH_CONCERNS** | Read concerns. If correctness/scope issue → address before review. If observation → note and proceed. |
| **NEEDS_CONTEXT** | Provide missing context via SendMessage, let them continue |
| **BLOCKED** | Assess: context problem → provide more context. Too hard → re-dispatch with Opus. Too large → break into smaller tasks. Plan wrong → escalate to user. |

Never force the same approach on a blocked teammate. Something must change.

### 3.6 Two-Stage Review (from superpowers)

After each implementer completes, run TWO separate reviews in order:

**Stage 1 — Spec Compliance Review:**
Spawn a reviewer teammate that checks: did the implementer build what was requested?
- Read actual code, do NOT trust the implementer's report
- Check for missing requirements, extra unneeded work, misunderstandings
- Output: PASS or FAIL with specific issues + file:line references

**Stage 2 — Code Quality Review (only after spec passes):**
Spawn a reviewer teammate that checks: is the implementation well-built?
- Clean, tested, maintainable code
- Each file has one clear responsibility
- Follows existing codebase patterns
- Output: PASS or FAIL with issues categorized as Critical/Important/Minor

If either review fails → relay issues to implementer via SendMessage → implementer fixes → re-review. Do NOT skip the re-review.

### 3.7 Context Isolation

- Each teammate gets **only** the context relevant to its specific task
- Provide full task text in the prompt — never make teammates read plan files
- Let teammates discover codebase patterns by reading files themselves
- Orchestrator never reads implementation files or full review reports — only parse structured headers

### 3.8 Worktree Isolation

| Mode | Worktree | Reason |
|------|----------|--------|
| SINGLE | No | One teammate, no conflict risk |
| PARALLEL | **Yes, by default** | Multiple teammates editing simultaneously |
| SEQUENTIAL | Optional (user request or risky changes) | Tasks run in order, low conflict risk |
| COMPETITIVE | **Yes, by default** | Generators produce competing solutions in same files |

When using worktrees:
- Pass `isolation: "worktree"` in the Agent call
- After teammate completes, the result includes the worktree branch name
- Orchestrator merges worktree branches sequentially after all teammates finish
- If merge conflicts arise, spawn a teammate to resolve them

---

## 4. SINGLE Mode

**When:** One focused task, no decomposition needed.

### Process

1. **Analyze complexity** → select model tier
2. **Create team:**
   ```
   TeamCreate("orchestrate-single-{slug}", "Single task: {description}")
   TaskCreate(title: "{task name}", description: "{task details}")
   ```
3. **Spawn teammate:**
   ```
   Agent(
     prompt: {CoT prefix + task body + self-critique suffix},
     team_name: "orchestrate-single-{slug}",
     name: "worker",
     model: "{selected tier}"
   )
   ```
4. **Review output** — check TaskList for completion
5. **If high-stakes:** spawn judge teammate (see Judge Protocol below)
6. **Apply 3-strike rule** if verification fails
7. **Cleanup:**
   ```
   SendMessage(to: "worker", message: "Shutdown request")
   TeamDelete()
   ```

### Concrete Example

Implementing an auth middleware:

```
TeamCreate("orchestrate-single-auth-middleware", "Single task: auth middleware")
TaskCreate(title: "Implement auth middleware", description: "Create middleware that validates JWT tokens and attaches user to request context")

Agent(
  prompt: "Implement auth middleware for Next.js. Validate JWT from Supabase, attach user to request. Files: src/middleware.ts, src/lib/auth.ts. Write tests first (TDD). Verify with: npx tsc --noEmit && npm test",
  team_name: "orchestrate-single-auth-middleware",
  name: "worker",
  model: "opus"
)
```

---

## 5. PARALLEL Mode

**When:** Multiple independent subtasks that can run concurrently.

### Pre-Flight Checks

Before spawning teammates, validate:
- [ ] Subtasks have **no shared files** (non-overlapping file ownership)
- [ ] Subtasks have **no output dependencies** (A doesn't need B's result)
- [ ] Subtasks have **no ordering requirement**

If any check fails → downgrade to SEQUENTIAL mode.

### Process

1. **Identify targets** — files, components, modules, or subsystems
2. **Validate independence** — check file ownership overlap
3. **Select model** — same tier for all teammates in a batch (simplifies reasoning)
4. **Create team:**
   ```
   TeamCreate("orchestrate-parallel-{slug}", "Parallel: {N} independent targets")
   ```
5. **Create all tasks:**
   ```
   TaskCreate(title: "Target 1: {name}", description: "{scoped task}")
   TaskCreate(title: "Target 2: {name}", description: "{scoped task}")
   ...
   ```
6. **Spawn ALL teammates in a SINGLE response** (critical — never serialize):
   ```
   Agent(prompt: ..., team_name: ..., name: "worker-1", isolation: "worktree", model: ...)
   Agent(prompt: ..., team_name: ..., name: "worker-2", isolation: "worktree", model: ...)
   Agent(prompt: ..., team_name: ..., name: "worker-3", isolation: "worktree", model: ...)
   ```
   All Agent calls in ONE message. Each teammate gets `isolation: "worktree"`.
   Use `run_in_background: true` if tasks are expected to take >30 seconds.
7. **Collect results** — TaskList to check completion status per target
8. **Merge worktree branches** — sequentially merge each teammate's branch
   - If merge conflict: spawn a resolver teammate to handle it
9. **Summarize:** success/failure per target, files modified, any conflicts resolved
10. **Cleanup:** SendMessage shutdown to each → TeamDelete

### Concrete Example

Building a dashboard with independent frontend + backend + database work:

```
TeamCreate("orchestrate-parallel-dashboard", "Parallel: 3 targets for dashboard feature")

TaskCreate(title: "Frontend: Dashboard UI", description: "Build the dashboard page with charts and tables. Files: src/app/dashboard/*, src/components/charts/*")
TaskCreate(title: "Backend: Dashboard API", description: "Create API routes for dashboard data. Files: src/app/api/dashboard/*, src/lib/services/dashboard.ts")
TaskCreate(title: "Database: Dashboard schema", description: "Create Supabase migration for dashboard tables. Files: supabase/migrations/*")

# ALL three spawned in ONE message:
Agent(prompt: "Build the dashboard UI page...", team_name: "orchestrate-parallel-dashboard", name: "frontend", isolation: "worktree", model: "opus")
Agent(prompt: "Create the dashboard API routes...", team_name: "orchestrate-parallel-dashboard", name: "backend", isolation: "worktree", model: "opus")
Agent(prompt: "Create the database migration...", team_name: "orchestrate-parallel-dashboard", name: "database", isolation: "worktree", model: "sonnet")
```

Each teammate gets ONLY its file scope. They work simultaneously in isolated worktrees. Merge branches after all complete.

### Batch Size

- Default: up to 5 teammates per batch
- If >5 targets: batch into groups of 5, run sequentially between batches
- Reason: too many concurrent worktrees strains resources

---

## 6. SEQUENTIAL Mode

**When:** Tasks with dependencies that must execute in order.

### Process

1. **Decompose** task into ordered subtasks with dependency graph
2. **Create team:**
   ```
   TeamCreate("orchestrate-sequential-{slug}", "Sequential: {N} ordered steps")
   ```
3. **Create ALL tasks upfront** (even though execution is ordered):
   ```
   TaskCreate(title: "Step 1: {name}", description: "{details}")
   TaskCreate(title: "Step 2: {name}", description: "{details + deps on step 1}")
   ...
   ```
4. **For each step:**

   a. Select model based on step complexity

   b. Build prompt with: CoT prefix + step body + prior step context + self-critique suffix

   c. Spawn implementer:
      ```
      Agent(prompt: ..., team_name: ..., name: "step-{N}")
      ```

   d. Spawn judge teammate for verification:
      ```
      Agent(
        prompt: {judge template with acceptance criteria},
        team_name: ...,
        name: "judge-{N}",
        model: "sonnet"
      )
      ```

   e. Parse judge VERDICT (do NOT read full report):
      - **PASS** (score >= 3.5): TaskUpdate completed, extract context summary for next step
      - **FAIL**: Apply 3-strike rule

5. **Context passing between steps** — pass forward ONLY:
   - Files modified (paths)
   - Key changes (3-5 bullets)
   - Decisions that affect later steps
   - Warnings or caveats
   - **Max 200 words** per step summary

6. **After all steps:** optional final reviewer teammate for integration check
7. **Cleanup:** SendMessage shutdown to all → TeamDelete

### Worktree (optional)

Add `isolation: "worktree"` to individual steps when:
- The step involves risky/experimental changes
- The user explicitly requests it
- Rollback might be needed

---

## 7. COMPETITIVE Mode

**When:** High-stakes decisions where quality matters more than speed.

### Process

1. **Create team:**
   ```
   TeamCreate("orchestrate-competitive-{slug}", "Competitive: 3 solutions + 3 judges")
   ```

2. **Phase 1 — Generate 3 competing solutions:**
   ```
   TaskCreate(title: "Solution A: {task}", description: "...")
   TaskCreate(title: "Solution B: {task}", description: "...")
   TaskCreate(title: "Solution C: {task}", description: "...")
   ```
   Spawn ALL 3 generators in ONE response, each with `isolation: "worktree"`:
   ```
   Agent(prompt: ..., name: "generator-a", isolation: "worktree", model: "opus")
   Agent(prompt: ..., name: "generator-b", isolation: "worktree", model: "opus")
   Agent(prompt: ..., name: "generator-c", isolation: "worktree", model: "opus")
   ```
   Each generator gets the same task but works independently.

3. **Phase 2 — Judge all 3 solutions:**
   ```
   TaskCreate(title: "Judge 1: evaluate all solutions", description: "...")
   TaskCreate(title: "Judge 2: evaluate all solutions", description: "...")
   TaskCreate(title: "Judge 3: evaluate all solutions", description: "...")
   ```
   Spawn ALL 3 judges in ONE response:
   ```
   Agent(prompt: {judge template}, name: "judge-1", model: "sonnet")
   Agent(prompt: {judge template}, name: "judge-2", model: "sonnet")
   Agent(prompt: {judge template}, name: "judge-3", model: "sonnet")
   ```
   Each judge must output:
   ```
   VOTE: [Solution A/B/C]
   SCORES:
     Solution A: [X.X]/5.0
     Solution B: [X.X]/5.0
     Solution C: [X.X]/5.0
   ISSUES: [list per solution]
   ```

4. **Phase 3 — Adaptive strategy** (orchestrator decides, parse headers only):

   | Condition | Strategy | Action |
   |-----------|----------|--------|
   | All 3 judges vote same solution | SELECT_AND_POLISH | Merge winning worktree, spawn polisher for improvements |
   | All solutions score < 3.0 | REDESIGN | Return to Phase 1 with lessons learned (max 1 redesign) |
   | Split decision | FULL_SYNTHESIS | Spawn synthesizer to combine best elements from all solutions |

5. **Merge** the winning/synthesized worktree branch
6. **Cleanup:** SendMessage shutdown to all → TeamDelete

---

## 8. Judge Protocol

Used by SEQUENTIAL (every step) and COMPETITIVE (phase 2). Also available for high-stakes SINGLE tasks.

### Custom Evaluation Criteria

Before using the generic rubric, check for project-specific criteria at:
- `.claude/evaluation-criteria.md` — project-level criteria
- `.autopilot/criteria.md` — autopilot-run-specific criteria

If found, use those criteria instead of the generic rubric. If not found, use the generic rubric below.

**Creating criteria** (`/orchestrate criteria`):

Ask the user what aspects matter for their project. Common domains:

| Domain | Example Criteria |
|--------|-----------------|
| **UI/Frontend** | Quality (cohesive vs stitched together), Originality (not default AI patterns), Craft (typography, spacing, color harmony), Functionality (components enhance UX) |
| **API/Backend** | Correctness (handles edge cases), Performance (no N+1, proper indexing), Security (auth, input validation), Consistency (naming, patterns) |
| **Architecture** | Simplicity (minimal moving parts), Extensibility (can add features without rewrites), Separation (clear boundaries), Testability |
| **UX/Flows** | Intuitiveness (no manual needed), Completeness (error states, loading, empty), Accessibility (screen readers, contrast), Responsiveness |

Write criteria to `.claude/evaluation-criteria.md`:

```markdown
# Evaluation Criteria

## UI (weight: 30%)
- Quality: Is the design cohesive or just components strung together? (1-5)
- Originality: Does it avoid default AI patterns (purple gradients, generic cards)? (1-5)
- Craft: Typography, spacing, consistency, color harmony? (1-5)
- Functionality: Does each component serve the user experience? (1-5)

## API (weight: 40%)
- Correctness: All edge cases handled? (1-5)
- Security: Auth, validation, no injection vectors? (1-5)
- Performance: No N+1 queries, proper caching? (1-5)

## Code Quality (weight: 30%)
- Patterns: Follows existing codebase conventions? (1-5)
- Simplicity: Minimal complexity for the requirement? (1-5)
- Tests: Meaningful coverage, not just line count? (1-5)
```

### Judge Prompt Template

```
You are an independent judge evaluating work quality. You have NO prior context
about this task — evaluate based solely on what you observe.

<original_task>{the original requirement}</original_task>
<work_produced>{summary of what was created}</work_produced>
<files>{list of files to review}</files>
<criteria>{weighted evaluation criteria — use project criteria if available}</criteria>

Evaluate using this rubric:
  1 = Unacceptable (broken, wrong approach)
  2 = Below Average (works but significant issues) — THIS IS THE DEFAULT
  3 = Adequate (works, minor issues)
  4 = Good (solid work, production-ready)
  5 = Excellent (exceptional, rare — <5% of evaluations)

Output ONLY this structured format:
---
VERDICT: [PASS/FAIL]
SCORE: [X.X]/5.0
CRITERIA_SCORES:
  {criterion_1}: [X.X]/5.0
  {criterion_2}: [X.X]/5.0
  ...
ISSUES: [numbered list of specific issues]
IMPROVEMENTS: [numbered list of specific suggestions]
---

Score >= 3.5 = PASS. Justify scores with specific evidence.
Default assumption: score is 2 until evidence proves otherwise.
```

### Orchestrator Rules for Judge Output

- Parse ONLY the structured headers (VERDICT, SCORE, CRITERIA_SCORES, ISSUES)
- Do NOT read the full judge report — it pollutes orchestrator context
- If PASS: proceed to next step
- If FAIL: extract ISSUES list, relay to implementer via SendMessage for retry
- Track CRITERIA_SCORES across phases to spot recurring weaknesses

---

## 9. Quick Reference

| Mode | Teammates | Worktree | Judge | Max Strikes |
|------|-----------|----------|-------|-------------|
| SINGLE | 1 (+optional judge) | No | Optional | 3 |
| PARALLEL | N (batch <=5) | Yes | Self-critique | 3 per target |
| SEQUENTIAL | 1 per step (+judge) | Optional | Every step | 3 per step |
| COMPETITIVE | 3 gen + 3 judge + 1 synth | Yes (generators) | Yes (3 judges) | 1 redesign cycle |
