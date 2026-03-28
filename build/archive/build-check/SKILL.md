---
name: build-check
description: Use when a build workflow must inspect docs, inputs, and readiness before briefing and planning begin.
---

# Build Check

Inspect the current build context and determine whether the workflow can move into briefing.

`superpowers` owns this stage.

## Inputs

- upstream docs such as PRD, design docs, ADRs, and build notes
- current `docs/build/*.md` files if they already exist

## Process

1. Read the current upstream docs and any existing `docs/build/*.md`.
2. Determine:
   - what the build is trying to deliver
   - which docs are authoritative
   - which assumptions changed since the last run
   - whether there are blockers or missing prerequisites
3. If the scope is too ambiguous to brief cleanly, invoke `superpowers:brainstorming` to tighten the problem before continuing.
4. Update `docs/build/check.md` with:
   - timestamp
   - readiness status
   - source docs used
   - blockers or missing context
   - what `build-brief` must resolve next
5. If no blocker remains, route automatically to `build-brief`.

## Output

The stage is complete when `docs/build/check.md` captures readiness and the workflow can move to `build-brief`.
