---
name: minify-context
description: The "Context Compressor" that rewrites verbose active context files into dense, token-efficient form without losing meaning.
Abbreviation: Mc
Category: Maintenance
Type: Tier 2
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write]
---

# Skill: Minify Context

## Description
The "Context Compressor" of the Agent OS. Reads active context files and rewrites verbose passages into concise, token-efficient form. Preserves all information and structure — no deletions, only compression. Distinct from `context-cleaner` (which removes stale/completed items); this skill compresses *active* content that has grown wordy over time.

## Operational Rules
- **🛡️ MIDDLEWARE ISOLATION (MANDATORY)**: You are the **Architect** (Tier 2). You are **STRUCTURALLY BLOCKED** from touching source code or final deliverables.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header:
    > **[Name] ([Role])**
- **Preserve-First Rule**: Never delete information. If in doubt between keeping and cutting, keep it. Compression means fewer words for the same meaning — not fewer facts.
- **Structure Intact**: All headers, field names, tables, and section order must remain unchanged. Only the prose inside sections is rewritten.

## Target Files

Default targets (compress all unless user specifies a subset):
1. `.agent/context/AGENTIC.md` — Static DNA
2. `.agent/context/tracks.md` — Dynamic DNA
3. `.agent/context/product.md` — Product context (if present)
4. Any other `.md` files in `.agent/context/`

Do NOT touch:
- Archived files in `.agent/archives/`
- Rule files in `.agent/rules/`
- Skill files

## Compression Protocol

For each target file:

**Step 1 — Audit**
Read the file. Identify:
- Verbose prose that can be tightened (e.g., 3-sentence explanations that can be 1)
- Redundant information repeated across sections
- Outdated preamble or context no longer relevant to the current sprint
- Placeholder language that was never filled in (flag these, don't compress)

**Step 2 — Rewrite**
Produce a compressed version:
- Replace multi-sentence prose with tight single sentences
- Convert narrative paragraphs to bullet points where structure is clearer
- Remove filler phrases ("In order to...", "It is important to note that...", "As previously mentioned...")
- Keep all technical specifics: names, commands, file paths, values, dates

**Step 3 — Report**
Before writing, show the delta:
```
## Minify Report: [filename]
Before: [N] lines / ~[N] tokens
After:  [N] lines / ~[N] tokens
Reduction: [N]%
Flags: [any unfilled placeholders or ambiguous content found]
```
Write the compressed file only after reporting.

## Verification
1. **No Information Loss**: Confirm every fact, name, command, and value from the original appears in the compressed version.
2. **Structure Preserved**: Confirm all headers and field names are intact.
3. **Delta Reported**: Confirm before/after counts were shown before writing.
4. **Archives Untouched**: Confirm no archived files were modified.

## Stats
- **Overhead**: Low
- **Operational Level**: Level 2 (Strategic Maintenance)
- **Benefit**: Keeps active context lean and agent-sharp as projects grow. Run at sprint end or whenever context feels heavy.

## Trigger
Tell Architect: "Minify the context files."
