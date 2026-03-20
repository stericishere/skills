---
name: sadd
description: "Router for Sub-Agent Driven Development (SADD) orchestration patterns. Use when the task benefits from parallel execution, multi-step pipelines, competitive approaches, quality judging, debate-based evaluation, tree-of-thought reasoning, or spawning sub-agents. Also use when explicitly asked about SADD patterns, agent orchestration, multi-agent workflows, or when a task is large enough to warrant decomposition into sub-agent work."
---

# SADD Router

Read the appropriate pattern guide based on orchestration need:

| Pattern | When to use | Action |
|---------|-------------|--------|
| do-in-parallel | Independent subtasks that can run concurrently | Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` |
| do-in-steps | Sequential pipeline where each step feeds the next | Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` |
| do-and-judge | Execute then evaluate quality of output | Read `~/.claude/skills/archive/do-and-judge/GUIDE.md` |
| do-competitively | Multiple agents solve same problem, pick best | Read `~/.claude/skills/archive/do-competitively/GUIDE.md` |
| judge | Evaluate and score an existing output | Read `~/.claude/skills/archive/judge/GUIDE.md` |
| judge-with-debate | Adversarial debate to surface quality issues | Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md` |
| tree-of-thoughts | Branching exploration of solution paths | Read `~/.claude/skills/archive/tree-of-thoughts/GUIDE.md` |
| launch-sub-agent | Spawn a single sub-agent for a focused task | Read `~/.claude/skills/archive/launch-sub-agent/GUIDE.md` |
| subagent-driven-development | Full SADD methodology overview and composition | Read `~/.claude/skills/archive/subagent-driven-development/GUIDE.md` |

Start with `subagent-driven-development` if unsure which pattern fits. Patterns can be composed together.
