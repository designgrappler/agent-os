#!/usr/bin/env bash
# claude/hooks/sprint-state-on-session-start.sh
#
# SessionStart hook: emits active sprint state to stdout at session open.
#
# Reads docs/context/plan.md for an active sprint and counts open tracks in
# docs/context/tracks.md. Emits a one-line informational signal so every new
# session receives structural sprint context without reading the full files.
#
# Output format:
#   [Agent OS] Sprint S81 active — Agent OS System Integrity | 9 tracks open
#
# Exits 0 silently when:
#   - plan.md does not exist or contains no current sprint
#   - tracks.md does not exist
#   - git rev-parse fails (not in a git repo)
#
# No network calls, no jq dependency — file reads only.

set -euo pipefail

# ------------------------------------------------------------------ #
# 1. Find project root                                                #
# ------------------------------------------------------------------ #
PROJECT_ROOT=$(git -C "${CLAUDE_PROJECT_DIR:-.}" rev-parse --show-toplevel 2>/dev/null) || exit 0

PLAN_FILE="$PROJECT_ROOT/docs/context/plan.md"
TRACKS_FILE="$PROJECT_ROOT/docs/context/tracks.md"

# ------------------------------------------------------------------ #
# 2. Verify plan.md exists                                           #
# ------------------------------------------------------------------ #
if [ ! -f "$PLAN_FILE" ]; then
  exit 0
fi

# ------------------------------------------------------------------ #
# 3. Extract sprint ID and goal from plan.md                         #
# ------------------------------------------------------------------ #
# Line format: ## Current Sprint: S81 — Agent OS System Integrity
# Whitespace-delimited fields: ## Current Sprint: S81 — <goal words...>
# Field 4 = sprint ID; fields 6+ = goal (field 5 is the em-dash separator)
sprint_line=$(grep -m1 "^## Current Sprint:" "$PLAN_FILE" 2>/dev/null) || exit 0

if [ -z "$sprint_line" ]; then
  exit 0
fi

sprint_id=$(printf '%s' "$sprint_line" | awk '{print $4}')
sprint_goal=$(printf '%s' "$sprint_line" | awk '{out=""; for(i=6;i<=NF;i++) out=out (i>6?" ":"") $i; print out}')

if [ -z "$sprint_id" ]; then
  exit 0
fi

# ------------------------------------------------------------------ #
# 4. Count open tracks in tracks.md                                  #
# ------------------------------------------------------------------ #
open_count=0
if [ -f "$TRACKS_FILE" ]; then
  open_count=$(grep -c "^- \*\*Status:\*\* OPEN" "$TRACKS_FILE" 2>/dev/null) || open_count=0
fi

# ------------------------------------------------------------------ #
# 5. Emit sprint state signal to stdout                              #
# ------------------------------------------------------------------ #
if [ -n "$sprint_goal" ]; then
  echo "[Agent OS] Sprint ${sprint_id} active — ${sprint_goal} | ${open_count} tracks open"
else
  echo "[Agent OS] Sprint ${sprint_id} active | ${open_count} tracks open"
fi

exit 0
