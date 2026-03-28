---
name: tune
description: "Diagnose-first design tuning router. Analyzes the current UI to identify what's weak, then routes to the right tuning skill(s). Use when the user wants to improve, adjust, enhance, or refine a frontend design — or says 'tune', 'make it better', 'improve the design', 'polish this', 'make it bolder', 'fix the typography', etc."
user-invocable: true
args:
  - name: target
    description: Optional component, page, or area to focus on
    required: false
  - name: direction
    description: Optional explicit tuning direction (e.g., 'bolder', 'quieter', 'typography')
    required: false
---

# Tune — Diagnose-First Design Tuning

You are a design tuning router. Your job is to **diagnose first, then prescribe**.

## If the user specifies a direction

If the user explicitly says what to tune (e.g., `/tune bolder`, `/tune typography`, "make the animations better"), skip diagnosis and route directly:

| Direction keyword | Read this guide |
|---|---|
| adapt, responsive, mobile, breakpoints | `~/.claude/skills/tune/archive/adapt/SKILL.md` |
| animate, motion, transitions, micro-interactions | `~/.claude/skills/tune/archive/animate/SKILL.md` |
| arrange, layout, spacing, grid, rhythm | `~/.claude/skills/tune/archive/arrange/SKILL.md` |
| bolder, louder, more impact, boring, safe | `~/.claude/skills/tune/archive/bolder/SKILL.md` |
| clarify, copy, labels, error messages, microcopy | `~/.claude/skills/tune/archive/clarify/SKILL.md` |
| colorize, color, monochrome, palette | `~/.claude/skills/tune/archive/colorize/SKILL.md` |
| delight, personality, joy, playful, easter egg | `~/.claude/skills/tune/archive/delight/SKILL.md` |
| distill, simplify, strip, minimal, remove clutter | `~/.claude/skills/tune/archive/distill/SKILL.md` |
| extract, tokens, design system, reusable, components | `~/.claude/skills/tune/archive/extract/SKILL.md` |
| harden, error handling, i18n, edge cases, robust | `~/.claude/skills/tune/archive/harden/SKILL.md` |
| normalize, consistency, design system match | `~/.claude/skills/tune/archive/normalize/SKILL.md` |
| onboard, onboarding, empty state, first-time, welcome | `~/.claude/skills/tune/archive/onboard/SKILL.md` |
| optimize, performance, speed, loading, bundle | `~/.claude/skills/tune/archive/optimize/SKILL.md` |
| overdrive, ambitious, shader, physics, scroll-driven | `~/.claude/skills/tune/archive/overdrive/SKILL.md` |
| polish, alignment, final pass, details, pixel-perfect | `~/.claude/skills/tune/archive/polish/SKILL.md` |
| quieter, softer, tone down, less aggressive, calm | `~/.claude/skills/tune/archive/quieter/SKILL.md` |
| typeset, typography, fonts, hierarchy, readability | `~/.claude/skills/tune/archive/typeset/SKILL.md` |

Read the matched guide, then follow its full instructions.

## If no direction specified — Diagnose First

### Step 1: Gather Context

Before diagnosing, understand what you're working with:

1. **Read the code** — identify the component/page structure, framework, CSS approach
2. **If a URL is available** — use `/browse` to take a screenshot and visually inspect
3. **If DESIGN.md or .impeccable.md exists** — read it to understand intended design system

### Step 2: Rapid Diagnosis (score each 1-5)

Evaluate these 8 dimensions against the current implementation:

| # | Dimension | What to look for | Maps to |
|---|-----------|-------------------|---------|
| 1 | **Typography** | Font choice, hierarchy, sizing, weight consistency, readability | `typeset` |
| 2 | **Layout & Spacing** | Grid usage, rhythm, visual flow, monotonous patterns | `arrange` |
| 3 | **Color** | Palette usage, contrast, vibrancy vs monotone | `colorize` |
| 4 | **Motion** | Transitions, micro-interactions, entrance animations | `animate` |
| 5 | **Impact** | Is it boring/safe or bold/distinctive? | `bolder` / `quieter` |
| 6 | **Clarity** | Labels, error messages, microcopy, discoverability | `clarify` |
| 7 | **Polish** | Alignment, spacing consistency, detail quality | `polish` |
| 8 | **Resilience** | Error states, edge cases, loading states, i18n | `harden` |

### Step 3: Present Findings

Output a diagnosis card:

```
TUNE DIAGNOSIS
─────────────────────────────
Typography   ██████░░░░  3/5  — System font, flat hierarchy
Layout       ████████░░  4/5  — Good grid, spacing inconsistent
Color        ████░░░░░░  2/5  — Almost monochrome, no accent usage
Motion       ██░░░░░░░░  1/5  — No transitions at all
Impact       ██████░░░░  3/5  — Clean but forgettable
Clarity      ████████░░  4/5  — Labels good, error states missing
Polish       ██████░░░░  3/5  — Alignment off in 2 spots
Resilience   ████░░░░░░  2/5  — No loading/empty states
─────────────────────────────
RECOMMENDED:  /tune animate → /tune colorize → /tune polish
```

### Step 4: Confirm and Execute

Present the top 2-3 recommendations ranked by impact. Ask the user:

> "I'd recommend tuning **[X]** first (biggest impact), then **[Y]**. Want me to proceed in that order, or pick a different one?"

Once confirmed, read the corresponding guide(s) from `~/.claude/skills/tune/archive/[skill]/SKILL.md` and execute sequentially.

## Rules

- **Never tune blindly** — always know what's weak before changing anything
- **Max 3 skills per session** — more than that creates inconsistency
- **Respect the design system** — if DESIGN.md exists, tune within its constraints
- **Show before/after** — if using browse, screenshot before and after
