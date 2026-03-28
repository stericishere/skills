---
name: build-review-ship
description: Use when the fix loop is green and the build must be turned into a PR and shipped through the standard closeout path.
---

# Build Review Ship

Create or update the PR and complete the shipping path.

By the time this stage starts, `fix` has already converged. This stage should not reopen the main review loop unless shipping itself uncovers a new blocker.

## Inputs

- `docs/build/check.md`
- `docs/build/brief.md`
- `docs/build/plan.md`
- `docs/build/execute.md`
- `docs/build/fix.md`

## Process

1. Create or update the PR using the stage docs as the source of truth.
2. Use `gstack:/ship` as the default shipping path.
3. Once the PR is merged, use `gstack:/land-and-deploy` to land and verify production:
   - Merge the PR (if not already merged)
   - Wait for CI and deploy to complete
   - Run canary health checks against the production URL
   - If canary checks fail, flag immediately and halt — do not mark the stage complete
4. If branch cleanup or alternate closeout handling is needed after shipping, invoke `superpowers:finishing-a-development-branch`.
5. Update `docs/build/review-ship.md` with:
   - PR link or branch status
   - shipping path used
   - deploy verification result (pass/fail with evidence)
   - ship decision and closeout outcome
6. Compile the final workflow summary in `docs/build/claude.md` using the stage docs.

## Output

The stage is complete only when:

- the PR has been created or updated
- deployment has been verified via `gstack:/land-and-deploy` canary checks
- shipping outcome is decided or explicitly blocked
- `docs/build/review-ship.md` has been updated
- `docs/build/claude.md` has been updated as the final canonical summary
