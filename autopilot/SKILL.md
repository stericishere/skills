---
name: autopilot
description: "Autonomous multi-phase build pipeline. Reads a plan, breaks it into phases, then chains /build and /fix sessions automatically via Stop hook. Each phase gets a fresh context window in a new tmux tab. Resumable, self-terminating, 3-strike escalation. All state stored in .autopilot/ in the project directory. Use when: 'autopilot', 'build the whole thing', 'run the full plan', 'build all phases'."
user-invocable: true
---

# /autopilot — Autonomous Build Pipeline

Chains `/build` → `/fix` → merge → next phase automatically. Each phase runs in a fresh tmux window via Stop hook. No manual intervention needed between phases.

All autopilot files live in `.autopilot/` in the project root.

## Prerequisites

- Must be running inside tmux (`tmux new-session -s autopilot`)
- Stop hook must be registered (run `/autopilot setup` if not)

## .autopilot/ Directory Structure

```
<project-root>/
└── .autopilot/
    ├── state.json          # Current phase, step, strikes, PR numbers
    ├── pipeline.json       # Pipeline config (optional — default is implementation)
    ├── runner.sh            # Auto-generated runner script (used by hook)
    ├── prompts/             # Generated prompts for each session (timestamped)
    │   ├── auth-build-20260330-202500.md
    │   ├── auth-review-20260330-203015.md
    │   └── ...
    └── logs/
        ├── auth-build-20260330-202500.log
        ├── auth-review-20260330-203015.log
        └── ...
```

Add `.autopilot/` to `.gitignore` — it's local runtime state, not source code.

## Commands

### Start: `/autopilot <plan reference>`

**If `.autopilot/state.json` already exists**, check its status:

| Existing state | Action |
|---|---|
| `step: "done"` | Previous run completed. Append to history, start fresh. |
| `step: "blocked"` | Previous run is stuck. Ask user: resume or start new? |
| Any other step | Previous run is in progress. Ask user: resume or start new? |

**When starting new (after previous run):**
1. Append current `state.json` to `.autopilot/history.json` (array of past runs)
2. Clear `state.json` for the new run

```bash
# Append completed state to history
if [ -f .autopilot/history.json ]; then
  # Add to existing array
  jq --slurpfile old .autopilot/state.json '. += $old' .autopilot/history.json > /tmp/ap-hist.tmp && mv /tmp/ap-hist.tmp .autopilot/history.json
else
  # Create new array with first entry
  jq -s '.' .autopilot/state.json > .autopilot/history.json
fi
```

**history.json format** — array of completed runs:
```json
[
  {
    "pipeline": "implementation",
    "plan": "plan-v1.md",
    "phases": [...],
    "started_at": "2026-03-31T10:00:00Z",
    "completed_at": "2026-03-31T18:00:00Z",
    "step": "done"
  },
  {
    "pipeline": "implementation",
    "plan": "plan-v2.md",
    "phases": [...],
    "started_at": "2026-04-01T09:00:00Z",
    "completed_at": "2026-04-01T15:00:00Z",
    "step": "done"
  }
]
```

This keeps all grades, scores, and phase data from every run in one file. `state.json` is always the current run only.

**If no existing state**, proceed normally:

1. **Parse the plan** into ordered phases (3-7 buildable units, each producing a mergeable PR)

2. **Create `.autopilot/` directory** in the project root:
   ```bash
   mkdir -p .autopilot/logs .autopilot/prompts
   ```

3. **Create `.autopilot/state.json`**:
   ```json
   {
     "pipeline": "implementation",
     "plan": "<path to plan file or inline description>",
     "project_path": "<current working directory>",
     "deploy_urls": {
       "frontend": "https://myapp.vercel.app",
       "api": "https://myapp-api.railway.app"
     },
     "phases": [
       {"name": "auth-api", "status": "pending", "pr": null, "strikes": 0, "last_issues": null, "deploy_targets": ["api"]},
       {"name": "dashboard-ui", "status": "pending", "pr": null, "strikes": 0, "last_issues": null, "deploy_targets": ["frontend", "api"]}
     ],
     "current_phase": 0,
     "step": "build",
     "started_at": "<ISO timestamp>",
     "updated_at": "<ISO timestamp>"
   }
   ```

4. **Add `.autopilot/` to `.gitignore`** if not already there

5. **Verify tmux** — check if tmux is running. If not, tell user to start tmux first.

6. **Verify hook** — check `~/.claude/settings.json` has the Stop hook. If not, tell user to run `/autopilot setup`.

Note: No pointer file needed. The Stop hook finds `.autopilot/` by walking up from cwd (like git finds `.git/`). Multiple projects can run autopilot concurrently.

8. **Start phase 1** — run `/build` for the first phase. When complete:
   - Update `.autopilot/state.json`: status = "pr_created", pr = N, step = "review"
   - Let Claude finish — Stop hook reads state and spawns review session

### Setup: `/autopilot setup`

Register the Stop hook in `~/.claude/settings.json`. Add to hooks.Stop array:

```json
{
  "type": "command",
  "command": "bash ~/.claude/hooks/autopilot-chain.sh"
}
```

### Resume: `/autopilot resume`

When blocked (3 strikes):
1. Read `.autopilot/state.json` — show what's blocked and why
2. Accept user guidance
3. Reset strikes to 0, set step back to "review"
4. Let Claude finish — Stop hook spawns retry session

### Status: `/autopilot status`

Read and display `.autopilot/state.json`:
- All phases with status
- Current phase and step
- Strike count and PR numbers
- Elapsed time
- Recent log files

### Cancel: `/autopilot cancel`

1. Remove `.autopilot/state.json` (hook won't find it → becomes no-op)
2. Keep `.autopilot/` directory (preserves logs and prompts for inspection)

### Clean: `/autopilot clean`

1. Delete `.autopilot/` directory entirely

## State Updates

After `/build` creates PR:
```bash
jq --argjson idx $PHASE_IDX --argjson pr $PR_NUMBER \
  '.phases[$idx].status = "pr_created" | .phases[$idx].pr = $pr | .step = "review" | .updated_at = (now | todate)' \
  .autopilot/state.json > /tmp/ap-state.tmp && mv /tmp/ap-state.tmp .autopilot/state.json
```

After `/fix` merges PR:
```bash
jq --argjson idx $PHASE_IDX \
  '.phases[$idx].status = "completed" | .current_phase += 1 | .step = "build" | .updated_at = (now | todate)' \
  .autopilot/state.json > /tmp/ap-state.tmp && mv /tmp/ap-state.tmp .autopilot/state.json
```

After `/fix` hits 3 strikes:
```bash
jq --argjson idx $PHASE_IDX --argjson strikes $COUNT --arg issues "$DESC" \
  '.phases[$idx].strikes = $strikes | .phases[$idx].last_issues = $issues | .step = "blocked" | .updated_at = (now | todate)' \
  .autopilot/state.json > /tmp/ap-state.tmp && mv /tmp/ap-state.tmp .autopilot/state.json
```

## Execution Model — Orchestrate, Don't Code

**The main session never writes code directly. It orchestrates.**

During BUILD, the main session:
1. Breaks the phase into file-level tasks (each task = one file or tightly-coupled file pair)
2. Creates an Agent Team (`TeamCreate`)
3. Dispatches tasks to teammates in parallel — check `~/.claude/agents/{domain}/` for matching `subagent_type`
4. Monitors progress via `TaskList`/`SendMessage`, unblocks teammates as needed
5. When all teammates finish, reviews the combined diff, commits the slice
6. Shuts down teammates, `TeamDelete`

**Within a single slice**, parallelize file-level work across teammates. The main session's job is:
- Decompose → Dispatch → Monitor → Integrate → Commit

Never fall back to coding in the main session. If a task is too small for a teammate, batch it with related files into one teammate's scope.

## State Machine

```
/autopilot start
    │
    ▼
┌───────────┐     ┌──────────┐     ┌──────────┐     ┌─────────┐
│   BUILD   │────▶│  REVIEW  │────▶│  VERIFY  │────▶│  NEXT   │
│orchestrate│     │  /fix    │     │ deploy+qa│     │ PHASE   │──▶ BUILD
│ via teams │     └────┬─────┘     └────┬─────┘     └─────────┘
└───────────┘          │                │
                   3 strikes        deploy fail
                       │                │
                       ▼                ▼
                 ┌──────────┐    ┌──────────┐
                 │ BLOCKED  │    │ BLOCKED  │
                 │ wait user│    │ wait user│
                 └──────────┘    └──────────┘
```

## Rules

- **Main session orchestrates, never codes** — all implementation via Agent Teams
- **One phase at a time** — never skip ahead
- **State file is the source of truth** — always read before acting
- **Update state before finishing** — the Stop hook reads it to decide what's next
- **3 strikes = blocked** — never continue past 3 failures without user input
- **All files in `.autopilot/`** — state, prompts, logs, pipeline config
- **`.autopilot/` goes in `.gitignore`** — it's runtime state, not code
