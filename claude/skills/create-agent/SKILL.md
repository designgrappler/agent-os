---
name: create-agent
description: Adds a new agent persona to ~/.claude/user-prefs.md — no agent file is created.
whenToUse: When the user wants to customize an agent name, personality, or context, or add a new specialist persona to their user preferences.
---

## Instructions

### Step 1 — Ask which canonical role to customize

Present the following 14 options and ask the user to choose one:

```
backend, critic, database, designer, frontend, marketing, mobile, ops, pm, qa, researcher, strategist, technical, writer
```

Wait for their selection before continuing.

---

### Step 2 — Gather persona details

Ask the user for:

1. **Name** — what should this agent be called? (e.g. "Bandit", "Suzy", "Max")
2. **Personality** — one sentence describing tone, disposition, or behavioral emphasis
3. **Context** — one sentence scoping where this agent operates (project or team name)

Wait for all three answers before continuing.

---

### Step 3 — Append to ~/.claude/user-prefs.md

1. Check whether `~/.claude/user-prefs.md` exists.
   - If **absent**: create the file with a `# User Preferences` heading.
   - If **present**: read the file. If a `## <role-key>` section for the chosen role already exists, overwrite its three fields in place. Otherwise append a new section at the end.

2. Write or append the following section:

```markdown
## <role-key>
**Name:** <Name>
**Personality:** <Personality>
**Context:** <Context>
```

Substitute the user's answers. Do not leave any `<brackets>` or placeholder text.

---

### Step 4 — Confirm

Tell the user:

```
Persona saved: ~/.claude/user-prefs.md

Role key: <role-key>
Name: <Name>
Personality: <Personality>
Context: <Context>

The orchestrator will prepend this persona to briefs when invoking the <role-key> agent.
```
