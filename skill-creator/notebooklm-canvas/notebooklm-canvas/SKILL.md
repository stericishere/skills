---
name: notebooklm-canvas
description: Transform NotebookLM content into visual knowledge maps. Use when user provides NotebookLM URLs and wants to (1) summarize content, (2) create Obsidian canvas visualizations, or (3) both. Triggered by phrases like "summarize this link", "sum up", "create a canvas for this content" followed by NotebookLM URLs. Combines notebooklm skill for content extraction with json-canvas skill for visual organization. Outputs markdown summaries and .canvas files for Obsidian.
---

# NotebookLM Canvas

Transform NotebookLM content into visual knowledge maps with markdown summaries and Obsidian canvas files.

## Overview

This skill extracts content from NotebookLM notebooks and creates two outputs:
1. **Markdown summary** - Structured overview with key themes and insights
2. **Obsidian canvas file** - Visual knowledge map showing relationships between concepts

## Workflow

### Step 1: Extract Content from NotebookLM

Use the `notebooklm` skill to query the notebook:

1. **Get table of contents**:
   ```
   "What is the table of contents or outline of this notebook?"
   ```

2. **Extract theme details** for each main topic:
   ```
   "What are the key points about [theme name]?"
   "Summarize the content related to [topic]"
   ```

3. **Identify relationships**:
   ```
   "How do [topic A] and [topic B] relate to each other?"
   ```

**See [notebooklm-integration.md](references/notebooklm-integration.md)** for detailed query patterns and content structuring strategies.

### Step 2: Choose Canvas Layout

Based on content structure, select layout pattern:

**Hierarchical** (default for structured content):
- Central topic at top
- Main themes as groups below
- Sub-topics within each group
- Top-down connections showing hierarchy

**Mindmap** (for interconnected concepts):
- Central concept in center
- Related topics radiating outward
- Bidirectional connections showing relationships

**See [canvas-patterns.md](references/canvas-patterns.md)** for detailed layout specifications, node positioning formulas, and connection strategies.

### Step 3: Generate Markdown Summary

Use the summary template from `assets/summary-template.md`:

Structure:
```markdown
# [Notebook Title]
> Source: [NotebookLM URL]

## Overview
[Brief summary]

## Main Themes
### Theme 1: [Name]
- Key point 1
- Key point 2

### Theme 2: [Name]
- Key point 1
- Key point 2

## Relationships & Connections
- Theme 1 → Theme 2: [relationship]

## Sources
[List sources from NotebookLM]
```

Save to vault as `[notebook-title]-summary.md`

### Step 4: Create Canvas File

Use the `json-canvas` skill to build the .canvas file:

**Node creation**:
- Text nodes for individual concepts (width: 250-400px)
- Group nodes for themes (width: 600-800px, color-coded)
- Appropriate spacing and positioning per chosen layout

**Edge creation**:
- Connect related concepts
- Add labels describing relationships ("supports", "example of", "contrasts")

**Base template**: Start from `assets/canvas-template.json`

Save to vault as `[notebook-title]-canvas.canvas`

### Step 5: Link Summary to Canvas

In the markdown summary, add at bottom:
```markdown
---
**Canvas file**: [[notebook-title-canvas.canvas]]
```

## Quick Examples

**Example 1: Simple summary**
```
User: "summarize this link: https://notebooklm.google.com/notebook/abc123"
→ Extract content via notebooklm skill
→ Generate markdown summary only
→ Save as [title]-summary.md
```

**Example 2: Canvas visualization**
```
User: "create a canvas for this content: https://notebooklm.google.com/notebook/abc123"
→ Extract content via notebooklm skill
→ Analyze structure → choose layout (hierarchical/mindmap)
→ Generate both markdown summary and .canvas file
→ Link summary to canvas
```

**Example 3: Short command**
```
User: "sum up: https://notebooklm.google.com/notebook/abc123"
→ Quick summary generation (markdown only)
```

## Output Naming Convention

- Summary: `[sanitized-notebook-title]-summary.md`
- Canvas: `[sanitized-notebook-title]-canvas.canvas`
- Place both files in current vault location or ask user for preferred directory

## Error Handling

**NotebookLM unavailable**: Inform user and request manual content or authentication
**No table of contents**: Extract main themes through content summarization
**Complex structure**: Default to hierarchical layout with clear groups

## Resources

### references/
- **canvas-patterns.md** - Layout templates (hierarchical, mindmap, concept map)
- **notebooklm-integration.md** - Query patterns and content extraction strategies

### assets/
- **canvas-template.json** - Base JSON structure for .canvas files
- **summary-template.md** - Markdown template with placeholders
