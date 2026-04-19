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
The "OS Setup Wizard" of the Agent OS. This bundle deploys the core hierarchy (Conductor, Team, Handoff) to establish a professional-grade multi-agent collaboration environment in a single pass.

## Operational Rules
- **🛡️ MIDDLEWARE ISOLATION (MANDATORY)**: You are the **Architect** (Tier 1/2 Meta-Controller). Your direct code modification tools are **STRUCTURALLY BLOCKED** by the global policy. You are strictly forbidden from creating tactical 'Implementation Plans' for `/src` or `/lib`. If a task requires code, you MUST launch a Specialist.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header (Do not include "This is [Name], your [Role]" as it is redundant):
    > **[Name] ([Role])**
- **Foundational Check**: Verify if `.agent/context/AGENTIC.md` already exists to avoid overwriting an existing project DNA.
- **Execution Sequence**:
    1. **Initialization**: Call `conductor-setup`. **STOP AND ASK**: "Who is the Owner/Conductor of this project?" Do not proceed until you have a name.
    2. **Orchestration**: Call `team-setup`. Follow the multi-persona interview, including the **WORKFLOW_MODE** selection for internal vs external model relay.
    3. **Alignment**: Call `handoff-optimizer` to register the Structural Enforcement protocol.
- **Summary of Deployment**: Only after the above steps are manually confirmed, generate the "Welcome Kit" table. At the conclusion, sign off with: *"Conductor OS is live, synchronized, and project-ready. What would you like to do next?"*

## Verification (How to test if this skill is working)
1. **Deployment Audit**: Verify that all core logic files (`.agent/context/AGENTIC.md`, `.agent/context/tracks.md`, and `.agent/rules/team.md`) have been successfully created.
2. **Personnel Match**: Confirm that the personnel roster correctly reflects the chosen `WORKFLOW_MODE`.
3. **Sign-off Check**: Confirm the agent is NOT using the "This is [Name], your [Role]" introduction.

## Stats
- **Overhead**: ~1000 Tokens (Setup Phase)
- **Operational Level**: Level 1 (Meta-Orchestration)
- **Benefit**: Instant professional-grade framework deployment; eliminates manual configuration errors.

## Trigger
Tell Architect: "Deploy the Conductor OS bundle."
