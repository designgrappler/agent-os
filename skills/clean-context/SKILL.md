---
name: clean-context
description: The "Entropy Filter" that sanitizes the environment and prepares a clean context for the next strategic turn.
Abbreviation: Cc
Category: Maintenance
Type: Tier 3
Capabilities: [fs_read, fs_write]
---

# Skill: Context Cleaner

## Description
The "Entropy Filter" of the Agent OS. This skill sanitizes the implementation environment by archiving scratch files, consolidating temporary test results, and ensuring the context is lean and high-signal for the Architect.

## Operational Rules
- **🛡️ TACTICAL EXECUTION (MANDATORY)**: You are a member of the **Implementation Team** (Tier 3). Your goal is to eliminate context bloat.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header (Do not include "This is [Name], your [Role]" as it is redundant):
    > **[Name] ([Role])**
- **Zero-Pause Automation**: When you declare the start of a sanitization activity (e.g., "Archiving scratchpads now"), you **MUST** trigger the relevant tool call in the same turn. Do not stop and wait for a user "ok."
- **De-clutter Logic**:
    1. **Safety check first**: run `git status` and bail with a warning if there is any uncommitted work in the current branch or any worktree listed by `git worktree list`. Do not proceed until the workspace is clean.
    2. Scan for old `scratchpad_*.md` files or temporary build artifacts.
    3. Move them to `.agent/archives/` or delete as per project policy.
    4. **Merged worktree sweep**: for each directory under `.worktrees/`, check whether its branch is merged into `main` (`git branch --merged main`). If merged, run `git worktree remove <path>`; use `--force` only when the worktree contains nothing beyond generated/symlinked artifacts (e.g. `node_modules`). Log any skipped worktrees with the reason.
    5. **Merged branch sweep**: run `git branch --merged main` and delete every `track/*` branch that appears (`git branch -d <branch>`). Never use `-D` (force-delete) — if a branch is not fully merged, log it and skip.
    6. Update `tracks.md` to reflect the "Context Health" status.

## Verification (How to test if this skill is working)
1. **Safety gate**: Confirm the skill refuses to proceed when `git status` shows uncommitted work or a dirty worktree.
2. **Sanitization Audit**: Verify that scratch files were moved/removed and `.worktrees/` entries for merged branches were removed — all in a single turn.
3. **Branch sweep**: Confirm no `track/*` branches that were already merged to `main` remain after the run.
4. **Identity Check**: Confirm the "Clean Color Bar" (blockquote) header is present and the bold intro sentence is NOT used.

## Stats
- **Overhead**: Very Low
- **Operational Level**: Level 3 (Tactical Maintenance)
- **Benefit**: Prevents "context rot" and reduces token overhead for the Architect.

## Trigger
Tell Specialist: "Clean our project context."
