#!/usr/bin/env bash
# .claude/hooks/remind-close-sprint.sh
#
# PostToolUse hook: reminds user to run /close-sprint when all current-sprint
# tracks are DONE or CLOSED.
#
# Triggered by PostToolUse on edits/writes to docs/context/tracks.md or
# docs/context/plan.md (wired via if-clause in settings.json).
#
# Detection:
#   - Current sprint = highest T<N>.x sprint number across all ## Track headers
#   - If ALL tracks for that sprint have header-level **Status:** DONE or CLOSED
#     → emit reminder to stderr and exit 2
#   - Otherwise exit 0 silently
#
# Fails open on any error (missing tracks.md, parse failure, etc.).
#
# NOTE: this hook fires once during a legitimate /close-sprint run when it
# flips the final track to DONE and saves. That is acceptable — it is
# non-blocking and the user has already invoked /close-sprint.

set -uo pipefail

# Drain stdin (PostToolUse delivers tool result JSON; not needed here)
cat > /dev/null

TRACKS_FILE="${CLAUDE_PROJECT_DIR}/docs/context/tracks.md"

if [ ! -f "$TRACKS_FILE" ]; then
  exit 0
fi

# ------------------------------------------------------------------ #
# 1. Find current sprint: highest N in "## Track T<N>." headers       #
# ------------------------------------------------------------------ #
current_sprint=$(grep -oE '^## Track T[0-9]+\.' "$TRACKS_FILE" 2>/dev/null \
  | grep -oE 'T[0-9]+' \
  | grep -oE '[0-9]+' \
  | sort -n \
  | tail -1)

if [ -z "$current_sprint" ]; then
  exit 0
fi

# ------------------------------------------------------------------ #
# 2. Collect header-level **Status:** values for current-sprint tracks #
# ------------------------------------------------------------------ #
# For each "## Track T<N>." header, capture the FIRST **Status:** line
# encountered (the track's own status, not the exit-record status).
statuses=$(awk -v sprint="$current_sprint" '
  /^## Track T/ {
    in_track = 0
    if (index($0, "## Track T" sprint ".") > 0) {
      in_track = 1
    }
  }
  in_track && /\*\*Status:\*\*/ {
    line = $0
    sub(/.*\*\*Status:\*\*[[:space:]]*/, "", line)
    print line
    in_track = 0
  }
' "$TRACKS_FILE")

if [ -z "$statuses" ]; then
  exit 0
fi

# ------------------------------------------------------------------ #
# 3. Check if all statuses are DONE or CLOSED                         #
# ------------------------------------------------------------------ #
all_complete=true
while IFS= read -r status; do
  # Strip leading/trailing whitespace
  trimmed="${status#"${status%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
  if [ "$trimmed" != "DONE" ] && [ "$trimmed" != "CLOSED" ]; then
    all_complete=false
    break
  fi
done <<< "$statuses"

if [ "$all_complete" = true ]; then
  echo "Sprint work looks complete — run /close-sprint rather than editing tracks.md/plan.md directly." >&2
  exit 2
fi

exit 0
