#!/bin/bash
# Fires on every UserPromptSubmit. Checks once per project path whether
# Agent OS is globally installed but the current project has no local scaffold.
# Emits a JSON systemMessage (user-visible) then marks the path so it fires once only.

# Guard 1: skip if Agent OS global layer not installed
if [ ! -d "$HOME/.claude/agents" ] || [ -z "$(ls -A "$HOME/.claude/agents" 2>/dev/null)" ]; then
  exit 0
fi

# Guard 2: skip if project already scaffolded
if [ -f "CLAUDE.md" ]; then
  exit 0
fi

# Guard 3: skip if this path was already notified
if command -v md5sum >/dev/null 2>&1; then
  _HASH=$(printf '%s' "$(pwd)" | md5sum | cut -d' ' -f1)
else
  _HASH=$(printf '%s' "$(pwd)" | md5 -q)
fi
MARKER_FILE="$HOME/.claude/agent-os-notified-$_HASH"
if [ -f "$MARKER_FILE" ]; then
  exit 0
fi

# Write marker before emitting — prevents double-fire if hook is interrupted
touch "$MARKER_FILE"

printf '{"systemMessage": "Agent OS is installed globally but this project has no local scaffold. Run /install-agent-scaffold (new project) or /onboard-existing-project (existing project) to enable sprints, backlog, agent routing, and orchestration for this project."}\n'
exit 0
