---
name: open-sprint
description: Opens a new sprint with a clean setup — surfaces unresolved prior work, sets the sprint objective, creates the first track entry, and orients the team.
---
# Sprint Open
Opens a new sprint with a clean setup — surfaces unresolved prior work, sets the sprint objective, creates the first track entry, and orients the team. The counterpart to `clean-context`.

## Auto-Trigger
This skill should be invoked automatically when the user says phrases like:
- "start planning", "new sprint", "let's plan", "begin planning"
- "what are we working on next", "ready to start"
- Any message that signals intent to begin a new planning cycle

---

## Protocol

### Step 1 — Prior Sprint Check
Read `docs/context/tracks.md` and `docs/context/plan.md`.

If any tracks are marked **in progress** or **blocked**, surface them:
> *"There are [N] unresolved tracks: [list]. Carry them forward, close them, or archive them before opening the new sprint?"*

Wait for confirmation before continuing.

### Step 2 — Context Archival (Optional)
Ask once:
> *"Archive completed tracks before opening the new sprint? (Recommended — keeps context lean)"*

If yes: run `/clean-context`. If no: proceed.

### Step 3 — Sprint Interview
Ask as a single message. Wait for all answers.

> 1. **Sprint objective** — What is the primary goal? (1-2 sentences)
> 2. **First task** — What is the first specific track to execute?
> 3. **Owner** — Which specialist handles the first task? (or "TBD")

### Step 4 — Update Context Files

**`docs/context/plan.md`:**
```markdown
## Current Sprint: [Sprint Objective]

### Sprint Goals:
- [ ] [First task] — [Owner] — Track [N]

---
*Last updated: [DATE]*
```

**`docs/context/tracks.md`** — add new track:
```markdown
## Track [N]: [First Task Name]
- **Owner:** [Specialist]
- **Status:** Ready for Handoff Bridge
- **Sprint:** [Sprint Objective]
- **Opened:** [DATE]
```

**Confirm `AGENTIC.md`** is current — read and flag any stale fields. Do not modify without explicit direction.

### Step 5 — Sprint Summary

```
## Sprint [N] Open

**Objective:** [Sprint objective]
**First Track:** Track [N] — [Task] → [Owner]
**Team:** [From AGENTIC.md]
**Context:** [Clean / N archived / N flags]

Ready. Call @[architect-name] with the first Handoff Bridge when set.
```
