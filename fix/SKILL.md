---
name: fix
description: |
  Use when implemented work or a known bug must be driven through review, targeted fix planning, repeated repair, and simplification until the code is clean enough to ship.
---

# Fix

This is a single workflow skill with internal stages. Do not split it into public `fix-*` commands.

## Core systems

| System | Responsibility |
|---|---|
| `superpowers` | fix planning, TDD, verification-before-completion, worktree discipline |
| `sadd` | `Agent Team` orchestration for all parallel review work |
| `gstack` | `/review`, `/codex`, `/simplify`, shipping-facing review surface |

## Agent Team rule

All parallel work uses `Agent Team`.

The standard fix team has these roles:
- `orchestrator`
- `reviewer-review` running `gstack:/review`
- `reviewer-codex` running `gstack:/codex`
- `fixer`
- `simplifier` only after both reviewers are clean

## Internal stages

### 1. Review pass

1. Launch an `Agent Team`.
2. Run `gstack:/review` and `gstack:/codex` in parallel.
3. Consolidate findings into one issue list.

If there are no findings, move to the simplify pass.
If there are findings, move to the fix pass.

### 2. Fix pass

For the active issue batch:

1. The `fixer` writes a minimal fix plan.
   - issue being addressed
   - files or modules affected
   - regression test or verification target
   - blast radius
2. Implement the fix using:
   - `superpowers:test-driven-development`
   - `superpowers:verification-before-completion`
3. Re-run the parallel review pass.

### 3. Same-issue retry policy

Track retries by issue, not just by stage run.

Treat an issue as the same issue when the same reviewer finding, failing acceptance criterion, or failing behavior remains materially unresolved.

| Same issue attempt | Action |
|---|---|
| `1` | normal fix attempt |
| `2` | retry with a materially different approach |
| `3` | invoke `/pua`, then continue |
| `4` | final attempt |
| `>4` | stop and escalate |

If the same issue survives more than 4 total iterations, stop and report:
- the issue
- what was tried
- current evidence
- recommendation for the user

### 4. Simplify pass

Only enter this stage when both reviewers return clean.

1. Run `gstack:/simplify`.
2. If `/simplify` finds meaningful cleanup:
   - apply the cleanup
   - re-run the parallel review pass
3. If `/simplify` finds nothing meaningful left to improve, the fix stage is green.

Do not run `/simplify` in parallel with active fix attempts.

## Process summary

```text
parallel review
-> if issues: write fix plan -> implement -> parallel review
-> if clean: /simplify
-> if simplify changes code: parallel review
-> if simplify finds nothing meaningful: green
```

## Required stage doc

Always update `docs/build/fix.md` with:
- issue batches reviewed
- current retry count for repeated issues
- fix plans applied
- verification evidence
- simplify passes taken
- final green or blocked status

If the stage turns green, route automatically to `build-review-ship`.

## Escape protocol

Escalate when:
- the same issue survives more than 4 iterations
- a reviewer finding implies an architecture change
- the work can no longer be verified safely

Escalation must include:
- blocker
- evidence
- attempts made
- recommended next move
