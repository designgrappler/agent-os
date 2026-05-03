# Scaffold Workflow
Bootstraps a complete Claude Code Conductor orchestration project from scratch. Prompts for project details, then generates all required files: AGENTIC.md, CLAUDE.md, agent definitions, docs/context/, and settings.json hooks.

> **Existing project?** Stop. Use `/project-adopt` instead. This skill assumes a blank slate — running it on an existing project will treat your current files as conflicts.

## Trigger
When the user runs `/scaffold-workflow`, execute the following steps in order.

---

## Step 1: Gather Project Details

Ask the user the following questions. Wait for all answers before proceeding. Do not use placeholders — collect real values.

1. **Project name** — What is this project called?
2. **One-sentence description** — What does it do?
3. **Tech stack** — Brief summary (e.g., "React + Node.js + PostgreSQL" or "Python + FastAPI + Supabase"). Frontend framework, backend runtime/framework, database.
4. **Conductor name** — What is the human owner/approver's name? (This is the person, not an agent.)
5. **Architect agent name** — What should the Lead Architect agent be called? (e.g., "Peaches", "Atlas", "Architect")
6. **Specialist roles** — How many specialist agents are needed, and what are their names and domains? (e.g., "3 specialists: Max for frontend, Rusty for backend, Lucy for database")
7. **Critic agent name** — What should the QA Critic agent be called? (e.g., "Bandit", "Sentinel", "Critic")
8. **Build/type-check command** — What command verifies a clean build? (e.g., `bunx tsc --noEmit && bun run build` or `npm run typecheck && npm run build` or `python -m pytest`)

---

## Step 2: Generate Files

Create the following files using the gathered values. Replace all `[PLACEHOLDERS]` with actual values from Step 1.

### 2a. `AGENTIC.md` (root)

```markdown
# AGENTIC DNA (Static DNA)

This document contains the foundational constraints, identities, and protocols for [PROJECT NAME]. It is the root "Source of Truth" and must be ingested by all agents before any actions are taken.

---

## 1. DNA Taxonomy
- **Static DNA:** Foundational tech, team roles, and protocol constraints (this file).
- **Dynamic DNA:** High-churn task state, roadmap, and requirements (`docs/context/`).

---

## 2. Tech Stack (Static DNA)

[Insert tech stack details from user input — backend runtime/framework, frontend framework, database, and any transport/protocol constraints]

---

## 3. Team Architecture

### Core Org Chart
- **[CONDUCTOR NAME] (Conductor):** Vision & Approval.
- **Claude (Orchestrator):** Coordinates specialists.
- **[ARCHITECT NAME] (Lead Architect):** Context Owner. Zero-code. Plans and produces Handoff Bridges.
[For each specialist: - **[SPECIALIST NAME] ([Domain] Specialist):** Owns [domain scope].]
- **[CRITIC NAME] (Quality Critic):** QA and build verification.

---

## 4. Worktree Protocol

Each Track gets an isolated git worktree:

\`\`\`bash
git worktree add .worktrees/track-N track/N-short-description
\`\`\`

- Worktrees live in `.worktrees/` (add to `.gitignore`)
- Branch naming: `track/N-short-description`
- Never work directly on the main branch when 2+ tracks are active in parallel
- Worktree removed only after Critic issues PASS verdict

---

## 5. Conductor Protocols

### Stability Rules
- **Circuit Breaker:** 3 consecutive failures with the **same root cause** → STOP and escalate to [CONDUCTOR NAME]. Different error types reset the counter. Any single destructive or security-related failure triggers an immediate stop.
- **Git Hygiene:** No commits unless directed. Use `git add` for staging only.
- **Sentinel Proof:** Never trust an agent summary. Verify with `git diff` or direct file reads.

### Execution Chain
Work flows in dependency order: [Database Specialist] → [Backend Specialist] → [Frontend Specialist]
(Adapt to your stack's dependency graph.)

---

## 6. Commit Convention

All commits must follow Conventional Commits:

\`\`\`
<type>(<scope>): <description>

feat(auth): add OAuth redirect handler
fix(items): correct rounding on calculation
chore(deps): upgrade dependency version
\`\`\`

**Types:** `feat` · `fix` · `chore` · `refactor` · `docs` · `style` · `perf` · `test`

---

## 7. Definition of Done

A track is **Done** only when ALL of the following are true:

- [ ] `[BUILD COMMAND]` exits with zero errors
- [ ] All changes are within the declared track scope (no scope drift)
- [ ] No `console.log`, `debugger`, or hardcoded secrets in the diff
- [ ] `docs/context/plan.md` and `tracks.md` updated to reflect the completed track
- [ ] [CRITIC NAME] has issued a **PASS** verdict
- [ ] [CONDUCTOR NAME] has given final approval (for tracks touching auth, schema, or payments)

---

## 8. Handoff Bridge Template

\`\`\`markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Static DNA Check:** [Confirm alignment with AGENTIC.md]
**Dynamic DNA State:**
- **Product Context:** [1-sentence requirement]
- **Current Plan:** [step in plan.md]
- **Execution Files:** [files to modify]
**Worktree Setup:** [git worktree command or "N/A — single active track"]
**Verification:** [command or URL]
**Next Step:** [specific task for the Specialist]
\`\`\`
```

---

### 2b. `CLAUDE.md` (root)

```markdown
# [PROJECT NAME] — Claude Code Configuration

## Team Architecture

| Role | Agent | Scope |
|---|---|---|
| **[CONDUCTOR NAME]** | Conductor | Vision & Approval |
| **Claude** | Orchestrator | Coordinates specialists |
| **[ARCHITECT NAME]** | Lead Architect | Plans, Handoff Bridges — zero code |
[For each specialist: | **[SPECIALIST NAME]** | [Domain] Specialist | [scope] |]
| **[CRITIC NAME]** | QA Critic | Read-only quality gate |

Agents are defined in `.claude/agents/`. Invoke via `@[architect-name]`, `@[critic-name]`, etc.

---

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status

---

## Execution Protocol

**No execution without a Handoff Bridge.**

All work flows through:
```
[CONDUCTOR NAME] → [ARCHITECT NAME] → Specialist → [CRITIC NAME]
```

---

## Worktree Protocol

```bash
git worktree add .worktrees/track-N track/N-description
```

Worktrees live in `.worktrees/` (gitignored). Never work directly on the main branch for multi-track sprints.

---

## Hooks

| Hook | Trigger | Action |
|---|---|---|
| **Stop** | Session ends | DNA hygiene reminder |
| **PreToolUse(Bash)** | `git push` | Blocks if `[BUILD COMMAND]` fails |

---

## Stability Rules

- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP. Call [ARCHITECT NAME] for Red Flag Analysis.
- **Git Hygiene:** No commits unless [CONDUCTOR NAME] directs.
- **Sentinel Proof:** Never trust a verbal summary. Verify with `git diff` or file reads.
```

---

### 2c. `docs/context/plan.md`

```markdown
# [PROJECT NAME] — Active Plan

## Current Sprint: Initial Setup

### Sprint Goals:
- [ ] Complete project scaffolding and verify all agents are configured correctly.

---

*Last updated: [TODAY'S DATE]*
```

### 2d. `docs/context/tracks.md`

```markdown
# Active Tracks

No active tracks. Add tracks as work begins.

---

*Last updated: [TODAY'S DATE]*
```

### 2e. `docs/context/product.md`

```markdown
# Product Context

## Vision
[PROJECT NAME]: [ONE-SENTENCE DESCRIPTION]

## Current Focus
[To be filled in by the Conductor.]

---

*Last updated: [TODAY'S DATE]*
```

---

### 2f. `.claude/agents/[architect-name].md`

Use the architect template from `claude/agents/architect.md` in the agent-skills-private repo. Update:
- `name:` frontmatter → architect's name
- `description:` → include the project name
- Tech stack reference section → paste from AGENTIC.md

---

### 2g. `.claude/agents/[specialist-name].md` (one per specialist)

Use the specialist template from `claude/agents/specialist.md`. For each specialist:
- `name:` → specialist's name
- `description:` → include domain and project name
- Update the scope section to describe their specific domain

---

### 2h. `.claude/agents/[critic-name].md`

Use the critic template from `claude/agents/critic.md`. Update:
- `name:` → critic's name
- Replace the example build command with the actual build command from Step 1

---

### 2i. `.claude/settings.json`

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '$CLAUDE_TOOL_INPUT' | grep -q '\"git push\"' && ([BUILD COMMAND] || (echo 'Build failed — push blocked.' && exit 1)) || exit 0"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ended. Reminder: archive completed tracks, verify plan.md is current, and confirm no uncommitted changes on staging.'"
          }
        ]
      }
    ]
  }
}
```

---

### 2j. `.gitignore` additions

Append to `.gitignore` if not already present:
```
.worktrees/
.claude/settings.local.json
```

---

## Step 3: Confirm and Orient

After creating all files, report:

```
## Scaffold Complete

**Project:** [PROJECT NAME]
**Files created:** [count] files across AGENTIC.md, CLAUDE.md, docs/context/, .claude/agents/, .claude/settings.json

**Your team:**
- [ARCHITECT NAME] — invoke with @[architect-name]
- [SPECIALIST NAMES] — invoke with @[name]
- [CRITIC NAME] — invoke with @[critic-name]

**Next steps:**
1. Review AGENTIC.md and fill in any remaining tech stack details.
2. Add your first track to docs/context/tracks.md.
3. Call @[architect-name] to begin planning your first sprint.

**Verification:** Run [BUILD COMMAND] to confirm the build environment is clean before starting work.
```
