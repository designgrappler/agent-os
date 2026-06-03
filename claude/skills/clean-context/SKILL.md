---
name: clean-context
description: Sanitize the project environment — archive scratchpads, remove merged worktrees and branches, update Context Health in tracks.md. Bail if uncommitted work is detected.
---

## Safety check

Run `git status`. If there is any uncommitted work in the current branch, **bail immediately** with a warning and do not proceed.

Run `git worktree list`. If any worktree (other than the main one) is dirty, bail with a warning naming the affected worktree.

Only continue when both checks pass.

## Scratchpad and temp-artifact archival

Scan for `scratchpad_*.md` files and temporary build artifacts in the project root and subdirectories.

Move them to `.agent/archives/` per project policy, or delete if the project has no archive directory and the file has no useful content. Log each action.

## Merged worktree sweep

For each directory under `.claude/worktrees/` (and `.worktrees/` if present), check whether its branch is merged into `main`:

```
git branch --merged main
```

If merged: run `git worktree remove <path>`. Use `--force` only when the worktree contains nothing beyond generated or symlinked artifacts (e.g. `node_modules`). Log any skipped worktrees with the reason.

## Merged branch sweep

Run `git branch --merged main`. Delete every `track/*` branch that appears:

```
git branch -d <branch>
```

**Never use `-D` (force-delete).** If a branch is not fully merged, log it and skip.

## Memory hygiene scan

Run after the merged-branch sweep and before the Context Health update.

Locate the memory directory at `~/.claude/projects/<sanitized-cwd>/memory/` where `<sanitized-cwd>` is the value of `CLAUDE_PROJECT_DIR` (or current working directory) with the leading `/` stripped and all remaining `/` replaced with `-`. Example: `/Users/I826932/Developer/agent-os-private` → `-Users-I826932-Developer-agent-os-private`.

If the memory directory does not exist, print `Memory hygiene scan: no memory directory found at <path> — skipping` and continue without error.

### File classification

For each file in the memory directory (excluding `MEMORY.md` itself), classify by filename prefix:

- **`reference_*`** — reference memory (pointers to external systems)
- **`feedback_*`** — feedback memory (behavioral rules)
- **`project_*`** — project memory (sprint/initiative state)
- **unclassified** — any file not matching the above prefixes

### Per-category staleness policy

**`reference_*` — never auto-flag for prune.** Only flag as `RETIRE candidate` if the concrete artifact referenced in the body (script path, repo path, file path) no longer exists at that path.

**`feedback_*` — never auto-flag for prune.** Only flag as `RETIRE candidate` if the behavioral rule has been codified verbatim into `AGENTIC.md`, any `claude/agents/*.md`, or any `claude/skills/**/SKILL.md` (i.e. the rule is now enforced as a system constraint and the memory file is redundant).

**`project_*` — flag as `RETIRE candidate` only if BOTH of the following signals are present (two-signal rule):**
1. The `Created:` field (per AGENTIC.md Memory Authoring Convention) is older than 90 days, OR the file's mtime is older than 90 days.
2. The referenced sprint is archived (appears in `docs/context/plan.md` Completed Sprint sections OR in `docs/archive/plan-docs/`), OR the file contains no sprint reference AND is not referenced in `MEMORY.md`'s index.

A single signal alone (e.g. mtime > 90 days by itself) is **not sufficient** to flag a `project_*` file. Both signals must be independently satisfied.

If the `Created:` field is missing, surface the file as `stale-undatable` in the `Stale signals matched` column — the two-signal rule still applies; missing `Created:` alone does not trigger a flag.

**Unclassified — never auto-flag.** Surface as `manual review required` with no action proposed.

### Report format

Print findings as a markdown table with these columns:

| File | Category | Stale signals matched | Action proposed |
|---|---|---|---|
| `path/to/file.md` — first-line summary | reference / feedback / project / unclassified | explicit list e.g. "mtime 187d; S6 archived; not in MEMORY.md index" | RETAIN / RETIRE candidate / MERGE candidate (duplicate of X) / manual review required |

If no findings are produced (all files pass their category policy), print `Memory hygiene scan: no findings — all memory files current.`

### Hard constraints

**Never delete any memory file.** This step is read-only with respect to memory file content and existence. The Conductor decides whether to mark a candidate `STATUS: retired`.

When the Conductor approves a retirement, the skill writes two lines into the file in-place (no deletion):
```
STATUS: retired — <one-line reason>
Retired: YYYY-MM-DD
```
The file remains on disk as part of the learning record.

### Tombstone retirement workflow

After the report is displayed, ask: "Approve any retirements? (list file numbers, or 'none')"

For each approved file:
1. Write `STATUS: retired — <reason from Conductor>` and `Retired: YYYY-MM-DD` as the first content lines (after frontmatter, before body).
2. Print confirmation: `Retired: <filename>`.
3. Do NOT delete the file.

For declined files: log as `Retained — Conductor decision`.

## Context Health update

Open `docs/context/tracks.md`. Update the "Context Health" status line to reflect the current state (branches pruned, worktrees removed, scratchpads archived, memory hygiene scan run). Record the date.

## Verification checklist

- Safety gate fires: skill refuses to proceed when `git status` shows uncommitted work or any worktree is dirty.
- Scratchpad/temp files were moved or deleted; `.agent/archives/` updated where applicable.
- Merged worktrees under `.claude/worktrees/` (and `.worktrees/` if present) were removed; unmerged ones were logged and skipped.
- No `track/*` branch that was already merged to `main` remains; unmerged ones were logged.
- Memory hygiene scan: the pruning report fired (or "no findings" was printed); no memory file was deleted.
- `tracks.md` Context Health entry updated with the current date.
