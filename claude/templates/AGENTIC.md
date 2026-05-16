# AGENTIC DNA — [PROJECT NAME]

[PROJECT DESCRIPTION]

This document is the root source of truth for this project. All agents read it before any work begins. Edit via your primary agent — do not edit directly.

---

## 2. Tech Stack

### Backend
- **Runtime:** [RUNTIME]
- **Framework:** [FRAMEWORK]
- **Database:** [DATABASE]
- **Transport:** [TRANSPORT]

### Frontend
- **Framework:** [FRONTEND FRAMEWORK]
- **Styling:** [STYLING]
- **Design System:** [DESIGN SYSTEM]

### Quality & Automation
- **Type Checking:** [TYPE CHECK COMMAND]
- **Build:** [BUILD COMMAND]
- **Linting:** [LINTER]

---

## 3. Project Team

- **[CONDUCTOR NAME] (Conductor):** Vision & Approval.
- **Claude (Orchestrator):** Coordinates specialists, no direct execution.
- **[ARCHITECT NAME] (Lead Architect):** Context Owner. Zero-code. Plans and produces Handoff Bridges.
- **[SPECIALIST 1 NAME] ([Domain 1] Specialist):** Owns [scope].
- **[SPECIALIST 2 NAME] ([Domain 2] Specialist):** Owns [scope].
- **[SPECIALIST 3 NAME] ([Domain 3] Specialist):** Owns [scope].
- **[QA NAME] (QA):** Build verification and quality gate. Read-only.

---

## 7. Definition of Done

A track is **Done** only when ALL of the following are true:

- [ ] `[BUILD COMMAND]` exits with zero errors
- [ ] All changes are within the declared track scope (no scope drift)
- [ ] No `console.log`, `debugger`, or hardcoded secrets in the diff
- [ ] `docs/context/plan.md` and `tracks.md` updated to reflect the completed track
- [ ] [QA NAME] has issued a **PASS** verdict
- [ ] [CONDUCTOR NAME] has given final approval (for tracks touching auth, schema, or payments)

---
---

# How Your Agents Operate

> **For reference only.** The sections below describe how your agents behave.

---

## 1. DNA Taxonomy
- **Static DNA:** Foundational tech, team roles, and protocol constraints (this file).
- **Dynamic DNA:** High-churn task state, roadmap, and requirements (`docs/context/`).

---

## 4. Worktree Protocol

Each track gets an isolated git worktree to prevent cross-track contamination:

```bash
# Open a new track
git worktree add .worktrees/track-N track/N-short-description

# Specialist works inside that worktree only
# QA reviews the diff before merge back to main branch
git worktree remove .worktrees/track-N
```

- Worktrees live in `.worktrees/` (add to `.gitignore`)
- Branch naming: `track/N-short-description`
- Never work directly on the main branch when 2+ tracks are active in parallel
- Worktree removed only after QA issues PASS verdict

---

## 5. Conductor Protocols

### Stability Rules
- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP and escalate to the Conductor. Any single destructive or security-related failure triggers an immediate stop regardless of count.
- **Git Hygiene:** No commits unless directed. Use `git add` for staging only.
- **Sentinel Proof:** Never trust an agent's verbal summary. Verify with `git diff` or direct file reads.

### Handoff Logic
- **Phase 1 (Verify):** Downstream specialist verifies upstream interface before any implementation begins.
- **Phase 2 (Align):** Synchronize with `AGENTIC.md` and `tracks.md`.
- **Phase 3 (Draft):** Architect drafts implementation plan.
- **Phase 4 (Bridge):** Architect compresses Dynamic DNA into a Handoff Bridge for the Specialist.

---

## 6. Commit Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

feat(auth): add OAuth redirect handler
fix(items): correct rounding on split calculation
chore(deps): upgrade dependency
refactor(ui): extract component into standalone file
```

**Types:** `feat` · `fix` · `chore` · `refactor` · `docs` · `style` · `perf` · `test`
**Breaking changes:** append `!` after type and include `BREAKING CHANGE:` in the body.

---

## 8. Handoff Bridge Template

```markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Static DNA Check:** [Confirm alignment with AGENTIC.md tech/roles]
**Dynamic DNA State:**
- **Product Context:** [1-sentence summary of requirement]
- **Current Plan:** [step in plan.md]
- **Execution Files:** [list of files to modify]
**Worktree Setup:** [git worktree command, or "N/A — single active track"]
**Verification:** [specific command or URL]
**Next Step:** [specific task for the Specialist]
```
