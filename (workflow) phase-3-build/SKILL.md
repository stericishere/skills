---
name: (workflow) phase-3-build
description: Phase 3 BUILD — feature list, user stories, specs, priority stack, git-worktree, SADD parallel execution, TDD, quality gates, QA, code review, PR merge
---

## Design Pattern
**Pipeline** (strict sequential workflow with quality gate checkpoints per task) + **Inversion** (structured feature discovery) + **Reviewer** (prioritization via judge-with-debate, multi-model code review with triage)

## Upstream reads
- `docs/ideate/prd.md`
- `docs/ideate/design-doc.md`
- `docs/design/adr/` (all ADRs)
- `docs/design/claude.md`

## Tech stack skills — enable based on project stack

Load only the skills relevant to your project's stack. Check `docs/design/adr/` for stack decisions.

| Technology | Skill |
|------------|-------|
| Supabase (auth, DB, RLS, edge functions, storage) | Read `~/.claude/skills/implementation-toolkit/backend/supabase/GUIDE.md` |
| Stripe (payments, subscriptions, webhooks, checkout) | Read `~/.claude/skills/implementation-toolkit/backend/stripe/GUIDE.md` |
| Expo (React Native, EAS builds, mobile) | Read `~/.claude/skills/implementation-toolkit/frontend/expo/GUIDE.md` |
| iOS native (SwiftUI, UIKit, Apple APIs) | Read `~/.claude/skills/implementation-toolkit/frontend/ios/GUIDE.md` |
| iOS Simulator (testing, screenshots, automation) | Read `~/.claude/skills/implementation-toolkit/testing/ios-simulator-skill/GUIDE.md` |
| Next.js caching (RSC, ISR, component cache) | Read `~/.claude/skills/implementation-toolkit/frontend/cache-components/GUIDE.md` |
| LangChain (agents, chains, RAG, vector stores) | Read `~/.claude/skills/implementation-toolkit/backend/langchain-architecture/GUIDE.md` |
| Docker (containers, compose, Dockerfile) | Read `~/.claude/skills/implementation-toolkit/backend/docker-patterns/GUIDE.md` |
| Deployment (CI/CD, hosting, cloud) | Read `~/.claude/skills/implementation-toolkit/backend/deployment-patterns/GUIDE.md` |

## Agent selection from `~/.claude/agents/`

| Task type | Agent definition |
|-----------|-----------------|
| Frontend UI | `engineering/engineering-frontend-developer` |
| Backend/API | `engineering/engineering-backend-architect` |
| Mobile (Expo) | `engineering/engineering-mobile-app-builder` |
| Full-stack | `engineering/engineering-senior-developer` |
| DevOps/infra | `engineering/engineering-devops-automator` |
| AI/ML features | `engineering/engineering-ai-engineer` |
| Security-sensitive | `engineering/engineering-security-engineer` |

## Steps

> **Steps 1–9 repeat per feature** (outer loop over `priority-stack.md`, top to bottom)
> **Steps 10–17 run once** after all features are implemented

---

### Step 1 — Create Feature List
**SADD:** `do-and-judge` — Read `~/.claude/skills/archive/do-and-judge/GUIDE.md`
**Skills:** `/plan-ceo-review` + `/plan-eng-review` (run simultaneously)

CEO lens: "Does each feature serve the core JTBD from the PRD?"
Eng lens: "Is each feature buildable within the current architecture?"

Merge into a single prioritized feature list.
Each row: feature name . description . JTBD it serves . complexity estimate . ADR dependencies

**Output:** `docs/build/feature-list.md`

> **DECISION GATE:** "Feature list approved? Lock scope before writing user stories."

---

### Step 2 — Write User Stories
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` (one feature at a time, in priority order)
**Skills:** `pm/user-story` + `pm/user-story-splitting`

For each feature in `feature-list.md` (top to bottom):
1. Write user stories in Cohn format: "As a [user], I want [action], so that [outcome]"
2. Write Gherkin acceptance criteria: Given / When / Then
3. If story is too large -> split using `pm/user-story-splitting` before moving to next feature
4. Do NOT start next feature until current feature's stories are complete and reviewed

**Output:** `docs/build/user-stories/[feature-name].md` (one file per feature)

> **DECISION GATE:** "All user stories written and reviewed? Approve before generating specs."

---

### Step 3 — Generate Feature Specs
**SADD:** `do-in-steps` — Read `~/.claude/skills/archive/do-in-steps/GUIDE.md`
**Skill:** `pm/epic-breakdown-advisor` — Read `~/.claude/skills/pm/epic-breakdown-advisor/GUIDE.md`

For each user story file -> derive implementable feature spec:
- Component breakdown
- Data model requirements
- API endpoints needed
- Edge cases and error states
- Acceptance criteria mapped to implementation tasks

**Output:** `docs/build/feature-specs/[feature-name].md`

---

### Step 4 — Prioritize
**SADD:** `judge-with-debate` — Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md`
**Skill:** `pm/prioritization-advisor` — Read `~/.claude/skills/pm/prioritization-advisor/GUIDE.md`

Agent A: prioritizes by user value (RICE score)
Agent B: prioritizes by technical risk (de-risk first)
Agent C: prioritizes by strategic alignment
Judge: synthesizes final priority stack

**Output:** `docs/build/priority-stack.md`

> **DECISION GATE:** "Sprint 1 scope locked. Proceed to implementation."

---

### Step 5 — Write Implementation Plan (per feature)
**Skill:** `superpowers:writing-plans`

Produce per feature:
- Task list with dependency graph
- Parallel vs sequential split
- Complexity estimate per task
- Testing strategy per task

**Output:** `docs/build/plan-[feature].md`

---

### Step 6 — Isolate
**Skill:** `superpowers:using-git-worktrees`

Create git worktree for isolated implementation. Do not work on main branch directly.

---

### Step 7 — Execute
**SADD:** Dispatch subagents based on task dependencies.
**Agent prompts:** Reference `~/.claude/agents/` for specialized agent definitions.

```
Independent tasks -> do-in-parallel (Read ~/.claude/skills/archive/do-in-parallel/GUIDE.md)
Dependent tasks   -> do-in-steps (Read ~/.claude/skills/archive/do-in-steps/GUIDE.md)
Complex algorithm -> tree-of-thoughts (Read ~/.claude/skills/archive/tree-of-thoughts/GUIDE.md)
Multiple solutions -> do-competitively (Read ~/.claude/skills/archive/do-competitively/GUIDE.md)
```

**Each subagent receives:**
- Full task text from the plan (don't make subagent read plan file)
- Context: where the task fits, dependencies, architectural decisions
- Directives:
  1. `superpowers:test-driven-development` — write tests first
  2. `superpowers:executing-plans` — follow each step exactly, run verifications, commit
  3. `superpowers:verification-before-completion` — confirm green build before marking done

---

### Step 8 — Quality Gate (per task)
**SADD:** `do-and-judge` — Read `~/.claude/skills/archive/do-and-judge/GUIDE.md`

Execute task -> judge on:
- Lint passes
- TypeScript types valid
- Unit tests pass
- No security flags
- Matches acceptance criteria from feature spec

If below threshold: agent self-fixes -> re-judges (max 2 retries)
If still failing after 2 retries: escalate to `tree-of-thoughts` (Read `~/.claude/skills/archive/tree-of-thoughts/GUIDE.md`) for root cause
If agent is stuck or passive: trigger `/pua`

---

### Step 9 — Feature Verification
**Skill:** `superpowers:verification-before-completion`

After all tasks for a feature complete:
1. Run full test suite
2. Verify build passes
3. Confirm all acceptance criteria met

**Output:** `docs/build/review-[feature].md`

> **DECISION GATE (per feature):** "Feature [X] complete. Issues? Fix -> re-run Step 8. Clean -> next feature."

---

### Step 10 — Functional QA
**Skill:** `/qa`

Run headless browser QA against running app:
- Navigation flows work
- Forms submit correctly
- Error states render
- API responses correct
- Mobile responsiveness (if web)

Fix bugs found -> atomic commits -> re-verify.

**Output:** QA report with health score

---

### Step 11 — Visual QA
**Skill:** `/design-review`

Designer's eye audit: visual inconsistency, spacing issues, hierarchy problems, AI slop detection.
Fixes what it finds with atomic commits and before/after screenshots.

**Output:** Design review with before/after evidence

---

### Step 12 — Code Cleanup
**Skill:** `/simplify`

Review changed code for reuse, quality, and efficiency. Fix issues found:
- Remove dead code, ensure DRY
- Reduce complexity
- Improve naming

---

### Step 13 — Create PR
**Skill:** `superpowers:finishing-a-development-branch`

- Stage changes per feature (not all at once)
- Commit message: references feature spec + ADR numbers changed
- PR description: summary . feature spec link . test results . QA health score . ADR changes log
- Push worktree branch

---

### Step 14 — Claude Code Review
**Skill:** `/review`

Pre-landing review analyzing diff against base branch:
- SQL safety, LLM trust boundary violations
- Conditional side effects
- Security: input validation, auth/authz, injection vectors, secrets
- Performance: N+1 queries, caching, unnecessary re-renders
- Architecture alignment with ADRs

**Output:** Review findings on PR

---

### Step 15 — Cross-Model Review
**Skill:** `/codex`

Independent code review from OpenAI Codex CLI:
- `codex review` mode: pass/fail gate on the diff
- Cross-model analysis when both `/review` and `/codex` have run

**Output:** Codex review findings

---

### Step 16 — Resolve Disagreements
**SADD:** `judge-with-debate` — Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md`
**Only when** `/review` and `/codex` disagree on a finding.

Agent A: argues the finding IS a real issue (cites the reviewer that flagged it)
Agent B: argues the finding is noise (cites the reviewer that passed it)
Agent C: judges — real issue -> fix, noise -> document why and move on

---

### Step 17 — Triage + Fix Loop
For each confirmed issue from Steps 14-16:

```
Code-level fix (style, bug, naming)  -> agent fixes -> /simplify -> push to PR
Design issue (visual, UX)            -> /design-review -> fix -> push to PR
Architecture violation               -> Route to Escape Protocol
```

After fixes: re-run Steps 14+15 on updated PR.

> **DECISION GATE:** "Both /review and /codex pass -> merge PR"

---

### Step 18 — Phase Journal
Write `docs/build/claude.md`:
- Sprint 1 scope locked
- Deferred features list with rationale
- Key user story edge cases noted
- ADR changes made during implementation
- Review findings summary (from both models)
- Disagreements and how they were resolved
- Decisions made during review
- Deferred issues (with ticket references)

**Output:** Also write `docs/review/claude.md` (symlink or copy from build journal review section)

> **DECISION GATE:** "PR merged -> `/phase-4-launch`"

---

## Architecture Change Protocol
**Triggered when:** implementation requires deviating from any ADR.

1. PAUSE current execution
2. Supersede the affected ADR in `docs/design/adr/` (write new ADR, don't edit old)
3. Append to `docs/build/adr-changes.md`: [Date] . [ADR number] . [what changed] . [why]
4. DECISION GATE: "ADR updated. Confirm to resume."
5. Resume execution

## Escape Protocol
If implementation reveals a fundamental architecture flaw:
1. PAUSE and document in phase journal
2. Route back to `/phase-2-design` with the finding
3. Re-run Phase 2 -> Phase 3

If feature decomposition reveals architecture gaps:
1. PAUSE and document the gap in phase journal
2. Route back to `/phase-2-design` to update ADRs
3. Re-run from Phase 3 with updated architecture

If review reveals an architecture violation:
1. PAUSE and document in phase journal
2. Route back to `/phase-2-design` to update ADRs
3. Re-run from Phase 3 to re-implement

## Supporting skills (use as needed)
- `doc-coauthoring` — structured co-authoring for feature specs, user stories, phase journals — Read `~/.claude/skills/doc-coauthoring/SKILL.md`
- `frontend-code-review` — detailed tsx/ts/js review checklist — Read `~/.claude/skills/archive/frontend-code-review/GUIDE.md`
- `component-refactoring` — refactor when complexity > 50 or lineCount > 300 — Read `~/.claude/skills/archive/component-refactoring/GUIDE.md`
- `tree-of-thoughts` — complex algorithmic decisions — Read `~/.claude/skills/archive/tree-of-thoughts/GUIDE.md`
- `pm/customer-journey-map` — full journey mapping before writing stories
- `pm/lean-ux-canvas` — hypothesis-driven feature design
- `pm/opportunity-solution-tree` — explore solution space before committing
- `pm/storyboard` — visual flow storyboarding for onboarding

## Output contract
**Required for Phase 4:**
- `docs/build/feature-specs/` (all features)
- `docs/build/priority-stack.md`
- Code committed in worktree
- `docs/build/review-[feature].md` per feature
- `docs/build/adr-changes.md` (if any ADR changes)
- `docs/build/claude.md`
- PR merged

## Next phase
`/phase-4-launch`
