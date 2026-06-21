---
name: sync-tasks-to-tracks
description: Regenerates the active-tracks section of docs/context/tracks.md from docs/tasks.json. Tasks.json is the source of truth; tracks.md is the human view. The Backlog section of tracks.md is never touched.
---

# Sync Tasks to Tracks

One-way sync from `docs/tasks.json` → `docs/context/tracks.md`. Run after any write to `tasks.json` to keep the human view current.

## Rules

- **One-way only.** `tasks.json` wins on divergence. Never read `tracks.md` to update `tasks.json`.
- **Active-tracks section only.** The Backlog section of `tracks.md` is hand-authored and is never regenerated or modified by this skill.
- **Idempotent.** Running this skill multiple times with the same `tasks.json` produces the same `tracks.md` output.
- **Validation first.** If `tasks.json` is missing, unparseable, or contains a status value outside the permitted set (`OPEN`, `CLAIMED`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `FAILED`), surface the error and stop — do not write to `tracks.md`.

## Protocol

### Step 1 — Read and validate `tasks.json`

Read `docs/tasks.json`. Confirm:
1. File exists and parses as valid JSON.
2. `$schema-version` is present.
3. `tasks` is an array (may be empty).
4. Every task's `status` value is one of: `OPEN`, `CLAIMED`, `IN_PROGRESS`, `DONE`, `BLOCKED`, `FAILED`.

If any check fails, surface the specific error and stop. Do not proceed to Step 2.

### Step 2 — Read the current `tracks.md`

Read `docs/context/tracks.md`. Locate the boundary between the active-tracks section and the Backlog section. The Backlog section begins at the line `## Backlog` (or the nearest equivalent heading). Everything from that heading to end-of-file is preserved verbatim and never touched.

If `tracks.md` does not exist, create it with only the header comment and the regenerated active-tracks content followed by an empty Backlog section.

### Step 3 — Generate the active-tracks section

Group tasks by sprint (descending sprint number — current sprint first). For each sprint group, emit:

```
## Sprint <N> Tracks (<sprint objective if known, else omit>)

### Track <id> — <title>
- **Status:** <status>
- **Specialist:** <specialist>
- **Branch:** `track/<id-lowercase>-<slug>`
- **Plan reference:** `<bridge_file>`
```

Status rendering:
- `OPEN` → `OPEN`
- `CLAIMED` → `CLAIMED`
- `IN_PROGRESS` → `IN PROGRESS`
- `DONE` → `DONE — Bandit APPROVED`
- `BLOCKED` → `BLOCKED`
- `FAILED` → `FAILED`

If `tasks` is empty, emit a single line: `*(No active tasks — tasks.json is empty.)*`

### Step 4 — Write `tracks.md`

Reconstruct `tracks.md` as:
1. The source-of-truth header comment (preserve verbatim from the current file, or emit the canonical form if creating fresh).
2. The generated active-tracks content from Step 3.
3. A blank line separator.
4. The Backlog section verbatim from Step 2.

Write the file. Report: `Synced tracks.md from tasks.json — <N> tasks across <M> sprints.`

### Step 5 — Flag protocol violations

If any task in `tasks.json` has a status value outside the permitted set, report each violation by task ID before stopping in Step 1. Format:
```
Protocol violation: task <id> has status "<value>" — not in permitted set (OPEN, CLAIMED, IN_PROGRESS, DONE, BLOCKED, FAILED).
```

## Verification Checklist

After running this skill:
- [ ] `docs/context/tracks.md` reflects the current state of all tasks in `docs/tasks.json`.
- [ ] The Backlog section of `tracks.md` is unchanged from its pre-sync state.
- [ ] No task with a non-permitted status value was written to `tracks.md`.
- [ ] If `tasks.json` was empty, `tracks.md` active-tracks section shows the empty-state placeholder.
