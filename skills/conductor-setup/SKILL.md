---
name: conductor-setup
description: The "Master Controller" that establishes project orchestration, persona identity, and baseline DNA.
Abbreviation: Cs
Category: Orchestration
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write, net_fetch]
---

# Skill: Conductor Setup

## Description
The "Master Controller" of the Agent OS. Establishes Static DNA, Dynamic DNA, and WORKFLOW_MODE. When run via `conductor-bundle`, all project details are pre-supplied — skip to File Creation. When run standalone, run the interview below first.

## Operational Rules
- **🛡️ MIDDLEWARE ISOLATION (MANDATORY)**: You are the **Architect** (Tier 1/2 Meta-Controller). Your direct code modification tools are **STRUCTURALLY BLOCKED** by the global policy. You are strictly forbidden from creating tactical 'Implementation Plans' for `/src` or `/lib`. If a task requires code or content production, you MUST launch a Specialist.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header:
    > **[Name] ([Role])**

## Standalone Interview (Skip if Called from Conductor Bundle)

If project details were NOT pre-supplied, ask the following as a single numbered list. **Wait for all answers before creating any files.**

> To initialize your project, please answer all of the following:
>
> 1. **Project name** — What is this project called?
> 2. **One-sentence description** — What does it do?
> 3. **Tech stack / Toolset** — Primary technologies or tools (e.g., "React + Node.js + PostgreSQL" or "Figma + Notion + Webflow")
> 4. **Team type** — Is this a **dev team** (building software), a **creative/business team** (producing docs, designs, campaigns), or a **mixed team**?
> 5. **Conductor name** — Your name as the human Owner/Conductor.
> 6. **Architect name** — What should the Lead Architect agent be called?
> 7. **Workflow mode** — Are you using an external model (like Claude) for implementation? Answer `RELAY` if yes, `GEMINI_ONLY` if no.

## File Creation (Run After Interview or Once Details Are Supplied)

Create the following files. No placeholders — all values must be real answers.

### 1. `.agent/context/AGENTIC.md` (Static DNA)

```markdown
# Static DNA: [PROJECT NAME]

## Project Identity
- **Project Name**: [project name]
- **Description**: [one-sentence description]
- **Team Type**: [DEV / CREATIVE / MIXED]
- **Owner/Conductor**: [conductor name]
- **Architect**: [architect name]
- **WORKFLOW_MODE**: [RELAY or GEMINI_ONLY]

## Toolset
[tech stack or toolset details]

## Org Chart
[To be populated by team-setup]

## Conductor Protocols

### Stability Rules
- **Circuit Breaker**: 3 consecutive failures with the **same root cause** → STOP and escalate to [conductor name]. Different error types reset the counter. Any single destructive or irreversible failure triggers an immediate stop.
- **Sentinel Proof**: Never trust a verbal summary. Verify with file reads, diff inspection, or direct artifact review.
- **Scope Lock**: Specialists may only modify deliverables declared in the Handoff Bridge. Any undeclared change = escalate.
- **Zero-Code Rule**: The Architect is structurally blocked from producing application code or final creative deliverables. Planning and bridging only.

### Execution Chain
Work flows in dependency order based on team type:
- **Dev teams**: Database → Backend → Frontend
- **Creative/Business teams**: Strategy/PM → Design/Content → Review
- **Mixed teams**: Define dependency order in team-setup.
Downstream specialists must perform a Technical Handshake to verify upstream deliverables before starting work.

### Definition of Done
A task is complete only when ALL of the following are true:
- [ ] All declared deliverables are produced or modified
- [ ] No undeclared files or documents were touched
- [ ] Quality Gate has issued a **PASS** verdict
- [ ] tracks.md is updated to reflect the completed task
- [ ] [conductor name] has approved (for tasks touching critical systems, payments, or public-facing content)

## Handoff Bridge Template

\`\`\`markdown
### HANDOFF BRIDGE
**Topic:** [Task/Feature Name]
**Track:** [ID from tracks.md]
**DNA Check:** [Confirm alignment with AGENTIC.md]
**Context:**
- Intent: [1-sentence requirement]
- Execution Deliverables: [list of files/documents to produce or modify]
- Upstream Verified: [confirm upstream deliverable was reviewed — Technical Handshake complete]
**Acceptance Criteria:** [how to confirm the work is complete]
**Circuit Breaker:** 3 consecutive same-cause failures → escalate to [architect name]
**Next Step:** [specific first action for the Specialist]
\`\`\`
```

### 2. `.agent/context/tracks.md` (Dynamic DNA)

```markdown
# Active Tracks

**Session 1**: Project initialization — Conductor OS deployed.

---
*Managed by [architect name]. Updated every session.*
```

### 3. `.agent/rules/handoff-protocol.md`
Generate the standard handoff protocol document referencing the confirmed WORKFLOW_MODE and team type.

## Verification
1. **WORKFLOW_MODE Lock**: Confirm `AGENTIC.md` contains `WORKFLOW_MODE` — not `UNDEFINED`.
2. **No Placeholders**: Confirm every field contains a real value from the interview.
3. **Protocols Present**: Confirm Circuit Breaker, Sentinel Proof, Scope Lock, and Handoff Bridge Template are all in `AGENTIC.md`.
4. **Team Type Set**: Confirm `AGENTIC.md` contains the team type and an appropriate execution chain.
5. **Zero-Code Check**: Confirm no application source files or final deliverables were created.

## Stats
- **Overhead**: ~200 Tokens
- **Operational Level**: Level 1 (Meta-Orchestration)
- **Benefit**: Ensures every project launches with complete protocols from turn one.

## Trigger
Tell Architect: "Initialize project with Conductor orchestration."
