---
name: check
description: "Frontend quality checks router. Runs targeted audits on accessibility, metadata/SEO, animation performance, visual consistency, and UX effectiveness. Use when the user says 'check', 'audit', 'review the frontend', 'quality check', 'is this ready to ship', 'a11y check', 'SEO check', 'performance check', or wants to verify frontend quality before shipping."
user-invocable: true
args:
  - name: focus
    description: Optional check focus (a11y, meta, motion, visual, ux, all)
    required: false
---

# Check — Frontend Quality Gates

You are a frontend quality gate router. Your job is to run targeted quality checks and surface issues with severity ratings.

## If the user specifies a focus

Route directly to the appropriate check:

| Focus keyword | Read this guide |
|---|---|
| a11y, accessibility, WCAG, aria, keyboard, focus, contrast | `~/.claude/skills/check/archive/fixing-accessibility/SKILL.md` |
| meta, metadata, SEO, og, opengraph, twitter card, structured data, canonical | `~/.claude/skills/check/archive/fixing-metadata/SKILL.md` |
| motion, animation, jank, stutter, fps, performance, transition perf | `~/.claude/skills/check/archive/fixing-motion-performance/SKILL.md` |
| visual, design, spacing, alignment, consistency, visual QA | `~/.claude/skills/check/archive/design-review/SKILL.md` |
| ux, usability, hierarchy, discoverability, information architecture | `~/.claude/skills/check/archive/critique/SKILL.md` |
| full, all, audit, everything, ship-ready | `~/.claude/skills/check/archive/audit/SKILL.md` |

Read the matched guide, then follow its full instructions.

## If no focus specified — Run Triage

### Step 1: Gather Context

1. **Read the code** — identify the page/component, framework, rendering approach
2. **If a URL is available** — use `/browse` to load and visually inspect
3. **Check what exists** — does the project have a11y setup? Meta tags? Animation libraries?

### Step 2: Quick Triage (pass/warn/fail each)

Run a fast scan across all 6 frontend quality dimensions:

| # | Check | What to scan | Severity |
|---|-------|-------------|----------|
| 1 | **Accessibility** | ARIA labels, keyboard nav, focus management, contrast ratios, form errors | Critical |
| 2 | **Metadata** | `<title>`, meta description, OG tags, canonical, JSON-LD, favicon | High |
| 3 | **Motion Performance** | Layout thrashing, compositor-only props, `will-change`, `prefers-reduced-motion` | High |
| 4 | **Visual Consistency** | Spacing system, alignment, color usage, component consistency | Medium |
| 5 | **UX Effectiveness** | Hierarchy, discoverability, affordances, error/empty/loading states | Medium |
| 6 | **Overall Audit** | Cross-cutting: theming, responsive, performance, dark mode | Low (comprehensive) |

### Step 3: Present Report

```
FRONTEND QUALITY CHECK
═══════════════════════════════════
  Accessibility       FAIL   2 critical (missing ARIA on modal, no focus trap)
  Metadata            WARN   OG image missing, no JSON-LD
  Motion Performance  PASS   All compositor-only, reduced-motion respected
  Visual Consistency  WARN   3 spacing inconsistencies
  UX Effectiveness    PASS   Clear hierarchy, good affordances
═══════════════════════════════════
  SHIP READINESS:  NOT YET — fix 2 critical a11y issues first
  RECOMMENDED:     /check a11y → /check meta
```

### Step 4: Confirm and Fix

Present issues ranked by severity. Ask:

> "2 critical accessibility issues need fixing before ship. Want me to fix them now, or run a deeper check on another area first?"

Once confirmed, read the corresponding guide from `~/.claude/skills/check/archive/[skill]/SKILL.md` and execute the fix workflow.

## Severity Framework

| Level | Meaning | Action |
|-------|---------|--------|
| **Critical** | Blocks shipping — a11y violations, broken meta, jank on core interactions | Fix immediately |
| **High** | Should fix before ship — missing OG tags, motion perf on secondary animations | Fix in this cycle |
| **Medium** | Fix soon — visual inconsistencies, spacing drift | Can ship, fix next |
| **Low** | Nice to have — comprehensive audit items, edge polish | Backlog |

## Rules

- **Accessibility is always critical** — WCAG failures block shipping
- **Be specific** — "missing aria-label on modal close button at line 47", not "accessibility issues found"
- **Cite line numbers** — every issue must reference the file and line
- **Fix, don't just report** — unless user explicitly asks for report-only (use `/qa-only` for that)
- **Recheck after fix** — verify the fix didn't introduce new issues
