---
name: sync-guidance
description: Syncs existing PRPs and the three foundational UI context files to what actually shipped, post-QA, in any sprint containing non-deterministic tracks.
whenToUse: Run as the final post-QA step in any sprint with at least one non-deterministic track — after QA approves all execution work and before /close-sprint. Does not author new PRPs.
---

## Instructions

### Step 1 — Verify the post-QA trigger precondition

This skill syncs guidance to match what was actually shipped; "actually shipped" is not defined until QA passes. Read the current sprint plan doc `docs/temp-sprint<N>-plan.md` and confirm QA has APPROVED all execution tracks. If QA has not approved, halt and surface:

> "sync-guidance must run after QA approves all execution work. QA approval not found for sprint S\<N>."

Do not proceed.

### Step 2 — Determine scope

Accept an optional scope argument: a list of pages touched this sprint. If no argument is given, default scope = every page whose execution track in `docs/temp-sprint<N>-plan.md` bears the exact line:

    **Track type:** non-deterministic

Scan the plan doc for that exact marker (markdown-bold label, single space, lowercase hyphenated value) and collect the page source file declared by each matching track. If scope is empty (no non-deterministic tracks), halt silently — this skill has nothing to do.

### Step 3 — Sync each page PRP to the source

For each page in scope:

1. Derive the page slug: lowercase-hyphenated form of the source filename (e.g. `GoalsPage.tsx` → `goals-page`). The PRP path is `docs/context/prp-[page-slug]-page.md`.
2. Read the current source file and the current PRP at that path.
3. Identify divergences between the PRP's load-bearing sections (page anatomy, state model, component→primitive map, semantic variable inventory, replication checklist) and what the source actually contains.
4. Update the PRP to match what is in the source — only what ships, never design intent as fact (per `docs/context/prp-spec.md` §3 "What NOT to put in a PRP"). Update the `Last audited` line to `S<N> / T<track-id>`.
5. If no divergences exist, make no edit and record "no drift found" for that file.

Do NOT create a PRP that does not already exist — PRP authoring is owned by `@Plan` at sprint open (`docs/context/prp-spec.md` §4). If a page in scope has no PRP, record it as an error in the completion record and continue; do not author one.

### Step 4 — Update the three foundational files

Update `docs/context/ui-components.md`, `docs/context/ui-rules.md`, and `docs/context/ui-design.md` to reflect what shipped this sprint:

- `ui-components.md` — any new components added this sprint (import path, exports, props, usage note).
- `ui-rules.md` — any rule additions or forbidden-pattern changes.
- `ui-design.md` — any new or changed semantic tokens, typography, spacing, or motion values.

For any foundational file with no shipped changes, make no edit and record "no drift found" for it.

### Step 5 — Write the completion record

Append the following section to `docs/temp-sprint<N>-plan.md`:

```
## /sync-guidance — S<N>

- Sprint: S<N>
- Date run: <YYYY-MM-DD>
- Files updated: <list each PRP and foundational file edited>
- No drift found: <list each in-scope file that required no change>
```

This heading is a cross-track contract and must be written exactly as `## /sync-guidance — S<N>`. The close-sprint pre-flight check scans for it.

### Step 6 — Execution receipt

On successful completion, append one line to `docs/context/skill-receipts.jsonl` (create the file and any missing parent directories if absent; append only, never overwrite):

```json
{"skill":"sync-guidance","timestamp":"<ISO-8601>","sprint":"<sprint-id>","version":"<release-version>","flags":[]}
```

- `timestamp`: current ISO-8601 datetime.
- `sprint`: read from the current sprint plan doc (match `## Current Sprint: S<N>`); if not found use `"unknown"`.
- `version`: read `release-version` from `skills-manifest.json`; if not found use `"unknown"`.

## Ownership

Owned by the `frontend` specialist agent. Reads source files and context files; writes to context files (PRPs + the three foundational files) and the sprint plan completion record only. Never touches source code.

## Verification Checklist (Internal — Run Before Reporting Complete)

- QA approval confirmed before any sync edit was made.
- Scope resolved from the `**Track type:** non-deterministic` marker (or explicit argument).
- Every in-scope PRP either updated or recorded "no drift found"; no new PRP authored.
- Three foundational files either updated or recorded "no drift found".
- `## /sync-guidance — S<N>` completion record appended to the plan doc with sprint ID, date, files updated, and no-drift list.
- One receipt line appended to `docs/context/skill-receipts.jsonl`.
