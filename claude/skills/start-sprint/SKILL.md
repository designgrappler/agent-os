---
name: start-sprint
description: Opens a new sprint — sets sprint goal, defines tracks, initializes plan.md and tracks.md.
whenToUse: When the user wants to start a new sprint or begin a structured work session with multiple tracks.
---

## Instructions

### Step 1 — Gather sprint context

Check whether a temp plan doc already exists at `docs/temp-sprint*.md` (glob pattern). If one is found, read it and extract the sprint goal and track list from it — skip to Step 2.

If no temp plan doc exists, ask the user:

1. What is the sprint goal? (one sentence)
2. What tracks will this sprint include? (list each track with a short description and owner if known)

Wait for the user's response before continuing.

### Step 2 — Determine sprint ID

Read `docs/context/plan.md` if it exists. Find the highest sprint number currently referenced (look for `## Current Sprint: S<N>` or `## Completed Sprint: S<N>`). The new sprint ID is that number plus one. If no prior sprint is found, start at S1.

### Step 3 — Write `docs/context/plan.md`

Create or overwrite the Current Sprint section at the top of `docs/context/plan.md`:

```markdown
## Current Sprint: S<N> — <sprint goal>

### Sprint Goals:
- [ ] <Track ID> — <description> — <owner or TBD>

---
*Last updated: <today's date>*
```

If the file already contains completed sprint entries (lines matching `## Completed Sprint: S<N> ✓`), preserve them below the new current sprint section.

If `docs/` does not exist, create it silently before writing.

### Step 4 — Write `docs/context/tracks.md`

Add one entry per track to `docs/context/tracks.md`. Each entry follows this shape:

```markdown
## Track <ID>: <Task Name>
- **Owner:** <agent name, or null if unclaimed>
- **Status:** OPEN
- **Sprint:** S<N>
- **Opened:** <today's date>
- **Exit Record**
  - **Status:**
  - **What happened:**
  - **Next steps:**
```

If the file already has entries from a prior sprint, append the new entries below them.

### Step 5 — Confirm

Output a short confirmation:

```
Sprint S<N> open.

Goal: <sprint goal>
Tracks: <count> track(s) added to docs/context/tracks.md
Plan: docs/context/plan.md updated

Next step: review the tracks, then dispatch work.
```
