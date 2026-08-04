#!/usr/bin/env bash
# .claude/hooks/block-uncommitted-dispatch.sh
#
# PreToolUse hook: blocks Specialist dispatch when main has tracked-file
# changes (staged or unstaged). Tool-layer enforcement of the CLAUDE.md §5
# "Commit-before-dispatch" rule (codified in S29 T29.C).
#
# Behavior:
#   - Reads PreToolUse stdin JSON.
#   - If `agent_id` is present in the JSON → call is from inside a subagent
#     (Specialist, Architect, QA). Allow immediately (only main-thread dispatch
#     is guarded — subagents cannot themselves dispatch via the main thread).
#   - If `agent_id` is absent → call is from the main thread (Conductor or
#     Sprint Coordinator initiating dispatch).
#   - Runs `git diff --quiet && git diff --cached --quiet` from CLAUDE_PROJECT_DIR.
#     Both must exit 0 (no tracked-file changes, staged or unstaged) for the
#     hook to allow.
#   - Untracked files are intentionally ignored — only tracked-file changes
#     are in scope for the commit-before-dispatch rule.
#   - If tracked-file changes are found: emit a remediation message on stderr
#     referencing CLAUDE.md §5 and exit 2 (blocking error).
#
# Notes:
#   - Requires `jq` (assumed present; install via Homebrew: `brew install jq`).
#   - Requires `git` (always present in this repo).
#   - CLAUDE_PROJECT_DIR is set by the Claude Code runtime (same env var used
#     by block-orchestrator-execution.sh and block-manual-agent-spawn.sh).

set -euo pipefail

# Read all stdin
INPUT="$(cat)"

# Extract agent_id; produces empty string when the field is absent or null.
AGENT_ID="$(printf '%s' "$INPUT" | jq -r '.agent_id // empty')"

if [ -n "$AGENT_ID" ]; then
  # Subagent invocation (Specialist, QA, nested agent) — allow.
  exit 0
fi

# Main-thread dispatch — check for tracked-file changes.
# git diff --quiet exits 0 if no unstaged tracked-file changes.
# git diff --cached --quiet exits 0 if no staged tracked-file changes.
# Untracked files are NOT checked; only tracked-file state matters.
if git -C "${CLAUDE_PROJECT_DIR}" diff --quiet 2>/dev/null && \
   git -C "${CLAUDE_PROJECT_DIR}" diff --cached --quiet 2>/dev/null; then
  # Working tree is clean (tracked files only) — allow dispatch.
  exit 0
fi

# Tracked-file changes detected — block dispatch.
cat >&2 <<'EOF'
Specialist dispatch blocked by commit-before-dispatch hook.

RULE: CLAUDE.md §5 "Commit-before-dispatch (binding)"
  Before dispatching a Specialist, the Conductor must commit all staged
  changes on main. Uncommitted working-tree changes do not reach Specialist
  worktrees — dispatching with uncommitted state silently strands the
  Specialist on a stale baseline.

CAUSE: main has tracked-file changes (staged or unstaged).
  NOTE: Untracked files are NOT the cause — this hook ignores them.

RECOVERY:
  1. Run `git status` to inspect what is uncommitted.
  2. Commit the changes: `git add <files> && git commit -m "..."`.
     OR stash them if they should not be committed: `git stash push -u`.
  3. Re-invoke the Specialist once the working tree is clean.
EOF

exit 2
