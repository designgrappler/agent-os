#!/usr/bin/env bash
# block-manual-agent-spawn.sh
# Blocks Sprint Coordinator-initiated Agent tool spawns in gated-approve mode (exit 2).
# Identity detection: agent_id absent = main-thread (Sprint Coordinator) call;
# agent_id present = subagent call (Specialist, QA, nested agent) — always passes through.
# gated-approve mode: exit 2 with blocking stderr message. auto-approve mode: exit 0.
# Source: docs/bridges/T26A-hook-block.md (Gap 1 — exit 2 enforcement)
# Behavioral claims pinned to https://code.claude.com/docs/en/hooks

set -euo pipefail

INPUT="$(cat)"

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
AGENT_ID="$(printf '%s' "$INPUT" | jq -r '.agent_id // empty')"

# Not an Agent/Task tool call → allow
if [[ "$TOOL_NAME" != "Agent" && "$TOOL_NAME" != "Task" ]]; then
  exit 0
fi

# Subagent call (agent_id present) → allow (Specialist, QA, or nested agent)
if [ -n "$AGENT_ID" ]; then
  exit 0
fi

# Main-thread Agent/Task call → check operating mode
OPERATING_MODE="$(jq -r '.operatingMode // empty' "${CLAUDE_PROJECT_DIR}/.claude/settings.json" 2>/dev/null)"

if [ "$OPERATING_MODE" = "gated-approve" ]; then
  echo "Sprint Coordinator Agent tool spawn blocked in gated-approve mode." >&2
  echo "gated-approve mode dispatch: output a kickoff card (two fenced blocks per track) for Tim to paste." >&2
  echo "Inline Agent tool spawning is only valid in auto-approve mode. See AGENTIC.md §3." >&2
  exit 2
fi

# auto-approve mode or mode unset → allow
exit 0
