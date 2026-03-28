---
name: build-execute
description: Use when the build plan is ready and implementation should be carried out, with Agent Team used for all parallel work.
---

# Build Execute

Implement the approved build plan.

`sadd` owns all parallel orchestration in this stage. `superpowers` owns implementation discipline inside the work.

## Inputs

- `docs/build/brief.md`
- `docs/build/plan.md`
- `docs/build/check.md`

## Pattern selection

| Situation | Pattern |
|---|---|
| Independent tasks across different files or isolated targets | `sadd:do-in-parallel` |
| Dependent tasks that must happen in order | `sadd:do-in-steps` |
| Single high-risk task that needs explicit judge verification | `sadd:do-and-judge` |
| Hard reasoning, unclear solution space, or escalation | `sadd:tree-of-thoughts` |

## Rules

- All parallel work uses `Agent Team`.
- Do not use ad hoc parallelism outside `sadd`.
- Sequential work may stay with the orchestrator.
- Teammates receive only the task slice and context they need.
- Every implementation prompt must enforce:
  - `superpowers:test-driven-development`
  - `superpowers:verification-before-completion`
- Frontend-specific or backend-specific guidance may be loaded inside this stage when the brief calls for it, but workflow ownership stays with `superpowers`, `sadd`, and `gstack`.

## Process

1. Read `docs/build/brief.md` and `docs/build/plan.md`.
2. Select the execution slice.
3. Decide which work is sequential and which work can run in parallel.
4. For every parallel slice, use `sadd` with `Agent Team`.
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
