---
name: install-agent-scaffold
description: Bootstraps a new project with the full Agent OS structure.
---
# Install Agent Scaffold
Bootstraps a new project with the full Agent OS structure. Drops a setup file for the user to fill in — no files are generated until it's complete.

> **Existing project?** Stop. Use `/onboard-existing-project` instead. This skill assumes a blank slate.

## Trigger
When the user runs `/install-agent-scaffold`.

---

## Step 1: Pre-flight

1. If `AGENTIC.md` exists → stop. Tell the user this project is already initialized. Suggest `/onboard-existing-project` to update an existing setup.
2. If `AgentOS-Setup.md` does **not** exist → go to Step 2.
3. If `AgentOS-Setup.md` exists → go to Step 3.

---

## Step 2: Drop Setup File

Write the following content to `AgentOS-Setup.md` at the project root, then stop and tell the user:

> **Step 1 of 2 complete — `AgentOS-Setup.md` created.**
>
> Fill in your project details:
> - **Project** — your project name and description
> - **Set Up Your Team** — replace the name placeholders with your agent names; add or remove specialist rows as needed
> - **Define Your Tech Stack** — defaults are pre-selected; replace any value you want to change
>
> When you're done, run `/install-agent-scaffold` again in this chat. Step 2 will generate: `AGENTIC.md`, `CLAUDE.md`, agent definitions, `docs/context/` files, and settings.

```markdown
# Agent OS Setup

Fill in the fields below, then run `/install-agent-scaffold` in Claude Code.
This file will be deleted automatically when setup is complete.

---

## Project

**Project name:** 
**Short description:** 

---

## Set Up Your Team

Edit the table below to define which roles you need for your project. Specify an agent name, their role, and key responsibilities. Ask your primary agent if you have questions.

Agents can be invoked by typing their name via `@[architect-name]`, `@[qa-name]`, etc. Agent profiles are located in `.claude/agents/` and can be edited at any time.

| Agent Name | Role | Scope and Responsibilities |
|---|---|---|
| **[YOUR NAME]** | Conductor | Vision & Approval |
| **[YOUR AI]** | Orchestrator | Coordinates specialists, no direct execution | <!-- e.g., Claude, Gemini -->
| **[ARCHITECT NAME]** | Lead Architect | Plans, Red Flag Analysis, Handoff Bridges — zero code |
| **[SPECIALIST 1 NAME]** | Frontend Specialist | UI components, pages, and styling |
| **[SPECIALIST 2 NAME]** | Backend Specialist | API routes, server logic, and integrations |
| **[SPECIALIST 3 NAME]** | Database Specialist | Schema, migrations, and queries |
| **[QA NAME]** | QA | Read-only quality gate — no code writes |

---

## Define Your Tech Stack

Defaults are pre-selected. Replace any value you want to change. Leave blank to skip optional fields.

**Runtime:** Node.js <!-- alternatives: Bun · Python · Go · Deno -->
**Framework:** Express <!-- alternatives: Hono · FastAPI (Python) · Gin (Go) · Koa -->
**Database:** PostgreSQL via Supabase <!-- alternatives: PlanetScale · MongoDB · SQLite · leave blank if none -->
**Frontend framework:** React + Vite <!-- alternatives: Next.js · SvelteKit · Nuxt · Remix · leave blank if none -->
**Styling:** Tailwind CSS <!-- alternatives: CSS Modules · Styled Components · Sass · leave blank if none -->
**Build command:** npm run build <!-- alternatives: bun run build · python -m build -->
**Type check command:** <!-- e.g. bunx tsc --noEmit · mypy · leave blank if none -->
**Linter:** ESLint + Prettier <!-- alternatives: Biome · Ruff (Python) · leave blank if none -->

---

## Existing docs to migrate *(optional)*

Update the paths below to match your actual files. Delete rows that don't apply.

| Current file | Maps to |
|---|---|
| README.md | docs/context/product.md |
| [roadmap, backlog, or requirements doc] | docs/context/plan.md |
| [design spec or product brief] | docs/context/product.md |
| [sprint notes or task list] | docs/context/tracks.md |
```

Stop here. Do not generate any other files.

---

## Step 3: Parse AgentOS-Setup.md

Read `AgentOS-Setup.md`. Extract values as follows.

**Project fields** — read `**Project name:**` and `**Short description:**`, take the value after the colon.

**Team table** — parse each row (skip the header row and the Orchestrator row):
- Row with Role = "Conductor" → `OWNER` = Agent Name value (strip `**`)
- Row with Role = "Orchestrator" → `ORCHESTRATOR` = Agent Name value (strip `**`)
- Row with Role = "Lead Architect" → `ARCHITECT` = Agent Name value (strip `**`)
- Row with Role = "QA" → `QA` = Agent Name value (strip `**`)
- All remaining rows → `SPECIALISTS` list, each with name, domain (from Role column, strip " Specialist"), and scope (from Scope column, strip backticks)

**Tech stack fields** — for each `**Field:** value <!-- comment -->` line, take the text between `:` and `<!--` (trim whitespace). If blank, the field is not configured.

**Docs migration** — for each row in the migration table where the "Current file" cell is not a placeholder (not blank, not bracketed), record `{from: "path", to: "docs/context/X.md"}`.

**Extracted values:**
- `NAME` = Project name
- `DESCRIPTION` = Short description
- `OWNER` = Conductor agent name
- `ORCHESTRATOR` = Orchestrator agent name
- `ARCHITECT` = Lead Architect agent name
- `QA` = QA agent name
- `SPECIALISTS` = list of specialist rows (may be empty)
- `RUNTIME`, `FRAMEWORK`, `DATABASE`, `FRONTEND`, `STYLING`, `BUILD_CMD`, `TYPECHECK_CMD`, `LINTER`
- `MIGRATIONS` = list of confirmed doc migration pairs

**Validation** — stop and list what's missing if any of these are blank:
- `NAME`, `DESCRIPTION`, `OWNER`, `ARCHITECT`, `QA`, `BUILD_CMD`

If all required values are present → proceed to Step 4.

---

## Step 4: Generate Files

Create all files below. For each file that already exists, show the diff and ask: merge, replace, or skip.

---

### Model alias and tier guidance (read before generating any agent)

Use the short alias (`opus`, `sonnet`, `haiku`) for `model:` in every generated agent file. The short alias tracks the best-available model in that tier. To pin a specific checkpoint instead, use the long form (e.g. `claude-opus-4-7`) — pinning trades freshness for reproducibility.

The table below is **guidance, not a hard rule.** [OWNER] retains the right to override per project.

| Role | Tier | Model alias | Why this tier |
|---|---|---|---|
| Architect / Peaches | Strategic / planning | `opus` | Heavy reasoning, plan synthesis, Red Flag Analysis |
| Strategist | Strategic / planning | `opus` | Pre-planning, market and product framing |
| Specialist (Skylar) | Implementation / coding | `sonnet` | Code execution at speed |
| Backend / Frontend / Fullstack / Database | Implementation / coding | `sonnet` | Standard implementation work |
| Designer | Implementation / craft | `sonnet` | Visual / UX deliverables |
| PM | Implementation / writing | `sonnet` | Requirements drafting, ticket grooming |
| Marketing | Implementation / writing | `sonnet` | Copy and positioning |
| Critic / QA / Bandit | Lightweight review | `sonnet` | Fast read-only verdict (Sonnet preferred for nuance; Haiku acceptable for purely-mechanical checks) |
| Lightweight / fast tasks | Routine | `haiku` | Quick reformat, summarization, simple lookups |

---

### 4a. `AGENTIC.md`

```markdown
# AGENTIC DNA — [NAME]

[DESCRIPTION]

This document is the root source of truth for this project. All agents read it before any work begins. Edit via your primary agent — do not edit directly.

---

## 2. Tech Stack

### Backend
- **Runtime:** [RUNTIME]
- **Framework:** [FRAMEWORK]
- **Database:** [DATABASE]

### Frontend
- **Framework:** [FRONTEND]
- **Styling:** [STYLING]

### Quality & Automation
- **Type Checking:** [TYPECHECK_CMD or "none configured"]
- **Build:** [BUILD_CMD]
- **Linting:** [LINTER or "none configured"]

---

## 3. Project Team

- **[OWNER] (Conductor):** Vision & Approval.
- **[ORCHESTRATOR] (Orchestrator):** Coordinates specialists, no direct execution.
- **[ARCHITECT] (Lead Architect):** Context Owner. Zero-code. Plans and produces Handoff Bridges.
[For each specialist: - **[NAME] ([DOMAIN] Specialist):** Owns [SCOPE].]
- **[QA] (QA):** Build verification and quality gate. Read-only.

---

## 7. Definition of Done

A track is **Done** only when ALL of the following are true:

- [ ] `[BUILD_CMD]` exits with zero errors
- [ ] All changes are within the declared track scope (no scope drift)
- [ ] No `console.log`, `debugger`, or hardcoded secrets in the diff
- [ ] `docs/context/plan.md` and `tracks.md` updated to reflect the completed track
- [ ] [QA] has issued an **APPROVED** verdict
- [ ] [OWNER] has given final approval for tracks touching auth, schema, or payments

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

\`\`\`bash
git worktree add .worktrees/track-N track/N-short-description
git worktree remove .worktrees/track-N
\`\`\`

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

\`\`\`
feat(auth): add OAuth redirect handler
fix(api): correct pagination offset
chore(deps): upgrade dependencies
\`\`\`

**Types:** `feat` · `fix` · `chore` · `refactor` · `docs` · `style` · `perf` · `test`

---

## 8. Handoff Bridge Template

\`\`\`markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Static DNA Check:** [Confirm alignment with AGENTIC.md tech/roles]
**Dynamic DNA State:**
- **Product Context:** [1-sentence summary of requirement]
- **Current Plan:** [step in plan.md]
- **Execution Files:** [list of files to modify]
**Migration Safety:** [N/A / Reversible / Irreversible — Conductor acceptance: YES (date) if irreversible]
**Security Review:** [N/A / Auth / Payments / Schema — Conductor acceptance: YES (date) if any]
**Worktree Setup:** [git worktree command, or "N/A — single active track"]
**Verification:** [specific command or URL]
**Next Step:** [specific task for the Specialist]
\`\`\`

---

*Last Refined: [TODAY'S DATE]*
```

---

### 4b. `CLAUDE.md`

```markdown
# [NAME] — Claude Code Configuration

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA (tech stack, team, protocols, hard constraints)
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status

---

## Execution Protocol

**No execution without a Handoff Bridge.**

All work must flow through:
\`\`\`
Conductor (approval) → Architect (plan + Handoff Bridge) → Specialist (execute) → QA (quality gate)
\`\`\`

---

## Worktree Protocol

Each track gets an isolated branch and worktree:
\`\`\`bash
git worktree add .worktrees/track-N track/N-description
\`\`\`

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
```

---

### 4c. `docs/context/plan.md`

If a migration source was confirmed for `plan.md`, copy that file and prepend:
```
<!-- Migrated from [original path] — review and update stale content. -->
```
Otherwise create:

```markdown
# [NAME] — Active Plan

## Current Sprint: Initial Setup

- [ ] Review AGENTIC.md and confirm the team configuration looks right.
- [ ] Open your first sprint with @[ARCHITECT].

---

*Last updated: [TODAY'S DATE]*
```

---

### 4d. `docs/context/tracks.md`

```markdown
# Active Tracks

No active tracks. Add tracks as work begins.

---

*Last updated: [TODAY'S DATE]*
```

---

### 4e. `docs/context/product.md`

If a migration source was confirmed for `product.md`, copy that file and prepend the migration header. Otherwise create:

```markdown
# Product Context

## Vision
[NAME]: [DESCRIPTION]

## Current Focus
[To be filled in.]

---

*Last updated: [TODAY'S DATE]*
```

---

### 4f. `.claude/agents/[ARCHITECT].md`

Generate an architect agent definition:

- `name:` → ARCHITECT (lowercase, hyphen-separated if multi-word)
- `description:` → "Lead Architect for [NAME]. Zero-code planner — owns plans, Red Flag Analysis, and Handoff Bridges."
- `model: opus`
- `tools: Read, Write, Edit, Bash`
- Body: Initialization (read AGENTIC.md, plan.md, tracks.md, product.md, INSTALL_CHECKLIST.md — surface any unchecked required items before planning), Core Identity (zero-code planner), Capabilities (Red Flag Analysis, Implementation Plan, Handoff Bridge using template from AGENTIC.md §8, Sprint Housekeeping), Hard Constraints (no source file edits; writes to `docs/context/` and `docs/archive/` only; never issue a Bridge with unfilled safety fields), Sign-Off Protocol, Circuit Breaker.
- Replace "Conductor" references with OWNER throughout.

---

### 4g. `.claude/agents/[QA].md`

Generate a QA agent definition:

- `name:` → QA (lowercase, hyphen-separated if multi-word)
- `description:` → "QA for [NAME]. Zero-write quality gate — issues PASS or BLOCKED verdict."
- `model: sonnet`
- `tools: Read, Bash`
- Body: Initialization, Core Identity (zero-write), Spec Gate (must receive Handoff Bridge before auditing), Quality Gate checks (scope, build passes `[BUILD_CMD]`, no secrets, format), Context Gate (track hygiene), Hard Constraints (never write or edit; verdict is APPROVED or BLOCKED only), Circuit Breaker.

---

### 4h. `.claude/agents/[SPECIALIST NAME].md` (one per specialist row)

For each specialist parsed from the team table, generate an agent definition:

- `name:` → specialist name (lowercase, hyphen-separated if multi-word)
- `description:` → "[NAME] [DOMAIN] Specialist for [NAME]. Owns [SCOPE]."
- `model: sonnet`
- `tools: Read, Write, Edit, Bash`
- Body: Initialization (read DNA files), Core Identity (domain and scope), Capabilities, Hard Constraints (Bridge is the only scope boundary; STOP if Bridge safety fields are unpopulated for auth/schema/payment changes), Sign-Off Protocol.

---

### 4i. `.claude/settings.json`

If `.claude/settings.json` already exists, merge — do not remove existing entries. If it does not exist, create:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ended. Reminder: archive completed tracks, verify plan.md is current, confirm no uncommitted changes.'"
          }
        ]
      }
    ]
  },
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(find *)",
      "Bash(grep *)"
    ]
  }
}
```

---

### 4j. `.gitignore` additions

Append to `.gitignore` if not already present:
```
.worktrees/
.claude/settings.local.json
```

---

### 4k. `INSTALL_CHECKLIST.md`

```markdown
# Install Checklist

## Required
Complete these before opening the first sprint.

- [x] Agent OS scaffold generated — [TODAY'S DATE]
- [ ] Confirm `[BUILD_CMD]` exits with zero errors
- [ ] Review AGENTIC.md — verify team configuration is correct

## Optional
Complete at any time. Your Architect will surface unchecked items at the start of each session.

- [ ] Product focus — fill in Current Focus in `docs/context/product.md`
- [ ] Team conventions — update AGENTIC.md §5 with any project-specific workflow rules
```

---

### 4l. Delete `AgentOS-Setup.md`

After all files are created successfully, delete `AgentOS-Setup.md`.

---

## Step 5: Confirm

```
## Agent OS Installed

**Project:** [NAME]
**Files created:** [count]

**Your team:**
- @[ARCHITECT] — Lead Architect (planning + Handoff Bridges)
- @[QA] — QA (quality gate)
[For each specialist: - @[NAME] — [DOMAIN] specialist]

**Next steps:**
Your first move: open a planning session with `@[ARCHITECT]`.

- See `INSTALL_CHECKLIST.md` for any remaining setup items.
- AGENTIC.md is your project's source of truth — your Architect keeps it current.

**Verification:** Run `[BUILD_CMD]` to confirm the build environment is clean.

**Activate skills:** Close and reopen your IDE window — installed skills load on session start.
```
