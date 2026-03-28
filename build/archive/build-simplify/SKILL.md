---
name: build-simplify
description: Use when verified build changes need a mandatory maintainability pass before final review and shipping.
---

# Build Simplify

Run `/simplify` as a required gate after verification. This stage exists to improve maintainability without treating cleanup as optional polish.

## Inputs

- `docs/build/verify.md`
- changed files for the active build scope

## Focus

- dead code removal
- complexity reduction
- naming improvements
- reuse and consolidation

## Process

1. Run `/simplify` on the changed scope.
2. Apply maintainability improvements without broadening product scope.
3. Update `docs/build/simplify.md` with:
   - files or areas simplified
   - cleanup categories performed
   - any follow-up verification required

## Routing

- If simplification materially changes behavior-sensitive code, re-enter `build-verify` before moving on.
- If simplification is clean and low risk, continue to `build-review-ship`.

## Output

The stage is complete when the maintainability pass is finished and `docs/build/simplify.md` has been updated.
