---
name: install-agent-scaffold
description: Bootstraps a new project with the Agent OS structure.
---
# Install Agent Scaffold
Bootstraps a new project with the Agent OS structure. Drops a setup file for the user to fill in — no files are generated until it's complete.

> **Existing project?** Stop. Use `/onboard-existing-project` instead. This skill assumes a blank slate.

## Trigger
When the user runs `/install-agent-scaffold`.

---

## Step 1: Pre-flight

1. If `CLAUDE.md` exists and contains Agent OS content → stop. Tell the user this project is already initialized. Suggest `/onboard-existing-project` to update an existing setup.
2. If `AgentOS-Setup.md` does **not** exist → go to Step 2.
3. If `AgentOS-Setup.md` exists → go to Step 3.

---

## Step 2: Drop Setup File

Write the following content to `AgentOS-Setup.md` at the project root, then stop and tell the user:

> **Step 1 of 2 complete — `AgentOS-Setup.md` created.**
>
> Fill in your project details:
> - **Project** — your project name and description
> - **Tech Stack** — defaults are pre-selected; replace any value you want to change
>
> When you're done, run `/install-agent-scaffold` again in this chat. Step 2 will generate: `CLAUDE.md`, agent definitions, `docs/context/` files, and `skills-manifest.json`.

```markdown
# Agent OS Setup

Fill in the fields below, then run `/install-agent-scaffold` in Claude Code.
This file will be deleted automatically when setup is complete.

---

## Project

**Project name:** 
**Short description:** 

---

## Define Your Tech Stack

Defaults are pre-selected. Replace any value you want to change. Leave blank to skip optional fields.

**Runtime:** Node.js <!-- alternatives: Bun · Python · Go · Deno -->
**Framework:** Express <!-- alternatives: Hono · FastAPI (Python) · Gin (Go) · Koa -->
**Database:** PostgreSQL via Supabase <!-- alternatives: PlanetScale · MongoDB · SQLite · leave blank if none -->
**Frontend framework:** React + Vite <!-- alternatives: Next.js · SvelteKit · Nuxt · Remix · leave blank if none -->
**Styling:** Tailwind CSS <!-- alternatives: CSS Modules · Styled Components · Sass · leave blank if none -->
**Build command:** npm run build <!-- alternatives: bun run build · python -m build -->
**Type check command:** <!-- e.g. bunx tsc --noEmit · mypy · leave blank if none -->
**Linter:** ESLint + Prettier <!-- alternatives: Biome · Ruff (Python) · leave blank if none -->

---

## Existing docs to migrate *(optional)*

Update the paths below to match your actual files. Delete rows that don't apply.

| Current file | Maps to |
|---|---|
| README.md | docs/context/product.md |
| [roadmap, backlog, or requirements doc] | docs/context/plan.md |
| [design spec or product brief] | docs/context/product.md |
| [sprint notes or task list] | docs/context/tracks.md |
```

Stop here. Do not generate any other files.

---

## Step 3: Parse AgentOS-Setup.md

Read `AgentOS-Setup.md`. Extract values as follows.

**Project fields** — read `**Project name:**` and `**Short description:**`, take the value after the colon.

**Tech stack fields** — for each `**Field:** value <!-- comment -->` line, take the text between `:` and `<!--` (trim whitespace). If blank, the field is not configured.

**Docs migration** — for each row in the migration table where the "Current file" cell is not a placeholder (not blank, not bracketed), record `{from: "path", to: "docs/context/X.md"}`.

**Extracted values:**
- `NAME` = Project name
- `DESCRIPTION` = Short description
- `RUNTIME`, `FRAMEWORK`, `DATABASE`, `FRONTEND`, `STYLING`, `BUILD_CMD`, `TYPECHECK_CMD`, `LINTER`
- `MIGRATIONS` = list of confirmed doc migration pairs

**Validation** — stop and list what's missing if any of these are blank:
- `NAME`, `DESCRIPTION`, `BUILD_CMD`

If all required values are present → proceed to Step 4.

---

## Step 4: Generate Files

Create all files below. For each file that already exists, show the diff and ask: merge, replace, or skip.

---

### Model alias guidance (read before generating any agent)

Every generated agent file uses these frontmatter fields:

```yaml
model: sonnet          # tier alias: opus | sonnet | haiku
```

Use the short alias — it tracks the best-available model in that tier.

| Role | Tier |
|---|---|
| Technical Architect | `opus` — heavy reasoning, plan synthesis |
| Orchestrator / Specialist / QA | `sonnet` — standard execution |
| Lightweight / fast tasks | `haiku` — quick lookups, reformatting |

---

### 4a. `CLAUDE.md`

```markdown
# [NAME] — Claude Code Configuration

## Team

| Role | Function |
|---|---|
| **Tim** | Owner — vision and approval |
| **Orchestrator** | Routes tasks, triage decisions |
| **Specialist** | Domain expert for complex tasks |
| **Task Agent** | Executes scoped work |
| **QA** | Read-only quality gate |

Agents are defined in `.claude/agents/`.

---

## Orchestrator Behavior

Orchestrator behavior is defined in `claude/skills/orchestrator/SKILL.md` — loaded at session start.

---

## Sprint Workflow

Sprint workflow: invoke `/start-sprint` to enter sprint mode.

---

## Tech Stack

- **Runtime:** [RUNTIME]
- **Framework:** [FRAMEWORK]
- **Database:** [DATABASE or "none configured"]
- **Frontend:** [FRONTEND or "none configured"]
- **Styling:** [STYLING or "none configured"]
- **Build Command:** `[BUILD_CMD]`
- **Type Check:** [TYPECHECK_CMD or "none configured"]
- **Linter:** [LINTER or "none configured"]

---

## Worktree Protocol

Worktree isolation is automatic via agent frontmatter (`isolation: worktree`) and `.claude/settings.json` (`worktree.baseRef: "head"`). No manual git commands needed.

---

## Hooks

Stop hook: prints hygiene reminder at session end.
```

---

### 4b. `claude/skills/orchestrator/SKILL.md`

Copy from the canonical source at `claude/skills/orchestrator/SKILL.md`. This is a verbatim copy — do not modify its content.

---

### 4c. `.claude/agents/` — Role agent files

Copy the following agent files from the canonical `claude/agents/` directory into the project's `.claude/agents/`:

- `technical-architect.md`
- `qa.md`
- `task-coder.md`
- `task-researcher.md`
- `task-writer.md`

These are unmodified copies of the canonical files.

**Global-namespace guard:** before copying any agent to a global `~/.claude/agents/` scope, verify the agent name is present in `skills-manifest.json` `agents[]`. If absent, install project-local only and log:
```
"<name>" is not a canonical agent — installed project-local only.
```

---

### 4d. `docs/context/plan.md`

If a migration source was confirmed for `plan.md`, copy that file and prepend:
```
<!-- Migrated from [original path] — review and update stale content. -->
```
Otherwise create:

```markdown
# [NAME] — Active Plan

## Current Sprint: Initial Setup

- [ ] Review CLAUDE.md and confirm the team configuration looks right.
- [ ] Open your first sprint with `/start-sprint`.

---

*Last updated: [TODAY'S DATE]*
```

---

### 4e. `docs/context/tracks.md`

```markdown
# Active Tracks

No active tracks. Add tracks as work begins.

---

*Last updated: [TODAY'S DATE]*
```

---

### 4f. `skills-manifest.json`

Create `skills-manifest.json` at the project root pointing to the canonical registry:

```json
{
  "canonical-registry": "https://raw.githubusercontent.com/gastownhall/agent-os/main/skills-manifest.json",
  "installed-version": "v0.20.0"
}
```

---

### 4g. `.claude/settings.json`

If `.claude/settings.json` already exists, merge — do not remove existing entries. If it does not exist, create:

```json
{
  "worktree": {
    "baseRef": "head"
  },
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ended. Reminder: archive completed tracks, verify plan.md is current, confirm no uncommitted changes.'"
          }
        ]
      }
    ]
  },
  "permissions": {
    "defaultMode": "default",
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(find *)",
      "Bash(grep *)"
    ]
  }
}
```

---

### 4h. `.gitignore` additions

Append to `.gitignore` if not already present:
```
.worktrees/
.claude/settings.local.json
```

---

### 4i. Delete `AgentOS-Setup.md`

After all files are created successfully, delete `AgentOS-Setup.md`.

---

## Step 5: Confirm

```
## Agent OS Installed

**Project:** [NAME]
**Files created:** [count]

**Next steps:**
1. Review CLAUDE.md — confirm tech stack is correct.
2. Open your first sprint with `/start-sprint`.
3. Run `[BUILD_CMD]` to confirm the build environment is clean.

**Activate skills:** Close and reopen your IDE window — installed skills load on session start.
```
