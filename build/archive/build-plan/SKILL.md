---
name: build-plan
description: Use when a build brief is ready and the implementation plan must be written before execution begins.
---

# Build Plan

Turn the brief into an execution-ready implementation plan.

`superpowers` owns this stage through `superpowers:writing-plans`.

## Inputs

- `docs/build/brief.md`
- `docs/build/check.md`
- relevant upstream docs

## Process

1. Read `docs/build/brief.md`.
2. Invoke `superpowers:writing-plans`.
3. Write the detailed implementation plan using the normal `writing-plans` discipline.
4. Always update `docs/build/plan.md` with the execution-facing handoff:
   - work slices
   - file or module ownership
   - test strategy
   - validation commands
   - where Agent Team parallelism is allowed
   - blockers or deferred items
5. If the plan is execution-ready, route automatically to `build-execute`.

## Output

The stage is complete when `docs/build/plan.md` is ready for implementation and the next stage is `build-execute`.
