#!/usr/bin/env bash
# .claude/hooks/block-backlog-write.sh
#
# PreToolUse hook: blocks all Edit/Write calls targeting docs/backlog.md
# from any caller — main thread or subagent.
#
# docs/backlog.md is user-owned. It may only be modified by:
#   - /start-sprint  (removes promoted items)
#   - /track-close   (removes reconciled item)
#   - /close-sprint  (removes completed items)
#   - Direct user instruction (explicit approval at the tool prompt)
#
# All other writes — observations, QA findings, permission notes, etc. —
# are out of scope and must not happen.

set -euo pipefail

INPUT="$(cat)"
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"')"
FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // "unknown"')"

cat >&2 <<EOF
docs/backlog.md is write-protected.

Tool:  $TOOL_NAME
Path:  $FILE_PATH

docs/backlog.md may only be written by explicit user instruction or the
skills /start-sprint, /track-close, and /close-sprint. Observations,
findings, and notes belong in chat — not in the backlog.
EOF

exit 2
