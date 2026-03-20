# Canvas Layout Patterns

This document provides template patterns for organizing NotebookLM content into Obsidian canvas visualizations.

## Pattern 1: Hierarchical Layout

**Best for**: Structured content with clear topic hierarchy (table of contents structure)

**Structure**:
```
Central Topic Node (top)
  ├─ Main Theme Group 1 (left)
  │   ├─ Sub-topic 1a
  │   └─ Sub-topic 1b
  ├─ Main Theme Group 2 (center)
  │   ├─ Sub-topic 2a
  │   └─ Sub-topic 2b
  └─ Main Theme Group 3 (right)
      ├─ Sub-topic 3a
      └─ Sub-topic 3b
```

**Node Positioning**:
- Central topic: x=0, y=-400
- Main theme groups: y=0, x=[-800, 0, 800]
- Sub-topics: offset from parent by y=+300, x varies

**Connections**: Parent → Child (top to bottom flow)

## Pattern 2: Mindmap Layout

**Best for**: Interconnected concepts with multiple relationships

**Structure**:
```
        Topic 2
           ↑
           |
Topic 1 ← Central → Topic 3
           |
           ↓
        Topic 4
```

**Node Positioning**:
- Central node: x=0, y=0
- Primary topics: radial from center at distance 500px
  - North: x=0, y=-500
  - East: x=500, y=0
  - South: x=0, y=500
  - West: x=-500, y=0
- Secondary topics: radial from primary at distance 400px

**Connections**: Bidirectional arrows between related concepts

## Pattern 3: Concept Map with Groups

**Best for**: Content with distinct thematic sections that have internal relationships

**Structure**:
- Create color-coded groups for each major theme
- Place related concepts within groups
- Connect concepts across groups when relationships exist

**Group Colors** (Obsidian palette):
- Color 1 (red): Primary theme
- Color 2 (orange): Secondary theme
- Color 3 (yellow): Supporting concepts
- Color 4 (green): Examples/Applications
- Color 5 (cyan): Key insights
- Color 6 (purple): Questions/Further exploration

## Node Types to Use

### Text Nodes
**When**: Individual concepts, quotes, key points
**Properties**:
- width: 250-400px (depending on content)
- height: auto (based on text length)

### Group Nodes
**When**: Thematic sections, related concepts cluster
**Properties**:
- width: 600-800px
- height: 400-600px
- label: Theme name

### File Nodes (for links)
**When**: Reference to source materials, related notes
**Properties**: Link to existing vault files

## Connection Strategies

**Explicit relationships**: Draw edges for clear logical connections
**Labels**: Use edge labels for relationship types ("supports", "contrasts", "example of")
**Avoid over-connecting**: Only draw meaningful relationships to keep canvas readable

## Layout Algorithms

### Auto-spacing calculation:
```
node_spacing = max(300, longest_text_width + 100)
group_spacing = node_spacing * 2
vertical_offset = 250 per level
```

### Collision detection:
Check if nodes overlap before placing. If collision detected, shift by +node_spacing horizontally.
