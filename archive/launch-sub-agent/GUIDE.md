---
name: sadd:launch-teammate
description: Launch an intelligent teammate with automatic model selection based on task complexity, specialized agent matching, Zero-shot CoT reasoning, and mandatory self-critique verification using Agent Teams
argument-hint: Task description (e.g., "Implement user authentication" or "Research caching strategies") [--model opus|sonnet|haiku] [--agent <agent-name>] [--output <path>]
---

# launch-teammate

<task>
Launch a focused teammate to execute the provided task. Analyze the task to intelligently select the optimal model and agent configuration, then spawn a teammate via the Agent Teams API with Zero-shot Chain-of-Thought reasoning at the beginning and mandatory self-critique verification at the end.
</task>

<context>
This command implements the **Agent Teams pattern** where you (the team lead) create a team, spawn a focused teammate with isolated context. The primary benefit is **context isolation** - each teammate operates in a clean context window focused on its specific task without accumulated context pollution. The Agent Teams API provides shared task tracking and inter-agent communication via SendMessage.
</context>

## Process

### Phase 1: Task Analysis with Zero-shot CoT

Before spawning the teammate, analyze the task systematically. Think through step by step:

```
Let me analyze this task step by step to determine the optimal configuration:

1. **Task Type Identification**
   "What type of work is being requested?"
   - Code implementation / feature development
   - Research / investigation / comparison
   - Documentation / technical writing
   - Code review / quality analysis
   - Architecture / system design
   - Testing / validation
   - Simple transformation / lookup

2. **Complexity Assessment**
   "How complex is the reasoning required?"
   - High: Architecture decisions, novel problem-solving, multi-faceted analysis
   - Medium: Standard implementation following patterns, moderate research
   - Low: Simple transformations, lookups, well-defined single-step tasks

3. **Output Size Estimation**
   "How extensive is the expected output?"
   - Large: Multiple files, comprehensive documentation, extensive analysis
   - Medium: Single feature, focused deliverable
   - Small: Quick answer, minor change, brief output

4. **Domain Expertise Check**
   "Does this task match a specialized agent profile?"
   - Development: code, implement, feature, endpoint, TDD, tests
   - Research: investigate, compare, evaluate, options, library
   - Documentation: document, README, guide, explain, tutorial
   - Architecture: design, system, structure, scalability
   - Exploration: understand, navigate, find, codebase patterns
```

### Phase 2: Model Selection

Select the optimal model based on task analysis:

| Task Profile | Recommended Model | Rationale |
|--------------|-------------------|-----------|
| **Complex reasoning** (architecture, design, critical decisions) | `opus` | Maximum reasoning capability |
| **Specialized domain** (matches agent profile) | Opus + Specialized Agent | Domain expertise + reasoning power |
| **Non-complex but long** (extensive docs, verbose output) | `sonnet[1m]` | Good capability, cost-efficient for length |
| **Simple and short** (trivial tasks, quick lookups) | `haiku` | Fast, cost-effective for easy tasks |
| **Default** (when uncertain) | `opus` | Optimize for quality over cost |

**Decision Tree:**

```
Is task COMPLEX (architecture, design, novel problem, critical decision)?
|
+-- YES --> Use Opus (highest capability)
|           |
|           +-- Does it match a specialized domain?
|               +-- YES --> Include specialized agent prompt
|               +-- NO --> Use Opus alone
|
+-- NO --> Is task SIMPLE and SHORT?
           |
           +-- YES --> Use Haiku (fast, cheap)
           |
           +-- NO --> Is output LONG but task not complex?
                      |
                      +-- YES --> Use Sonnet (balanced)
                      |
                      +-- NO --> Use Opus (default)
```

### Phase 3: Specialized Agent Matching

If the task matches a specialized domain, incorporate the relevant agent prompt. Specialized agents provide domain-specific best practices, quality standards, and structured approaches that improve output quality.

**Decision:** Use specialized agent when task clearly benefits from domain expertise. Skip for trivial tasks where specialization adds unnecessary overhead.

**Agents:** Available specialized agents depends on project and plugins installed. Common agents from the `sdd` plugin include: `sdd:developer`, `sdd:researcher`, `sdd:software-architect`, `sdd:tech-lead`, `sdd:team-lead`, `sdd:qa-engineer`, `sdd:code-explorer`, `sdd:business-analyst`. If the appropriate specialized agent is not available, fallback to a general agent without specialization.

**Integration with Model Selection:**

- Specialized agents are combined WITH model selection, not instead of
- Complex task + specialized domain = Opus + Specialized Agent
- Simple task matching domain = Haiku without specialization (overhead not justified)

**Usage:**

1. Read the agent definition
2. Include the agent's instructions in the teammate prompt AFTER the CoT prefix
3. Combine with Zero-shot CoT prefix and Critique suffix

### Phase 4: Construct Teammate Prompt

Build the teammate prompt with these mandatory components:

#### 4.1 Zero-shot Chain-of-Thought Prefix (REQUIRED - MUST BE FIRST)

```markdown
## Reasoning Approach

Before taking any action, you MUST think through the problem systematically.

Let's approach this step by step:

1. "Let me first understand what is being asked..."
   - What is the core objective?
   - What are the explicit requirements?
   - What constraints must I respect?

2. "Let me break this down into concrete steps..."
   - What are the major components of this task?
   - What order should I tackle them?
   - What dependencies exist between steps?

3. "Let me consider what could go wrong..."
   - What assumptions am I making?
   - What edge cases might exist?
   - What could cause this to fail?

4. "Let me verify my approach before proceeding..."
   - Does my plan address all requirements?
   - Is there a simpler approach?
   - Am I following existing patterns?

Work through each step explicitly before implementing.
```

#### 4.2 Task Body

```markdown
<task>
{Task description from $ARGUMENTS}
</task>

<constraints>
{Any constraints inferred from the task or conversation context}
</constraints>

<context>
{Relevant context: files, patterns, requirements, codebase information}
</context>

<output>
{Expected deliverable: format, location, structure}
</output>
```

#### 4.3 Self-Critique Suffix (REQUIRED - MUST BE LAST)

```markdown
## Self-Critique Loop (MANDATORY)

Before completing, you MUST verify your work. Submitting unverified work is UNACCEPTABLE.

### 1. Generate 5 Verification Questions

Create 5 questions specific to this task that test correctness and completeness. There example questions:

| # | Verification Question | Why This Matters |
|---|----------------------|------------------|
| 1 | Does my solution fully address ALL stated requirements? | Partial solutions = failed task |
| 2 | Have I verified every assumption against available evidence? | Unverified assumptions = potential failures |
| 3 | Are there edge cases or error scenarios I haven't handled? | Edge cases cause production issues |
| 4 | Does my solution follow existing patterns in the codebase? | Pattern violations create maintenance debt |
| 5 | Is my solution clear enough for someone else to understand and use? | Unclear output reduces value |

### 2. Answer Each Question with Evidence

For each question, examine your solution and provide specific evidence:

[Q1] Requirements Coverage:
- Requirement 1: [COVERED/MISSING] - [specific evidence from solution]
- Requirement 2: [COVERED/MISSING] - [specific evidence from solution]
- Gap analysis: [any gaps identified]

[Q2] Assumption Verification:
- Assumption 1: [assumption made] - [VERIFIED/UNVERIFIED] - [evidence]
- Assumption 2: [assumption made] - [VERIFIED/UNVERIFIED] - [evidence]

[Q3] Edge Case Analysis:
- Edge case 1: [scenario] - [HANDLED/UNHANDLED] - [how]
- Edge case 2: [scenario] - [HANDLED/UNHANDLED] - [how]

[Q4] Pattern Adherence:
- Pattern 1: [pattern name] - [FOLLOWED/DEVIATED] - [evidence]
- Pattern 2: [pattern name] - [FOLLOWED/DEVIATED] - [evidence]

[Q5] Clarity Assessment:
- Is the solution well-organized? [YES/NO]
- Are complex parts explained? [YES/NO]
- Could someone else use this immediately? [YES/NO]

### 3. Revise If Needed

If ANY verification question reveals a gap:
1. **STOP** - Do not submit incomplete work
2. **FIX** - Address the specific gap identified
3. **RE-VERIFY** - Confirm the fix resolves the issue
4. **DOCUMENT** - Note what was changed and why

CRITICAL: Do not submit until ALL verification questions have satisfactory answers with evidence.
```

### Phase 5: Create Team and Spawn Teammate

Set up the team and spawn the teammate with the selected configuration:

```
1. TeamCreate("launch-teammate-{task-name}", "Focused task execution: {task summary}")
   → Creates team config at ~/.claude/teams/{name}/config.json
   → Creates task directory at ~/.claude/tasks/{name}/

2. TaskCreate(
     title: "{brief task summary}",
     description: "{task description with requirements}"
   )

3. Agent(
     prompt: {constructed prompt with CoT prefix + task + critique suffix},
     team_name: "launch-teammate-{task-name}",
     name: "worker"
   )
```

**Context isolation reminder:** Pass only context relevant to this specific task. Do not pass entire conversation history.

### Phase 6: Review Results and Cleanup

After the teammate completes:

1. **Review the output** - Parse the summary and verification results
2. **TaskUpdate** - Mark the task as completed
3. **Cleanup**:
   ```
   SendMessage(to: "worker", message: "Work complete. Please shut down.")
   TeamDelete()  — clean up team config and task directory
   ```

## Examples

### Example 1: Complex Architecture Task (Opus)

**Input:** `/launch-teammate Design a caching strategy for our API that handles 10k requests/second`

**Analysis:**

- Task type: Architecture / design
- Complexity: High (performance requirements, system design)
- Output size: Medium (design document)
- Domain match: sdd:software-architect

**Selection:** Opus + sdd:software-architect agent

**Execution:**

```
TeamCreate("launch-teammate-caching-strategy", "Design API caching strategy")
TaskCreate("Design caching strategy for 10k req/s", "...")
Agent(prompt: ..., team_name: "launch-teammate-caching-strategy", name: "worker")
  → Worker completes design
TaskUpdate(task_id, status: "completed")
SendMessage(to: "worker", message: "Shutdown request")
TeamDelete()
```

---

### Example 2: Simple Documentation Update (Haiku)

**Input:** `/launch-teammate Update the README to add --verbose flag to CLI options`

**Analysis:**

- Task type: Documentation (simple edit)
- Complexity: Low (single file, well-defined)
- Output size: Small (one section)
- Domain match: None needed (too simple)

**Selection:** Haiku (fast, cheap, sufficient for task)

**Execution:**

```
TeamCreate("launch-teammate-readme-update", "Update README CLI options")
TaskCreate("Add --verbose flag to README", "...")
Agent(prompt: ..., team_name: "launch-teammate-readme-update", name: "worker")
  → Worker completes update
TaskUpdate(task_id, status: "completed")
TeamDelete()
```

---

### Example 3: Moderate Implementation (Sonnet + Developer)

**Input:** `/launch-teammate Implement pagination for /users endpoint following patterns in /products`

**Analysis:**

- Task type: Code implementation
- Complexity: Medium (follow existing patterns)
- Output size: Medium (implementation + tests)
- Domain match: sdd:developer

**Selection:** Sonnet + sdd:developer agent (non-complex but needs domain expertise)

**Execution:**

```
TeamCreate("launch-teammate-pagination", "Implement /users pagination")
TaskCreate("Add pagination to /users endpoint", "...")
Agent(prompt: ..., team_name: "launch-teammate-pagination", name: "worker")
  → Worker completes implementation
TaskUpdate(task_id, status: "completed")
TeamDelete()
```

---

### Example 4: Research Task (Opus + Researcher)

**Input:** `/launch-teammate Research authentication options for mobile app - evaluate OAuth2, SAML, passwordless`

**Analysis:**

- Task type: Research / comparison
- Complexity: High (comparative analysis, recommendations)
- Output size: Large (comprehensive research)
- Domain match: sdd:researcher

**Selection:** Opus + sdd:researcher agent

**Execution:**

```
TeamCreate("launch-teammate-auth-research", "Research mobile auth options")
TaskCreate("Evaluate OAuth2, SAML, and passwordless auth", "...")
Agent(prompt: ..., team_name: "launch-teammate-auth-research", name: "worker")
  → Worker completes research
TaskUpdate(task_id, status: "completed")
TeamDelete()
```

## Best Practices

### Context Isolation

- Pass only context relevant to the specific task
- Avoid passing entire conversation history
- Let teammates discover codebase patterns through tools
- Use file paths and references rather than embedding large content

### Model Selection

- When in doubt, use Opus (quality over cost)
- Use Haiku only for truly trivial tasks
- Use Sonnet for "grunt work" - needs capability but not genius
- Production code always deserves Opus

### Specialized Agents

- Use when domain expertise clearly improves quality
- Combine with CoT and critique patterns
- Don't force specialization on general tasks

### Quality Gates

- Self-critique loop is non-negotiable
- Teammates must answer verification questions before completing
- Review teammate output before accepting

### Resource Management

- Always TeamDelete when work is complete
- SendMessage shutdown request to teammates before TeamDelete
- Keep team names descriptive for easy identification
