# [PROJECT NAME] — Claude Code Configuration

## Team Architecture

The Orchestrator coordinates specialists and writes no code. It does not plan.

> **Orchestrator constraint:** the Orchestrator never drafts plans, track specs, or planning artifacts. Planning belongs exclusively to the Architect. See AGENTIC.md §3 Orchestrator Constraints.

---

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
**Worktree Setup:** Automatic — `isolation: worktree` in Specialist frontmatter + `worktree.baseRef: "head"` in `.claude/settings.json`. Verify both are present before Specialist begins. (`isolation: worktree` is a CWD setting — built-in file tools are governed by the permission system, not the worktree CWD; Bridge Execution Files scope is the protocol-layer compensating control.)
**Verification:** [command or URL]
**Next Step:** [specific task for the Specialist]
```

---

## Worktree Protocol

Worktree isolation is enforced via each Specialist's agent frontmatter (`isolation: worktree`) and `.claude/settings.json` (`worktree.baseRef: "head"`). No manual git commands needed — the Agent tool runtime manages lifecycle. CWD isolation only: relative paths are isolated, absolute paths are not.

---

## Hooks (Auto-Enforced)

| Hook | Trigger | Action |
|---|---|---|
| **Stop** | Session ends | Prints DNA hygiene reminder |
| **PreToolUse(Bash)** | `git push` | Blocks if build command fails (see AGENTIC.md §2) |
| **SessionStart** | Session starts | Prints memory-staleness reminder if newest memory entry is >14 days old |

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
| "report an issue", "file feedback", "this skill is broken", "report an Agent OS issue", "this Agent OS skill is broken" | `/submit-agent-os-feedback` |
