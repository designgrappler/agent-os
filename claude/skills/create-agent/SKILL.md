---
name: create-agent
description: Interactively scaffolds a new agent definition file at .claude/agents/<name>.md
whenToUse: When the user wants to create a new agent, add a new specialist, or set up a custom agent for their project.
---

## Instructions

### Step 1 — Gather agent details

Ask the user for the following. Wait for all answers before continuing.

1. **Agent name** — a short, lowercase, hyphen-separated identifier (e.g. `data-analyst`, `mobile-specialist`)
2. **Role description** — one sentence describing what this agent does
3. **Domain** — what area is this agent expert in? (e.g. "iOS native development", "data pipelines", "frontend React")
4. **Tools needed** — which tools should this agent have access to? (defaults: Read, Write, Edit, Bash, WebFetch — ask if they want to add or remove any)
5. **Worktree isolation** — should this agent get an isolated copy of the repo when it runs? (yes / no — default: yes for Specialists that write files, no for read-only agents like QA or researchers)

---

### Step 2 — Derive frontmatter values

From the user's answers, derive:

- `name:` → the agent name as given (lowercase, hyphen-separated)
- `description:` → the role description (one sentence, present tense, concise)
- `provider: claude`
- `model: sonnet`
- `tools:` → the tools list the user confirmed
- `isolation: worktree` → include this line only if the user said yes to worktree isolation

---

### Step 3 — Generate the agent file

Write the following to `.claude/agents/<name>.md` (where `<name>` is the agent name from Step 1):

```markdown
---
name: <name>
description: <description>
provider: claude
model: sonnet
tools:
  - Read
  - Write
  - Edit
  - Bash
  - WebFetch
[  - isolation: worktree   ← include only if user said yes]
---

# <Role Title>

<One paragraph: what this agent does, what domain it operates in, and what it does NOT do. Be concrete — name the files, systems, or areas it owns.>

## What the agent does

- <Capability 1>
- <Capability 2>
- <Capability 3>

## What the agent does NOT do

- Does not touch files outside its declared scope
- Does not make planning or architecture decisions
- <Any other specific exclusions based on the domain>

## Hard constraints

- Scope-locked to the files declared in the task context
- Never commits unless explicitly directed
- 3 consecutive failures with the same root cause → stop and report to the orchestrator
```

Substitute all placeholder values with the user's actual answers. Do not leave any `<brackets>` or placeholder text in the output file.

**Tool list:** use only the tools the user confirmed. If the user wants `isolation: worktree`, that line belongs in the frontmatter `tools:` block's sibling position — not inside the `tools:` list itself. Correct frontmatter shape when isolation is included:

```yaml
---
name: <name>
description: <description>
provider: claude
model: sonnet
isolation: worktree
tools:
  - Read
  - Write
  - Edit
  - Bash
  - WebFetch
---
```

---

### Step 4 — Confirm

Tell the user:

```
Agent created: .claude/agents/<name>.md

Role: <description>
Tools: <comma-separated list>
Isolation: <yes / no>

You can invoke this agent with @<name> in Claude Code.
To edit: open .claude/agents/<name>.md directly or ask your orchestrator.
```
