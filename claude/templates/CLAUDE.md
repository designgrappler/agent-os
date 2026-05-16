# [PROJECT NAME] — Claude Code Configuration

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA (tech stack, team, protocols, hard constraints)
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status

---

## Execution Protocol

**No execution without a Handoff Bridge.**

All work must flow through:
```
Conductor (approval) → Architect (plan + Handoff Bridge) → Specialist (execute) → QA (quality gate)
```

A Handoff Bridge looks like:
```
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Static DNA Check:** [Confirmed alignment with AGENTIC.md]
**Dynamic DNA State:**
- Product Context: [1-sentence requirement]
- Current Plan: [step in plan.md]
- Execution Files: [files to modify]
**Worktree Setup:** [git worktree command or "N/A — single active track"]
**Verification:** [command or URL]
**Next Step:** [specific task for the Specialist]
```

---

## Worktree Protocol

Each track gets an isolated branch and worktree:
```bash
git worktree add .worktrees/track-N track/N-description
```

Worktrees live in `.worktrees/` (gitignored). Never work directly on the main branch for multi-track sprints.

---

## Hooks (Auto-Enforced)

| Hook | Trigger | Action |
|---|---|---|
| **Stop** | Session ends | Prints DNA hygiene reminder |
| **PreToolUse(Bash)** | `git push` | Blocks if build command fails (see AGENTIC.md §2) |

---

## Stability Rules

- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP. Call the Architect for Red Flag Analysis. Any destructive or irreversible failure triggers an immediate stop.
- **Git Hygiene:** No commits unless the Conductor directs.
- **Sentinel Proof:** Never trust a verbal summary. Verify with `git diff` or file reads.

---

## Auto-Invocations

Invoke the following skills automatically when the user's message matches these patterns — do not wait to be asked explicitly:

| User says... | Invoke |
|---|---|
| "start planning", "new sprint", "let's plan", "begin planning", "what are we working on next" | `/sprint-open` |
| "catch me up", "what's the status", "where are we", "status check", "quick update" | `/track-status` |
