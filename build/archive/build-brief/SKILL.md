---
name: build-brief
description: Use when build inputs have been checked and the work needs a concise brief that locks scope, acceptance criteria, and implementation track before planning.
---

# Build Brief

Create the build brief that the rest of the workflow will execute.

`superpowers` owns this stage. If the work is still ambiguous, use `superpowers:brainstorming` to resolve ambiguity before writing the brief.

## Inputs

- upstream product and design docs
- `docs/build/check.md`
- any existing `docs/build/*.md` context

## Process

1. Read `docs/build/check.md` first.
2. Lock the build scope for this run.
3. Record the implementation track:
   - `frontend`
   - `backend`
   - `fullstack`
4. Record which guidance is required during execution.
   - Keep the workflow ownership inside `superpowers`, `orchestrate`, and `gstack`.
   - Note any stack-specific references only as execution inputs, not as top-level workflow owners.
5. Write `docs/build/brief.md` with:
   - feature summary
   - problem being solved
   - acceptance criteria
   - implementation track
   - dependencies and constraints
   - required guidance for execution
   - risks or open assumptions
6. If the brief is clear enough to implement, route automatically to `build-plan`.

## Output

The stage is complete when `docs/build/brief.md` makes the execution target unambiguous and the next stage is `build-plan`.
