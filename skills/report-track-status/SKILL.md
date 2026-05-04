---
name: report-track-status
description: The "Situation Report" that produces a quick, scannable summary of all active tracks — what's in progress, blocked, awaiting review, or needs approval. Ideal after a break or at session start.
Abbreviation: Ts2
Category: Maintenance
Type: Tier 2
Bundle: ARCHITECT
Capabilities: [fs_read]
---

# Skill: Report Track Status

## Description
The "Situation Report" of the Agent OS. Reads the current project state and produces a structured, scannable summary in seconds. No modifications — read-only. Designed for returning after a break, starting a new session, or quickly orienting before a handoff.

**Auto-trigger:** This skill should be invoked automatically when the user says phrases like "catch me up," "what's the status," "where are we," "what's in progress," "quick update," "status check," or returns to a session after a gap.

## Operational Rules
- **Read-Only**: This skill reads files only. It makes no modifications to any context, plan, or track file.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header:
    > **[Name] ([Role])**
- **Brevity Rule**: The report must be scannable in under 30 seconds. Use structured lists, not prose paragraphs.

## Status Report Protocol

### Step 1 — Read State
Read the following files in order:
1. `.agent/context/AGENTIC.md` — team roster and protocols
2. `.agent/context/plan.md` — current sprint objective
3. `.agent/context/tracks.md` — all active tracks and their status

### Step 2 — Produce Report

Output the following structure. Keep each item to one line.

```
## Project Status Report
**Project:** [project name]
**Sprint:** [current sprint objective from plan.md]
**Generated:** [current date/time]

---

### Active Tracks

| Track | Task | Owner | Status | Blocker |
|---|---|---|---|---|
| [N] | [task name] | [owner] | 🟡 In Progress | — |
| [N] | [task name] | [owner] | 🔴 Blocked | [blocker summary] |
| [N] | [task name] | [owner] | 🔵 Awaiting Quality Gate | — |
| [N] | [task name] | [owner] | 🟠 Awaiting Approval | [who must approve] |
| [N] | [task name] | [owner] | ✅ Done | — |

---

### What's Next
[1-2 sentences on the most logical next action — e.g., "Track 5 is ready for a Handoff Bridge. Track 3 needs Conductor approval before proceeding."]

### Flags
[Any stale tracks, missing owners, or context hygiene issues worth noting. "None" if clean.]
```

**Status key:**
- 🟡 In Progress — specialist is actively working
- 🔴 Blocked — waiting on a dependency or decision
- 🔵 Awaiting Quality Gate — specialist signed off, needs Critic review
- 🟠 Awaiting Approval — Conductor sign-off required
- ✅ Done — Quality Gate passed, Conductor approved

### Step 3 — Suggest Next Action

After the table, always end with a single concrete suggestion:
> *"Recommended next step: [specific action — e.g., 'Run optimize-handoff for Track 6' or 'Resolve the blocker on Track 3 before proceeding']."*

## Verification
1. **Read-Only**: Confirm no files were modified during the report.
2. **All Tracks Covered**: Confirm every track in `tracks.md` appears in the table.
3. **Concrete Next Step**: Confirm the report ends with a specific recommended action.

## Stats
- **Overhead**: Minimal
- **Operational Level**: Level 2 (Situational Awareness)
- **Benefit**: Eliminates the "lost on return" problem — full project orientation in one command.

## Trigger
Tell Architect: "Status check" — or any catch-up phrase (see Auto-trigger above).
