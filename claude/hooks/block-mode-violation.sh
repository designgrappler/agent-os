#!/usr/bin/env bash
# .claude/hooks/block-mode-violation.sh
#
# PreToolUse hook: blocks Edit/Write tool calls if any track in
# docs/context/tracks.md has Status: OPEN.
#
# Behavior:
#   - Reads PreToolUse stdin JSON.
#   - If tool_name is not Edit or Write, allow (exit 0).
#   - If docs/context/tracks.md does not exist, allow (no track state to
#     enforce against).
#   - If docs/context/tracks.md contains any line matching '**Status:** OPEN',
#     block via exit code 2 with a remediation message on stderr.
#   - Otherwise, allow (exit 0).
#
# Coexistence:
#   - Runs alongside .claude/hooks/block-orchestrator-execution.sh under
#     the same PreToolUse matcher block (matcher: Edit|Write). Both fire
#     in parallel per Claude Code hooks contract (2026-06-20 verification).
#     Each hook enforces an independent rule; deny from either blocks.
#
# Notes:
#   - Path-pattern matching for file_path is NOT done by this script.
#     The policy is track-state-based, not path-based.
#   - Requires `jq` (for stdin JSON parsing) and grep (for tracks.md check).

set -euo pipefail

command -v jq >/dev/null 2>&1 || { echo "[hook] requires jq — install via: brew install jq" >&2; exit 1; }

# Read all stdin
INPUT="$(cat)"

# Extract tool_name. Default empty so the comparison below is deterministic.
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"

# Only enforce on Edit or Write. All other tools pass through.
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# Resolve tracks.md path. CLAUDE_PROJECT_DIR is provided by the Claude
# Code runtime to hooks; fall back to the current working directory if
# unset (defensive — hooks should always have it set, but no reason to
# crash if not).
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
TRACKS_FILE="$PROJECT_DIR/docs/context/tracks.md"

# Absent file → no track state to enforce → allow.
if [ ! -f "$TRACKS_FILE" ]; then
  exit 0
fi

# Check for any OPEN tracks. grep exits non-zero if no match → allow.
if ! grep -q '\*\*Status:\*\* OPEN' "$TRACKS_FILE" 2>/dev/null; then
  exit 0
fi

# OPEN tracks detected → deny.
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // "unknown"')"

cat >&2 <<EOF
Edit/Write blocked by tool-layer hook: open tracks detected.

Tool:  $TOOL_NAME
Path:  $FILE_PATH

The open-tracks guard forbids file modifications while any track in
docs/context/tracks.md has "**Status:** OPEN". Resolve or close all open
tracks before making changes, or proceed under explicit Conductor override.

To unblock:
  - Update open tracks to a terminal status (DONE, BLOCKED, or CANCELLED)
    in docs/context/tracks.md, OR
  - Get explicit Conductor override to bypass this check.

See docs/context/tracks.md for current track status.
EOF

exit 2
