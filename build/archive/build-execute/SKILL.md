---
name: build-execute
description: Use when the build plan is ready and implementation should be carried out, with Agent Team used for all parallel work.
---

# Build Execute

Implement the approved build plan.

`orchestrate` owns all parallel orchestration in this stage. `superpowers` owns implementation discipline inside the work.

## Inputs

- `docs/build/brief.md`
- `docs/build/plan.md`
- `docs/build/check.md`

## Pattern selection

| Situation | Pattern |
|---|---|
| Independent tasks across different files or isolated targets | `/orchestrate` → PARALLEL mode |
| Dependent tasks that must happen in order | `/orchestrate` → SEQUENTIAL mode |
| Single high-risk task that needs explicit judge verification | `/orchestrate` → SINGLE mode (with judge) |
| Hard reasoning, unclear solution space, or escalation | `/orchestrate` → COMPETITIVE mode |

## Rules

- **MANDATORY: Use `/orchestrate` with Agent Teams for ALL implementation work.** Do NOT implement code yourself in the main session. You are the orchestrator — you dispatch, you do not implement.
- Read `/orchestrate` skill to select the correct mode (SINGLE, PARALLEL, SEQUENTIAL, COMPETITIVE).
- Default to PARALLEL mode when tasks touch different files. Only use SEQUENTIAL when there are true dependencies.
- Teammates receive only the task slice and context they need.
- Every teammate prompt must enforce:
  - `superpowers:test-driven-development`
  - `superpowers:verification-before-completion`
- Frontend-specific or backend-specific guidance may be loaded inside this stage when the brief calls for it, but workflow ownership stays with `superpowers`, `orchestrate`, and `gstack`.

## Process

1. Read `docs/build/brief.md` and `docs/build/plan.md`.
2. Break the plan into implementable slices.
3. Analyze independence — which slices touch different files/modules?
4. **Invoke `/orchestrate`** — it will auto-route to the correct mode and create the Agent Team.
5. Track blockers, retries, and deferred work during execution.
6. Update `docs/build/execute.md` with:
   - scope executed
   - patterns used
   - Agent Teams launched
   - files or modules touched
   - blockers, retries, and deferred work
7. If execution is complete for the current scope, route automatically to `fix`.

## Output

The stage is complete when implementation work for the selected scope is done, `docs/build/execute.md` has been updated, and the next stage is `fix`.
