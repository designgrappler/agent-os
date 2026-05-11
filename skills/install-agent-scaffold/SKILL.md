---
name: install-agent-scaffold
description: Scaffold the full Agent OS structure for a new project. Drops a setup template the user fills in — no files are generated until the template is complete.
Abbreviation: Ias
Category: Orchestration
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write]
---

# Skill: Install Agent Scaffold

## Description
The project setup wizard for Agent OS. Drops a `SETUP.md` template for the user to fill in, then generates all required files in a single pass: `AGENTIC.md`, `CLAUDE.md` (or equivalent), agent definitions, `docs/context/` stubs, and hook configuration.

Uses a doc-fill pattern — no Q&A interview. The user fills in the template at their own pace, then triggers generation.

## Operational Rules

- **Zero-Code Identity**: Tier 1 Meta-Controller. Structurally forbidden from modifying production source code (`/src`, `/lib`). If a task requires code, yield to a Specialist.
- **Foundational Check**: Before writing any files, check whether `AGENTIC.md` exists. If it does, stop and direct the user to `onboard-existing-project`.
- **Two-Phase Execution**:
  1. **Phase 1 — Template drop**: If `SETUP.md` does not exist, write the setup template to `SETUP.md` and stop. Tell the user to fill it in and re-run.
  2. **Phase 2 — Validate and generate**: If `SETUP.md` exists, validate all required fields are filled, then generate all files in one uninterrupted pass.
- **Required fields** (validation must pass before any file is written):
  - `Name:` — project name
  - `Description:` — one-sentence description
  - `Owner:` — human conductor name
  - `Build command:` — shell command that verifies a clean build
  - `Tech stack:` — brief summary
  - At least one specialist role uncommented under `roles:`
- **Optional fields** (do not block generation; captured if provided):
  - `Brand color:` — hex value
  - `Primary font:` — typeface name
- **Extracted values**: derive `ARCHITECT` from `Architect name:` (default: `architect`), `CRITIC` from `Critic name:` (default: `critic`), `ROLES` from uncommented entries under `roles:`, `BRAND_COLOR` and `FONT` from optional fields (may be blank).
- **Generation sequence**: AGENTIC.md → CLAUDE.md (or tool-equivalent) → docs/context/ stubs → .claude/agents/ definitions (architect, critic, each selected specialist) → settings/hook config → `INSTALL_CHECKLIST.md` → .gitignore additions → delete SETUP.md.
- **INSTALL_CHECKLIST.md**: written to project root after all other files. Required section: verify build command works, review AGENTIC.md. Optional section: brand color, primary font, product focus, team conventions. Pre-check the scaffold item and any optional fields already provided in SETUP.md.
- **Agent definitions**: generate using the standard domain-specific template for each selected role. Dev specialists (fullstack, frontend, backend, database): `tools: Read, Write, Edit, Bash`. Non-dev specialists (designer, pm, marketing): `tools: Read, Write, Edit`. Architect: `model: claude-opus-4-7`, initialization reads 5 files (4 DNA files + INSTALL_CHECKLIST.md) and surfaces unchecked required items to the Conductor before proceeding. All others: `model: claude-sonnet-4-6`.
- **Sign-off**: After all files are written, output a summary listing every file created, the team roster with @mention names, and next steps. Confirm: "Agent OS is live. Call @[ARCHITECT] to open your first sprint."

## Setup Template (`SETUP.md`)

The template written in Phase 1:

```markdown
# Agent OS Setup
# Fill in the values below, then run install-agent-scaffold again.

## Project
Name:
Description:
Owner:

## Build
Build command:
Type-check command:

## Stack
Tech stack:

## Roles
# Keep the specialists you want, delete the rest.
# architect and critic are always included.
roles:
  - fullstack
  # - frontend
  # - backend
  # - database
  # - designer
  # - pm
  # - marketing

## Names (optional — leave blank to use role names)
Architect name:
Critic name:

## Optional
# These can be filled in later — they don't block generation.
Brand color:
Primary font:
```

## Verification
1. `AGENTIC.md` exists and contains `Tech Stack`, `Team Architecture`, and `Handoff Bridge Template` sections.
2. One agent definition file exists per selected role.
3. `docs/context/plan.md` and `docs/context/tracks.md` stubs were created.
4. `INSTALL_CHECKLIST.md` exists at project root with scaffold item pre-checked.
5. `SETUP.md` was deleted after generation.
6. No `.js`, `.ts`, `.css`, or source files were written.

## Trigger
"Install the agent scaffold for this project." or `install-agent-scaffold`
