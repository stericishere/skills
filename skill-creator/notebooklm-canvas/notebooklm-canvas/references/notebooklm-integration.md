# NotebookLM Integration Patterns

This document explains how to work with the `notebooklm` skill for content extraction.

## NotebookLM Skill Usage

The `notebooklm` skill provides authenticated access to NotebookLM notebooks for querying content.

### Basic Query Pattern

```
Use the notebooklm skill to query the notebook at [URL]:
1. Extract the table of contents or main themes
2. For each theme, get detailed content and key points
3. Identify relationships between topics
```

### Recommended Queries

**1. Get Table of Contents**
```
"What is the table of contents or outline of this notebook?"
"List all the main topics covered in this notebook"
```
Returns: Structured outline of content organization

**2. Extract Theme Details**
```
"What are the key points about [specific theme]?"
"Summarize the content related to [topic]"
```
Returns: Detailed content for specific sections

**3. Find Relationships**
```
"How do [topic A] and [topic B] relate to each other?"
"What connections exist between different sections?"
```
Returns: Conceptual relationships for canvas edges

## Content Structuring Strategy

### Phase 1: Discovery
1. Query for table of contents → Establish canvas structure
2. Identify 3-7 main themes → Create top-level groups

### Phase 2: Detail Extraction
For each main theme:
1. Query for sub-topics
2. Extract key points (3-5 per topic)
3. Note important quotes or examples

### Phase 3: Relationship Mapping
1. Query for cross-references between themes
2. Identify supporting/contrasting relationships
3. Map explicit connections for canvas edges

## Output Formatting

### Markdown Summary Structure
```markdown
# [Notebook Title]

## Overview
[Brief summary from NotebookLM]

## Main Themes

### Theme 1: [Name]
- Key point 1
- Key point 2
- Key point 3

### Theme 2: [Name]
- Key point 1
- Key point 2

## Relationships
- Theme 1 → Theme 2: [relationship description]
- Theme 2 ← Theme 3: [relationship description]

## Sources
[List of sources from NotebookLM]
```

### Data Structure for Canvas Generation
After extracting content, structure data as:
```
{
  "title": "Notebook Title",
  "themes": [
    {
      "name": "Theme 1",
      "content": "Summary text...",
      "key_points": ["Point 1", "Point 2"],
      "sub_topics": ["Sub A", "Sub B"]
    }
  ],
  "relationships": [
    {"from": "Theme 1", "to": "Theme 2", "type": "supports"}
  ]
}
```

This intermediate structure makes canvas generation straightforward.

## Error Handling

**NotebookLM unavailable**: Inform user and ask for manual content input
**Authentication required**: Guide user to authenticate with notebooklm skill
**No table of contents**: Fall back to extracting main themes through summarization
