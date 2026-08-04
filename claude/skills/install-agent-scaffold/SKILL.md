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

**Git detection (always run first).** Check whether the current folder is inside a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

- **If the command succeeds (exit 0):** set `GIT_PRESENT=true`. Proceed normally.
- **If the command fails (non-zero exit):** set `GIT_PRESENT=false`. Continue installation with the following adjustments active throughout:
  - In Step 4a (`CLAUDE.md`): omit the `## Worktree Protocol` section and `## Sprint Workflow` section. In their place, emit:
    ```
    > **Note:** No git repo detected — sprint workflow, worktree isolation, and Beads issue tracking are unavailable in this session. Run `git init` to activate the full Agent OS feature set on next session start. No reinstall needed — all `.claude/` files remain valid.
    ```
  - In Step 4g (`.claude/settings.json`): omit the `worktree.baseRef` field from the generated JSON.
  - In Step 4h (`.gitignore` additions): skip this step — no git repo means no `.gitignore` to update.
  - In Step 6 (Confirm output): add a notice line: `**Git repo:** Not detected — sprint workflow and Beads unavailable. Run \`git init\` to enable the full feature set on next session start.`

1. If `CLAUDE.md` exists and contains `## Orchestrator Behavior` → stop. Tell the user this project is already initialized. Suggest `/onboard-existing-project` to update an existing setup.
2. If `AgentOS-Setup.md` does **not** exist → go to Step 2.
3. If `AgentOS-Setup.md` exists but `agent-setup.yml` does **not** exist → go to Step 2b.
4. If both `AgentOS-Setup.md` and `agent-setup.yml` exist → go to Step 3.

---

## Step 2: Drop Setup Files

Write `AgentOS-Setup.md` to the project root (content below). Also write `agent-setup.yml` to the project root (content below). Then stop and tell the user:

> **Step 1 of 2 complete — setup files created.**
>
> Fill in your project details:
> - **`AgentOS-Setup.md`** — your project name, tech stack, and optional doc migration
> - **`agent-setup.yml`** — your model tier and provider (edit the values, comments explain the options)
>
> When you're done filling in both files, run `/install-agent-scaffold` again. Step 2 will generate: `CLAUDE.md`, agent definitions, `docs/context/` files, and `skills-manifest.json`.

`AgentOS-Setup.md` content:
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

---

## Tools / Connectors (optional)

List any MCP servers or external tools you use. Leave blank to add later.

> Entries here are written to `~/.claude/connectors.md` (global — shared across all your projects) and symlinked into this project at `docs/context/connectors.md`.
> If `~/.claude/connectors.md` already exists, it will not be overwritten — add new entries to it manually after setup.

| Name | Type | Command | Purpose | Notes |
|------|------|---------|---------|-------|
|      |      |         |         |       |
```

`agent-setup.yml` content:
```yaml
# Agent OS — Install Configuration
# Fill in values below, then re-run /install-agent-scaffold

# model_tier: tier of model to use for this agent
# Options: fast | balanced | powerful
# fast = lightweight/mechanical tasks, balanced = default, powerful = reasoning-heavy tasks
model_tier: balanced

# provider: AI provider for this agent (optional — omit or leave blank for default Anthropic/Claude)
# Options: anthropic (default) | google | openai | other
# If "other", replace with your provider's identifier string
provider: anthropic
```

Stop here. Do not generate any other files.

---

## Step 2b: Missing agent-setup.yml (edge case)

Reached only when `AgentOS-Setup.md` exists but `agent-setup.yml` does not.

Write the following content to `agent-setup.yml` at the project root:

```yaml
# Agent OS — Install Configuration
# Fill in values below, then re-run /install-agent-scaffold

# model_tier: tier of model to use for this agent
# Options: fast | balanced | powerful
# fast = lightweight/mechanical tasks, balanced = default, powerful = reasoning-heavy tasks
model_tier: balanced

# provider: AI provider for this agent (optional — omit or leave blank for default Anthropic/Claude)
# Options: anthropic (default) | google | openai | other
# If "other", replace with your provider's identifier string
provider: anthropic
```

Then stop and tell the user:

> **`agent-setup.yml` created.** Confirm the `model_tier` and `provider` values look right, then re-run `/install-agent-scaffold`.

---

## Step 3: Parse AgentOS-Setup.md and agent-setup.yml

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

Read `agent-setup.yml`. Extract provider and tier as follows.

**`model_tier`** — read the `model_tier:` value (trim whitespace, strip inline comments).
- Valid values: `fast`, `balanced`, `powerful`.
- If missing or not one of the three valid values → stop and tell the user: "Fill in `agent-setup.yml`: `model_tier` must be `fast`, `balanced`, or `powerful`."

**`provider`** — read the `provider:` value (trim whitespace, strip inline comments).
- If the field is absent, blank, or the value is `anthropic` → treat as default; set `PROVIDER` = `anthropic`.
- Any other non-empty value → set `PROVIDER` = that value.

**Map `model_tier` to agent frontmatter alias:**
- `fast` → `haiku`
- `balanced` → `sonnet`
- `powerful` → `opus`

Store the resolved alias as `MODEL_ALIAS`.

If all required values are present → proceed to Step 4.

---

## Step 4: Generate Files

Create all files below. For each file that already exists, show the diff and ask: merge, replace, or skip.

> **Note:** `task.md` is NOT created during scaffold. It is created by the orchestrator at session start when ephemeral mode is detected. Scaffold creates `product.md` for new project initialization only.

---

### Model and provider guidance (read before generating any agent)

Every generated agent file uses the `MODEL_ALIAS` resolved in Step 3. Emit `model: <MODEL_ALIAS>` in all agent frontmatter.

Only emit `provider: <PROVIDER>` when `PROVIDER` is not `anthropic`. Omit the `provider:` field entirely for the default Anthropic setup — this keeps existing installs clean.

Examples:
- `model_tier: balanced` + `provider: anthropic` → emit `model: sonnet` only (no `provider:` line)
- `model_tier: powerful` + `provider: google` → emit `model: opus` and `provider: google`

Default tier-to-role mapping (override with `MODEL_ALIAS` from `agent-setup.yml`):

| Role | Default Tier |
|---|---|
| Technical Architect | `opus` — heavy reasoning, plan synthesis |
| Orchestrator / Specialist / QA | `sonnet` — standard execution |
| Lightweight / fast tasks | `haiku` — quick lookups, reformatting |

When `agent-setup.yml` specifies a tier, use `MODEL_ALIAS` for all generated agents (overrides the default role-based tiers above).

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

### 4c. `.claude/agents/` — Global prerequisite check

Before writing any other project files, verify that the global Agent OS layer is installed:

1. Check whether `~/.claude/agents/` exists and contains at least one `.md` file.
2. **If absent or empty:** stop immediately and surface:
   > "Global Agent OS layer not found at `~/.claude/agents/`. Run `/update-agent-os` to install the canonical agent set before scaffolding a project."
   Do not proceed to 4d or any subsequent step.
3. **If present:** continue to 4d. No agent files are copied to `.claude/agents/` — canonical agents live in `~/.claude/agents/` and are available globally.

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

**Settings.json tiers (canonical vs project-specific).** The `.claude/settings.json` this step writes contains two tiers of fields:

- **Canonical tier** — part of the distributed Agent OS system, identical across installs: `worktree.baseRef` and the standard `Stop` hook (both written above). `operatingMode`, when present, is canonical but is managed by `/streamline-approvals`, not by this scaffold.
- **Project-specific tier** — owned by the user, never overwritten by any Agent OS skill: `permissions` (allow/deny lists), user-added custom hooks, and any `mcpServers` entries.

This scaffold supplies the canonical tier once, at install. `/update-agent-os` patches a **canonical** field into an existing `.claude/settings.json` only when that field is **absent** (e.g. `worktree.baseRef` or the standard `Stop` hook is missing) — it never overwrites a canonical field that is already present, and it never touches a project-specific field. The project-specific tier is always the user's to own.

---

### 4h. `.gitignore` additions

Append to `.gitignore` if not already present:
```
.worktrees/
.claude/settings.local.json
```

---

### 4i. `~/.claude/connectors.md`

Check whether the connectors table in `AgentOS-Setup.md` has any filled rows (rows where the `Name` cell is not blank):

- **If rows are filled:** create `~/.claude/connectors.md` with the following structure, using the entries from the filled table rows. Set `Status` to `active` for each entry. Only write this file if it does not already exist — if `~/.claude/connectors.md` already exists, skip silently and log: `~/.claude/connectors.md already exists — skipped.`

  ```markdown
  # Connectors

  ## [name from table]
  - **Type:** [type]
  - **Command:** [command from table, or blank]
  - **Purpose:** [purpose]
  - **Status:** active
  - **Notes:** [notes or blank]
  ```

- **If table is empty or all rows blank:** skip silently. Do not create the file.

---

### 4i-b. Connectors symlink

After writing (or skipping) `~/.claude/connectors.md`:

1. Create a symlink for in-project access:
   ```bash
   ln -sf ~/.claude/connectors.md docs/context/connectors.md
   ```
   If `docs/context/connectors.md` already exists as a symlink, skip silently.
2. Append to `.gitignore` if not already present:
   ```
   docs/context/connectors.md
   ```

---

### 4j. Delete setup files

After all files are created successfully, delete both `AgentOS-Setup.md` and `agent-setup.yml`.

---

## Coupled-file contract

`install-agent-scaffold` (install path) and `update-agent-os` (update path) govern the same distributed system from two directions. They are a **coupled pair**:

- Any change that adds, removes, or renames a **canonical** field in the `.claude/settings.json` template (section 4g above), or adds/removes a scaffold-generated canonical file, MUST be reflected in `update-agent-os/SKILL.md` so the install and update paths stay in sync — and vice versa.
- **QA directive:** when either `install-agent-scaffold/SKILL.md` or `update-agent-os/SKILL.md` is in a track's scope, the reviewer must open the coupled file and confirm it needs no matching change. Changing one without a recorded decision on the other is a review failure.

---

## Step 5: Verify Installation

Run inline verification before declaring success:

1. Confirm `CLAUDE.md` exists and contains `## Orchestrator Behavior`.
2. Confirm `claude/skills/orchestrator/SKILL.md` exists and is non-empty.
3. Confirm `~/.claude/agents/` exists and contains at least one `.md` file.
4. Confirm `skills-manifest.json` exists at the project root.

If any check fails, surface the specific failure before proceeding. Do not print the Step 6 confirmation until all four checks pass.

---

## Step 6: Confirm

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
