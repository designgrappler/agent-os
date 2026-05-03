---
name: conductor-bundle
description: The "OS Setup Wizard" that deploys the core Conductor OS hierarchy in a single pass.
Abbreviation: Cb
Category: Bundles
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write]
---

# Skill: Conductor Bundle

## Description
The "OS Setup Wizard" of the Agent OS. Deploys the full hierarchy (DNA, Team, Handoff) in a single pass. Runs a complete pre-flight interview before creating any files — all answers are gathered first, then execution proceeds without interruption.

> **Existing project?** Stop. Use `project-adopt` first. This skill assumes a blank slate and will treat existing files as conflicts.

## Operational Rules
- **🛡️ MIDDLEWARE ISOLATION (MANDATORY)**: You are the **Architect** (Tier 1/2 Meta-Controller). Your direct code modification tools are **STRUCTURALLY BLOCKED** by the global policy. You are strictly forbidden from creating tactical 'Implementation Plans' for `/src` or `/lib`. If a task requires code, you MUST launch a Specialist.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header:
    > **[Name] ([Role])**

## Pre-Flight Interview (MANDATORY — Complete Before Any File Creation)

**Do not call any other skills or create any files until ALL of the following questions are answered.** Ask them as a single, numbered list in one message. Wait for all answers before proceeding.

> Before I set up your project, I need a few details. Please answer all of the following:
>
> 1. **Project name** — What is this project called?
> 2. **One-sentence description** — What does it do?
> 3. **Tech stack / Toolset** — Primary technologies or tools (e.g., "React + Node.js + PostgreSQL" or "Figma + Notion + Webflow")
> 4. **Team type** — Is this a **dev team** (building software), a **creative/business team** (producing docs, designs, campaigns), or a **mixed team**? This determines how scope and deliverables are defined.
> 5. **Conductor name** — What is your name? (You are the human Owner/Conductor.)
> 6. **Architect name** — What should the Lead Architect agent be called? (e.g., "Peaches", "Atlas")
> 7. **Implementation Team** — How many specialist roles do you need, and what are their names and domains? (e.g., "3 roles: Max for frontend, Rusty for backend, Lucy for database" or "2 roles: Sara for product, Jamie for design")
> 8. **Critic name** — What should the Quality Gate agent be called? (e.g., "Bandit", "Sentinel")
> 9. **Workflow mode** — Are you using an external model (like Claude) for the Implementation Team? Answer `RELAY` if yes, `GEMINI_ONLY` if no.

Once all 9 answers are received, proceed to the Execution Sequence below without further interruption.

## Execution Sequence (Run After Interview Is Complete)

1. **Foundational Check**: Verify `.agent/context/AGENTIC.md` does not already exist to avoid overwriting an existing project.
2. **DNA Initialization**: Call `conductor-setup` — pass all project details from the interview. Do not re-ask questions that have already been answered.
3. **Team Roster**: Call `team-setup` — pass all personnel names, role assignments, and team type from the interview. Do not re-ask.
4. **Handoff Protocol**: Call `handoff-optimizer` — register the structural enforcement protocol and Handoff Gate using the confirmed WORKFLOW_MODE.
5. **Quality Gate Registration**: Add the Quality Gate agent ([critic name]) to the org chart in `AGENTIC.md` with read-only Sentinel scope.
6. **Welcome Kit**: Generate a summary table confirming the full setup. Sign off: *"Conductor OS is live, synchronized, and project-ready. What would you like to do next?"*

## Verification
1. **Interview Gate**: Confirm the agent asked ALL 8 questions in a single message before creating any files.
2. **No Mid-Execution Questions**: Confirm the agent did NOT stop to ask additional questions after the interview was complete.
3. **Personnel Match**: Confirm the roster in `AGENTIC.md` matches the names provided in the interview exactly — no placeholders.
4. **WORKFLOW_MODE Lock**: Confirm `AGENTIC.md` contains the selected WORKFLOW_MODE.

## Stats
- **Overhead**: ~1000 Tokens (Setup Phase)
- **Operational Level**: Level 1 (Meta-Orchestration)
- **Benefit**: Ensures a perfectly configured multi-agent environment in a single pass, with zero mid-setup interruptions.

## Trigger
Tell Architect: "Deploy the Conductor OS bundle."
