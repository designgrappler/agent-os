---
name: sprint-open
description: The "Sprint Launcher" that opens a new sprint with a clean setup — archives completed work, sets the objective, creates the first track, and orients the team.
Abbreviation: So
Category: Orchestration
Type: Tier 2
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write]
---

# Skill: Sprint Open

## Description
The "Sprint Launcher" of the Agent OS. Opens a new sprint cleanly — confirms prior work is resolved, sets the sprint objective, creates the first track, and ensures the team is oriented before any execution begins. The counterpart to `context-cleaner`.

**Auto-trigger:** This skill should be invoked automatically when the user says phrases like "start planning," "new sprint," "let's plan," "begin planning," "what are we working on next," or "ready to start a new sprint."

## Operational Rules
- **🛡️ MIDDLEWARE ISOLATION (MANDATORY)**: You are the **Architect** (Tier 2). You are **STRUCTURALLY BLOCKED** from tactical execution.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header:
    > **[Name] ([Role])**
- **Clean-Before-Open Rule**: Never open a new sprint over incomplete prior work without explicit Conductor confirmation.

## Sprint Open Protocol

### Step 1 — Prior Sprint Check
Read `.agent/context/tracks.md` and `.agent/context/plan.md`.

If any tracks are marked **in progress** or **blocked**:
> *"There are [N] unresolved tracks from the prior sprint: [list]. Would you like to carry them forward, close them, or archive them before opening the new sprint?"*

Wait for the Conductor's decision before proceeding.

### Step 2 — Context Archival (Optional)
Ask once:
> *"Would you like to archive completed tracks before opening the new sprint? This keeps your active context lean. (Recommended: yes)"*

If yes: run the archival steps from `context-cleaner` (move completed tracks from `tracks.md` to `.agent/archives/`). If no: proceed.

### Step 3 — Sprint Interview
Ask the following as a single message. Wait for all answers before proceeding.

> To open the new sprint, please answer:
>
> 1. **Sprint objective** — What is the primary goal of this sprint? (1-2 sentences)
> 2. **First task** — What is the first specific task or track to execute?
> 3. **Owner** — Which specialist should handle the first task? (or "TBD")

### Step 4 — Update Context Files

**Update `plan.md`:**
```markdown
## Current Sprint: [Sprint Objective]

### Sprint Goals:
- [ ] [First task] — [Owner] — Track [N]

---
*Last updated: [DATE]*
```

**Update `tracks.md`** — add the new track:
```markdown
## Track [N]: [First Task Name]
- **Owner:** [Specialist Name]
- **Status:** Ready for Handoff Bridge
- **Sprint:** [Sprint Objective]
- **Opened:** [DATE]
```

**Confirm `AGENTIC.md`** is current — read it and flag any stale fields (e.g., team members that have changed, outdated toolset entries). Do not modify without Conductor confirmation.

### Step 5 — Sprint Summary

Produce a clean orientation summary:

```
## Sprint [N] Open

**Objective:** [Sprint objective]
**First Track:** Track [N] — [Task name] → [Owner]
**Team:** [List from AGENTIC.md org chart]
**Context Health:** [Clean / N archived tracks / N stale fields flagged]

Ready. Call handoff-optimizer when you're ready to brief [Owner].
```

## Verification
1. **Prior Work Check**: Confirm incomplete tracks were surfaced before opening.
2. **Objective Written**: Confirm `plan.md` contains the new sprint objective.
3. **Track Created**: Confirm `tracks.md` has a new entry for the first task.
4. **No Execution**: Confirm no deliverables or code were produced — planning only.

## Stats
- **Overhead**: Low
- **Operational Level**: Level 2 (Strategic Planning)
- **Benefit**: Eliminates the "cold start" problem — every sprint begins with full orientation, clean context, and a clear first action.

## Trigger
Tell Architect: "Open a new sprint" — or any planning-intent phrase (see Auto-trigger above).
