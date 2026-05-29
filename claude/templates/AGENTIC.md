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

Each Specialist agent definition includes `isolation: worktree` in its frontmatter. Combined with `worktree.baseRef: "head"` in `.claude/settings.json`, every Specialist invocation automatically gets an isolated copy of the repo branched from the current session HEAD.

- `isolation: worktree` provides CWD isolation — the Specialist's working directory is the worktree. Claude's built-in file tools (`Read`, `Edit`, `Write`) are governed by the permission system, not the worktree CWD, so they can write outside the worktree if permissions allow
- `worktree.baseRef: "head"` is required — without it, worktrees branch from `origin/HEAD` and cannot see uncommitted context files
- Branch naming: managed automatically by the Agent tool runtime
- Never work directly on the main branch when 2+ tracks are active in parallel
- Worktree removed only after QA issues PASS verdict
- **Post-setup smoke:** After first enabling `worktree.baseRef: "head"`, invoke a Specialist on a no-op task and confirm the worktree contains uncommitted context files — verifies the setting is honoured (a misconfigured value falls back silently to `origin/HEAD`)

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
**Worktree Setup:** Automatic — `isolation: worktree` in Specialist frontmatter + `worktree.baseRef: "head"` in `.claude/settings.json`. Verify both are present before Specialist begins. (`isolation: worktree` is a CWD setting — built-in file tools are governed by the permission system, not the worktree CWD; Bridge Execution Files scope is the protocol-layer compensating control.)
**Verification:** [specific command or URL]
**Next Step:** [specific task for the Specialist]
```
