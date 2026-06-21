# [PROJECT NAME] — Claude Code Configuration

## Team Architecture

The Orchestrator coordinates specialists and writes no code. It does not plan.

> **Orchestrator constraint:** the Orchestrator never drafts plans, track specs, or planning artifacts. Planning belongs exclusively to the Architect. See AGENTIC.md §3 Orchestrator Constraints.

> **Orchestrator no-execution constraint:** the Orchestrator never edits execution files (`AGENTIC.md`, `CLAUDE.md`, `claude/**`, `.claude/agents/**`, `.claude/skills/**`, `docs/tasks.json`, `docs/context/**`) — even when a Specialist is blocked. The only two valid moves are (1) surface to Conductor, (2) call Architect for unblock plan. See AGENTIC.md §3 Orchestrator Constraints.

---

## Operating Mode

Current: MANUAL (autonomous loop inactive — Tim triggers each handoff)

To change: `/switch-workflow-mode autonomous` or `/switch-workflow-mode manual` (sprint boundary only — see feasibility gate).

---

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA (tech stack, team, protocols, hard constraints)
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status
4. **Operating mode mismatch check:** Compare the `operatingMode` field in `.claude/settings.json` against the `## Operating Mode` section in this file. If they differ, surface this warning at the top of the session: `Operating mode mismatch detected: settings.json says <X>, CLAUDE.md says <Y>. Run /switch-workflow-mode to reconcile.` Session continues; the warning persists until reconciled.

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

**Commit-before-dispatch (binding):** Conductor commits staged changes on `main` before dispatching. Uncommitted work does not reach Specialist worktrees. Canonical rule: AGENTIC.md §5.

**`.claude/` exception (binding):** `.claude/settings.json` and `.claude/hooks/**` are not worktree-isolated; edit on `main` (absolute path). Canonical rule: AGENTIC.md §5; Bridge template guidance: AGENTIC.md §8.

**Pre-staging hygiene (binding):** Run `git status` before `git add`; commit or stash unrelated dirty files first. Canonical rule: AGENTIC.md §5.

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

## Language Protocol

Plans, Handoff Bridges, and protocol documentation must use **system role terms** — not agent names.

| Use this | Not this |
|---|---|
| Architect | [project-specific Architect name] (or any project-specific name) |
| Specialist | [project-specific Specialist name] (or any project-specific name) |
| QA | [project-specific QA name] (or any project-specific name) |
| Conductor | [project-specific Conductor name] (or any individual's name) |

Agent names are project-specific and fungible. Role terms are stable across every Agent OS installation. File paths referencing `.claude/agents/<name>.md` are fine — those are paths, not role references.

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
