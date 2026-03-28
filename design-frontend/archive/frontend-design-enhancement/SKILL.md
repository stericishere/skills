---
name: frontend-design-enhancement
description: Use when an existing frontend, screen, component set, or implemented UI needs a structured workflow for critique, targeted design enhancement, polish, and handoff.
---

# Frontend Design Enhancement Workflow

Use this workflow when the UI already exists and needs to become more intentional, polished, and distinctive without losing product context.

## Mandatory preparation

Before running any enhancement pass:

1. Use `frontend-design` for design context and anti-pattern checks.
2. If no design context exists, run `teach-impeccable` first.
3. Confirm:
   - target area or screen
   - intended audience
   - quality bar: MVP, polished, or flagship

## Workflow

### 1. Frame the target

Define what is being improved and what success looks like.

Capture:
- target screen, flow, or component area
- product purpose and audience
- current pain points
- desired outcome: clarity, stronger hierarchy, more personality, higher conversion, better responsiveness, or better maintainability

**Output:** `docs/design/enhancement/brief.md`

---

### 2. Diagnose the design

Start with critique before making changes.

Primary skills:
- `critique` for design diagnosis
- `audit` when accessibility, performance, theming, or responsive risks are likely

Use this stage to identify:
- hierarchy problems
- layout rhythm issues
- typography issues
- color misuse
- AI slop patterns
- weak onboarding or unclear UX copy
- missing edge states

**Output:** `docs/design/enhancement/critique.md`

**Decision gate:** Do not enhance until the priority issues are clear.

---

### 3. Run targeted enhancement passes

Choose only the enhancement skills that match the diagnosis. Do not run every skill by default.

| Need | Skill |
|---|---|
| layout, spacing, composition | `arrange` |
| typography hierarchy and readability | `typeset` |
| color direction and emphasis | `colorize` |
| calmer or more aggressive tone | `quieter` or `bolder` |
| clarity of labels, UX copy, instructions | `clarify` |
| responsiveness and multi-device adaptation | `adapt` |
| motion and micro-interactions | `animate` |
| empty states, onboarding, first-run UX | `onboard` |
| remove clutter and sharpen intent | `distill` |
| add personality and memorable touches | `delight` |
| consistency with design system | `normalize` |
| component reuse and token extraction | `extract` |
| resilience and edge-case handling | `harden` |
| performance improvements | `optimize` |
| technically ambitious upgrade | `overdrive` |

When the enhancement requires real UI implementation work, use `frontend-design` as the implementation anchor and layer the enhancement skills on top.

**Output:** `docs/design/enhancement/plan.md`

**Decision gate:** Enhancement choices must map directly to the diagnosed issues.

---

### 4. Final polish and hardening

After the main enhancements are applied, run the final cleanup pass.

Primary skills:
- `polish`
- `baseline-ui`
- `fixing-accessibility`
- `fixing-motion-performance`
- `fixing-metadata` for page-level work

Use this stage to ensure:
- spacing and alignment are consistent
- states are complete
- accessibility issues are fixed
- animation quality is acceptable
- metadata is not neglected for production pages

**Decision gate:** Do not hand off until the UI is both visually improved and production-safe.

---

### 5. Review and handoff

Run a final design review and summarize what changed.

Recommended checks:
- `critique` for the final before/after assessment
- `polish` if the last pass reveals detail-level regressions

Record:
- what changed
- which enhancement skills were used
- which issues were fixed
- what remains deferred

**Output:** `docs/design/enhancement/claude.md`

## Quick reference

```text
frontend-design -> critique/audit -> targeted enhancement skills -> polish/baseline/accessibility/perf -> final critique
```

## Common mistakes

- Running every enhancement skill instead of selecting only the ones that fit the diagnosis
- Polishing before hierarchy and composition are fixed
- Adding motion before layout and copy are stable
- Making the UI louder without clarifying what the screen is trying to do
- Treating enhancement as decoration instead of targeted improvement

## Output contract

- `docs/design/enhancement/brief.md`
- `docs/design/enhancement/critique.md`
- `docs/design/enhancement/plan.md`
- `docs/design/enhancement/claude.md`
