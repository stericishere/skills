---
name: sadd
description: "Router for Agent Team orchestration patterns (formerly Sub-Agent Driven Development). Use when the task benefits from parallel execution, multi-step pipelines, competitive approaches, quality judging, debate-based evaluation, tree-of-thought reasoning, or spawning teammates. Also use when explicitly asked about SADD patterns, agent orchestration, multi-agent workflows, agent teams, or when a task is large enough to warrant decomposition into teammate work."
---

# SADD Router — Powered by Agent Teams

All patterns below use the **Agent Teams** execution layer. Teammates are full independent Claude Code sessions that share a task list and can message each other directly.

## How Agent Teams Work

```
1. TeamCreate(team_name, description)           — create team + shared task list
2. TaskCreate(title, description)                — populate shared task list
3. Agent(prompt, team_name, name)                — spawn teammates that join the team
4. SendMessage(to: teammate_name, message)       — inter-agent communication
5. TaskUpdate(task_id, status: "completed")       — mark tasks done
6. TeamDelete()                                  — cleanup when all teammates shut down
```

## Pattern Guides

Read the appropriate pattern guide based on orchestration need:

| Pattern | When to use | Action |
|---------|-------------|--------|
| do-in-parallel | Independent subtasks that can run concurrently (uses TeamCreate) | Read `~/.claude/skills/archive/do-in-parallel/GUIDE.md` |
| do-in-steps | Sequential pipeline where each step feeds the next (uses TeamCreate) | Read `~/.claude/skills/archive/do-in-steps/GUIDE.md` |
| do-and-judge | Execute then evaluate quality of output (uses TeamCreate) | Read `~/.claude/skills/archive/do-and-judge/GUIDE.md` |
| do-competitively | Multiple teammates solve same problem, pick best (uses TeamCreate) | Read `~/.claude/skills/archive/do-competitively/GUIDE.md` |
| judge | Evaluate and score an existing output (uses TeamCreate) | Read `~/.claude/skills/archive/judge/GUIDE.md` |
| judge-with-debate | Adversarial debate to surface quality issues (uses TeamCreate) | Read `~/.claude/skills/archive/judge-with-debate/GUIDE.md` |
| tree-of-thoughts | Branching exploration of solution paths (uses TeamCreate) | Read `~/.claude/skills/archive/tree-of-thoughts/GUIDE.md` |
| launch-teammate | Spawn a single teammate for a focused task (uses TeamCreate) | Read `~/.claude/skills/archive/launch-sub-agent/GUIDE.md` |
| team-driven-development | Full SADD methodology overview and composition (uses TeamCreate) | Read `~/.claude/skills/archive/subagent-driven-development/GUIDE.md` |

Start with `team-driven-development` if unsure which pattern fits. Patterns can be composed together.
