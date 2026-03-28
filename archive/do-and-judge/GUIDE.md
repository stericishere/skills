---
name: sadd:do-and-judge
description: Execute a task with teammate implementation and LLM-as-a-judge verification with automatic retry loop using Agent Teams
argument-hint: Task description (e.g., "Refactor the UserService class to use dependency injection")
---

# do-and-judge

<task>
Execute a single task by spawning an implementation teammate, verifying with an independent judge teammate, and iterating with feedback via SendMessage until passing or max retries exceeded.
</task>

<context>
This command implements a **single-task execution pattern** with **LLM-as-a-judge verification** using the Agent Teams API. You (the team lead) create a team, spawn a focused teammate to implement the task, then spawn an independent judge teammate to verify quality. If verification fails, you iterate with judge feedback via SendMessage until passing (score >=4) or max retries (2) exceeded.

Key benefits:

- **Fresh context** - Implementation teammate works with clean context window
- **External verification** - Judge teammate catches blind spots self-critique misses
- **Feedback loop** - Retry with specific issues relayed via SendMessage
- **Quality gate** - Work doesn't ship until it meets threshold
- **Shared task tracking** - TeamCreate provides visibility into task status
</context>

CRITICAL: You are the team lead - you MUST NOT perform the task yourself. Your role is to:

1. Create the team with TeamCreate and populate tasks with TaskCreate
2. Analyze the task and select optimal model
3. Spawn implementation teammate with Agent(team_name, name)
4. Spawn judge teammate to verify with Agent(team_name, name)
5. Parse verdict and iterate via SendMessage if needed (max 2 retries)
6. TaskUpdate to track progress
7. Report final results and TeamDelete to clean up

## RED FLAGS - Never Do These

**NEVER:**

- Read implementation files to understand code details (let teammates do this)
- Write code or make changes to source files directly
- Skip judge verification to "save time"
- Read judge reports in full (only parse structured headers)
- Proceed after max retries without user decision

**ALWAYS:**

- Use TeamCreate to set up the team and shared task list
- Use TaskCreate to define the implementation task
- Use Agent(team_name, name) to spawn teammates for ALL implementation work
- Use Agent(team_name, name) to spawn independent judge teammates for verification
- Use SendMessage for relaying feedback between teammates
- Use TaskUpdate to mark tasks completed
- Wait for implementation to complete before spawning judge
- Parse only VERDICT/SCORE/ISSUES from judge output
- Iterate with feedback via SendMessage if verification fails
- Use TeamDelete to clean up when done

## Process

### Phase 0: Team Setup

Create the team and task before starting work:

```
1. TeamCreate("do-and-judge-{task-name}", "Single task with judge verification: {task summary}")
   → Creates team config at ~/.claude/teams/{name}/config.json
   → Creates task directory at ~/.claude/tasks/{name}/

2. TaskCreate(
     title: "Implement: {brief task summary}",
     description: "{full task description with requirements}"
   )
```

### Phase 1: Task Analysis and Model Selection

Analyze the task to select the optimal model:

```
Let me analyze this task to determine the optimal configuration:

1. **Complexity Assessment**
   - High: Architecture decisions, novel problem-solving, critical logic
   - Medium: Standard patterns, moderate refactoring, API updates
   - Low: Simple transformations, straightforward updates

2. **Risk Assessment**
   - High: Breaking changes, security-sensitive, data integrity
   - Medium: Internal changes, reversible modifications
   - Low: Non-critical utilities, isolated changes

3. **Scope Assessment**
   - Large: Multiple files, complex interactions
   - Medium: Single component, focused changes
   - Small: Minor modifications, single file
```

**Model Selection Guide:**

| Model | When to Use | Examples |
|-------|-------------|----------|
| `opus` | **Default/standard choice**. Safe for any task. Use when correctness matters, decisions are nuanced, or you're unsure. | Most implementation, code writing, business logic, architectural decisions |
| `sonnet` | Task is **not complex but high volume** - many similar steps, large context to process, repetitive work. | Bulk file updates, processing many similar items, large refactoring with clear patterns |
| `haiku` | **Trivial operations only**. Simple, mechanical tasks with no decision-making. | Directory creation, file deletion, simple config edits, file copying/moving |

**Specialized Agents:** Common agents from the `sdd` plugin include: `sdd:developer`, `sdd:researcher`, `sdd:software-architect`, `sdd:tech-lead`, `sdd:qa-engineer`. If the appropriate specialized agent is not available, fallback to a general agent without specialization.

### Phase 2: Spawn Implementation Teammate

Construct the implementation prompt with these mandatory components:

#### 2.1 Zero-shot Chain-of-Thought Prefix (REQUIRED - MUST BE FIRST)

```markdown
## Reasoning Approach

Before taking any action, think through this task systematically.

Let's approach this step by step:

1. "Let me understand what this task requires..."
   - What is the specific objective?
   - What constraints exist?
   - What is the expected outcome?

2. "Let me explore the relevant code..."
   - What files are involved?
   - What patterns exist in the codebase?
   - What dependencies need consideration?

3. "Let me plan my approach..."
   - What specific modifications are needed?
   - What order should I make them?
   - What could go wrong?

4. "Let me verify my approach before implementing..."
   - Does my plan achieve the objective?
   - Am I following existing patterns?
   - Is there a simpler way?

Work through each step explicitly before implementing.
```

#### 2.2 Task Body

```markdown
## Task
{Task description from user}

## Constraints
- Follow existing code patterns and conventions
- Make minimal changes to achieve the objective
- Do not introduce new dependencies without justification
- Ensure changes are testable

## Output
Provide your implementation along with a "Summary" section containing:
- Files modified (full paths)
- Key changes (3-5 bullet points)
- Any decisions made and rationale
- Potential concerns or follow-up needed
```

#### 2.3 Self-Critique Suffix (REQUIRED - MUST BE LAST)

```markdown
## Self-Critique Verification (MANDATORY)

Before completing, verify your work. Do not submit unverified changes.

### Verification Questions

| # | Question | Evidence Required |
|---|----------|-------------------|
| 1 | Does my solution address ALL requirements? | [Specific evidence] |
| 2 | Did I follow existing code patterns? | [Pattern examples] |
| 3 | Are there any edge cases I missed? | [Edge case analysis] |
| 4 | Is my solution the simplest approach? | [Alternatives considered] |
| 5 | Would this pass code review? | [Quality check] |

### Answer Each Question with Evidence

Examine your solution and provide specific evidence for each question.

### Revise If Needed

If ANY verification question reveals a gap:
1. **FIX** - Address the specific gap identified
2. **RE-VERIFY** - Confirm the fix resolves the issue
3. **UPDATE** - Update the Summary section

CRITICAL: Do not submit until ALL verification questions have satisfactory answers.
```

#### 2.4 Spawn Teammate

```
Agent(
  prompt: {constructed prompt with CoT + task + self-critique},
  team_name: "do-and-judge-{task-name}",
  name: "implementer"
)
```

### Phase 3: Spawn Judge Teammate

After implementation completes, spawn an independent judge teammate.

**Judge prompt template:**

```markdown
You are verifying completion of a task.

## Task Requirements
{Original task description from user}

## Implementation Output
{Summary section from implementation teammate}
{Paths to files modified}

## Evaluation Criteria
1. **Correctness** (35%) - Does the implementation meet requirements?
2. **Quality** (25%) - Is the code well-structured and maintainable?
3. **Completeness** (25%) - Are all required elements present?
4. **Patterns** (15%) - Does it follow existing codebase conventions?

## Output
CRITICAL: You must reply with this exact structured header format:

---
VERDICT: [PASS/FAIL]
SCORE: [X.X]/5.0
ISSUES:
  - {issue_1 or "None"}
  - {issue_2 or "None"}
IMPROVEMENTS:
  - {improvement_1 or "None"}
---

[Detailed evaluation follows]

## Instructions
1. Read the implementation files
2. Verify each requirement was met with specific evidence
3. Identify any gaps, issues, or missing elements
4. Score each criterion and calculate weighted total

CRITICAL: List specific issues that must be fixed for retry.

## Scoring Scale

**DEFAULT SCORE IS 2. You must justify ANY deviation upward.**

| Score | Meaning | Evidence Required | Your Attitude |
|-------|---------|-------------------|---------------|
| 1 | Unacceptable | Clear failures, missing requirements | Easy call |
| 2 | Below Average | Multiple issues, partially meets requirements | Common result |
| 3 | Adequate | Meets basic requirements, minor issues | Need proof that it meets basic requirements |
| 4 | Good | Meets ALL requirements, very few minor issues | Prove it deserves this |
| 5 | Excellent | Exceeds requirements, genuinely exemplary | **Extremely rare** - requires exceptional evidence |

### Score Distribution Reality Check

- **Score 5**: Should be given in <5% of evaluations. If you're giving more 5s, you're too lenient.
- **Score 4**: Reserved for genuinely solid work. Not "pretty good" - actually good.
- **Score 3**: This is where refined work lands. Not average.
- **Score 2**: Common for first attempts. Don't be afraid to use it.
- **Score 1**: Reserved for fundamental failures. But don't avoid it when deserved.

```

**Spawn Judge:**

```
Agent(
  prompt: {judge verification prompt},
  team_name: "do-and-judge-{task-name}",
  name: "judge"
)
```

### Phase 4: Parse Verdict and Iterate

Parse judge output (DO NOT read full report):

```
Extract from judge reply:
- VERDICT: PASS or FAIL
- SCORE: X.X/5.0
- ISSUES: List of problems (if any)
- IMPROVEMENTS: List of suggestions (if any)
```

**Decision logic:**

```
If score >=4:
  → VERDICT: PASS
  → TaskUpdate(task_id, status: "completed")
  → Report success with summary
  → Include IMPROVEMENTS as optional enhancements

If score <4:
  → VERDICT: FAIL
  → Check retry count

  If retries < 2:
    → SendMessage(to: "implementer", message: {retry instructions with judge feedback})
      OR spawn new teammate:
    → Agent(
        prompt: {retry prompt with judge ISSUES},
        team_name: "do-and-judge-{task-name}",
        name: "implementer-retry-{R}"
      )
    → Return to Phase 3 (spawn judge teammate for re-verification)

  If retries >= 2:
    → Escalate to user (see Error Handling)
    → Do NOT proceed without user decision
```

### Phase 5: Retry with Feedback (If Needed)

**Retry prompt template (sent via SendMessage or used to spawn retry teammate):**

```markdown
## Retry Required

Your previous implementation did not pass judge verification.

## Original Task
{Original task description}

## Judge Feedback
VERDICT: FAIL
SCORE: {score}/5.0
ISSUES:
{list of issues from judge}

## Your Previous Changes
{files modified in previous attempt}

## Instructions
Let's fix the identified issues step by step.

1. Review each issue the judge identified
2. For each issue, determine the root cause
3. Plan the fix for each issue
4. Implement ALL fixes
5. Verify your fixes address each issue
6. Provide updated Summary section

CRITICAL: Focus on fixing the specific issues identified. Do not rewrite everything.
```

### Phase 6: Final Report and Cleanup

After task passes verification:

```markdown
## Execution Summary

**Task:** {original task description}
**Result:** PASS

### Verification
| Attempt | Score | Status |
|---------|-------|--------|
| 1 | {X.X}/5.0 | {PASS/FAIL} |
| 2 | {X.X}/5.0 | {PASS/FAIL} | (if retry occurred)

### Files Modified
- {file1}: {what changed}
- {file2}: {what changed}

### Key Changes
- {change 1}
- {change 2}

### Suggested Improvements (Optional)
{IMPROVEMENTS from judge, if any}
```

**Cleanup:**

```
1. SendMessage(to: all active teammates, message: "Work complete. Please shut down.")
2. TeamDelete()  — clean up team config and task directory
```

## Error Handling

### If Max Retries Exceeded

When task fails verification twice:

1. **STOP** - Do not proceed
2. **Report** - Provide failure analysis:
   - Original task requirements
   - All judge verdicts and scores
   - Persistent issues across retries
3. **Escalate** - Present options to user:
   - Provide additional context/guidance for retry
   - Modify task requirements
   - Abort task
4. **Wait** - Do NOT proceed without user decision

**Escalation Report Format:**

```markdown
## Task Failed Verification (Max Retries Exceeded)

### Task Requirements
{original task description}

### Verification History
| Attempt | Score | Key Issues |
|---------|-------|------------|
| 1 | {X.X}/5.0 | {issues} |
| 2 | {X.X}/5.0 | {issues} |
| 3 | {X.X}/5.0 | {issues} |

### Persistent Issues
{Issues that appeared in multiple attempts}

### Options
1. **Provide guidance** - Give additional context for another retry
2. **Modify requirements** - Simplify or clarify task
3. **Abort** - Stop execution

Awaiting your decision...
```

## Examples

### Example 1: Simple Refactoring (Pass on First Try)

**Input:**

```
/do-and-judge Extract the validation logic from UserController into a separate UserValidator class
```

**Execution:**

```
Phase 0: Team Setup
  TeamCreate("do-and-judge-user-validator", "Extract validation into UserValidator")
  TaskCreate("Implement: Extract UserValidator class", "...")

Phase 1: Task Analysis
  → Model: Opus

Phase 2: Spawn Implementation Teammate
  Agent(prompt: ..., team_name: "do-and-judge-user-validator", name: "implementer")
    → Created UserValidator.ts
    → Updated UserController to use validator
    → Summary: 2 files modified, validation extracted

Phase 3: Spawn Judge Teammate
  Agent(prompt: ..., team_name: "do-and-judge-user-validator", name: "judge")
    → VERDICT: PASS, SCORE: 4.2/5.0
    → ISSUES: None
    → IMPROVEMENTS: Add input validation for edge cases

Phase 6: Final Report and Cleanup
  TaskUpdate(task_id, status: "completed")
  PASS on attempt 1
  Files: UserValidator.ts (new), UserController.ts (modified)
  SendMessage(to: teammates, message: "Shutdown request")
  TeamDelete()
```

### Example 2: Complex Task (Pass After Retry)

**Input:**

```
/do-and-judge Implement rate limiting middleware with configurable limits per endpoint
```

**Execution:**

```
Phase 0: Team Setup
  TeamCreate("do-and-judge-rate-limiter", "Rate limiting middleware implementation")
  TaskCreate("Implement: Rate limiting middleware", "...")

Phase 1: Task Analysis
  - Complexity: High (new feature, multiple concerns)
  - Risk: High (affects all endpoints)
  - Scope: Medium (single middleware)
  → Model: opus

Phase 2: Spawn Implementation Teammate (Attempt 1)
  Agent(prompt: ..., team_name: "do-and-judge-rate-limiter", name: "implementer")
    → Created RateLimiter middleware
    → Added configuration schema

Phase 3: Spawn Judge Teammate
  Agent(prompt: ..., team_name: "do-and-judge-rate-limiter", name: "judge")
    → VERDICT: FAIL, SCORE: 3.1/5.0
    → ISSUES:
      - Missing per-endpoint configuration
      - No Redis support for distributed deployments
    → IMPROVEMENTS: Add monitoring hooks

Phase 5: Retry with Feedback
  SendMessage(to: "implementer", message: "Retry: Fix per-endpoint config and add Redis support")
  OR Agent(prompt: ..., team_name: "...", name: "implementer-retry-1")
    → Added endpoint-specific limits
    → Added Redis adapter option

Phase 3: Spawn Judge Teammate (Attempt 2)
  Agent(prompt: ..., team_name: "...", name: "judge-attempt-2")
    → VERDICT: PASS, SCORE: 4.4/5.0
    → IMPROVEMENTS: Add metrics export

Phase 6: Final Report and Cleanup
  TaskUpdate(task_id, status: "completed")
  PASS on attempt 2
  Files: RateLimiter.ts, config/rateLimits.ts, adapters/RedisAdapter.ts
  TeamDelete()
```

### Example 3: Task Requiring Escalation

**Input:**

```
/do-and-judge Migrate the database schema to support multi-tenancy
```

**Execution:**

```
Phase 0: Team Setup
  TeamCreate("do-and-judge-multi-tenancy", "Database schema migration for multi-tenancy")
  TaskCreate("Implement: Multi-tenancy schema migration", "...")

Phase 1: Task Analysis
  - Complexity: High
  - Risk: High (database schema change)
  → Model: opus

Attempt 1: FAIL (2.8/5.0) - Missing tenant isolation in queries
Attempt 2: FAIL (3.2/5.0) - Incomplete migration script
Attempt 3: FAIL (3.3/5.0) - Edge cases in existing data migration

ESCALATION:
  Persistent issue: Existing data migration requires business decisions
  about how to handle orphaned records.

  Options presented to user:
  1. Provide guidance on orphan handling
  2. Simplify to new tenants only
  3. Abort

User chose: Option 1 - "Delete orphaned records older than 1 year"

Attempt 4 (with guidance): PASS (4.1/5.0)
TeamDelete()
```

## Best Practices

### Model Selection

- **When in doubt, use Opus** - Quality matters more than cost for verified work
- **Match complexity** - Don't use Opus for simple transformations
- **Consider risk** - Higher risk = stronger model

### Judge Verification

- **Never skip** - The judge catches what self-critique misses
- **Parse only headers** - Don't read full reports to avoid context pollution
- **Trust the threshold** - 4/5.0 is the quality gate

### Iteration

- **Focus fixes** - Don't rewrite everything, fix specific issues
- **Pass feedback verbatim** - Use SendMessage to let the implementation teammate see exact issues from the judge
- **Escalate appropriately** - Don't loop forever on fundamental problems

### Context Management

- **Keep it clean** - You orchestrate, teammates implement
- **Summarize, don't copy** - Pass summaries, not full file contents
- **Trust teammates** - They can read files themselves
- **Clean up** - Always TeamDelete when work is done to free resources
