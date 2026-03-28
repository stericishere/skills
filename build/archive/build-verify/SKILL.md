---
name: build-verify
description: Use when implemented build work needs correctness validation, functional QA, and design QA before cleanup or shipping.
---

# Build Verify

Validate that executed build work is correct, working, and visually acceptable before simplification or final review.

## Inputs

- `docs/build/execute.md`
- `docs/build/feature-specs/[feature-name].md`
- changed code and tests for the active build scope

## Process

1. Run correctness gates using `superpowers:verification-before-completion`:
   - tests
   - build
   - acceptance criteria confirmation against feature specs
2. Run `/qa` for functional and flow-level validation.
3. Run `/design-review` for visual and UX validation.
4. For each verified feature, update `docs/build/review-[feature].md`.
5. Update `docs/build/verify.md` with:
   - commands and checks run
   - failures found
   - fixes required before continuing
   - features that passed verification

## Routing

- If correctness, QA, or design checks fail, route back to `build-execute`.
- If verification is clean, continue to `build-simplify`.

## Output

The stage is complete only when the active scope passes verification and `docs/build/verify.md` has been updated.
