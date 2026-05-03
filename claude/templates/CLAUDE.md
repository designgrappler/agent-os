# [PROJECT NAME] — Claude Code Configuration
*Fill in all [PLACEHOLDERS] before using. Delete this line when done.*

## Team Architecture

| Role | Agent | Scope |
|---|---|---|
| **[CONDUCTOR NAME]** | Conductor | Vision & Approval |
| **Claude** | Orchestrator | Coordinates specialists, no direct execution |
| **[ARCHITECT NAME]** | Lead Architect | Plans, Red Flag Analysis, Handoff Bridges — zero code |
| **[SPECIALIST 1 NAME]** | [Domain 1] Specialist | `[file scope — e.g., src/components/]` |
| **[SPECIALIST 2 NAME]** | [Domain 2] Specialist | `[file scope — e.g., api/, server.ts]` |
| **[SPECIALIST 3 NAME]** | [Domain 3] Specialist | `[file scope — e.g., supabase/migrations/]` |
| **[CRITIC NAME]** | QA Critic | Read-only quality gate — no code writes |

Agents are defined in `.claude/agents/`. Invoke via `@[architect-name]`, `@[critic-name]`, etc.

---

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA (tech stack, protocols, hard constraints)
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status

---

## Execution Protocol

**No execution without a Handoff Bridge.**

All work must flow through:
```
[CONDUCTOR NAME] (approval) → [ARCHITECT NAME] (plan + Handoff Bridge) → Specialist (execute) → [CRITIC NAME] (QA gate)
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
| **PreToolUse(Bash)** | `git push` | Blocks if `[BUILD COMMAND]` fails |

---

## Tech Stack (from AGENTIC.md — non-negotiable)

[Copy your tech stack summary from AGENTIC.md here for quick reference.]

---

## Stability Rules

- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP. Call [ARCHITECT NAME] for Red Flag Analysis. Any destructive or irreversible failure triggers an immediate stop.
- **Git Hygiene:** No commits unless [CONDUCTOR NAME] directs.
- **Sentinel Proof:** Never trust a verbal summary. Verify with `git diff` or file reads.

---

## Auto-Invocations

Invoke the following skills automatically when the user's message matches these patterns — do not wait to be asked explicitly:

| User says... | Invoke |
|---|---|
| "start planning", "new sprint", "let's plan", "begin planning", "what are we working on next" | `/sprint-open` |
| "catch me up", "what's the status", "where are we", "status check", "quick update" | `/track-status` |
