---
name: minify-context
description: Compresses verbose active context files into token-efficient form without losing meaning.
---
# Minify Context
Compresses verbose active context files into token-efficient form without losing meaning. Distinct from `clean-context` (which archives completed items) — this skill compresses *active* content that has grown wordy.

## When to Run
- At sprint end, after `clean-context` has archived completed tracks
- Any time context files feel heavy or agent responses seem unfocused
- When `tracks.md` or `AGENTIC.md` has grown through many edits and contains repetitive or padded prose

---

## Rules
- **Preserve-first**: Never delete information. Fewer words for the same meaning — not fewer facts.
- **Structure intact**: All headers, field names, tables, and section order remain unchanged.
- **No archiving**: Do not move or delete any content. That is `clean-context`'s job.

---

## Targets
Default: compress all active context files unless the user specifies a subset.
1. `AGENTIC.md`
2. `docs/context/plan.md`
3. `docs/context/tracks.md`
4. `docs/context/product.md` (if present)

Do NOT touch `docs/archive/` or `.claude/` files.

---

## Protocol

For each target file:

**1. Audit** — Read the file. Identify:
- Multi-sentence explanations reducible to one
- Redundant information repeated across sections
- Filler phrases ("In order to...", "It is important to note that...")
- Placeholder text never filled in — flag these, don't compress

**2. Rewrite** — Produce a compressed version:
- Replace verbose prose with tight sentences
- Convert narrative paragraphs to bullets where structure is clearer
- Keep all specifics: names, commands, file paths, values, dates

**3. Report** — Before writing, show the delta:
```
## Minify Report: [filename]
Before: [N] lines
After:  [N] lines
Reduction: [N]%
Flags: [unfilled placeholders or ambiguous content]
```

Write the file only after reporting.
