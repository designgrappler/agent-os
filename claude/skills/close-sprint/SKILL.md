---
name: close-sprint
description: Closes the current sprint — verifies all tracks are resolved, runs the build, bumps the version, archives the plan, and resets context files.
whenToUse: When the user wants to close the current sprint after all tracks are complete or explicitly deferred.
---

## Instructions

### Step 1 — Close any completed-but-not-yet-closed tracks

Read `docs/context/tracks.md`. For each track belonging to the current sprint:

- **Work complete, exit record not yet written (OPEN with completed work):** invoke `/track-close <track-id> "<outcome>"` to write the exit record. Do not write the exit record inline — `/track-close` is the sole mechanism for writing DONE exit records.
- **Explicitly deferred:** record a DEFERRED note in the track's exit record manually (deferral is not a DONE close; `/track-close` only writes DONE).
- **Still OPEN or BLOCKED with no completed work:** surface the list and stop:

  > The following tracks are not yet resolved: [list]. Resolve or explicitly defer each before closing the sprint.

  Wait for confirmation before continuing.

### Step 2 — Run build

Run `bun run build`. If it fails, surface the error and stop. Do not continue until the build passes.

### Step 3 — Bump version in `skills-manifest.json`

Read `skills-manifest.json` and determine the appropriate version bump:
- **Patch** — bug fixes, copy corrections, non-behavioral edits only
- **Minor** — new skills, new agents, or new features added this sprint
- **Major** — breaking changes that require manual user action

Increment `"release-version"` accordingly (e.g. `"v0.20.0"` → `"v0.20.1"` for patch, `"v0.21.0"` for minor). Write the updated value back to `skills-manifest.json`.

### Step 4 — Plan doc archival (rolling window)

**Plan doc archival (rolling window):** Move `docs/temp-sprint<N>-plan.md` to `docs/archive/plan-docs/S<N>.md`. Then check `docs/archive/plan-docs/` — delete any entries older than the 3-sprint window (keep current sprint + 2 prior). Git history retains all older content.

If `docs/archive/plan-docs/` does not exist, create it silently before moving.

### Step 5 — Archive the sprint plan

Read `docs/context/plan.md` and locate the `## Current Sprint: S<N>` section. Copy its full content (all headings, goals, and notes under it) to `docs/archive/plan-docs/S<N>.md` if the file does not already exist from Step 4.

### Step 6 — Reset context files

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

### Step 7 — Commit sprint close

Stage and commit the version bump, archive file, and context reset:

```bash
git add skills-manifest.json docs/archive/plan-docs/S<N>.md docs/context/plan.md docs/context/tracks.md
git commit -m "chore(S<N>): sprint close — <new-version>, archive plan, reset context"
```

### Step 8 — Create GitHub release and push

Before creating the release, derive the release notes from the sprint archive doc at `docs/archive/plan-docs/S<N>.md`. Use the "What changed" section (or equivalent) as the release body. Do not use a fallback string — if the archive doc is missing or has no substantive content, stop and ask the user for release notes before proceeding.

```bash
gh release create <new-version> \
  --repo designgrappler/agent-os-private \
  --title "<new-version>" \
  --notes "<release notes from archive doc>"

git push
git fetch origin <new-version>
```

Note: `gh release create` pushes the tag to the remote. `git fetch origin <new-version>` syncs it locally. Do not run `git push origin <new-version>` — the tag already exists on the remote after `gh release create`.

### Step 9 — Confirm

Output a short confirmation:

```
Sprint S<N> closed.

Version bumped to: <new-version>
Archive: docs/archive/plan-docs/S<N>.md
plan.md and tracks.md reset.
GitHub release: https://github.com/designgrappler/agent-os-private/releases/tag/<new-version>
```
