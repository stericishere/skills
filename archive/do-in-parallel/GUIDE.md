---
name: sadd:do-in-parallel
description: Launch multiple teammates in parallel to execute tasks across files or targets with intelligent model selection and quality-focused prompting
argument-hint: Task description [--files "file1.ts,file2.ts,..."] [--targets "target1,target2,..."] [--model opus|sonnet|haiku] [--output <path>]
---

# do-in-parallel

<task>
Launch multiple teammates in parallel to execute the same task across different files or targets. Analyze the task to intelligently select the optimal model, generate quality-focused prompts with Zero-shot Chain-of-Thought reasoning and mandatory self-critique, then dispatch all teammates simultaneously via an agent team and collect results.
</task>

<context>
This command implements the **Supervisor/Orchestrator pattern** with parallel dispatch via the Agent Teams API. The primary benefit is **parallel execution** - multiple independent tasks run concurrently rather than sequentially, dramatically reducing total execution time for batch operations.

**Common use cases:**
- Apply the same refactoring across multiple files
- Run code analysis on several modules simultaneously
- Generate documentation for multiple components
- Execute independent transformations in parallel
</context>

## Process

### Phase 1: Parse Input and Identify Targets

Extract targets from the command arguments:

```
Input patterns:
1. --files "src/a.ts,src/b.ts,src/c.ts"    --> File-based targets
2. --targets "UserService,OrderService"    --> Named targets
3. Infer from task description             --> Parse file paths from task
```

**Parsing rules:**
- If `--files` provided: Split by comma, validate each path exists
- If `--targets` provided: Split by comma, use as-is
- If neither: Attempt to extract file paths or target names from task description

### Phase 2: Task Analysis with Zero-shot CoT

Before dispatching, analyze the task systematically:

```
Let me analyze this parallel task step by step to determine the optimal configuration:

1. **Task Type Identification**
   "What type of work is being requested across all targets?"
   - Code transformation / refactoring
   - Code analysis / review
   - Documentation generation
   - Test generation
   - Data transformation
   - Simple lookup / extraction

2. **Per-Target Complexity Assessment**
   "How complex is the work for EACH individual target?"
   - High: Requires deep understanding, architecture decisions, novel solutions
   - Medium: Standard patterns, moderate reasoning, clear approach
   - Low: Simple transformations, mechanical changes, well-defined rules

3. **Per-Target Output Size**
   "How extensive is each target's expected output?"
   - Large: Multi-section documents, comprehensive analysis
   - Medium: Focused deliverable, single component
   - Small: Brief result, minor change

4. **Independence Check**
   "Are the targets truly independent?"
   - Yes: No shared state, no cross-dependencies, order doesn't matter
   - Partial: Some shared context needed, but can run in parallel
   - No: Dependencies exist --> Use sequential execution instead
```

#### Independence Validation (REQUIRED before parallel dispatch)

Verify tasks are truly independent before proceeding:

| Check | Question | If NO |
|-------|----------|-------|
| File Independence | Do targets share files? | Cannot parallelize - files conflict |
| State Independence | Do tasks modify shared state? | Cannot parallelize - race conditions |
| Order Independence | Does execution order matter? | Cannot parallelize - sequencing required |
| Output Independence | Does any target read another's output? | Cannot parallelize - data dependency |

**Independence Checklist:**
- [ ] No target reads output from another target
- [ ] No target modifies files another target reads
- [ ] Order of completion doesn't matter
- [ ] No shared mutable state
- [ ] No database transactions spanning targets

If ANY check fails: STOP and inform user why parallelization is unsafe. Recommend sequential execution instead.

### Phase 3: Model and Agent Selection

Select the optimal model and specialized agent based on task analysis. **Same configuration for all parallel teammates** (ensures consistent quality):

#### 3.1 Model Selection

| Task Profile | Recommended Model | Rationale |
|--------------|-------------------|-----------|
| **Complex per-target** (architecture, design) | `opus` | Maximum reasoning capability per task |
| **Specialized domain** (code review, security) | `opus` | Domain expertise matters |
| **Medium complexity, large output** | `sonnet` | Good capability, cost-efficient for volume |
| **Simple transformations** (rename, format) | `haiku` | Fast, cheap, sufficient for mechanical tasks |
| **Default** (when uncertain) | `opus` | Optimize for quality over cost |

**Decision Tree:**

```
Is EACH target's task COMPLEX (architecture, novel problem, critical decision)?
|
+-- YES --> Use Opus for ALL teammates
|
+-- NO --> Is task SIMPLE and MECHANICAL (rename, format, extract)?
           |
           +-- YES --> Use Haiku for ALL teammates
           |
           +-- NO --> Is output LARGE but task not complex?
                      |
                      +-- YES --> Use Sonnet for ALL teammates
                      |
                      +-- NO --> Use Opus for ALL teammates (default)
```

#### 3.2 Specialized Agent Selection (Optional)

If the task matches a specialized domain, include the relevant agent prompt in ALL parallel teammates. Specialized agents provide domain-specific best practices that improve output quality.

**Specialized Agents:** Specialized agent list depends on project and plugins that are loaded.

**Decision:** Use specialized agent when:
- Task clearly benefits from domain expertise
- Consistency across all parallel teammates is important
- Task is NOT trivial (overhead not justified for simple tasks)

Skip specialized agent when:
- Task is simple/mechanical (Haiku-tier)
- No clear domain match exists
- General-purpose execution is sufficient

### Phase 4: Construct Per-Target Prompts

Build identical prompt structure for each target, customized only with target-specific details:

#### 4.1 Zero-shot Chain-of-Thought Prefix (REQUIRED - MUST BE FIRST)

```markdown
## Reasoning Approach

Let's think step by step.

Before taking any action, think through the problem systematically:

1. "Let me first understand what is being asked for this specific target..."
   - What is the core objective?
   - What are the explicit requirements?
   - What constraints must I respect?

2. "Let me analyze this specific target..."
   - What is the current state?
   - What patterns or conventions exist?
   - What context is relevant?

3. "Let me plan my approach..."
   - What are the concrete steps?
   - What could go wrong?
   - Is there a simpler approach?

Work through each step explicitly before implementing.
```

#### 4.2 Task Body (Customized per target)

```markdown
<task>
{Task description from $ARGUMENTS}
</task>

<target>
{Specific target for this agent: file path, component name, etc.}
</target>

<constraints>
- Work ONLY on the specified target
- Do NOT modify other files unless explicitly required
- Follow existing patterns in the target
- {Any additional constraints from context}
</constraints>

<output>
{Expected deliverable location and format}
</output>
```

#### 4.3 Self-Critique Suffix (REQUIRED - MUST BE LAST)

```markdown
## Self-Critique Verification (MANDATORY)

Before completing, verify your work for this target. Do not submit unverified changes.

### 1. Generate Verification Questions

Create questions specific to your task and target. There examples of questions:

| # | Question | Why It Matters |
|---|----------|----------------|
| 1 | Did I achieve the stated objective for this target? | Incomplete work = failed task |
| 2 | Are my changes consistent with patterns in this file/codebase? | Inconsistency creates technical debt |
| 3 | Did I introduce any regressions or break existing functionality? | Breaking changes are unacceptable |
| 4 | Are edge cases and error scenarios handled appropriately? | Edge cases cause production issues |
| 5 | Is my output clear, well-formatted, and ready for review? | Unclear output reduces value |

### 2. Answer Each Question with Evidence

For each question, provide specific evidence from your work:

[Q1] Objective Achievement:
- Required: [what was asked]
- Delivered: [what you did]
- Gap analysis: [any gaps]

[Q2] Pattern Consistency:
- Existing pattern: [observed pattern]
- My implementation: [how I followed it]
- Deviations: [any intentional deviations and why]

[Q3] Regression Check:
- Functions affected: [list]
- Tests that would catch issues: [if known]
- Confidence level: [HIGH/MEDIUM/LOW]

[Q4] Edge Cases:
- Edge case 1: [scenario] - [HANDLED/NOTED]
- Edge case 2: [scenario] - [HANDLED/NOTED]

[Q5] Output Quality:
- Well-organized: [YES/NO]
- Self-documenting: [YES/NO]
- Ready for PR: [YES/NO]

### 3. Fix Issues Before Submitting

If ANY verification reveals a gap:
1. **FIX** - Address the specific issue
2. **RE-VERIFY** - Confirm the fix resolves the issue
3. **DOCUMENT** - Note what was changed and why

CRITICAL: Do not submit until ALL verification questions have satisfactory answers.
```

### Phase 5: Team Setup and Parallel Dispatch

Create an agent team and launch all teammates simultaneously.

**CRITICAL: Agent Teams Dispatch Pattern**

**Step 1: Create the team**

```
TeamCreate(
  team_name: "parallel-{task-slug}",
  description: "Parallel execution of '{task}' across {N} targets"
)
```

**Step 2: Create tasks in the shared task list**

For each target, create a task:

```
TaskCreate(
  title: "Parallel: {task summary} in {target}",
  description: "{CoT prefix + task body for target + critique suffix}"
)
```

**Step 3: Spawn teammates — ALL in a SINGLE response**

Launch ALL teammates in a SINGLE response. Do NOT wait for one teammate to complete before starting another:

```markdown
## Dispatching 3 parallel teammates

[Teammate 1]
Agent(
  prompt: [CoT prefix + task body for target_1 + critique suffix],
  team_name: "parallel-{task-slug}",
  name: "worker-1"
)

[Teammate 2]
Agent(
  prompt: [CoT prefix + task body for target_2 + critique suffix],
  team_name: "parallel-{task-slug}",
  name: "worker-2"
)

[Teammate 3]
Agent(
  prompt: [CoT prefix + task body for target_3 + critique suffix],
  team_name: "parallel-{task-slug}",
  name: "worker-3"
)

[All 3 teammates launched simultaneously - results collected when all complete]
```

**Step 4: Monitor progress**

Use `TaskList` to check progress of all tasks in the team. Teammates self-claim unassigned tasks and mark them complete via `TaskUpdate(task_id, status: "completed")`.

**Parallelization Guidelines:**
- Launch ALL independent teammates in a single batch (same response)
- Do NOT wait for one teammate before starting another
- Do NOT make sequential Agent tool calls
- Agent Teams API handles parallelization automatically
- Results collected after all complete

**Context Isolation (IMPORTANT):**
- Pass only context relevant to each specific target
- Do NOT pass the full list of all targets to each teammate
- Let teammates discover local patterns through file reading
- Each teammate works in clean context without accumulated confusion

### Phase 6: Collect, Summarize, and Cleanup

After all teammates complete, aggregate results:

```markdown
## Parallel Execution Summary

### Configuration
- **Task:** {task description}
- **Model:** {selected model}
- **Team:** parallel-{task-slug}
- **Targets:** {count} items

### Results

| Target | Teammate | Status | Summary |
|--------|----------|--------|---------|
| {target_1} | worker-1 | SUCCESS/FAILED | {brief outcome} |
| {target_2} | worker-2 | SUCCESS/FAILED | {brief outcome} |
| ... | ... | ... | ... |

### Overall Assessment
- **Completed:** {X}/{total}
- **Failed:** {Y}/{total}
- **Common patterns:** {any patterns across results}

### Verification Summary
{Aggregate self-critique results - any common gaps?}

### Files Modified
- {list of all modified files}

### Next Steps
{If any failures, suggest remediation}
```

**Step 5: Clean up the team**

After collecting results, shut down teammates and delete the team:

```
SendMessage(to: "worker-1", message: "All tasks complete. Please shut down.")
SendMessage(to: "worker-2", message: "All tasks complete. Please shut down.")
SendMessage(to: "worker-3", message: "All tasks complete. Please shut down.")
TeamDelete()
```

**Failure Handling:**
- Report failed tasks clearly with error details
- Successful tasks are NOT affected by failures
- Do NOT retry automatically (let user decide)
- Suggest re-running failed targets individually

## Examples

### Example 1: Code Simplification Across Modules

**Input:**
```
/do-in-parallel "Simplify error handling to use early returns instead of nested if-else" \
  --files "src/services/user.ts,src/services/order.ts,src/services/payment.ts"
```

**Analysis:**
- Task type: Code transformation / refactoring
- Per-target complexity: Medium (pattern-based transformation)
- Output size: Medium (modified file)
- Independence: Yes (separate files, no cross-dependencies)

**Model Selection:** Sonnet (pattern-based, medium complexity)

**Dispatch:** 3 parallel teammates, one per file

**Result:**
```markdown
## Parallel Execution Summary

### Configuration
- **Task:** Simplify error handling to use early returns
- **Model:** Sonnet
- **Targets:** 3 files

### Results

| Target | Teammate | Status | Summary |
|--------|----------|--------|---------|
| src/services/user.ts | worker-1 | SUCCESS | Converted 4 nested if-else blocks to early returns |
| src/services/order.ts | worker-2 | SUCCESS | Converted 6 nested if-else blocks to early returns |
| src/services/payment.ts | worker-3 | SUCCESS | Converted 3 nested if-else blocks to early returns |

### Overall Assessment
- **Completed:** 3/3
- **Common patterns:** All files followed consistent early return pattern
```

---

### Example 2: Documentation Generation

**Input:**
```
/do-in-parallel "Generate JSDoc documentation for all public methods" \
  --files "src/api/users.ts,src/api/products.ts,src/api/orders.ts,src/api/auth.ts"
```

**Analysis:**
- Task type: Documentation generation
- Per-target complexity: Low (mechanical documentation)
- Output size: Medium (inline comments)
- Independence: Yes

**Model Selection:** Haiku (mechanical, well-defined rules)

**Dispatch:** 4 parallel teammates

---

### Example 3: Security Analysis

**Input:**
```
/do-in-parallel "Analyze for potential SQL injection vulnerabilities and suggest fixes" \
  --files "src/db/queries.ts,src/db/migrations.ts,src/api/search.ts"
```

**Analysis:**
- Task type: Security analysis
- Per-target complexity: High (security requires careful analysis)
- Output size: Medium (analysis report + suggestions)
- Independence: Yes

**Model Selection:** Opus (security-critical, requires deep analysis)

**Dispatch:** 3 parallel teammates

---

### Example 4: Test Generation

**Input:**
```
/do-in-parallel "Generate unit tests achieving 80% coverage" \
  --targets "UserService,OrderService,PaymentService,NotificationService"
```

**Analysis:**
- Task type: Test generation
- Per-target complexity: Medium (follow testing patterns)
- Output size: Large (multiple test files)
- Independence: Yes (separate services)

**Model Selection:** Sonnet (pattern-based, extensive output)

**Dispatch:** 4 parallel teammates

---

### Example 5: Inferred Targets from Task

**Input:**
```
/do-in-parallel "Apply consistent logging format to src/handlers/user.ts, src/handlers/order.ts, and src/handlers/product.ts"
```

**Analysis:**
- Targets inferred: 3 files extracted from task description
- Task type: Code transformation
- Complexity: Low
- Independence: Yes

**Model Selection:** Haiku (simple, mechanical)

**Dispatch:** 3 parallel teammates

## Best Practices

### Target Selection

- **Be specific:** List exact files when possible
- **Use globs carefully:** Review expanded list before confirming
- **Limit scope:** 10-15 targets max per batch for manageability
- **Group by similarity:** Similar targets benefit from consistent patterns

### Model Selection Guidelines

| Scenario | Model | Reason |
|----------|-------|--------|
| Security analysis | Opus | Critical reasoning required |
| Architecture decisions | Opus | Quality over speed |
| Simple refactoring | Haiku | Fast, sufficient |
| Documentation generation | Haiku | Mechanical task |
| Code review per file | Sonnet | Balanced capability |
| Test generation | Sonnet | Extensive but patterned |

### Context Isolation

- **Minimal context:** Each teammate gets only what it needs
- **No cross-references:** Don't tell Teammate A about Teammate B's target
- **Let them discover:** Teammates read files to understand patterns
- **File system as truth:** Changes are coordinated through the filesystem

### Quality Assurance

- **Self-critique is mandatory:** Every teammate must verify its work
- **Review the summary:** Check for failed or partial completions
- **Run tests after:** Parallel changes may have subtle interactions
- **Commit atomically:** All changes from one batch = one commit

#### Error Handling

| Failure Type | Description | Recovery Action |
|--------------|-------------|-----------------|
| **Recoverable** | Teammate made a mistake but approach is sound | Retry step with corrected prompt (max 1 retry) |
| **Approach Failure** | The approach for this step is wrong | Escalate to user with options |
| **Foundation Issue** | Previous step output is insufficient | May need to revisit earlier step |

**Critical Rules:**
- NEVER continue past a failed step
- NEVER try to "fix forward" without addressing the failure
- NEVER retry more than once without user input
- STOP and report if context is missing (don't guess)
