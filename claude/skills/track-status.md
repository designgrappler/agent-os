# Track Status
Produces a quick, scannable summary of all active tracks — what's in progress, blocked, awaiting review, or needs approval. Read-only. Designed for returning after a break or orienting at session start.

## Auto-Trigger
This skill should be invoked automatically when the user says phrases like:
- "catch me up", "what's the status", "where are we", "status check"
- "what's in progress", "quick update", "what did we do"
- Any message that signals the user is returning after a gap or needs orientation

---

## Rules
- **Read-only**: No files are modified. This skill only reads.
- **Brevity**: The report must be scannable in under 30 seconds.

---

## Protocol

Read in order: `AGENTIC.md` → `docs/context/plan.md` → `docs/context/tracks.md`

Produce this structure:

```
## Project Status
**Sprint:** [current objective from plan.md]
**Date:** [today]

### Tracks

| Track | Task | Owner | Status |
|---|---|---|---|
| [N] | [task] | [owner] | 🟡 In Progress |
| [N] | [task] | [owner] | 🔴 Blocked — [reason] |
| [N] | [task] | [owner] | 🔵 Awaiting Quality Gate |
| [N] | [task] | [owner] | 🟠 Awaiting Approval |
| [N] | [task] | [owner] | ✅ Done |

### What's Next
[1 sentence — the most logical immediate action]

### Flags
[Any stale tracks, missing owners, or hygiene issues. "None" if clean.]
```

**Status key:**
- 🟡 In Progress
- 🔴 Blocked
- 🔵 Awaiting Quality Gate (Bandit)
- 🟠 Awaiting Conductor Approval
- ✅ Done

Always end with a single concrete recommended next step.
