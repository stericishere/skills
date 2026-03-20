#!/bin/bash
# Initialize the docs/ folder structure for a new project
# Usage: bash ~/.claude/skills/app-dev/init-project-docs.sh [project-root]

PROJECT_ROOT="${1:-.}"

echo "Initializing app-dev docs structure in: $PROJECT_ROOT/docs/"

# Phase 1: Ideate
mkdir -p "$PROJECT_ROOT/docs/ideate"

# Phase 2: Design
mkdir -p "$PROJECT_ROOT/docs/design/adr"

# Phase 3: Build
mkdir -p "$PROJECT_ROOT/docs/build/user-stories"
mkdir -p "$PROJECT_ROOT/docs/build/feature-specs"

# Phase 4: Launch (with project-local memory)
mkdir -p "$PROJECT_ROOT/docs/launch/ab-tests"
mkdir -p "$PROJECT_ROOT/docs/launch/memory/checkpoints"
mkdir -p "$PROJECT_ROOT/docs/launch/memory/decisions"
mkdir -p "$PROJECT_ROOT/docs/launch/memory/learnings"

# Phase 5: Iterate (with project-local memory)
mkdir -p "$PROJECT_ROOT/docs/iterate"
mkdir -p "$PROJECT_ROOT/docs/iterate/memory/decisions"
mkdir -p "$PROJECT_ROOT/docs/iterate/memory/learnings"

# Create placeholder claude.md in each phase
for phase_dir in "$PROJECT_ROOT"/docs/ideate "$PROJECT_ROOT"/docs/design "$PROJECT_ROOT"/docs/build "$PROJECT_ROOT"/docs/launch "$PROJECT_ROOT"/docs/iterate; do
  if [ ! -f "$phase_dir/claude.md" ]; then
    phase_name=$(basename "$phase_dir")
    cat > "$phase_dir/claude.md" << EOF
# $phase_name — Decisions & Context

## Date
[Not started]

## Summary
[To be filled when this phase is completed]

## Key Decisions
- [None yet]

## Inputs Used
- [None yet]

## Outputs Produced
- [None yet]

## Open Questions
- [None yet]

## Constraints & Trade-offs
- [None yet]

## Deferred Items
- [None yet]
EOF
  fi
done

# Create memory indexes for Phase 4 and Phase 5
if [ ! -f "$PROJECT_ROOT/docs/launch/memory/MEMORY.md" ]; then
  cat > "$PROJECT_ROOT/docs/launch/memory/MEMORY.md" << EOF
# Phase 4 Launch — Memory Index

## Checkpoints
<!-- Sub-stage completion status -->

## Decisions
<!-- Marketing, analytics, deploy decisions -->

## Learnings
<!-- What worked, what failed -->
EOF
fi

if [ ! -f "$PROJECT_ROOT/docs/iterate/memory/MEMORY.md" ]; then
  cat > "$PROJECT_ROOT/docs/iterate/memory/MEMORY.md" << EOF
# Phase 5 Iterate — Memory Index

## Decisions
<!-- Triage outcomes, routing decisions -->

## Learnings
<!-- Retro findings, pattern discoveries -->
EOF
fi

echo "Done! Structure created:"
find "$PROJECT_ROOT/docs" -type f | sort
echo ""
echo "Next step: Start Phase 1 with /phase-1-ideate"
