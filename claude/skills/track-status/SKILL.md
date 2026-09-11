---
name: track-status
description: Shows a resume-ready summary of all active tracks — status, last activity, and next steps. Read-only.
whenToUse: When the user wants a quick overview of where things stand across all active tracks.
---

## Instructions

### Step 1 — Read sprint goal

Read `docs/context/plan.md`. Extract the sprint goal from the current `## Current Sprint:` section. If the file does not exist or no current sprint is found, set sprint goal to `(no active sprint)`.

### Step 2 — Read track list

Read `docs/context/tracks.md`.

If the file does not exist or has no tracks, output:

> No tracks found. Run `/start-sprint` to open a sprint first.

Stop. Do not continue.

### Step 3 — Per-track activity lookup

For each open track (status is not DONE, MERGED, or DEFERRED), run:

```bash
git log --oneline --grep "T<id>" -10
```

where `<id>` is the track number extracted from the track entry (e.g. for `T85.3`, run `git log --oneline --grep "T85.3" -10`).

Capture the most recent matching commit message and its timestamp. If no commits match, mark activity as `(no commits found)`.

### Step 4 — Produce summary

Output the summary directly to chat. Do not write it to disk.

Format:

```
## Track Status — Sprint <N>
Goal: <sprint goal from plan.md>

| Track | Description | Status | Last Activity | Next Steps |
|-------|-------------|--------|---------------|------------|
| T<id> | <task name> | <status> | <most recent commit msg, truncated to ~60 chars> or (no activity) | <next steps from exit record or —> |
```

**Field rules:**
- **Status**: read directly from the `Status:` field in each track entry. Do not infer.
- **Last Activity**: most recent `git log` commit message matching the track ID. If multiple matches, use the most recent. Truncate to ~60 characters if longer. If no matches: `(no commits found)`.
- **Next Steps**: if the track's exit record has a filled `Next steps:` field, include a one-sentence summary. If blocked, note `blocked — <reason>`. If no next steps recorded, use `—`.

### Hard Constraints

- **No writes. No edits. Read only.** This skill never modifies any file.
- Output is emitted to chat, not written to disk.
