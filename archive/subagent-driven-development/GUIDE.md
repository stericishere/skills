---
name: sadd:team-driven-development
description: Use when executing implementation plans with independent tasks in the current session or facing 3+ independent issues that can be investigated without shared state or dependencies - creates an agent team with fresh teammates for each task, with code review between tasks, enabling fast iteration with quality gates
---

# Team-Driven Development

Create and execute plan by spawning fresh teammates per task or issue via the Agent Teams API, with code and output review after each or batch of tasks.

**Core principle:** Fresh teammate per task + review between or after tasks = high quality, fast iteration.

Executing Plans through agent teams:

- Same session (no context switch)
- Fresh teammate per task (no context pollution)
- Code review after each or batch of tasks (catch issues early)
- Faster iteration (no human-in-loop between tasks)
- Shared task list for visibility and coordination

## Supported types of execution

### Sequential Execution

When you have tasks or issues that are related to each other, and they need to be executed in order, investigating or modifying them sequentially is the best way to go.

Spawn one teammate per task or issue. Let it work sequentially. Review the output and code after each task or issue.

**When to use:**

- Tasks are tightly coupled
- Tasks should be executed in order

### Parallel Execution

When you have multiple unrelated tasks or issues (different files, different subsystems, different bugs), investigating or modifying them sequentially wastes time. Each task or investigation is independent and can happen in parallel.

Spawn one teammate per independent problem domain. Let them work concurrently. Teammates can use SendMessage to share findings if needed.

**When to use:**

- Tasks are mostly independent
- Overall review can be done after all tasks are completed

## Team Setup

Before starting any execution mode, create the team:

```
1. TeamCreate("tdd-{plan-name}", "Team-driven development: {plan description}")
   → Creates team config at ~/.claude/teams/{name}/config.json
   → Creates task directory at ~/.claude/tasks/{name}/

2. For each task in the plan:
   TaskCreate(
     title: "Task {N}: {task name}",
     description: "{task details, inputs, expected outputs}"
   )
```

## Sequential Execution Process

### 1. Load Plan

Read plan file, create team with TeamCreate, populate tasks with TaskCreate.

### 2. Execute Task with Teammate

For each task:

**Spawn fresh teammate:**

```
Agent(
  prompt: |
    You are implementing Task N from [plan-file].

    Read that task carefully. Your job is to:
    1. Implement exactly what the task specifies
    2. Write tests (following TDD if task says to)
    3. Verify implementation works
    4. Commit your work
    5. Report back

    Work from: [directory]

    Report: What you implemented, what you tested, test results, files changed, any issues
  ,
  team_name: "tdd-{plan-name}",
  name: "implementer-task-{N}"
)
```

**Teammate reports back** with summary of work.

### 3. Review Teammate's Work

**Spawn code-reviewer teammate:**

```
Agent(
  prompt: |
    Use template at requesting-code-review/code-reviewer.md

    WHAT_WAS_IMPLEMENTED: [from teammate's report]
    PLAN_OR_REQUIREMENTS: Task N from [plan-file]
    BASE_SHA: [commit before task]
    HEAD_SHA: [current commit]
    DESCRIPTION: [task summary]
  ,
  team_name: "tdd-{plan-name}",
  name: "reviewer-task-{N}"
)
```

**Code reviewer returns:** Strengths, Issues (Critical/Important/Minor), Assessment

### 4. Apply Review Feedback

**If issues found:**

- Fix Critical issues immediately
- Fix Important issues before next task
- Note Minor issues

**Spawn follow-up teammate if needed:**

```
Agent(
  prompt: "Fix issues from code review: [list issues]",
  team_name: "tdd-{plan-name}",
  name: "fixer-task-{N}"
)
```

Or use SendMessage to relay feedback:

```
SendMessage(to: "implementer-task-{N}", message: "Fix these issues: [list]")
```

### 5. Mark Complete, Next Task

- TaskUpdate(task_id, status: "completed")
- Move to next task
- Repeat steps 2-5

### 6. Final Review

After all tasks complete, spawn final code-reviewer teammate:

- Reviews entire implementation
- Checks all plan requirements met
- Validates overall architecture

```
Agent(
  prompt: "Final review of entire implementation...",
  team_name: "tdd-{plan-name}",
  name: "final-reviewer"
)
```

### 7. Complete Development and Cleanup

After final review passes:

- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice
- **Cleanup:**
  ```
  SendMessage(to: all active teammates, message: "Work complete. Please shut down.")
  TeamDelete()  — clean up team config and task directory
  ```

### Example Workflow

```
You: I'm using Team-Driven Development to execute this plan.

[TeamCreate("tdd-hook-system", "Hook system implementation")]
[TaskCreate for each task]
[Load plan, populate task list]

Task 1: Hook installation script

[Spawn implementation teammate]
Agent(prompt: ..., team_name: "tdd-hook-system", name: "implementer-task-1")
Teammate: Implemented install-hook with tests, 5/5 passing

[Get git SHAs, spawn code-reviewer teammate]
Agent(prompt: ..., team_name: "tdd-hook-system", name: "reviewer-task-1")
Reviewer: Strengths: Good test coverage. Issues: None. Ready.

[TaskUpdate(task-1, status: "completed")]

Task 2: Recovery modes

[Spawn implementation teammate]
Agent(prompt: ..., team_name: "tdd-hook-system", name: "implementer-task-2")
Teammate: Added verify/repair, 8/8 tests passing

[Spawn code-reviewer teammate]
Agent(prompt: ..., team_name: "tdd-hook-system", name: "reviewer-task-2")
Reviewer: Strengths: Solid. Issues (Important): Missing progress reporting

[Spawn fix teammate]
Agent(prompt: ..., team_name: "tdd-hook-system", name: "fixer-task-2")
Fix teammate: Added progress every 100 conversations

[Verify fix, TaskUpdate(task-2, status: "completed")]

...

[After all tasks]
[Spawn final code-reviewer teammate]
Agent(prompt: ..., team_name: "tdd-hook-system", name: "final-reviewer")
Final reviewer: All requirements met, ready to merge

[SendMessage to all teammates: "Shutdown request"]
[TeamDelete()]

Done!
```

### Red Flags

**Never:**

- Skip code review between tasks
- Proceed with unfixed Critical issues
- Spawn multiple implementation teammates in parallel for sequential mode (conflicts)
- Implement without reading plan task

**If teammate fails task:**

- Spawn fix teammate with specific instructions or SendMessage feedback
- Don't try to fix manually (context pollution)

## Parallel Execution Process

Load plan, review critically, execute tasks in batches with parallel teammates, report for review between batches.

**Core principle:** Batch execution with checkpoints for architect review.

**Announce at start:** "I'm using the Team-Driven Development skill to implement this plan."

### Step 1: Load and Review Plan

1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: TeamCreate, TaskCreate for all tasks, and proceed

### Step 2: Execute Batch

**Default: First 3 tasks**

For each task in batch:

1. TaskUpdate(task_id, status: "in_progress")
2. Spawn teammate:
   ```
   Agent(
     prompt: "Implement Task N from [plan]...",
     team_name: "tdd-{plan-name}",
     name: "implementer-task-{N}"
   )
   ```
3. All teammates in the batch run concurrently
4. Teammates can use SendMessage to share findings with each other if tasks overlap

### Step 3: Report

When batch complete:

- Show what was implemented (from teammate reports)
- Show verification output
- TaskUpdate for each completed task
- Say: "Ready for feedback."

### Step 4: Continue

Based on feedback:

- Apply changes if needed (spawn fix teammates)
- Execute next batch
- Repeat until complete

### Step 5: Complete Development and Cleanup

After all tasks complete and verified:

- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice
- **Cleanup:**
  ```
  SendMessage(to: all active teammates, message: "Shutdown request")
  TeamDelete()
  ```

### When to Stop and Ask for Help

**STOP executing immediately when:**

- Hit a blocker mid-batch (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

### When to Revisit Earlier Steps

**Return to Review (Step 1) when:**

- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

### Remember

- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Between batches: just report and wait
- Stop when blocked, don't guess
- Always TeamDelete when done

## Parallel Investigation Process

Special case of parallel execution, when you have multiple unrelated failures that can be investigated without shared state or dependencies.

### 1. Identify Independent Domains

Group failures by what's broken:

- File A tests: Tool approval flow
- File B tests: Batch completion behavior
- File C tests: Abort functionality

Each domain is independent - fixing tool approval doesn't affect abort tests.

### 2. Create Team and Focused Tasks

```
TeamCreate("tdd-investigation-{topic}", "Parallel investigation of {N} independent failures")

For each domain:
  TaskCreate(
    title: "Investigate: {domain name}",
    description: "{specific scope, clear goal, constraints, expected output}"
  )
```

Each teammate gets:

- **Specific scope:** One test file or subsystem
- **Clear goal:** Make these tests pass
- **Constraints:** Don't change other code
- **Expected output:** Summary of what you found and fixed

### 3. Spawn Teammates in Parallel

```
Agent(
  prompt: "Fix agent-tool-abort.test.ts failures...",
  team_name: "tdd-investigation-{topic}",
  name: "investigator-abort"
)
Agent(
  prompt: "Fix batch-completion-behavior.test.ts failures...",
  team_name: "tdd-investigation-{topic}",
  name: "investigator-batch"
)
Agent(
  prompt: "Fix tool-approval-race-conditions.test.ts failures...",
  team_name: "tdd-investigation-{topic}",
  name: "investigator-approval"
)
// All three run concurrently as teammates in the same team
// They can SendMessage to each other if they discover shared issues
```

### 4. Review and Integrate

When teammates return:

- Read each summary
- Verify fixes don't conflict
- Run full test suite
- Integrate all changes
- TaskUpdate for each completed investigation
- TeamDelete when done

### Teammate Prompt Structure

Good teammate prompts are:

1. **Focused** - One clear problem domain
2. **Self-contained** - All context needed to understand the problem
3. **Specific about output** - What should the teammate return?

```markdown
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. "should abort tool with partial output capture" - expects 'interrupted at' in message
2. "should handle mixed completed and aborted tools" - fast tool aborted instead of completed
3. "should properly track pendingToolCount" - expects 3 results but gets 0

These are timing/race condition issues. Your task:

1. Read the test file and understand what each test verifies
2. Identify root cause - timing issues or actual bugs?
3. Fix by:
   - Replacing arbitrary timeouts with event-based waiting
   - Fixing bugs in abort implementation if found
   - Adjusting test expectations if testing changed behavior

Do NOT just increase timeouts - find the real issue.

If you discover this is related to another domain, use SendMessage(to: "investigator-{other}", message: "Found shared issue: ...")

Return: Summary of what you found and what you fixed.
```

### Common Mistakes

**Bad: Too broad:** "Fix all the tests" - teammate gets lost
**Good: Specific:** "Fix agent-tool-abort.test.ts" - focused scope

**Bad: No context:** "Fix the race condition" - teammate doesn't know where
**Good: Context:** Paste the error messages and test names

**Bad: No constraints:** Teammate might refactor everything
**Good: Constraints:** "Do NOT change production code" or "Fix tests only"

**Bad: Vague output:** "Fix it" - you don't know what changed
**Good: Specific:** "Return summary of root cause and changes"

### When NOT to Use

**Related failures:** Fixing one might fix others - investigate together first
**Need full context:** Understanding requires seeing entire system
**Exploratory debugging:** You don't know what's broken yet
**Shared state:** Teammates would interfere (editing same files, using same resources)

### Real Example from Session

**Scenario:** 6 test failures across 3 files after major refactoring

**Failures:**

- agent-tool-abort.test.ts: 3 failures (timing issues)
- batch-completion-behavior.test.ts: 2 failures (tools not executing)
- tool-approval-race-conditions.test.ts: 1 failure (execution count = 0)

**Decision:** Independent domains - abort logic separate from batch completion separate from race conditions

**Team Setup:**

```
TeamCreate("tdd-investigation-test-failures", "Parallel investigation of 3 test failure domains")
TaskCreate("Investigate: abort timing", "Fix agent-tool-abort.test.ts failures")
TaskCreate("Investigate: batch completion", "Fix batch-completion-behavior.test.ts failures")
TaskCreate("Investigate: race conditions", "Fix tool-approval-race-conditions.test.ts failures")
```

**Spawn Teammates:**

```
Agent(prompt: ..., team_name: "tdd-investigation-test-failures", name: "investigator-abort")
Agent(prompt: ..., team_name: "tdd-investigation-test-failures", name: "investigator-batch")
Agent(prompt: ..., team_name: "tdd-investigation-test-failures", name: "investigator-approval")
```

**Results:**

- investigator-abort: Replaced timeouts with event-based waiting
- investigator-batch: Fixed event structure bug (threadId in wrong place)
- investigator-approval: Added wait for async tool execution to complete

**Integration:** All fixes independent, no conflicts, full suite green

**Cleanup:**

```
TaskUpdate for each investigation: status: "completed"
SendMessage(to: all teammates, message: "Shutdown request")
TeamDelete()
```

**Time saved:** 3 problems solved in parallel vs sequentially

### Verification

After teammates return:

1. **Review each summary** - Understand what changed
2. **Check for conflicts** - Did teammates edit same code?
3. **Run full suite** - Verify all fixes work together
4. **Spot check** - Teammates can make systematic errors
5. **TaskUpdate** - Mark all completed
6. **TeamDelete** - Clean up when done
