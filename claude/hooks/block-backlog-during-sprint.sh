#!/usr/bin/env bash
# .claude/hooks/block-backlog-during-sprint.sh
#
# PreToolUse hook: blocks Read/Write/Edit/Bash tool calls targeting
# docs/backlog.md when a sprint is currently open.
#
# Sprint state is determined by reading docs/context/plan.md:
#   - If any line matches '^## Current Sprint:' → sprint is open → block.
#   - If no such line exists → no active sprint → allow.
#
# Fails open on infrastructure errors: missing plan.md, missing jq, or
# unreadable file all result in exit 0 so the tool call proceeds normally.
#
# Tool discrimination:
#   Read/Write/Edit — checks .tool_input.file_path for "backlog.md"
#   Bash            — checks .tool_input.command   for "backlog.md"

set -euo pipefail

INPUT="$(cat)"
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"')"

# --------------------------------------------------------------------------- #
# 1. Determine if this call targets docs/backlog.md                           #
# --------------------------------------------------------------------------- #
TARGETING_BACKLOG=false

case "$TOOL_NAME" in
  Read|Write|Edit)
    FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')"
    case "$FILE_PATH" in
      *backlog.md*|*backlog*)
        TARGETING_BACKLOG=true
        ;;
    esac
    ;;
  Bash)
    COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')"
    # Skip git commands: "backlog.md" may appear in commit messages or log
    # output without the command actually reading or writing the file.
    case "$COMMAND" in
      git\ *|git$'\t'*)
        ;;
      *backlog.md*)
        TARGETING_BACKLOG=true
        ;;
    esac
    ;;
esac

if [ "$TARGETING_BACKLOG" = false ]; then
  exit 0
fi

# --------------------------------------------------------------------------- #
# 2. Check sprint state via docs/context/plan.md                              #
# --------------------------------------------------------------------------- #
PLAN_FILE="${CLAUDE_PROJECT_DIR}/docs/context/plan.md"

if [ ! -f "$PLAN_FILE" ]; then
  exit 0  # Fail open: plan.md not found
fi

if ! grep -q "^## Current Sprint:" "$PLAN_FILE" 2>/dev/null; then
  exit 0  # No active sprint — allow
fi

# --------------------------------------------------------------------------- #
# 3. Sprint is open + call targets backlog.md — hard block                    #
# --------------------------------------------------------------------------- #
cat >&2 <<'EOF'
Backlog locked during active sprint.

RULE: docs/backlog.md is off-limits once a sprint is open.
  The backlog is only read at /start-sprint time. Items added mid-sprint
  are the owner's scratch space — not tasks for the current sprint.

RECOVERY:
  If the owner explicitly needs backlog content mid-sprint, they should
  paste the relevant content directly into the conversation.
EOF

exit 2
