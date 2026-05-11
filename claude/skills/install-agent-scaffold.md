# Install Agent Scaffold
Bootstraps a new project with the full Agent OS structure. Drops a setup template for the user to fill in — no files are generated until it's complete.

> **Existing project?** Stop. Use `/onboard-existing-project` instead. This skill assumes a blank slate.

## Trigger
When the user runs `/install-agent-scaffold`.

---

## Step 1: Pre-flight

1. If `AGENTIC.md` exists → stop. Tell the user this project is already initialized. Suggest `/onboard-existing-project` to update an existing setup.
2. If `SETUP.md` does **not** exist → go to Step 2.
3. If `SETUP.md` exists → go to Step 3.

---

## Step 2: Create Setup Template

Write the following file to `SETUP.md`, then stop and tell the user:

> "**SETUP.md created.** Fill in your project details, then run `/install-agent-scaffold` again to generate all files."

```markdown
# Agent OS Setup
# Fill in the values below, then run /install-agent-scaffold again.

## Project
Name:
Description:
Owner:

## Build
Build command:
Type-check command:

## Stack
Tech stack:

## Roles
# Keep the specialists you want, delete the rest.
# architect and critic are always included.
roles:
  - fullstack
  # - frontend
  # - backend
  # - database
  # - designer
  # - pm
  # - marketing

## Names (optional — leave blank to use role names)
Architect name:
Critic name:

## Optional
# These can be filled in later — they don't block generation.
Brand color:
Primary font:
```

Stop here. Do not generate any other files.

---

## Step 3: Validate SETUP.md

Read `SETUP.md`. Check that all required fields are filled (not blank):

- `Name:`
- `Description:`
- `Owner:`
- `Build command:`
- `Tech stack:`
- At least one role is uncommented under `roles:`

If any required field is empty → list what's missing and stop. Tell the user to complete `SETUP.md` and re-run.

If all required fields are present → extract values and proceed to Step 4.

**Extracted values:**
- `NAME` = value of `Name:`
- `DESCRIPTION` = value of `Description:`
- `OWNER` = value of `Owner:`
- `BUILD_CMD` = value of `Build command:`
- `TYPECHECK_CMD` = value of `Type-check command:` — if blank, use `# none configured`
- `STACK` = value of `Tech stack:`
- `ROLES` = all uncommented entries under `roles:` (always add `architect` and `critic`)
- `ARCHITECT` = value of `Architect name:` if set, else `architect`
- `CRITIC` = value of `Critic name:` if set, else `critic`
- `BRAND_COLOR` = value of `Brand color:` — may be blank
- `FONT` = value of `Primary font:` — may be blank

---

## Step 4: Generate Files

Create all files below using the extracted values.

---

### 4a. `AGENTIC.md`

```markdown
# AGENTIC DNA (Static DNA)

This document contains the foundational constraints, identities, and protocols for [NAME]. It is the root "Source of Truth" and must be ingested by all agents before any actions are taken.

---

## 1. DNA Taxonomy
- **Static DNA:** Foundational tech, team roles, and protocol constraints (this file).
- **Dynamic DNA:** High-churn task state, roadmap, and requirements (`docs/context/`).

---

## 2. Tech Stack (Static DNA)

[STACK]

### Quality & Automation
- **Build Command:** `[BUILD_CMD]`
- **Type-check:** `[TYPECHECK_CMD]`

---

## 3. Team Architecture

### Org Chart
- **[OWNER] (Conductor):** Vision & Approval.
- **Claude (Orchestrator):** Coordinates specialists.
- **[ARCHITECT] (Lead Architect):** Context Owner. Zero-code. Plans and produces Handoff Bridges.
[For each specialist role selected: - **[ROLE] Specialist:** Owns [role] domain.]
- **[CRITIC] (QA Critic):** Read-only quality gate.

### Execution Chain
[ARCHITECT] → Specialist(s) → [CRITIC]

### Specialist Selection

[Generate the appropriate subset of this table based on selected roles:]

| Scenario | Specialist |
|---|---|
| Solo project or single-track cross-layer feature | `fullstack` |
| UI / presentation layer only | `frontend` |
| API routes / services / business logic only | `backend` |
| Schema / migrations / queries only | `database` |

**Mutual exclusivity:** `fullstack` cannot run concurrently with `frontend`, `backend`, or `database` on overlapping tracks.

**Uncovered layers:** If a feature requires a layer with no active specialist, [ARCHITECT] opens a new track. Specialists never expand scope to cover gaps.

---

## 4. Worktree Protocol

Each Track gets an isolated git worktree:

\`\`\`bash
git worktree add .worktrees/track-N track/N-short-description
\`\`\`

- Worktrees live in `.worktrees/` (gitignored)
- Branch naming: `track/N-short-description`
- Never work directly on main when 2+ tracks are active in parallel
- Worktree removed only after [CRITIC] issues APPROVED verdict

---

## 5. Conductor Protocols

### Stability Rules
- **Circuit Breaker:** 3 consecutive failures with the **same root cause** → STOP and escalate to [OWNER]. Different error types reset the counter. Any single destructive or security-related failure triggers immediate stop.
- **Git Hygiene:** No commits unless directed. Stage only.
- **Sentinel Proof:** Never trust a verbal summary. Verify with `git diff` or file reads.

### Handoff Logic
1. **Verify** — confirm interfaces match before implementation begins.
2. **Align** — sync with AGENTIC.md and tracks.md.
3. **Draft** — [ARCHITECT] drafts implementation plan.
4. **Bridge** — [ARCHITECT] compresses Dynamic DNA into a Handoff Bridge. Before issuing: evaluate Migration Safety and Security Review. Both fields must be explicitly set — never left as placeholders.

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

## 7. Definition of Done

A track is **Done** only when ALL of the following are true:

- [ ] `[BUILD_CMD]` exits with zero errors
- [ ] All changes are within the declared track scope (no scope drift)
- [ ] No `console.log`, `debugger`, or hardcoded secrets in the diff
- [ ] `docs/context/plan.md` and `tracks.md` updated to reflect the completed track
- [ ] [CRITIC] has issued an **APPROVED** verdict
- [ ] [OWNER] has given final approval for tracks touching auth, schema, or payments — this approval happens at Bridge issuance, not after [CRITIC]

---

## 8. Handoff Bridge Template

\`\`\`markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Specialist:** [role]
**Static DNA Check:** [Confirm alignment with AGENTIC.md]
**Dynamic DNA State:**
- **Product Context:** [1-sentence requirement]
- **Current Plan:** [step in plan.md]
- **Execution Files:** [files to modify]
**Migration Safety:** [N/A / Reversible / Irreversible — Conductor acceptance: YES (date) if irreversible]
**Security Review:** [N/A / Auth / Payments / Schema — Conductor acceptance: YES (date) if any]
**Worktree Setup:** [git worktree command or "N/A — single active track"]
**Verification:** [command or URL]
**Next Step:** [specific task for the Specialist]
\`\`\`

---

*Last Refined: [TODAY'S DATE]*
```

---

### 4b. `CLAUDE.md`

```markdown
# [NAME] — Claude Code Configuration

## Team Architecture

| Role | Agent | Scope |
|---|---|---|
| **[OWNER]** | Conductor | Vision & Approval |
| **Claude** | Orchestrator | Coordinates specialists |
| **[ARCHITECT]** | Lead Architect | Plans, Handoff Bridges — zero code |
[For each specialist: | **[ROLE]** | [Role] Specialist | [domain scope] |]
| **[CRITIC]** | QA Critic | Read-only quality gate |

Agents are defined in `.claude/agents/`. Invoke via `@[ARCHITECT]`, `@[CRITIC]`, etc.

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
[OWNER] → [ARCHITECT] → Specialist → [CRITIC]
```

---

## Worktree Protocol

```bash
git worktree add .worktrees/track-N track/N-description
```

Worktrees live in `.worktrees/` (gitignored). Never work directly on main for multi-track sprints.

---

## Stability Rules

- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP. Call [ARCHITECT] for Red Flag Analysis.
- **Git Hygiene:** No commits unless [OWNER] directs.
- **Sentinel Proof:** Never trust a verbal summary. Verify with `git diff` or file reads.
```

---

### 4c. `docs/context/plan.md`

```markdown
# [NAME] — Active Plan

## Current Sprint: Initial Setup

- [ ] Review AGENTIC.md and verify team configuration.
- [ ] Open first sprint with @[ARCHITECT].

---

*Last updated: [TODAY'S DATE]*
```

### 4d. `docs/context/tracks.md`

```markdown
# Active Tracks

No active tracks. Add tracks as work begins.

---

*Last updated: [TODAY'S DATE]*
```

### 4e. `docs/context/product.md`

```markdown
# Product Context

## Vision
[NAME]: [DESCRIPTION]

## Current Focus
[To be filled in by the Conductor.]

---

*Last updated: [TODAY'S DATE]*
```

---

### 4f. `.claude/agents/[ARCHITECT].md`

Generate an architect agent definition using the standard architect template structure:

- `name:` → ARCHITECT (lowercase, hyphen-separated if multi-word)
- `description:` → "Lead Architect for [NAME]. Zero-code planner — owns plans, Red Flag Analysis, and Handoff Bridges."
- `model: claude-opus-4-7`
- `tools: Read, Write, Edit, Bash`
- Body: Initialization (read 5 files: the 4 DNA files plus `INSTALL_CHECKLIST.md` — if any required checklist items are unchecked, surface them to the Conductor before proceeding with planning), Core Identity (zero-code planner), Capabilities (Red Flag Analysis, Implementation Plan, Handoff Bridge with the template from AGENTIC.md, Sprint Housekeeping), Hard Constraints (no source files; writes to `docs/context/` and `docs/archive/` only; read-only Bash; never issue Bridge with unfilled safety fields), Sign-Off Protocol, Circuit Breaker.
- Replace "Tim" with OWNER throughout.

---

### 4g. `.claude/agents/[CRITIC].md`

Generate a critic agent definition using the standard critic template structure:

- `name:` → CRITIC (lowercase, hyphen-separated if multi-word)
- `description:` → "QA Critic for [NAME]. Zero-write quality gate — issues APPROVED or BLOCKED verdict."
- `model: claude-sonnet-4-6`
- `tools: Read, Bash`
- Body: Initialization, Core Identity (zero-write), Spec Gate (must receive Handoff Bridge before auditing), Quality Gate checks (scope, build, secrets, format), Context Gate (track hygiene), Hard Constraints (never write or edit files; verdict is APPROVED or BLOCKED only), Circuit Breaker.
- Set build command to BUILD_CMD in the Quality Gate section.

---

### 4h. `.claude/agents/[ROLE].md` (one per selected specialist)

For each specialist role in ROLES (excluding architect and critic), generate the appropriate agent definition:

- Use the domain-specific template for the role: `frontend`, `backend`, `database`, `fullstack`, `designer`, `pm`, or `marketing`
- `name:` → role name (lowercase)
- `description:` → "[Role] Specialist for [NAME]."
- `model: claude-sonnet-4-6`
- `tools:` → `Read, Write, Edit, Bash` for dev roles; `Read, Write, Edit` for non-dev roles
- Body: follow the standard domain specialist structure — Initialization (read DNA files), Core Identity (scope and domain), Capabilities, Technical Handshake, Hard Constraints (Bridge is only scope boundary; STOP if safety fields unpopulated for relevant changes), Sign-Off Protocol.

---

### 4i. `.claude/settings.json`

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
      "Read",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(ls *)",
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

Write this file to the project root. Pre-check the scaffold item. Pre-check brand color and font only if those values were provided in SETUP.md.

```markdown
# Install Checklist

## Required
Complete these before opening the first sprint.

- [x] Agent OS scaffold generated — [TODAY'S DATE]
- [ ] Confirm `[BUILD_CMD]` exits with zero errors
- [ ] Review AGENTIC.md — verify team configuration is correct

## Optional
Complete at any time. [ARCHITECT] will surface unchecked items here at the start of each session.

- [PRE-CHECK IF BRAND_COLOR PROVIDED, ELSE LEAVE UNCHECKED] Brand color — add to AGENTIC.md Tech Stack: `[BRAND_COLOR or #______]`
- [PRE-CHECK IF FONT PROVIDED, ELSE LEAVE UNCHECKED] Primary font — add to AGENTIC.md Tech Stack: `[FONT or ______]`
- [ ] Product focus — fill in Current Focus in `docs/context/product.md`
- [ ] Team conventions — update AGENTIC.md §5 with project-specific workflow rules
```

---

### 4l. Delete `SETUP.md`

After all files are created successfully, delete `SETUP.md`.

---

## Step 5: Confirm

Report:

```
## Agent OS Installed

**Project:** [NAME]
**Files created:** [count]

**Your team:**
- @[ARCHITECT] — Lead Architect (planning + Handoff Bridges)
- @[CRITIC] — QA Critic (quality gate)
[For each specialist: - @[ROLE] — [role] specialist]

**Next steps:**
1. Review AGENTIC.md — verify the team configuration is correct.
2. Call @[ARCHITECT] to open your first sprint.

**Verification:** Run [BUILD_CMD] to confirm the build environment is clean.
```
