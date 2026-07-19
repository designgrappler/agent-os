#!/usr/bin/env bash
# .claude/hooks/block-mode-violation.sh
#
# PreToolUse hook: blocks Edit/Write tool calls if any task in
# docs/tasks.json is in CLAIMED or IN_PROGRESS state. Standalone
# tasks-in-flight Edit/Write guard (codified in T17.3, hardened in T19.6).
# Not tied to the /switch-workflow-mode skill (retired S23 T23.A.2).
#
# Behavior:
#   - Reads PreToolUse stdin JSON.
#   - If tool_name is not Edit or Write, allow (exit 0).
#   - If docs/tasks.json does not exist or is empty, allow (no tasks in
#     flight; no policy to enforce).
#   - If docs/tasks.json contains any task with status CLAIMED or
#     IN_PROGRESS, block via exit code 2 with a remediation message on
#     stderr listing every blocking task.
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
#     The policy is tasks-state-based, not path-based.
#   - Requires `jq` (already a dependency of S18.1 hook; assumed present).

set -euo pipefail

# Read all stdin
INPUT="$(cat)"

# Extract tool_name. Default empty so the comparison below is deterministic.
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"

# Only enforce on Edit or Write. All other tools pass through.
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ]; then
  exit 0
fi

# Resolve tasks.json path. CLAUDE_PROJECT_DIR is provided by the Claude
# Code runtime to hooks; fall back to the current working directory if
# unset (defensive — hooks should always have it set, but no reason to
# crash if not).
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
TASKS_FILE="$PROJECT_DIR/docs/tasks.json"

# Absent or empty file → no tasks in flight → allow.
if [ ! -f "$TASKS_FILE" ]; then
  exit 0
fi
if [ ! -s "$TASKS_FILE" ]; then
  exit 0
fi

# Parse tasks.json defensively. If the file is not valid JSON, allow
# (do NOT block on a parse error — that would create a soft-brick if
# tasks.json gets corrupted). Surface the parse failure on stderr for
# observability but exit 0.
if ! BLOCKING_TASKS="$(jq -r '
  .tasks // []
  | map(select(.status == "CLAIMED" or .status == "IN_PROGRESS"))
  | map("\(.id) is \(.status)")
  | join(", ")
' "$TASKS_FILE" 2>/dev/null)"; then
  echo "block-mode-violation.sh: warning — could not parse $TASKS_FILE; allowing." >&2
  exit 0
fi

# No blocking tasks → allow.
if [ -z "$BLOCKING_TASKS" ]; then
  exit 0
fi

# Blocking tasks present → deny.
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // "unknown"')"

cat >&2 <<EOF
Edit/Write blocked by tool-layer hook: active tasks detected.

Tool:           $TOOL_NAME
Path:           $FILE_PATH
Blocking tasks: $BLOCKING_TASKS

The tasks-in-flight guard forbids file modifications while
any task in docs/tasks.json is in CLAIMED or IN_PROGRESS state. This
prevents mid-flight mode switches from corrupting active sprint work.

To unblock:
  - Resolve all in-flight tasks (move them to DONE or BLOCKED), OR
  - Cancel the affected tasks explicitly via /sync-tasks-to-tracks.

See AGENTIC.md §3 for the tasks-in-flight Edit/Write guard enforcement model.
EOF

exit 2
