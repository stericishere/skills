---
name: autopilot-creator
description: "Create autopilot pipelines for different verticals. Defines phase templates, skill chains, and state machines for any repeatable workflow. The implementation autopilot (/autopilot) is one example — this skill creates others. Use when: 'create autopilot', 'new pipeline', 'automate this workflow', 'autopilot for content', 'autopilot for marketing'."
user-invocable: true
---

# /autopilot-creator — Build Autopilot Pipelines for Any Vertical

Creates new autopilot pipeline definitions that the autopilot system can execute. Each pipeline defines its own phases, skills, and state machine.

## How It Works

The autopilot system has two layers:
1. **Engine** — the Stop hook (`~/.claude/hooks/autopilot-chain.sh`) + state file + tmux spawning
2. **Pipeline** — defines WHAT skills to chain and HOW phases connect

`/autopilot` (implementation) is a pipeline. This skill creates new pipelines.

## .autopilot/ Directory

All autopilot files live in `.autopilot/` in the project root:

```
<project-root>/
└── .autopilot/
    ├── state.json          # Current phase, step, strikes, PR numbers
    ├── pipeline.json       # Pipeline config (defines the vertical's step chain)
    ├── prompt.md           # Auto-generated prompt for next session
    └── logs/               # Session logs per phase/step
```

Add `.autopilot/` to `.gitignore`.

The Stop hook finds `.autopilot/` by walking up from cwd (like git finds `.git/`). No pointer file needed. Multiple projects can run autopilot concurrently.

## Pipeline Definition Format

Each pipeline is a SKILL.md at `~/.claude/skills/autopilot-<vertical>/SKILL.md` plus a pipeline config that gets written to `.autopilot/pipeline.json` when the pipeline starts.

### Pipeline Config Schema

```json
{
  "name": "<vertical name>",
  "description": "<what this pipeline does>",
  "version": "1.0",
  "steps_per_phase": [
    {
      "step": "build",
      "skill": "/build",
      "description": "Build the phase",
      "on_complete": {
        "update_state": {"status": "pr_created", "step": "review"},
        "next": "review"
      }
    },
    {
      "step": "review",
      "skill": "/fix",
      "description": "Review and fix the PR",
      "max_strikes": 3,
      "on_complete": {
        "update_state": {"status": "completed"},
        "advance_phase": true,
        "next": "build"
      },
      "on_blocked": {
        "update_state": {"step": "blocked"},
        "wait_for_user": true
      }
    }
  ],
  "phase_decomposition": {
    "strategy": "<how to break work into phases>",
    "guidelines": "<phase sizing guidance>"
  }
}
```

## Creating a Pipeline

When the user asks to create an autopilot for a vertical:

### Step 1: Understand the Vertical

Ask:
- What is the repeatable workflow?
- What skills does each step use?
- What's the output of each step? (PR, document, published content, etc.)
- When should it stop and wait for user input?
- How do you know a step succeeded?

### Step 2: Map the State Machine

Draw the state machine:
```
step_a → step_b → step_c → advance phase → step_a (loop)
                     ↓
                  blocked → user input → retry
```

Every pipeline needs:
- At least 2 steps per phase (do + verify)
- A blocked state with user escalation
- A clear "phase complete" signal
- A way to advance to the next phase

### Step 3: Generate the Pipeline Config

Write the template to `~/.claude/autopilot-pipelines/<vertical>.json` (reusable template).
When an autopilot starts, the template gets copied to `.autopilot/pipeline.json` in the project.

### Step 4: Generate the Skill

Write to `~/.claude/skills/autopilot-<vertical>/SKILL.md` with:
- Frontmatter (name, description, user-invocable)
- How to parse input into phases
- State file format
- Step instructions
- Resume/cancel/status commands

### Step 5: Hook Compatibility

The Stop hook already supports custom pipelines. It reads `.autopilot/pipeline.json` if present and uses it to generate the right prompt per step. No hook modification needed.

The state file includes a `pipeline` field:

```json
{
  "pipeline": "<vertical>",
  "plan": "...",
  "phases": [...],
  "current_phase": 0,
  "step": "<current step name>"
}
```

## Built-in Pipelines

### 1. Implementation (already built)
```
/autopilot — build → review/fix → merge → next phase
Skills: /build, /fix
Output: Merged PRs per phase
```

### 2. Content Production
```
/autopilot-content — research → write → review → publish → next topic
Skills: /fetch, /content, /review (adapted for content), publish step
Output: Published articles/posts per topic
```

### 3. Marketing Campaign
```
/autopilot-marketing — audit → strategy → create → review → launch → next channel
Skills: /marketing, /content, /design-shotgun, /review
Output: Campaign assets per channel
```

### 4. QA Campaign
```
/autopilot-qa — scan → report → fix → verify → next area
Skills: /qa-only, /fix, /qa
Output: Clean QA report per area
```

### 5. Research Deep-Dive
```
/autopilot-research — discover → extract → analyze → synthesize → next topic
Skills: /fetch, /content (research mode), /review
Output: Research report per topic
```

### 6. Design System
```
/autopilot-design — consult → explore → refine → implement → next component
Skills: /design-consultation, /design-shotgun, /design-review, /design-html
Output: Implemented components per design
```

## Example: Creating a Content Autopilot

User: "create an autopilot for content production"

### Generated Pipeline Config (`~/.claude/autopilot-pipelines/content.json`):

```json
{
  "name": "content",
  "description": "Automated content production pipeline — research to publish",
  "version": "1.0",
  "steps_per_phase": [
    {
      "step": "research",
      "skill": "/fetch",
      "description": "Research the topic — pull sources, extract key points",
      "prompt_template": "Research the topic '{{phase_name}}'. Use /fetch to pull relevant sources. Save research notes to docs/content/{{phase_name}}/research.md",
      "on_complete": {
        "update_state": {"step": "write"},
        "next": "write"
      }
    },
    {
      "step": "write",
      "skill": "/content",
      "description": "Write the content piece based on research",
      "prompt_template": "Write content for '{{phase_name}}'. Read research at docs/content/{{phase_name}}/research.md. Use /content to produce the final piece. Save to docs/content/{{phase_name}}/draft.md",
      "on_complete": {
        "update_state": {"step": "review"},
        "next": "review"
      }
    },
    {
      "step": "review",
      "skill": "/review",
      "description": "Review content quality, accuracy, tone",
      "prompt_template": "Review the content at docs/content/{{phase_name}}/draft.md. Check for accuracy against research, tone consistency, and quality. If issues found, fix them. If clean, finalize.",
      "max_strikes": 3,
      "on_complete": {
        "update_state": {"status": "completed"},
        "advance_phase": true,
        "next": "research"
      },
      "on_blocked": {
        "update_state": {"step": "blocked"},
        "wait_for_user": true
      }
    }
  ],
  "phase_decomposition": {
    "strategy": "One phase per content piece or topic",
    "guidelines": "Each phase should produce one publishable piece. Break series into individual articles."
  }
}
```

### Generated Skill (`~/.claude/skills/autopilot-content/SKILL.md`):

The skill follows the same pattern as `/autopilot` but with content-specific phases, skills, and instructions.

## How the Hook Uses Pipeline Config

The Stop hook reads `.autopilot/pipeline.json` (if present) to determine what skill to run and what prompt to generate for each step. If no pipeline.json exists, it falls back to the default implementation pipeline (build → review).

## Rules

- Every pipeline must have a verify/review step — no autopilot without quality gates
- Every pipeline must have a blocked state — no infinite loops without user escape
- Pipelines are JSON configs, not code — the engine (hook) is shared
- New pipelines do NOT require a new hook — the existing hook reads the pipeline config
- Phase names must be unique within a pipeline
- Step names must be unique within a pipeline's step list
