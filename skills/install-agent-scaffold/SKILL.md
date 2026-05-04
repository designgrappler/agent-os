---
name: install-agent-scaffold
description: Scaffold the full multi-agent workflow for a new project — AGENTIC.md, agent definitions, docs/context/ files, and hooks — in a single guided pass.
Abbreviation: Ias
Category: Orchestration
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write, net_fetch]
---

# Skill: Install Agent Scaffold

## Description
The project setup wizard for the Agent OS. Deploys the full multi-agent hierarchy — Static DNA (AGENTIC.md), Dynamic DNA (tracks.md, plan.md), agent role definitions, and hook configuration — in a single guided pass.

Consolidates the functionality of the former `conductor-bundle` and `conductor-setup` skills.

## Operational Rules
- **Zero-Code Identity**: You are a Tier 1 Meta-Controller. You are structurally forbidden from modifying production source code (`/src`, `/lib`) or creating implementation plans targeting those directories. If a task requires code, yield to a Specialist.
- **Foundational Check**: Before writing any files, verify whether `AGENTIC.md` already exists. If it does, stop and ask the user whether to overwrite or update.
- **Gather Before Writing**: Collect all project details across three question batches before writing a single file. Do not write files mid-interview.
- **Execution Sequence**:
  1. Confirm current working directory (`pwd`). Store as `PROJECT_DIR`.
  2. Ask Batch A (4 questions): project name, owner name, backend stack, frontend stack.
  3. Ask Batch B (4 questions): primary brand color (hex or URL), primary font, type-check command, package manager + build command. If a URL is given for brand color, fetch the page and extract candidate hex values before asking the user to confirm.
  4. Ask Batch C (role selection): which specialist roles to include (Backend, Frontend, Database, Full-Stack, Mobile, DevOps, Security, Data Engineer).
  5. Ask Batch D/E: names for all selected roles (Lead Architect, QA Critic, each specialist).
  6. Write all files in one uninterrupted pass: AGENTIC.md, CLAUDE.md (or equivalent), agent definition files, docs/context/ stubs, docs/archive/ stubs, settings/hook config.
- **Sign-off**: After all files are written, output a summary table listing every file created and confirm: "Agent OS is live. What would you like to do next?"

## Verification
1. Confirm `AGENTIC.md` was created and contains `Tech_Stack` and `Team_Structure` sections.
2. Confirm one agent definition file exists per selected role.
3. Confirm `docs/context/plan.md` and `docs/context/tracks.md` stubs were created.
4. Confirm the agent did not write any `.js`, `.ts`, `.css`, or source files.

## Stats
- **Overhead**: ~1200 tokens (setup phase)
- **Operational Level**: Level 1 (Meta-Orchestration)
- **Benefit**: Single-pass, fully consistent project scaffold across Claude and Gemini.

## Trigger
Tell Architect: "Install the agent scaffold for this project."
