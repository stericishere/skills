---
name: sadd:do-in-steps
description: Execute complex tasks through sequential teammate orchestration with intelligent model selection, and LLM-as-a-judge verification using Agent Teams
argument-hint: Task description (e.g., "Refactor UserService class and update all consumers")
---

# do-in-steps

<task>
Execute a complex task by decomposing it into sequential subtasks and orchestrating teammates to complete each step in order. Automatically analyze the task to identify dependencies, select optimal models for each subtask, pass relevant context from completed steps to subsequent ones, and verify each step with an independent judge before proceeding.
</task>

<context>
This command implements the **Agent Teams pattern** for sequential task execution with context passing and **LLM-as-a-judge verification**. You (the lead) create a team, populate a shared task list, and spawn teammates for each step. Each teammate receives:
- **Isolated context** - Clean context window for its specific subtask
- **Optimal model** - Selected based on subtask complexity (Opus/Sonnet/Haiku)
- **Previous step context** - Summary of relevant outputs from preceding steps via SendMessage
- **Structured reasoning** - Zero-shot CoT prefix for systematic thinking
- **Self-critique** - Internal verification before submission
- **External judge** - LLM-as-a-judge verification with iteration loop

</context>

CRITICAL: You are the team lead - you MUST NOT perform the subtasks yourself. Your role is to:

1. Analyze and decompose the task
2. Create the team and shared task list with TeamCreate and TaskCreate
3. Select optimal models and agents for each subtask
4. Spawn teammates with Agent(team_name, name) to execute steps
5. **Spawn judge teammates to verify step completion**
6. **Use SendMessage to relay judge feedback for retries (max 2)**
7. Use TaskUpdate to track progress
8. Report final results and TeamDelete to clean up

## RED FLAGS - Never Do These

**NEVER:**

- Read implementation files to understand code details (let teammates do this)
- Write code or make changes to source files directly
- Skip decomposition and jump to implementation
- Perform multiple steps yourself "to save time"
- Overflow your context by reading step outputs in detail
- Read judge reports in full (only parse structured headers)
- Skip judge verification and proceed next step

**ALWAYS:**

- Use TeamCreate to set up the team and shared task list
- Use TaskCreate to populate the task list for each subtask
- Use Agent(team_name, name) to spawn teammates for ALL implementation work
- Use Agent(team_name, name) to spawn **independent judge teammates** for step verification
- Use SendMessage for inter-teammate communication (feedback, context passing)
- Use TaskUpdate to mark tasks completed or assign them
- Pass only necessary context summaries, not full file contents
- Wait for each step to complete before starting verification AND
- Get pass from judge verification before proceeding to next step
- Iterate with judge feedback via SendMessage if verification fails (max 2 retries)
- Use TeamDelete to clean up when all work is done

Any deviation from orchestration (attempting to implement subtasks yourself, reading implementation files, reading full judge reports, or making direct changes) will result in context pollution and ultimate failure, as a result you will be fired!

## Process

### Setup: Create Team and Reports Directory

Before starting, set up the team and ensure the reports directory exists:

```
1. TeamCreate("do-in-steps-{task-name}", "Sequential execution of {task description}")
   → Creates team config at ~/.claude/teams/{name}/config.json
   → Creates task directory at ~/.claude/tasks/{name}/

2. mkdir -p .specs/reports
```

**Report naming convention:** `.specs/reports/{task-name}-step-{N}-{YYYY-MM-DD}.md`

Where:

- `{task-name}` - Derived from task description (e.g., `user-dto-refactor`)
- `{N}` - Step number
- `{YYYY-MM-DD}` - Current date

**Note:** Implementation outputs go to their specified locations; only judge verification reports go to `.specs/reports/`

### Phase 1: Task Analysis and Decomposition

Analyze the task systematically using Zero-shot Chain-of-Thought reasoning:

```
Let me analyze this task step by step to decompose it into sequential subtasks:

1. **Task Understanding**
   "What is the overall objective?"
   - What is being asked?
   - What is the expected final outcome?
   - What constraints exist?

2. **Identify Natural Boundaries**
   "Where does the work naturally divide?"
   - Database/model changes (foundation)
   - Interface/contract changes (dependencies)
   - Implementation changes (core work)
   - Integration/caller updates (ripple effects)
   - Testing/validation (verification)
   - Documentation (finalization)

3. **Dependency Identification**
   "What must happen before what?"
   - "If I do B before A, will B break or use stale information?"
   - "Does B need any output from A as input?"
   - "Would doing B first require redoing work after A?"
   - What is the minimal viable ordering?

4. **Define Clear Boundaries**
   "What exactly does each subtask encompass?"
   - Input: What does this step receive?
   - Action: What transformation/change does it make?
   - Output: What does this step produce?
   - Verification: How do we know it succeeded?
```

**Decomposition Guidelines:**

| Pattern | Decomposition Strategy | Example |
|---------|------------------------|---------|
| Interface change | 1. Update interface, 2. Update implementations, 3. Update consumers | "Change return type of getUser" |
| Feature addition | 1. Add core logic, 2. Add integration points, 3. Add API layer | "Add caching to UserService" |
| Refactoring | 1. Extract/modify core, 2. Update internal references, 3. Update external references | "Extract helper class from Service" |
| Bug fix with impact | 1. Fix root cause, 2. Fix dependent issues, 3. Update tests | "Fix calculation error affecting reports" |
| Multi-layer change | 1. Data layer, 2. Business layer, 3. API layer, 4. Client layer | "Add new field to User entity" |

**Decomposition Output Format:**

```markdown
## Task Decomposition

### Original Task
{task_description}

### Subtasks (Sequential Order)

| Step | Subtask | Depends On | Complexity | Type | Output |
|------|---------|------------|------------|------|--------|
| 1 | {description} | - | {low/med/high} | {type} | {what it produces} |
| 2 | {description} | Step 1 | {low/med/high} | {type} | {what it produces} |
| 3 | {description} | Steps 1,2 | {low/med/high} | {type} | {what it produces} |
...

### Dependency Graph
Step 1 ─→ Step 2 ─→ Step 3 ─→ ...
```

**Create Tasks in Shared List:**

After decomposition, populate the shared task list:

```
For each subtask:
  TaskCreate(
    title: "Step {N}: {subtask_name}",
    description: "{subtask description with inputs, outputs, and verification points}"
  )
```

### Phase 2: Model Selection for Each Subtask

For each subtask, analyze and select the optimal model:

```
Let me determine the optimal configuration for each subtask:

For Subtask N:
1. **Complexity Assessment**
   "How complex is the reasoning required?"
   - High: Architecture decisions, novel problem-solving, critical logic changes
   - Medium: Standard patterns, moderate refactoring, API updates
   - Low: Simple transformations, straightforward updates, documentation

2. **Scope Assessment**
   "How extensive is the work?"
   - Large: Multiple files, complex interactions
   - Medium: Single component, focused changes
   - Small: Minor modifications, single file

3. **Risk Assessment**
   "What is the impact of errors?"
   - High: Breaking changes, security-sensitive, data integrity
   - Medium: Internal changes, reversible modifications
   - Low: Non-critical utilities, documentation

4. **Domain Expertise Check**
   "Does this match a specialized agent profile?"
   - Development: implementation, refactoring, bug fixes
   - Architecture: system design, pattern selection
   - Documentation: API docs, comments, README updates
   - Testing: test generation, test updates
```

**Model Selection Matrix:**

| Complexity | Scope | Risk | Recommended Model |
|------------|-------|------|-------------------|
| High | Any | Any | `opus` |
| Any | Any | High | `opus` |
| Medium | Large | Medium | `opus` |
| Medium | Medium | Medium | `sonnet` |
| Medium | Small | Low | `sonnet` |
| Low | Any | Low | `haiku` |

**Decision Tree per Subtask:**

```
Is this subtask CRITICAL (architecture, interface, breaking changes)?
|
+-- YES --> Use Opus (highest capability for critical work)
|           |
|           +-- Does it match a specialized domain?
|               +-- YES --> Include specialized agent prompt
|               +-- NO --> Use Opus alone
|
+-- NO --> Is this subtask COMPLEX but not critical?
           |
           +-- YES --> Use Sonnet (balanced capability/cost)
           |
           +-- NO --> Is output LONG but task not complex?
                      |
                      +-- YES --> Use Sonnet (handles length well)
                      |
                      +-- NO --> Is this subtask SIMPLE/MECHANICAL?
                                 |
                                 +-- YES --> Use Haiku (fast, cheap)
                                 |
                                 +-- NO --> Use Sonnet (default for uncertain)
```

**Specialized Agent:** Specialized agent list depends on project and plugins that are loaded. Common agents from the `sdd` plugin include: `sdd:developer`, `sdd:tdd-developer`, `sdd:researcher`, `sdd:software-architect`, `sdd:tech-lead`, `sdd:team-lead`, `sdd:qa-engineer`. If the appropriate specialized agent is not available, fallback to a general agent without specialization.

**Decision:** Use specialized agent when subtask clearly benefits from domain expertise AND complexity justifies the overhead (not for Haiku-tier tasks).

**Selection Output Format:**

```markdown
## Model/Agent Selection

| Step | Subtask | Model | Agent | Rationale |
|------|---------|-------|-------|-----------|
| 1 | Update interface | opus | sdd:developer | Complex API design |
| 2 | Update implementations | sonnet | sdd:developer | Follow patterns |
| 3 | Update callers | haiku | - | Simple find/replace |
| 4 | Update tests | sonnet | sdd:tdd-developer | Test expertise |
```

### Phase 3: Sequential Execution with Judge Verification

Execute subtasks one by one, verify each with an independent judge teammate, iterate if needed, then pass context forward.

**Execution Flow per Step:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│ Step N                                                                  │
│                                                                         │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────────────┐   │
│   │ Implementer  │────▶│    Judge     │────▶│ Parse Verdict        │   │
│   │ (Teammate)   │     │ (Teammate)   │     │ (Team Lead)          │   │
│   └──────────────┘     └──────────────┘     └──────────────────────┘   │
│          ▲                                            │                 │
│          │                                            ▼                 │
│          │                              ┌─────────────────────────┐     │
│          │                              │ PASS (≥3.5)?            │     │
│          │                              │ ├─ YES → TaskUpdate     │     │
│          │                              │ │        → Next Step    │     │
│          │                              │ └─ NO  → Retry?         │     │
│          │                              │     ├─ <2 → SendMessage │     │
│          │                              │     │        (feedback)  │     │
│          │                              │     └─ ≥2 → Escalate    │     │
│          │                              └─────────────────────────┘     │
│          │                                            │                 │
│          └──────── SendMessage(feedback) ─────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 3.1 Context Passing Protocol

After each subtask completes, extract relevant context for subsequent steps:

**Context to pass forward (via SendMessage to next teammate):**

- Files modified (paths only, not contents)
- Key changes made (summary)
- New interfaces/APIs introduced
- Decisions made that affect later steps
- Warnings or considerations for subsequent steps

**Context filtering:**

- Pass ONLY information relevant to remaining subtasks
- Do NOT pass implementation details that don't affect later steps
- Keep context summaries concise (max 200 words per step)

**Context Size Guideline:** If cumulative context exceeds ~500 words, summarize older steps more aggressively. Teammates can read files directly if they need details.

**Example of Context Accumulation (Concrete):**

```markdown
## Completed Steps Summary

### Step 1: Define UserRepository Interface
- **What was done:** Created `src/repositories/UserRepository.ts` with interface definition
- **Key outputs:**
  - Interface: `IUserRepository` with methods: `findById`, `findByEmail`, `create`, `update`, `delete`
  - Types: `UserCreateInput`, `UserUpdateInput` in `src/types/user.ts`
- **Relevant for next steps:**
  - Implementation must fulfill `IUserRepository` interface
  - Use the defined input types for method signatures

### Step 2: Implement UserRepository
- **What was done:** Created `src/repositories/UserRepositoryImpl.ts` implementing `IUserRepository`
- **Key outputs:**
  - Class: `UserRepositoryImpl` with all interface methods implemented
  - Uses existing database connection from `src/db/connection.ts`
- **Relevant for next steps:**
  - Import repository from `src/repositories/UserRepositoryImpl`
  - Constructor requires `DatabaseConnection` injection
```

#### 3.2 Teammate Prompt Construction

For each subtask, construct the prompt with these mandatory components:

##### 3.2.1 Zero-shot Chain-of-Thought Prefix (REQUIRED - MUST BE FIRST)

```markdown
## Reasoning Approach

Before taking any action, think through this subtask systematically.

Let's approach this step by step:

1. "Let me understand what was done in previous steps..."
   - What context am I building on?
   - What interfaces/patterns were established?
   - What constraints did previous steps introduce?

2. "Let me understand what this step requires..."
   - What is the specific objective?
   - What are the boundaries of this step?
   - What must I NOT change (preserve from previous steps)?

3. "Let me plan my approach..."
   - What specific modifications are needed?
   - What order should I make them?
   - What could go wrong?

4. "Let me verify my approach before implementing..."
   - Does my plan achieve the objective?
   - Am I consistent with previous steps' changes?
   - Is there a simpler way?

Work through each step explicitly before implementing.
```

##### 3.2.2 Task Body

```markdown
<task>
{Subtask description}
</task>

<subtask_context>
Step {N} of {total_steps}: {subtask_name}
</subtask_context>

<previous_steps_context>
{Summary of relevant outputs from previous steps - ONLY if this is not the first step}
- Step 1: {what was done, key files modified, relevant decisions}
- Step 2: {what was done, key files modified, relevant decisions}
...
</previous_steps_context>

<constraints>
- Focus ONLY on this specific subtask
- Build upon (do not undo) changes from previous steps
- Follow existing code patterns and conventions
- Produce output that subsequent steps can build upon
</constraints>

<input>
{What this subtask receives - files, context, dependencies}
</input>

<output>
{Expected deliverable - modified files, new files, summary of changes}

CRITICAL: At the end of your work, provide a "Context for Next Steps" section with:
- Files modified (full paths)
- Key changes summary (3-5 bullet points)
- Any decisions that affect later steps
- Warnings or considerations for subsequent steps
</output>
```

##### 3.2.3 Self-Critique Suffix (REQUIRED - MUST BE LAST)

```markdown
## Self-Critique Verification (MANDATORY)

Before completing, verify your work integrates properly with previous steps. Do not submit unverified changes.

### Verification Questions

Generate verification questions based on the subtask description and the previous steps context. Examples:

| # | Question | Evidence Required |
|---|----------|-------------------|
| 1 | Does my work build correctly on previous step outputs? | [Specific evidence] |
| 2 | Did I maintain consistency with established patterns/interfaces? | [Specific evidence] |
| 3 | Does my solution address ALL requirements for this step? | [Specific evidence] |
| 4 | Did I stay within my scope (not modifying unrelated code)? | [List any out-of-scope changes] |
| 5 | Is my output ready for the next step to build upon? | [Check against dependency graph] |

### Answer Each Question with Evidence

Examine your solution and provide specific evidence for each question:

[Q1] Previous Step Integration:
- Previous step output: [relevant context received]
- How I built upon it: [specific integration]
- Any conflicts: [resolved or flagged]

[Q2] Pattern Consistency:
- Patterns established: [list]
- How I followed them: [evidence]
- Any deviations: [justified or fixed]

[Q3] Requirement Completeness:
- Required: [what was asked]
- Delivered: [what you did]
- Gap analysis: [any gaps]

[Q4] Scope Adherence:
- In-scope changes: [list]
- Out-of-scope changes: [none, or justified]

[Q5] Output Readiness:
- What later steps need: [based on decomposition]
- What I provided: [specific outputs]
- Completeness: [HIGH/MEDIUM/LOW]

### Revise If Needed

If ANY verification question reveals a gap:
1. **FIX** - Address the specific gap identified
2. **RE-VERIFY** - Confirm the fix resolves the issue
3. **UPDATE** - Update the "Context for Next Steps" section

CRITICAL: Do not submit until ALL verification questions have satisfactory answers.
```

#### 3.3 Judge Verification Protocol

After implementation teammate completes, spawn an **independent judge teammate** to verify the step.

**Judge report location:** `.specs/reports/{task-name}-step-{N}-{YYYY-MM-DD}.md`

**Prompt template for step judge:**

```markdown
You are verifying completion of Step {N}/{total}: {subtask_name}

<original_task>
{overall_task_description}
</original_task>

<step_requirements>
{subtask_description}
- Input: {what this step receives}
- Expected output: {what this step should produce}
- Verification points: {how to check success}
</step_requirements>

<previous_steps_context>
{Summary of what previous steps accomplished}
</previous_steps_context>

<implementation_output>
{Path to files modified by implementation teammate}
{Context for Next Steps section from implementation teammate}
</implementation_output>

<output>
Write report to: .specs/reports/{task-name}-step-{N}-{YYYY-MM-DD}.md

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
</output>

Evaluation criteria:
1. **Correctness** (35%) - Does the implementation meet step requirements?
2. **Integration** (25%) - Does it properly build on previous steps?
3. **Completeness** (25%) - Are all required elements present?
4. **Quality** (15%) - Is the code/output well-structured?

Instructions:
1. Read the implementation files and "Context for Next Steps" output
2. Verify each requirement was met with specific evidence
3. Check integration with previous steps' outputs
4. Identify any gaps, issues, or missing elements
5. Score each criterion and calculate weighted total
6. Generate 3 verification questions to verify your report. Answer them, correct report if found issues
7. Provide VERDICT:
   - PASS: Score ≥3.5/5.0 AND no critical issues
   - FAIL: Score <3.5/5.0 OR critical issues present

CRITICAL: If FAIL, list specific issues that must be fixed for retry.
```

#### 3.4 Spawn Teammates, Verify, and Iterate

For each subtask in sequence:

```
1. Spawn implementation teammate:
   Agent(
     prompt: {constructed prompt with CoT + task + previous context + self-critique},
     team_name: "do-in-steps-{task-name}",
     name: "implementer-step-{N}"
   )

2. Collect implementation output:
   - Parse "Context for Next Steps" section from teammate response
   - Note files modified and verification points

3. Spawn judge teammate:
   Agent(
     prompt: {judge verification prompt with step requirements and implementation output},
     team_name: "do-in-steps-{task-name}",
     name: "judge-step-{N}"
   )

4. Parse judge verdict (DO NOT read full report):
   Extract from judge reply:
   - VERDICT: PASS or FAIL
   - SCORE: X.X/5.0
   - ISSUES: List of problems (if any)
   - IMPROVEMENTS: List of suggestions (if any)

5. Decision based on verdict:

   If VERDICT = PASS (score ≥3.5):
     → TaskUpdate(task_id, status: "completed")
     → Proceed to next step with accumulated context
     → Include IMPROVEMENTS in context as optional enhancements

   If VERDICT = FAIL (score <3.5):
     → Check retry count for this step

     If retries < 2:
       → SendMessage(to: "implementer-step-{N}", message: {retry instructions with judge feedback})
         OR spawn new teammate for retry:
       → Agent(
           prompt: {retry prompt with judge ISSUES},
           team_name: "do-in-steps-{task-name}",
           name: "implementer-step-{N}-retry-{R}"
         )
       → Return to step 3 (judge verification)

     If retries ≥ 2:
       → Escalate to user (see Error Handling)
       → Do NOT proceed to next step

6. Proceed to next subtask with accumulated context
```

**Retry prompt template for implementation teammate:**

```markdown
## Retry Required: Step {N}/{total}

Your previous implementation did not pass judge verification.

<original_requirements>
{subtask_description}
</original_requirements>

<judge_feedback>
VERDICT: FAIL
SCORE: {score}/5.0
ISSUES:
{list of issues from judge}

Full report available at: {path_to_judge_report}
</judge_feedback>

<your_previous_output>
{files modified in previous attempt}
</your_previous_output>

Instructions:
Let's fix the identified issues step by step.

1. First, review each issue the judge identified
2. For each issue, determine the root cause
3. Plan the fix for each issue
4. Implement ALL fixes
5. Verify your fixes address each issue
6. Provide updated "Context for Next Steps" section

CRITICAL: Focus on fixing the specific issues identified. Do not rewrite everything.
```

### Phase 4: Final Summary, Report, and Cleanup

After all subtasks complete and pass verification, reply with a comprehensive report and clean up the team:

```markdown
## Sequential Execution Summary

**Overall Task:** {original task description}
**Total Steps:** {count}
**Total Teammates:** {implementation_teammates + judge_teammates}

### Step-by-Step Results

| Step | Subtask | Model | Judge Score | Retries | Status |
|------|---------|-------|-------------|---------|--------|
| 1 | {name} | {model} | {X.X}/5.0 | {0-2} | PASS |
| 2 | {name} | {model} | {X.X}/5.0 | {0-2} | PASS |
| ... | ... | ... | ... | ... | ... |

### Files Modified (All Steps)
- {file1}: {what changed, which step}
- {file2}: {what changed, which step}
...

### Key Decisions Made
- Step 1: {decision and rationale}
- Step 2: {decision and rationale}
...

### Integration Points
{How the steps connected and built upon each other}

### Judge Verification Summary
| Step | Initial Score | Final Score | Issues Fixed |
|------|---------------|-------------|--------------|
| 1 | {X.X} | {X.X} | {count or "None"} |
| 2 | {X.X} | {X.X} | {count or "None"} |

### Reports Directory
Judge reports saved to: `.specs/reports/{task-name}-step-*`

### Follow-up Recommendations
{Any improvements suggested by judges, tests to run, or manual verification needed}
```

**Cleanup:**

```
1. SendMessage(to: each active teammate, message: "Work complete. Please shut down.")
2. TeamDelete()  — clean up team config and task directory
```

## Error Handling

### If Judge Verification Fails (Score <3.5)

The judge-verified iteration loop handles most failures automatically:

```
Judge FAIL (Retry Available):
  1. Parse ISSUES from judge verdict
  2. SendMessage feedback to implementer OR spawn retry teammate
  3. Re-verify with judge teammate
  4. Repeat until PASS or max retries (2)
```

### If Step Fails After Max Retries

When a step fails judge verification twice:

1. **STOP** - Do not proceed with broken foundation
2. **Report** - Provide failure analysis:
   - Original step requirements
   - All judge verdicts and scores
   - Persistent issues across retries
3. **Escalate** - Present options to user:
   - Provide additional context/guidance for retry
   - Modify step requirements
   - Skip step (if optional)
   - Abort and report partial progress
4. **Wait** - Do NOT proceed without user decision

**Escalation Report Format:**

```markdown
## Step {N} Failed Verification (Max Retries Exceeded)

### Step Requirements
{subtask_description}

### Verification History
| Attempt | Score | Key Issues |
|---------|-------|------------|
| 1 | {X.X}/5.0 | {issues} |
| 2 | {X.X}/5.0 | {issues} |
| 3 | {X.X}/5.0 | {issues} |

### Persistent Issues
{Issues that appeared in multiple attempts}

### Judge Reports
- .specs/reports/{task-name}-step-{N}-attempt-1.md
- .specs/reports/{task-name}-step-{N}-attempt-2.md
- .specs/reports/{task-name}-step-{N}-attempt-3.md

### Options
1. **Provide guidance** - Give additional context for another retry
2. **Modify requirements** - Simplify or clarify step requirements
3. **Skip step** - Mark as skipped and continue (if non-critical)
4. **Abort** - Stop execution and preserve partial progress

Awaiting your decision...
```

**Never:**

- Continue past a failed step after max retries
- Skip judge verification to "save time"
- Ignore persistent issues across retries
- Make assumptions about what might have worked

### If Context is Missing

1. **Do NOT guess** what previous steps produced
2. **Re-examine** previous step output for missing information
3. **Check judge reports** - they may have noted missing elements
4. **SendMessage** to the relevant teammate to request clarification
5. **Update context passing** for future similar tasks

### If Steps Conflict

1. **Stop execution** at conflict point
2. **Analyze:** Was decomposition incorrect? Are steps actually dependent?
3. **Check judge feedback** - judges may have flagged integration issues
4. **Options:**
   - Re-order steps if dependency was missed
   - Combine conflicting steps into one
   - Add reconciliation step between conflicting steps

## Examples

### Example 1: Interface Change with Consumer Updates

**Input:**

```
/do-in-steps Change the return type of UserService.getUser() from User to UserDTO and update all consumers
```

**Phase 1 - Decomposition:**

| Step | Subtask | Depends On | Complexity | Type | Output |
|------|---------|------------|------------|------|--------|
| 1 | Create UserDTO class with proper structure | - | Medium | Implementation | New UserDTO.ts file |
| 2 | Update UserService.getUser() to return UserDTO | Step 1 | High | Implementation | Modified UserService |
| 3 | Update UserController to handle UserDTO | Step 2 | Medium | Refactoring | Modified UserController |
| 4 | Update tests for UserService and UserController | Steps 2,3 | Medium | Testing | Updated test files |

**Team Setup:**

```
TeamCreate("do-in-steps-user-dto-refactor", "Sequential DTO refactoring for UserService")
TaskCreate("Step 1: Create UserDTO", "...")
TaskCreate("Step 2: Update UserService", "...")
TaskCreate("Step 3: Update UserController", "...")
TaskCreate("Step 4: Update tests", "...")
```

**Phase 3 - Execution with Judge Verification:**

```
Step 1: Create UserDTO
  Agent(prompt: ..., team_name: "do-in-steps-user-dto-refactor", name: "implementer-step-1")
    -> Created UserDTO.ts with id, name, email, createdAt fields
  Agent(prompt: ..., team_name: "do-in-steps-user-dto-refactor", name: "judge-step-1")
    -> VERDICT: PASS, SCORE: 4.2/5.0
    -> IMPROVEMENTS: Consider adding validation methods
  TaskUpdate(task_id: step-1, status: "completed")
  -> Context passed via SendMessage to next implementer

Step 2: Update UserService (First Attempt Failed)
  Agent(prompt: ..., team_name: "...", name: "implementer-step-2")
    -> Updated return type but missed mapping logic
  Agent(prompt: ..., team_name: "...", name: "judge-step-2")
    -> VERDICT: FAIL, SCORE: 2.8/5.0
    -> ISSUES: Missing User->UserDTO mapping, return type changed but still returns User
  SendMessage(to: "implementer-step-2", message: "Retry with judge feedback: ...")
  OR Agent(prompt: ..., team_name: "...", name: "implementer-step-2-retry-1")
    -> Added static fromUser() factory method
    -> Updated getUser() to use mapping
  Agent(prompt: ..., team_name: "...", name: "judge-step-2-retry")
    -> VERDICT: PASS, SCORE: 4.5/5.0
  TaskUpdate(task_id: step-2, status: "completed")

Step 3: Update UserController
  Agent(prompt: ..., team_name: "...", name: "implementer-step-3")
    -> Updated controller to expect UserDTO
  Agent(prompt: ..., team_name: "...", name: "judge-step-3")
    -> VERDICT: PASS, SCORE: 4.0/5.0
  TaskUpdate(task_id: step-3, status: "completed")

Step 4: Update Tests
  Agent(prompt: ..., team_name: "...", name: "implementer-step-4")
    -> Updated service and controller tests
  Agent(prompt: ..., team_name: "...", name: "judge-step-4")
    -> VERDICT: PASS, SCORE: 4.3/5.0
  TaskUpdate(task_id: step-4, status: "completed")
```

**Cleanup:**

```
SendMessage(to: all active teammates, message: "Shutdown request")
TeamDelete()
```

**Final Summary:**

- Total Teammates: 9 (4 implementations + 1 retry + 4 judges)
- Steps with Retries: Step 2 (1 retry)
- All Judge Scores: 4.2, 4.5, 4.0, 4.3

---

### Example 2: Feature Addition Across Layers

**Input:**

```
/do-in-steps Add email notification capability to the order processing system
```

**Phase 1 - Decomposition:**

| Step | Subtask | Depends On | Complexity | Type | Output |
|------|---------|------------|------------|------|--------|
| 1 | Create EmailService with send capability | - | Medium | Implementation | New EmailService class |
| 2 | Add notification triggers to OrderService | Step 1 | Medium | Implementation | Modified OrderService |
| 3 | Create email templates for order events | Step 2 | Low | Documentation | Template files |
| 4 | Add configuration and environment variables | Step 1 | Low | Configuration | Updated config files |
| 5 | Add integration tests for email flow | Steps 1-4 | Medium | Testing | Test files |

**Phase 2 - Model Selection:**

| Step | Subtask | Impl Model | Judge Model | Rationale |
|------|---------|------------|-------------|-----------|
| 1 | EmailService | sonnet | sonnet | Standard implementation |
| 2 | Notification triggers | sonnet | sonnet | Business logic |
| 3 | Email templates | haiku | haiku | Simple content |
| 4 | Configuration | haiku | haiku | Mechanical updates |
| 5 | Integration tests | sonnet | sonnet | Test expertise |

**Phase 3 - Execution Summary:**

| Step | Subtask | Judge Score | Retries | Status |
|------|---------|-------------|---------|--------|
| 1 | EmailService | 4.1/5.0 | 0 | PASS |
| 2 | Notification triggers | 3.8/5.0 | 1 | PASS |
| 3 | Email templates | 4.5/5.0 | 0 | PASS |
| 4 | Configuration | 4.2/5.0 | 0 | PASS |
| 5 | Integration tests | 4.0/5.0 | 0 | PASS |

Total Teammates: 11 (5 implementations + 1 retry + 5 judges)

---

### Example 3: Multi-file Refactoring with Escalation

**Input:**

```
/do-in-steps Rename 'userId' to 'accountId' across the codebase - this affects interfaces, implementations, and callers
```

**Phase 1 - Decomposition:**

| Step | Subtask | Depends On | Complexity | Type | Output |
|------|---------|------------|------------|------|--------|
| 1 | Update interface definitions | - | High | Refactoring | Updated interfaces |
| 2 | Update implementations of those interfaces | Step 1 | Low | Refactoring | Updated implementations |
| 3 | Update callers and consumers | Step 2 | Low | Refactoring | Updated caller files |
| 4 | Update tests | Step 3 | Low | Testing | Updated test files |
| 5 | Update documentation | Step 4 | Low | Documentation | Updated docs |

**Phase 2 - Model Selection:**

| Step | Subtask | Impl Model | Judge Model | Rationale |
|------|---------|------------|-------------|-----------|
| 1 | Update interfaces | opus | sonnet | Breaking changes need careful handling |
| 2 | Update implementations | haiku | haiku | Mechanical rename |
| 3 | Update callers | haiku | haiku | Mechanical updates |
| 4 | Update tests | haiku | haiku | Mechanical test fixes |
| 5 | Update documentation | haiku | haiku | Simple text updates |

**Phase 3 - Execution with Escalation:**

```
Step 1: Update interfaces
  -> Judge: PASS, 4.3/5.0

Step 2: Update implementations
  -> Judge: PASS, 4.0/5.0

Step 3: Update callers (Problem Detected)
  Attempt 1: Judge FAIL, 2.5/5.0
    -> ISSUES: Missed 12 occurrences in legacy module
  Attempt 2: Judge FAIL, 2.8/5.0
    -> ISSUES: Still missing 4 occurrences, found new deprecated API usage
  Attempt 3: Judge FAIL, 3.2/5.0
    -> ISSUES: 2 occurrences in dynamically generated code

  ESCALATION TO USER:
  "Step 3 failed after 3 attempts. Persistent issue: Dynamic code generation
   in LegacyAdapter.ts generates 'userId' at runtime.
   Options: 1) Provide guidance, 2) Modify requirements, 3) Skip, 4) Abort"

  User response: "Update LegacyAdapter to use string template with accountId"

  Attempt 4 (with user guidance): Judge PASS, 4.1/5.0

Step 4-5: Complete without issues

TeamDelete()  — cleanup
```

Total Teammates: 14 (5 implementations + 4 retries + 5 judges)

## Best Practices

### Task Decomposition

- **Be explicit:** Each subtask should have a clear, verifiable outcome
- **Define verification points:** What should the judge check for each step?
- **Minimize steps:** Combine related work; don't over-decompose
- **Validate dependencies:** Ensure each step has what it needs from previous steps
- **Plan context:** Identify what context needs to pass between steps

### Model Selection

- **Match complexity:** Don't use Opus for simple transformations
- **Upgrade for risk:** First step and critical steps deserve stronger models
- **Consider chain effect:** Errors in early steps cascade; invest in quality early
- **When in doubt, use Opus:** Quality over cost for dependent steps
- **Judges can use Sonnet:** Verification is less complex than implementation

| Step Type | Implementation Model | Judge Model |
|-----------|---------------------|-------------|
| Critical/Breaking | Opus | Opus |
| Standard | Opus | Opus |
| Long and Simple | Sonnet | Sonnet |
| Simple and Short | Haiku | Haiku |

### Context Passing Guidelines

| Scenario | What to Pass | What to Omit |
|----------|--------------|--------------|
| Interface defined in step 1 | Full interface definition | Implementation details |
| Implementation in step 2 | Key patterns, file locations | Internal logic |
| Integration in step 3 | Usage patterns, entry points | Step 2 internal details |
| Judge feedback for retry | ISSUES list, report path | Full report contents |

**Keep context focused:**

- Pass what the next step NEEDS to build on
- Omit internal details that don't affect subsequent steps
- Highlight patterns/conventions to maintain consistency
- Include judge IMPROVEMENTS as optional enhancements
- Use SendMessage to relay context between teammates

### Judge Verification

- **After self-critique:** Judge reviews work that already passed internal verification
- **Independent verification:** Judge is a different teammate than the implementer
- **Structured output:** Always parse VERDICT/SCORE from reply, not full report
- **Threshold:** 3.5/5.0 minimum score for PASS
- **Max retries:** 2 attempts before escalating to user
- **Feedback loop:** SendMessage judge ISSUES to retry implementation teammate

**Judge Selection:**

- Use Opus for most verification (balanced cost/quality)
- Use Sonnet for long and simple step verification
- Use Haiku for simple and short step verification

### Quality Assurance

- **Two-layer verification:** Self-critique (internal) + Judge (external)
- **Self-critique first:** Implementation teammates verify own work before submission
- **External judge second:** Independent judge teammate catches blind spots self-critique misses
- **Iteration loop:** Retry with feedback via SendMessage until passing or max retries
- **Chain validation:** Judges check integration with previous steps
- **Escalation:** Don't proceed past failed steps - get user input
- **Final integration test:** After all steps, verify the complete change works together
- **Cleanup:** Always TeamDelete when done to free resources

## Context Format Reference

### Implementation Teammate Output Format

```markdown
## Context for Next Steps

### Files Modified
- `src/dto/UserDTO.ts` (new file)
- `src/services/UserService.ts` (modified)

### Key Changes Summary
- Created UserDTO with fields: id (string), name (string), email (string), createdAt (Date)
- UserDTO includes static `fromUser(user: User): UserDTO` factory method
- Added `toDTO()` method to User class for convenience

### Decisions That Affect Later Steps
- Used class-based DTO (not interface) to enable transformation methods
- Opted for explicit mapping over automatic serialization for better control

### Warnings for Subsequent Steps
- UserDTO does NOT include password field - ensure no downstream code expects it
- The `createdAt` field is formatted as ISO string in JSON serialization

### Verification Points
- TypeScript compiles without errors
- UserDTO.fromUser() correctly maps all User properties
- Existing service tests still pass
```

### Judge Verdict Format (Structured Header)

```markdown
---
VERDICT: PASS
SCORE: 4.2/5.0
ISSUES:
  - None
IMPROVEMENTS:
  - Consider adding input validation to fromUser() method
  - Add JSDoc comments for better IDE support
---

## Detailed Evaluation

### Correctness (35%) - Score: 4.5/5.0
[Evidence and analysis...]

### Integration (25%) - Score: 4.0/5.0
[Evidence and analysis...]

### Completeness (25%) - Score: 4.2/5.0
[Evidence and analysis...]

### Quality (15%) - Score: 4.0/5.0
[Evidence and analysis...]
```

### Judge Verdict Format (FAIL Example)

```markdown
---
VERDICT: FAIL
SCORE: 2.8/5.0
ISSUES:
  - Missing User->UserDTO mapping logic in getUser() method
  - Return type annotation changed but actual return value still returns User object
  - No null handling for optional User fields
IMPROVEMENTS:
  - Add static fromUser() factory method to UserDTO
  - Implement toDTO() as instance method on User class
---
```

**Key Insight:** Complex tasks with dependencies benefit from sequential execution where each teammate operates in a fresh context while receiving only the relevant outputs from previous steps via SendMessage. **External judge verification** by an independent teammate catches blind spots that self-critique misses, while the **iteration loop** ensures quality before proceeding. TeamCreate provides shared task tracking, and TeamDelete ensures clean resource management. This prevents both context pollution and error propagation.
