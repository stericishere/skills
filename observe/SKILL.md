---
description: Capture structured observations from the current session. Replaces dedicated observer agent sessions with a single command.
---

# Observe

Capture what was learned, decided, or discovered this session — without burning a separate observer session.

## When to Use

- End of a productive session (3+ meaningful tool calls or decisions)
- After solving a tricky bug or making a non-obvious decision
- When you discover something reusable across projects

## Process

### Step 1: Assess session value

Check: did this session produce any of the following?
- Non-obvious decisions or architectural choices
- Friction patterns (bugs, wrong approaches, wasted time)
- Reusable solutions or patterns
- Discoveries about APIs, tools, or libraries

If none of the above: respond "Nothing worth observing this session" and stop. Do NOT produce empty artifacts.

### Step 2: Gather context

- Review git log for commits made this session
- Recall key tool calls, errors, and decisions from the conversation
- Note any corrections the user made (these are high-value observations)

### Step 3: Write observation

Append to `~/.claude/observations/YYYY-MM-DD.md` (create file if it doesn't exist).

Each observation is a fenced block:

```markdown
### HH:MM — [one-line title]

**Type:** decision | discovery | friction | pattern | reusable-solution
**Project:** [project name]
**Files:** [key files involved, if any]

[2-5 sentences: what happened, why it matters, what to do differently next time]
```

Rules:
- Skip routine actions (file reads, simple edits, standard commits)
- Only record things that would save future-you time or prevent repeated mistakes
- If the user made a correction, always record it — these are the highest-value observations
- Keep each observation under 100 words

### Step 4: Confirm

Show the user what was captured:

```
Observation saved to ~/.claude/observations/YYYY-MM-DD.md

[show the observation text]

Anything to add or correct?
```
