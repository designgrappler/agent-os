---
name: team-setup
description: The "Process Scheduler" that establishes the multi-agent architecture and maps personnel to roles.
Abbreviation: Ts
Category: Orchestration
Type: Tier 2
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write]
---

# Skill: Team Setup

## Description
The "Process Scheduler" of the Agent OS. Maps personnel names to specialist roles and updates the org chart in `AGENTIC.md`. When called from `conductor-bundle`, all personnel details are pre-supplied — skip to DNA Mapping. When run standalone, run the interview below first.

## Operational Rules
- **🛡️ MIDDLEWARE ISOLATION (MANDATORY)**: You are the **Architect** (Tier 2 Strategic Planner). Your direct code modification tools are **STRUCTURALLY BLOCKED** by the global policy. You are strictly forbidden from creating tactical 'Implementation Plans' for `/src` or `/lib`. If a task requires code, you MUST launch a Specialist.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header:
    > **[Name] ([Role])**

## Standalone Interview (Skip if Called from Conductor Bundle)

If personnel details were NOT pre-supplied, ask the following as a single numbered list. **Wait for all answers before updating any files.**

> To build your Implementation Team, please answer all of the following:
>
> 1. **Conductor name** — Your name as the human Owner/Conductor.
> 2. **Architect name** — The Lead Architect agent's name.
> 3. **Team type** — Is this a **dev team**, a **creative/business team**, or a **mixed team**?
> 4. **Specialist roles** — How many specialist roles do you need, and what are their names and domains? (e.g., "3 roles: Max for frontend, Rusty for backend, Lucy for database" or "2 roles: Sara for product, Jamie for design")
> 5. **Dependency order** — In what order should specialists hand off to each other? (e.g., "Database first, then backend, then frontend" or "PM first, then design, then content")
> 6. **Quality Gate name** — The Sentinel/Critic agent's name.

**Capability Discovery (Optional):** If a `.agent/skills/` or `skills/` directory exists locally, list available specialist skills to help the user match roles to skills. If the directory does not exist or the `ls` fails, skip this step — proceed with the user's stated domains using `generic-specialist` as the base.

## DNA Mapping (Run After Interview or Once Details Are Supplied)

Using the confirmed personnel details, update `.agent/context/AGENTIC.md` with the formal Org Chart and dependency chain:

```markdown
## Org Chart

| Role | Name | Domain | Scope |
|---|---|---|---|
| **Conductor** | [conductor name] | — | Vision & Approval |
| **Architect** | [architect name] | — | Planning, Handoff Bridges — zero deliverable production |
| **[Domain 1] Specialist** | [specialist 1 name] | [domain 1] | [deliverable scope] |
| **[Domain 2] Specialist** | [specialist 2 name] | [domain 2] | [deliverable scope] |
| **Quality Gate** | [quality gate name] | — | Sentinel review — read-only |

## Execution Chain
[Specialist 1 name] → [Specialist 2 name] → [Specialist 3 name]
Each specialist must perform a Technical Handshake before starting: verify the upstream deliverable exists and is complete.

## Deliverable Scope by Team Type
- **Dev roles**: source files, configs, migrations — scoped by directory
- **Non-dev roles**: documents, briefs, design specs, copy, reports — scoped by document path or folder
- **Quality Gate**: reads all deliverable types; issues PASS or BLOCKED
```

Also update `.agent/rules/team.md` with:
- Full personnel roster
- Sign-off standard: every agent signs with their assigned name, not their role title
- Confirmed dependency order
- The term **"Implementation Team"** for the collective Tier 3 specialists

## Verification
1. **No Placeholders**: Confirm every name in the Org Chart is a real value — not "Specialist 1" or "[Name]".
2. **Registry Check**: Confirm `.agent/context/AGENTIC.md` contains a complete Org Chart with all roles filled.
3. **Interview Gate** (standalone only): Confirm all questions were asked in a single message before any files were updated.
4. **Discovery Fallback**: Confirm that if the `ls` of the skills directory failed, the skill did not error out — it continued with the user's stated domains.

## Stats
- **Overhead**: Low
- **Operational Level**: Level 2 (Strategic Planning)
- **Benefit**: Eliminates "Jack-of-all-trades" drift and hallucinatory role-swapping.

## Trigger
Tell Architect: "Set up our Implementation Team."
