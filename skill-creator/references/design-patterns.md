# 5 Skill Design Patterns

With 30+ agent tools standardizing on the same `SKILL.md` layout, the formatting problem is solved. The challenge is **content design** — how to structure the logic inside a skill. These five recurring patterns cover the vast majority of skill architectures.

## Decision Tree

```
Does the agent need to LEARN a technology/framework?
  → Tool Wrapper

Does the agent need to PRODUCE consistent documents?
  → Generator

Does the agent need to EVALUATE something against standards?
  → Reviewer

Are requirements unclear and need discovery first?
  → Inversion

Is this a multi-step process where order and checkpoints matter?
  → Pipeline
```

---

## Pattern 1: Tool Wrapper

Gives the agent on-demand context for a specific library. Instead of hardcoding API conventions into the system prompt, package them into a skill that loads `references/` only when the agent works with that technology.

**Use when:** Agent needs domain expertise for a library, framework, or internal standard.

**Key mechanism:** `references/` loaded on keyword match.

**Directory structure:**
```
api-expert/
├── SKILL.md
└── references/
    └── conventions.md
```

**SKILL.md example:**
```markdown
---
name: api-expert
description: FastAPI development best practices and conventions. Use when building, reviewing, or debugging FastAPI applications, REST APIs, or Pydantic models.
---

You are an expert in FastAPI development.

## When Reviewing Code
1. Load 'references/conventions.md' for the complete list of FastAPI best practices
2. Check the user's code against each convention
3. For each violation, cite the specific rule and suggest the fix

## When Writing Code
1. Load the conventions reference
2. Follow every convention exactly
3. Add type annotations to all function signatures
```

---

## Pattern 2: Generator

Enforces consistent output by orchestrating a fill-in-the-blank process. Uses `assets/` for output templates and `references/` for style guides. The instructions act as a project manager — load template, read style guide, ask for missing variables, populate.

**Use when:** Output must follow a consistent structure every time (reports, docs, scaffolds).

**Key mechanism:** `assets/` template + `references/` style guide.

**Directory structure:**
```
report-generator/
├── SKILL.md
├── assets/
│   └── report-template.md
└── references/
    └── style-guide.md
```

**SKILL.md example:**
```markdown
---
name: report-generator
description: Generates structured technical reports in Markdown. Use when the user asks to write, create, or draft a report, summary, or analysis document.
---

Follow these steps exactly:

Step 1: Load 'references/style-guide.md' for tone and formatting rules.
Step 2: Load 'assets/report-template.md' for the required output structure.
Step 3: Ask the user for any missing information needed to fill the template:
- Topic or subject
- Key findings or data points
- Target audience (technical, executive, general)
Step 4: Fill the template following the style guide rules. Every section in the template must be present in the output.
Step 5: Return the completed report as a single Markdown document.
```

---

## Pattern 3: Reviewer

Separates **what to check** from **how to check it**. Store a modular rubric in `references/` — swap the checklist to get a completely different audit using the same skill infrastructure.

**Use when:** Code or content must be scored against a rubric (PR reviews, security audits, style checks).

**Key mechanism:** `references/` checklist → severity-based output.

**Directory structure:**
```
code-reviewer/
├── SKILL.md
└── references/
    └── review-checklist.md
```

**SKILL.md example:**
```markdown
---
name: code-reviewer
description: Reviews Python code for quality, style, and common bugs. Use when the user submits code for review, asks for feedback, or wants a code audit.
---

Follow this review protocol exactly:

Step 1: Load 'references/review-checklist.md' for the complete review criteria.
Step 2: Read the user's code carefully. Understand its purpose before critiquing.
Step 3: Apply each rule from the checklist. For every violation:
- Note the line number
- Classify severity: error (must fix), warning (should fix), info (consider)
- Explain WHY it's a problem, not just WHAT is wrong
- Suggest a specific fix with corrected code
Step 4: Produce a structured review:
- **Summary**: What the code does, overall quality assessment
- **Findings**: Grouped by severity (errors first)
- **Score**: Rate 1-10 with brief justification
- **Top 3 Recommendations**: The most impactful improvements
```

---

## Pattern 4: Inversion

Flips the dynamic — the agent interviews the user before acting. Uses explicit, non-negotiable gating instructions ("DO NOT start until all phases complete") to force context gathering before synthesis.

**Use when:** Requirements are ambiguous and context must be gathered first (project planning, design systems, architecture).

**Key mechanism:** Phased questions with explicit gates.

**Directory structure:**
```
project-planner/
├── SKILL.md
└── assets/
    └── plan-template.md
```

**SKILL.md example:**
```markdown
---
name: project-planner
description: Plans a new software project by gathering requirements through structured questions before producing a plan. Use when the user says "I want to build", "help me plan", or "start a new project".
---

You are conducting a structured requirements interview. DO NOT start building or designing until all phases are complete.

## Phase 1 — Problem Discovery (ask one question at a time, wait for each answer)
- Q1: "What problem does this project solve for its users?"
- Q2: "Who are the primary users? What is their technical level?"
- Q3: "What is the expected scale? (users per day, data volume, request rate)"

## Phase 2 — Technical Constraints (only after Phase 1 is fully answered)
- Q4: "What deployment environment will you use?"
- Q5: "Do you have any technology stack requirements or preferences?"
- Q6: "What are the non-negotiable requirements? (latency, uptime, compliance, budget)"

## Phase 3 — Synthesis (only after all questions are answered)
1. Load 'assets/plan-template.md' for the output format
2. Fill in every section using the gathered requirements
3. Ask: "Does this plan accurately capture your requirements? What would you change?"
4. Iterate on feedback until the user confirms
```

---

## Pattern 5: Pipeline

Enforces a strict, sequential workflow with hard checkpoints. The instructions themselves serve as the workflow definition. Diamond gate conditions (requiring user approval before proceeding) ensure the agent cannot bypass steps or present unvalidated results.

**Use when:** Multi-step workflow where order matters and steps must not be skipped (doc generation, CI flows, migration processes).

**Key mechanism:** Sequential steps with diamond gates, per-step resource loading.

**Directory structure:**
```
doc-pipeline/
├── SKILL.md
├── assets/
│   └── api-doc-template.md
└── references/
    ├── docstring-style.md
    └── quality-checklist.md
```

**SKILL.md example:**
```markdown
---
name: doc-pipeline
description: Generates API documentation from Python source code through a multi-step pipeline. Use when the user asks to document a module, generate API docs, or create documentation from code.
---

Execute each step in order. Do NOT skip steps or proceed if a step fails.

## Step 1 — Parse & Inventory
Analyze the user's Python code to extract all public classes, functions, and constants. Present the inventory as a checklist. Ask: "Is this the complete public API you want documented?"

## Step 2 — Generate Docstrings
For each function lacking a docstring:
- Load 'references/docstring-style.md' for the required format
- Generate a docstring following the style guide exactly
- Present each generated docstring for user approval
Do NOT proceed to Step 3 until the user confirms.

## Step 3 — Assemble Documentation
Load 'assets/api-doc-template.md' for the output structure. Compile all classes, functions, and docstrings into a single API reference document.

## Step 4 — Quality Check
Review against 'references/quality-checklist.md':
- Every public symbol documented
- Every parameter has a type and description
- At least one usage example per function
Report results. Fix issues before presenting the final document.
```

---

## Patterns Compose

These patterns are not mutually exclusive:

- A **Pipeline** can include a **Reviewer** step at the end to double-check its own work
- A **Generator** can start with **Inversion** to gather template variables before filling
- A **Tool Wrapper** can feed into a **Pipeline** that applies the loaded knowledge across multiple steps
- A **Reviewer** can use **Generator** patterns to produce its structured report output

Choose the dominant pattern, then layer others as needed. Thanks to progressive disclosure, the agent only spends context tokens on the exact patterns it needs at runtime.
