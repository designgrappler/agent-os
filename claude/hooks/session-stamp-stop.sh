#!/usr/bin/env bash
# claude/hooks/session-stamp-stop.sh
#
# Stop hook: deletes the session stamp written by the orchestrator at session
# init. Ensures ~/.claude/.session-version is absent between sessions so that
# update-agent-os can distinguish a live session from an idle state.
#
# Wired as a Stop hook in .claude/settings.json (project) and
# ~/.claude/settings.json (global).

set -euo pipefail

# Drain stdin (Stop hook may deliver session JSON; not needed here)
cat > /dev/null 2>&1 || true

STAMP_FILE="$HOME/.claude/.session-version"

if [ -f "$STAMP_FILE" ]; then
  rm -f "$STAMP_FILE"
fi

exit 0
