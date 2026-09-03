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

### Step 1b — Backlog audit

After all tracks are confirmed DONE, scan `docs/backlog.md` for items that correspond to work completed in this sprint.

Match on: items explicitly tagged with the track ID (e.g. `(T53.1)`), or items whose title closely matches a completed track description.

**If matches found:** surface them to the user:
> "The following backlog items appear to correspond to completed work this sprint. Remove them?
> - [item title]"
> Wait for confirmation before removing.

**If no matches found:** skip silently. Do not mention this step in output.

**Removal:** if confirmed, remove the matched line(s) from `docs/backlog.md`. Do not remove section headers or surrounding items.

### Step 2 — Run build

Run `bun run build`. If it fails, surface the error and stop. Do not continue until the build passes.

### Step 3 — Bump version in `skills-manifest.json` (agent-os only)

**If the `claude/skills/` directory does not exist in the project root, skip this step silently — this project consumes agent-os but is not the agent-os repo.**

Read `skills-manifest.json` and determine the appropriate version bump:
- **Patch** — bug fixes, copy corrections, non-behavioral edits only
- **Minor** — new skills, new agents, or new features added this sprint
- **Major** — breaking changes that require manual user action

See `docs/context/versioning-policy.md` for the canonical definition of each tier and examples.

Increment `"release-version"` accordingly (e.g. `"v0.20.0"` → `"v0.20.1"` for patch, `"v0.21.0"` for minor). Write the updated value back to `skills-manifest.json`.

### Step 4 — Plan doc archival (rolling window)

**Plan doc archival (rolling window):** Move `docs/temp-sprint<N>-plan.md` to `docs/archive/plan-docs/S<N>.md`. Then check `docs/archive/plan-docs/` — delete any entries older than the 3-sprint window (keep current sprint + 2 prior). Git history retains all older content.

After moving the plan doc, stage the deletion so it does not appear as an uncommitted change:
```bash
git rm docs/temp-sprint<N>-plan.md
```

Then scan for any other `docs/temp-<sprint-scoped>-*.md` files whose name contains the sprint number (e.g. `docs/temp-s<N>-*.md`). For each found, run:
```bash
git rm <file>
```
Log each additional file removed. This catches spike docs, test results, editorial notes, and other sprint-scoped temp artifacts.

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
git add docs/archive/plan-docs/S<N>.md docs/context/plan.md docs/context/tracks.md
# If skills-manifest.json was updated in Step 3, stage it too:
# git add skills-manifest.json
git commit -m "chore(S<N>): sprint close — <new-version>, archive plan, reset context"
```

### Step 7b — Merged worktree sweep

After the sprint close commit, sweep merged worktrees:

1. For each directory under `.claude/worktrees/`:
   - Get the branch: `git -C <repo-root> -C <path> branch --show-current`
   - Check if merged: `git -C <repo-root> branch --merged main | grep <branch>`
   - If merged: `git -C <repo-root> worktree remove <path>` and log `removed worktree: <path> (branch: <branch>)`
   - If not merged or branch state ambiguous: log `skipped: <path> (not merged)` — do not remove
2. Delete all merged `worktree-agent-*` branches: `git -C <repo-root> branch --merged main | grep worktree-agent- | xargs git -C <repo-root> branch -d`
3. Log total removed count.

Note: use `git -C <repo-root>` form for all git commands in this step, where `<repo-root>` is the project root directory. This avoids the shell loop git-not-in-PATH issue that affects subshell environments.

### Step 8 — Create GitHub release and push (agent-os only)

**If the `claude/skills/` directory does not exist in the project root, skip the release creation: run `git push` only and continue — this project consumes agent-os but is not the agent-os repo.**

Before creating the release, derive the release notes from the sprint archive doc at `docs/archive/plan-docs/S<N>.md`. Use the "What changed" section (or equivalent) as the release body. Do not use a fallback string — if the archive doc is missing or has no substantive content, stop and ask the user for release notes before proceeding.

Derive the GitHub repo from the git remote — do not hardcode it:

```bash
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

gh release create <new-version> \
  --repo "$REPO" \
  --title "<new-version>" \
  --notes "<release notes from archive doc>"

git push
git fetch origin <new-version>
```

Note: `gh release create` pushes the tag to the remote. `git fetch origin <new-version>` syncs it locally. Do not run `git push origin <new-version>` — the tag already exists on the remote after `gh release create`.

### Step 9 — Run /clean-context

After the push succeeds, invoke `/clean-context`. This sweeps bridge files, merged worktrees, merged branches, and scratchpads automatically as the final act of sprint close.

`/clean-context` runs its own safety check (uncommitted work, dirty worktrees) and will bail with a warning if anything is unresolved — surface any bail messages to the user and do not proceed to Step 10 until the issue is resolved.

### Step 9b — Definition of Done (non-skippable)

Verify every item before writing the sprint close record. If any item is unchecked, surface it and stop — do not close the sprint until all items are verified.

- [ ] All tracks have exit records (MERGED, NO-OP, or DEFERRED with reason)
- [ ] Build passes (`bun run build` clean)
- [ ] (agent-os only) GitHub issues addressed this sprint are closed on the public mirror — skip if the `claude/skills/` directory does not exist in the project root
- [ ] No new tools, trackers, or third-party dependencies introduced outside an approved track
- [ ] QA APPROVED on all tracks

### Step 10 — Confirm

Output a short confirmation:

```
Sprint S<N> closed.

Version bumped to: <new-version>
Archive: docs/archive/plan-docs/S<N>.md
plan.md and tracks.md reset.
GitHub release: https://github.com/<repo>/releases/tag/<new-version>  (skipped if not an agent-os project)
/clean-context: complete
```

**Execution receipt:** On successful completion of all steps above, append one line to `docs/context/skill-receipts.jsonl` (create the file if absent):
```json
{"skill":"close-sprint","timestamp":"<ISO-8601 timestamp>","sprint":"<sprint-id>","version":"<release-version>","flags":[]}
```
- `timestamp`: current ISO-8601 datetime (e.g. `2026-09-02T14:30:00Z`)
- `sprint`: read from `docs/context/plan.md` — match `## Current Sprint: <ID>` or the sprint just closed (e.g. `S81`); if not found use `"unknown"`
- `version`: read `release-version` from `skills-manifest.json` in the project root (the post-bump value from Step 3); if not found use `"unknown"`
- Append only — never overwrite. Create the file and any missing parent directories silently if absent.

## Verification checklist

- All tracks for the closed sprint have DONE or DEFERRED exit records before Step 2 ran.
- `bun run build` passed.
- `skills-manifest.json` version bumped to the correct next version (agent-os only — skip if `claude/skills/` directory does not exist in the project root).
- Sprint plan doc archived to `docs/archive/plan-docs/S<N>.md`.
- `docs/context/plan.md` current sprint block collapsed to a single pointer line.
- `docs/context/tracks.md` sprint block collapsed to a single pointer line.
- Sprint close commit created with the correct message format.
- Merged worktrees swept (Step 7b): merged ones removed, non-merged ones logged.
- GitHub release created; `git push` and `git fetch origin <new-version>` ran without error.
- `/clean-context` invoked after push and completed without bail (or bail message surfaced to user if it fired).
