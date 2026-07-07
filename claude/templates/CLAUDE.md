# [PROJECT NAME] — Claude Code Configuration

## Team Architecture

The Orchestrator coordinates specialists and writes no code. It does not plan.

> **Sprint Coordinator constraint:** the Sprint Coordinator never drafts technical plans, track specs, or technical planning artifacts. Technical planning belongs exclusively to the Technical Architect. See AGENTIC.md §3 Sprint Coordinator Constraints.

> **Sprint Coordinator no-execution constraint:** the Sprint Coordinator never edits execution files (`AGENTIC.md`, `CLAUDE.md`, `claude/**`, `.claude/agents/**`, `.claude/skills/**`, `docs/tasks.json`, `docs/context/product.md`, `docs/context/io-contracts.md`, `docs/context/CONVENTIONS.md`, `docs/context/tasks-schema.md`, `docs/context/bridges/**`) — even when a Specialist is blocked. Note: `docs/context/tracks.md` and `docs/context/plan.md` are outside this blocked set (coordination-tier state, same treatment as `docs/backlog.md`); routine coordination updates to either are permitted. `docs/context/plan.md` is coordination-tier (pointers + sprint objective, not technical plans). The only two valid moves for blocked Specialists are (1) surface to Conductor, (2) call Technical Architect for unblock plan. See AGENTIC.md §3 Sprint Coordinator Constraints. Tool-layer enforcement: `.claude/hooks/block-orchestrator-execution.sh` (see `docs/bridges/S18.1-em-execution-hook.md`).

---

## Operating Mode

Current: MANUAL (autonomous loop inactive — Tim triggers each handoff)

To change approval frequency: run `/streamline-approvals manual` or `/streamline-approvals auto`. See `AGENTIC.md` §3 for the mode-aware dispatch model.

**Specialist dispatch protocol (mode-dependent):** The full binding rule lives in `AGENTIC.md` §3 Sprint Coordinator Constraints (T7.5 — one rule, one place). Summary:
- **MANUAL mode (approval-gated):** kickoff card only — two fenced blocks per track for the Conductor to paste into a new tab. Inline Agent tool spawning is FORBIDDEN.
- **AUTONOMOUS mode (auto-approve):** Agent tool inline spawn via native sub-agent isolation — each Specialist's context is isolated; Sprint Coordinator receives a bounded 3-field summary (Track / Verdict / Commit). Kickoff cards remain valid as a fallback. Multi-track: use `background: true` on Specialist for concurrent execution.

---

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA (tech stack, team, protocols, hard constraints)
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status
4. **Operating mode mismatch check:** Compare the `operatingMode` field in `.claude/settings.json` against the `## Operating Mode` section in this file. If they differ, surface this warning at the top of the session: `Operating mode mismatch detected: settings.json says <X>, CLAUDE.md says <Y>. Run /streamline-approvals manual or /streamline-approvals auto to reconcile.` Session continues; the warning persists until reconciled.

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

**No-Bridge rule (binding):** Any execution touching `src/`, `supabase/`, config files, agent profiles, skills, `CLAUDE.md`, or `AGENTIC.md` requires a Bridge first. "Sounds small", "it's just one line", and "quick fix" are not exemptions. Clarification questions are fine; execution is not.

**Anti-patterns that do NOT exempt a request from the Bridge requirement:** "sounds small", "quick fix", "it's just one line", "to match X", "just update", "matching reference", "small tactical fix". These phrasings are explicitly recorded as Issue #2 failure patterns — they caused a real protocol bypass. Any request using these patterns, or any close variant suggesting the change is too small to need a Bridge, triggers the same Bridge requirement.

**Sprint Coordinator acknowledgement (binding):** Before executing against any execution file, the Sprint Coordinator MUST emit a one-line acknowledgement: `"This request touches <file> — Bridge required. Calling Technical Architect."` Then surface to Conductor or call Technical Architect. Skipping this acknowledgement is a circuit-breaker event. See AGENTIC.md §3 for the Sprint Coordinator no-execution rule and AGENTIC.md §5 for the canonical No-Bridge rule.

**Commit-before-dispatch (binding):** Conductor commits staged changes on `main` before dispatching. Uncommitted work does not reach Specialist worktrees. Canonical rule: AGENTIC.md §5.

**`.claude/` exception (binding):** `.claude/settings.json` and `.claude/hooks/**` are not worktree-isolated; edit on `main` (absolute path). Canonical rule: AGENTIC.md §5; Bridge template guidance: AGENTIC.md §8.

**Pre-staging hygiene (binding):** Run `git status` before `git add`; commit or stash unrelated dirty files first. Canonical rule: AGENTIC.md §5.

---

## Communication Standards

All long-form structured output must be written to a `.md` file. Chat carries a 1–2 sentence summary + absolute path. See AGENTIC.md §10 for the canonical rule body, agent applicability scope, and exception cases. (T7.5 — one rule, one place.)

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
| Sprint Coordinator | Peaches (or any project-specific name) when referring to coordination/routing role |
| Technical Architect | Suzy (or any project-specific name) when referring to technical planning role |
| Specialist | Skylar (or any project-specific name) |
| QA | Bandit (or any project-specific name) |
| Conductor | Tim (or any individual's name) |

Agent names are project-specific and fungible. Role terms are stable across every Agent OS installation. File paths referencing `.claude/agents/peaches.md` are fine — those are paths, not role references.

---

## Stability Rules

- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP. Call the Technical Architect for Red Flag Analysis. Any destructive or irreversible failure triggers an immediate stop.
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
