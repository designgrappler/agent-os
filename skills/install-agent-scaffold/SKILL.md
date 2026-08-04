---
name: install-agent-scaffold
description: Scaffold the full Agent OS structure for a new project. Drops a setup file the user fills in — no files are generated until it's complete.
Abbreviation: Ias
Category: Orchestration
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write]
---

# Skill: Install Agent Scaffold

## Description
The project setup wizard for Agent OS. Drops an `AgentOS-Setup.md` file for the user to fill in, then generates all required files in a single pass: `CLAUDE.md` (or equivalent), agent definitions, `docs/context/` stubs, `docs/backlog.md`, and hook configuration.

Uses a form-fill pattern — no Q&A interview. The user fills in the form at their own pace, then triggers generation.

## Operational Rules

- **Zero-Code Identity**: Tier 1 Meta-Controller. Structurally forbidden from modifying production source code (`/src`, `/lib`). If a task requires code, yield to a Specialist.
- **Foundational Check**: Before writing any files, check whether `CLAUDE.md` already contains Agent OS content (e.g. `## Team`, `## Orchestrator Behavior` sections). If it does, stop and direct the user to `onboard-existing-project`.
- **Two-Phase Execution**:
  1. **Phase 1 — Form drop**: If `AgentOS-Setup.md` does not exist, write the setup form and stop. Tell the user to fill it in and re-run.
  2. **Phase 2 — Validate and generate**: If `AgentOS-Setup.md` exists, validate all required fields are filled, then generate all files in one uninterrupted pass.
- **Required fields** (validation must pass before any file is written):
  - `**Project name:**` — not blank
  - `**Short description:**` — not blank
  - Conductor row in team table — `[YOUR NAME]` replaced with actual name
  - Architect row in team table — `[ARCHITECT NAME]` replaced with actual name
  - QA row in team table — `[QA NAME]` replaced with actual name
  - `**Build command:**` — not blank
- **Extracted values**:
  - `NAME` = value of `**Project name:**`
  - `DESCRIPTION` = value of `**Short description:**`
  - `OWNER` = Agent Name from Conductor row (strip `**`)
  - `ORCHESTRATOR` = Agent Name from Orchestrator row (strip `**`)
  - `ARCHITECT` = Agent Name from Lead Architect row (strip `**`)
  - `QA` = Agent Name from QA row (strip `**`)
  - `SPECIALISTS` = all remaining rows (not Conductor, not Orchestrator, not Lead Architect, not QA) — each with name, domain (Role column minus " Specialist"), and scope (Scope column)
  - For each tech stack field (`**Runtime:**`, `**Framework:**`, etc.): take value between `:` and `<!--`, trim whitespace; if blank use the default shown in the comment
  - `MIGRATIONS` = rows in doc migration table where Current file is not a placeholder
- **Generation sequence**: `CLAUDE.md` (or tool-equivalent) → `docs/context/` stubs → `docs/backlog.md` stub → agent definitions (architect, QA, each specialist) → settings/hook config → `INSTALL_CHECKLIST.md` → `.gitignore` additions → delete `AgentOS-Setup.md`.
- **`docs/backlog.md` stub content**: write exactly:
  ```markdown
  # [NAME] — Backlog

  **Owner:** Orchestrator
  **Usage:** Items are trimmed on promotion into a sprint or explicit drop. Each item has an ID (B<n>). When pulled into a sprint track, reference the ID in the track and remove the item from this file.

  ---

  ## Ideas

  ---

  ## Deferred
  ```
- **INSTALL_CHECKLIST.md**: written to project root after all other files. Required section: verify build command works, review CLAUDE.md. Optional section: product focus, team conventions. Pre-check the scaffold item.
- **Agent definitions**: generate using the standard domain-specific template for each selected role. Dev specialists (fullstack, frontend, backend, database): `tools: Read, Write, Edit, Bash`. Non-dev specialists (designer, pm, marketing): `tools: Read, Write, Edit`. Architect: `model: claude-opus-4-7`, initialization reads 5 files (4 DNA files + INSTALL_CHECKLIST.md) and surfaces unchecked required items to the Conductor before proceeding. All others: `model: claude-sonnet-4-6`.
- **Sign-off**: After all files are written, output a summary listing every file created, the team roster with @mention names, and next steps. Confirm: "Agent OS is live. Call @[ARCHITECT] to open your first sprint."

## Setup Form (`AgentOS-Setup.md`)

The form written in Phase 1:

```markdown
# Agent OS Setup

Fill in the fields below, then run `install-agent-scaffold` again.
This file will be deleted automatically when setup is complete.

---

## Project

**Project name:** 
**Short description:** 

---

## Set Up Your Team

Edit the table below to define which roles you need for your project. Specify an agent name, their role, and key responsibilities. Ask your primary agent if you have questions.

Agents can be invoked by typing their name via `@[architect-name]`, `@[qa-name]`, etc. Agent profiles are located in `.claude/agents/` and can be edited at any time.

| Agent Name | Role | Scope and Responsibilities |
|---|---|---|
| **[YOUR NAME]** | Conductor | Vision & Approval |
| **[YOUR AI]** | Orchestrator | Coordinates specialists, no direct execution | <!-- e.g., Claude, Gemini -->
| **[ARCHITECT NAME]** | Lead Architect | Plans, Red Flag Analysis, Handoff Bridges — zero code |
| **[SPECIALIST 1 NAME]** | Frontend Specialist | UI components, pages, and styling |
| **[SPECIALIST 2 NAME]** | Backend Specialist | API routes, server logic, and integrations |
| **[SPECIALIST 3 NAME]** | Database Specialist | Schema, migrations, and queries |
| **[QA NAME]** | QA | Read-only quality gate — no code writes |

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

## Verification
1. `CLAUDE.md` exists and contains `Tech Stack`, `Project Team`, and `Orchestrator Behavior` sections.
2. One agent definition file exists per team member (architect, QA, each specialist).
3. `docs/context/plan.md`, `docs/context/tracks.md`, and `docs/backlog.md` stubs were created.
4. `INSTALL_CHECKLIST.md` exists at project root with scaffold item pre-checked.
5. `AgentOS-Setup.md` was deleted after generation.
6. No `.js`, `.ts`, `.css`, or source files were written.

## Trigger
"Install Agent OS on this project: https://github.com/designgrappler/agent-os" or `install-agent-scaffold`
