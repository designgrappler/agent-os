---
name: close-sprint
description: Closes the current sprint — verifies all tracks are resolved, runs the build, bumps the version, archives the plan, and resets context files.
whenToUse: When the user wants to close the current sprint after all tracks are complete or explicitly deferred.
---

## Instructions

### Step 1 — Check track status

Read `docs/context/tracks.md`. Confirm every track for the current sprint has a status of DONE, or has been explicitly deferred with a note in its Exit Record.

If any track is still OPEN or BLOCKED (no Exit Record filled in), surface the list and stop:

> The following tracks are not yet resolved: [list]. Mark each as DONE or DEFERRED before closing the sprint.

Wait for confirmation before continuing.

### Step 2 — Run build

Run `bun run build`. If it fails, surface the error and stop. Do not continue until the build passes.

### Step 3 — Bump version in `skills-manifest.json`

Read `skills-manifest.json` and determine the appropriate version bump:
- **Patch** — bug fixes, copy corrections, non-behavioral edits only
- **Minor** — new skills, new agents, or new features added this sprint
- **Major** — breaking changes that require manual user action

Increment `"release-version"` accordingly (e.g. `"v0.20.0"` → `"v0.20.1"` for patch, `"v0.21.0"` for minor). Write the updated value back to `skills-manifest.json`.

### Step 4 — Archive the sprint plan

Read `docs/context/plan.md` and locate the `## Current Sprint: S<N>` section. Copy its full content (all headings, goals, and notes under it) to a new file at `docs/archive/plan-docs/S<N>.md`.

If `docs/archive/plan-docs/` does not exist, create it silently before writing.

### Step 5 — Reset context files

**`docs/context/plan.md`:** Replace the current sprint section with a single archived pointer line:

```markdown
## Completed Sprint: S<N> ✓ — see docs/archive/plan-docs/S<N>.md
```

Preserve all prior completed sprint pointer lines below it.

**`docs/context/tracks.md`:** Replace all track entries for the closed sprint with the same single pointer line:

```markdown
## Completed Sprint: S<N> ✓ — see docs/archive/plan-docs/S<N>.md
```

Preserve any tracks from other sprints.

### Step 6 — Remind about GitHub release

Output this reminder before finishing:

> Before pushing the version tag, create a GitHub release on the private repo (agent-os-private) first. Tag: `<new-version>`. Then push.

### Step 7 — Confirm

Output a short confirmation:

```
Sprint S<N> closed.

Version bumped to: <new-version>
Archive: docs/archive/plan-docs/S<N>.md
plan.md and tracks.md reset.

Reminder: create the GitHub release on agent-os-private before pushing the version tag.
```
