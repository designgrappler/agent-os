---
name: minify-context
description: Compresses verbose active context files into token-efficient form without losing meaning. Includes opt-in memory compression target governed by the R3 per-category taxonomy.
---
# Minify Context
Compresses verbose active context files into token-efficient form without losing meaning. Distinct from `clean-context` (which archives completed items) — this skill compresses *active* content that has grown wordy.

## When to Run
- At sprint end, after `clean-context` has archived completed tracks
- Any time context files feel heavy or agent responses seem unfocused
- When `tracks.md` or `plan.md` has grown through many edits and contains repetitive or padded prose
- When memory files have accumulated verbose prose that could be compressed (opt-in — mention "memory" or "memory files" explicitly)

---

## Rules
- **Preserve-first**: Never delete information. Fewer words for the same meaning — not fewer facts.
- **Structure intact**: All headers, field names, tables, and section order remain unchanged.
- **No archiving**: Do not move or delete any content. That is `clean-context`'s job.
- **Never remove a memory entry — that is `clean-context`'s domain.** Compression is preserve-first.

---

## Targets
Default targets (compress all unless the user specifies a subset):
1. `docs/context/plan.md`
2. `docs/context/tracks.md`
3. `docs/context/product.md` (if present)

**Memory target (opt-in — off by default):** activated only when the user explicitly mentions "memory", "memory files", or "compress memory" when invoking the skill (e.g. "minify memory", "minify context including memory files"). When the memory target runs, see the **Memory Compression** section below.

Do NOT touch `docs/archive/` or `.claude/` files (except `.claude/projects/<sanitized-cwd>/memory/` when memory target is explicitly opted in).

---

## PROTOCOL_CANON Hard Exclusion

**PROTOCOL_CANON path exclusion: AGENTIC.md, claude/agents/architect.md, and claude/templates/AGENTIC.md are excluded from minification regardless of section content. The skill MUST skip these files entirely.**

When any of these files is explicitly named as a minification target, respond with exactly:
> `PROTOCOL_CANON exclusion — <filename> is not eligible for minification.`

No further action on those files.

---

## plan.md Active Sprint Exclusion

**plan.md Active Sprint exclusion: when minifying docs/context/plan.md, the topmost `## Current Sprint:` section is excluded; only `## Completed Sprint:` sections are eligible for compression.**

Detect the Active Sprint section as: the first `## Current Sprint:` heading and its body, up to but not including the first `## Completed Sprint:` heading. Preserve this section verbatim. Apply TRANSACTIONAL_STATE compression only to `## Completed Sprint:` sections.

---

## Protocol

For each target file:

**1. Audit** — Read the file. Identify:
- Multi-sentence explanations reducible to one
- Redundant information repeated across sections
- Filler phrases ("In order to...", "It is important to note that...")
- Placeholder text never filled in — flag these, don't compress

**2. Categorize** — Classify each section under the R3 taxonomy (see below) and determine the appropriate compression ratio. Show section-level category classifications in the preview.

**3. Preview** — Before any rewrite, show the user the proposed changes section by section, with each section's R3 category and target ratio. **The user must confirm before any rewrite is applied.**

**4. Backup** — Before applying any rewrite, write a `.minify-backup-<date>` copy of the original file alongside it (ISO date format: `YYYY-MM-DD`). Print the backup path in the Minify Report. Backups are kept until manual cleanup — no auto-purge.

**5. Rewrite** — Produce a compressed version:
- Replace verbose prose with tight sentences
- Convert narrative paragraphs to bullets where structure is clearer
- Keep all specifics: names, commands, file paths, values, dates

**6. Report** — After writing, show the delta per file:
```
## Minify Report: [filename]
Category: [R3 category]
Before: [N] lines
After:  [N] lines
Ratio achieved: [N]:1
Target ratio: [range]
Backup: [path to .minify-backup-<date> file]
Flags: [unfilled placeholders or ambiguous content]
```

---

## R3 Minification Taxonomy

Five categories govern compression behavior. Every section or file is classified into exactly one category before compression begins.

### TRANSACTIONAL_STATE — 4:1 to 6:1
Sprint plans, completed-sprint summaries, plan-doc files.

**Compress:** strip narrative prose, reduce verification checklists to commands only, collapse multi-step Work sections in DONE tracks to one-line outcomes.

**Preserve verbatim:** track ID, status, files in scope, final commit SHA, key decisions.

**Examples:** completed sprint entries in `plan.md`, done tracks in `tracks.md`, bridge summaries for merged work.

### FEEDBACK_RULES — 2:1 maximum
Feedback rule files and any file/section whose primary content is binary constraints.

**Compress:** drop explanatory framing only.

**Preserve verbatim:** imperative phrasing ("Never X. Always Y."), canonical example, source/trigger reference.

**Hard constraint: never compress feedback rules into prose.** The imperative form must survive compression unchanged.

### REFERENCE_DOCS — 1.1:1 to 1.3:1
Reference documentation, how-to sections, external resource pointers.

**Compress:** remove duplicates, outdated links, formatting noise only.

**Preserve verbatim:** all concrete details — file paths, commands, role names, repo names, URLs.

**If compression would force a choice between brevity and a concrete file path, keep the path.**

### PROTOCOL_CANON — 1:1
Protocol rules, agent definitions, AGENTIC.md content, architecture invariants.

**Compress:** remove redundancy only per the "one rule, one place" discipline.

**Everything else is preserved verbatim.** Compression ratio target is 1:1 (no change).

**Path exclusion:** AGENTIC.md, claude/agents/architect.md, and claude/templates/AGENTIC.md are excluded from minification entirely — see PROTOCOL_CANON Hard Exclusion above.

### NARRATIVE_CONTEXT — 8:1 to ∞
Historical narrative, sprint retrospectives, meeting notes, contextual background that is not actively referenced.

**Compress:** strip to a single sentence summary, or excise entirely.

**Move to archive:** if the narrative has historical value (e.g. explains a key architectural decision), move the detailed content to `docs/archive/` before stripping.

---

## Memory Compression

**Opt-in only.** Activated when the user explicitly mentions memory when invoking the skill.

**Absent-path handling:** if `~/.claude/projects/<sanitized-cwd>/memory/` does not exist, print:
> `memory target requested but no memory directory found at <path> — skipping`
and continue cleanly.

**Classification by filename prefix:**

| Prefix | R3 Category | Target Ratio |
|---|---|---|
| `feedback_*.md` | FEEDBACK_RULES | 2:1 max — preserve imperative phrasing + canonical example + source |
| `reference_*.md` | REFERENCE_DOCS | 1.1:1 — preserve all concrete details and file paths |
| `project_*.md` | TRANSACTIONAL_STATE (if sprint archived) or REFERENCE_DOCS (if sprint active) | 4:1–6:1 or 1.1:1 accordingly |
| No matching prefix | PROTOCOL_CANON | 1:1 — do not compress; flag for manual review |

**`project_*.md` sprint-archive test:** a sprint is considered archived if it appears in `docs/context/plan.md`'s `## Completed Sprint:` sections OR in `docs/archive/plan-docs/`. If the sprint is still active (appears in `## Current Sprint:`), treat the file as REFERENCE_DOCS (1.1:1) to preserve current state.

**MEMORY.md index compression:** when the memory target runs, compress `MEMORY.md` index lines to the canonical one-line hook form: `- [Title](file.md) — one-line hook (max ~120 chars)`. Verbose multi-line index entries are reduced to this form.

**Hard constraints:**
- **Never remove a memory entry — that is `clean-context`'s domain.** Every entry present before compression must be present after.
- The backup-before-rewrite rule applies to every memory file modified.
- Files classified as PROTOCOL_CANON (no `reference_` / `feedback_` / `project_` prefix) are not compressed — they are flagged as "manual review required" in the report.

---

## Verification Checklist

- [ ] PROTOCOL_CANON path exclusion enforced: AGENTIC.md, claude/agents/architect.md, claude/templates/AGENTIC.md were not modified (skip message shown if targeted).
- [ ] plan.md Active Sprint section preserved verbatim; only Completed Sprint sections compressed.
- [ ] Section-level R3 category classifications shown in preview before user confirmation.
- [ ] User confirmed before any rewrite was applied.
- [ ] `.minify-backup-<date>` files written before each rewrite; backup paths in report.
- [ ] Minify Report includes per-file: before/after line count, ratio achieved vs target, R3 category, backup path.
- [ ] All specifics (names, commands, file paths, values, dates) present in compressed output.
- [ ] No memory entries removed (memory target only).
- [ ] Absent memory directory handled gracefully with skip message (memory target only).
- [ ] Gemini-side `skills/minify-context/SKILL.md` mirrors these changes.
