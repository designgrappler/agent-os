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
| **[SPRINT COORDINATOR NAME]** | Sprint Coordinator | Sprint synthesis, routing, sprint interview docs — zero code |
| **[TECHNICAL ARCHITECT NAME]** | Technical Architect | Red Flag Analysis, Implementation Plans, Handoff Bridges for technical tracks — zero code |
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
- Row with Role = "Sprint Coordinator" → `SPRINT_COORDINATOR` = Agent Name value (strip `**`)
- Row with Role = "Technical Architect" → `TECHNICAL_ARCHITECT` = Agent Name value (strip `**`)
- Row with Role = "QA" → `QA` = Agent Name value (strip `**`)
- All remaining rows → `SPECIALISTS` list, each with name, domain (from Role column, strip " Specialist"), and scope (from Scope column, strip backticks)

**Tech stack fields** — for each `**Field:** value <!-- comment -->` line, take the text between `:` and `<!--` (trim whitespace). If blank, the field is not configured.

**Docs migration** — for each row in the migration table where the "Current file" cell is not a placeholder (not blank, not bracketed), record `{from: "path", to: "docs/context/X.md"}`.

**Extracted values:**
- `NAME` = Project name
- `DESCRIPTION` = Short description
- `OWNER` = Conductor agent name
- `ORCHESTRATOR` = Orchestrator agent name
- `SPRINT_COORDINATOR` = Sprint Coordinator agent name
- `TECHNICAL_ARCHITECT` = Technical Architect agent name
- `QA` = QA agent name
- `SPECIALISTS` = list of specialist rows (may be empty)
- `RUNTIME`, `FRAMEWORK`, `DATABASE`, `FRONTEND`, `STYLING`, `BUILD_CMD`, `TYPECHECK_CMD`, `LINTER`
- `MIGRATIONS` = list of confirmed doc migration pairs

**Validation** — stop and list what's missing if any of these are blank:
- `NAME`, `DESCRIPTION`, `OWNER`, `SPRINT_COORDINATOR`, `TECHNICAL_ARCHITECT`, `QA`, `BUILD_CMD`

If all required values are present → proceed to Step 4.

---

## Step 4: Generate Files

Create all files below. For each file that already exists, show the diff and ask: merge, replace, or skip.

---

### Model alias and tier guidance (read before generating any agent)

Every generated agent file uses **two frontmatter fields** to identify its model:

```yaml
provider: claude       # cloud provider: claude | gemini | (future)
model: sonnet          # tier alias within that provider
```

Use the short alias (`opus`, `sonnet`, `haiku`) for `model:` in every generated agent file. The short alias tracks the best-available model in that tier. To pin a specific checkpoint instead, use the long form (e.g. `claude-opus-4-7`) — pinning trades freshness for reproducibility.

**Compatibility note:** `provider:` absent defaults to `claude` during the compatibility window (see AGENTIC.md §9.2). All new agents must include the `provider:` line above `model:`.

The table below is **guidance, not a hard rule.** [OWNER] retains the right to override per project.

| Role | Tier | Provider | Model alias | Why this tier |
|---|---|---|---|---|
| Sprint Coordinator | Coordination / synthesis | `claude` | `sonnet` | Sprint synthesis, routing, sprint interview docs |
| Technical Architect | Strategic / planning | `claude` | `opus` | Heavy reasoning, plan synthesis, Red Flag Analysis |
| Strategist | Strategic / planning | `claude` | `opus` | Pre-planning, market and product framing |
| Specialist (Skylar) | Implementation / coding | `claude` | `sonnet` | Code execution at speed |
| Backend / Frontend / Fullstack / Database | Implementation / coding | `claude` | `sonnet` | Standard implementation work |
| Designer | Implementation / craft | `claude` | `sonnet` | Visual / UX deliverables |
| PM | Implementation / writing | `claude` | `sonnet` | Requirements drafting, ticket grooming |
| Marketing | Implementation / writing | `claude` | `sonnet` | Copy and positioning |
| Critic / QA / Bandit | Lightweight review | `claude` | `sonnet` | Fast read-only verdict (Sonnet preferred for nuance; Haiku acceptable for purely-mechanical checks) |
| Lightweight / fast tasks | Routine | `claude` | `haiku` | Quick reformat, summarization, simple lookups |

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

### Design Toolchain (optional — omit if no Designer-class agent on this project)

```yaml
design_tool: <none|pencil|figma|other>   # Which design tool the Designer agent uses
runtime: <desktop|vscode-extension|other> # Which Pencil/Figma runtime is installed
mcp_server_path: <absolute path or N/A>  # Path to the standalone MCP server binary (N/A if design_tool: none)
```

Projects with no Designer-class agent leave this section as a stub or omit it entirely. When populated, this section governs how the project configures the Designer agent's `mcpServers:` frontmatter. See `claude/agents/designer.md` for the two supported shapes (desktop, vscode-extension) and the known VSCode-extension limitation.

---

## 3. Project Team

- **[OWNER] (Conductor):** Vision & Approval.
- **[ORCHESTRATOR] (Orchestrator):** Coordinates specialists, no direct execution.
- **[SPRINT_COORDINATOR] (Sprint Coordinator):** Coordination hub. Zero-code. Sprint synthesis, routing.
- **[TECHNICAL_ARCHITECT] (Technical Architect):** Technical planning authority. Zero-code. Plans and produces Handoff Bridges.
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
- **Phase 3 (Draft):** Technical Architect drafts implementation plan.
- **Phase 4 (Bridge):** Technical Architect compresses Dynamic DNA into a Handoff Bridge for the Specialist.

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
- **Execution Files (source):** [list of primary source/canonical files]
- **Execution Files (tests):** [] — [one-line justification if empty]
- **Execution Files (tooling/config):** [list of build/config/scaffold files; "[]" if none]
**Migration Safety:** [N/A / Reversible / Irreversible — Conductor acceptance: YES (date) if irreversible]
**Security Review:** [N/A / Auth / Payments / Schema — Conductor acceptance: YES (date) if any]
**Worktree Setup:** Automatic — `isolation: worktree` in Specialist frontmatter + `worktree.baseRef: "head"` in `.claude/settings.json`. Verify both are present before Specialist begins. (`isolation: worktree` is a CWD setting — built-in file tools are governed by the permission system, not the worktree CWD; Bridge Execution Files scope is the protocol-layer compensating control.)
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

## Operating Mode

Current: MANUAL (autonomous loop inactive — Tim triggers each handoff)

To change approval frequency: run `/streamline-approvals auto` or `/streamline-approvals gated`. See `AGENTIC.md` §3 for the mode-aware dispatch model.

---

## Initialization Loop (Every Session)

Before any work, read:
1. `AGENTIC.md` — Static DNA (tech stack, team, protocols, hard constraints)
2. `docs/context/plan.md` — Current sprint objective
3. `docs/context/tracks.md` — Active tracks and their status
4. **Operating mode mismatch check:** Compare the `operatingMode` field in `.claude/settings.json` against the `## Operating Mode` section in this file. If they differ, surface this warning at the top of the session: `Operating mode mismatch detected: settings.json says <X>, CLAUDE.md says <Y>. Run /streamline-approvals gated or /streamline-approvals auto to reconcile.` Session continues; the warning persists until reconciled.

---

## Execution Protocol

**No execution without a Handoff Bridge.**

All work must flow through:
\`\`\`
Conductor (approval) → Sprint Coordinator (routing) → Technical Architect (plan + Handoff Bridge) → Specialist (execute) → QA (quality gate)
\`\`\`

---

## Worktree Protocol

Worktree isolation is enforced via each Specialist's agent frontmatter (`isolation: worktree`) and `.claude/settings.json` (`worktree.baseRef: "head"`). No manual git commands needed — the Agent tool runtime manages lifecycle. CWD isolation only: relative paths are isolated, absolute paths are not.

---

## Hooks (Auto-Enforced)

| Hook | Trigger | Action |
|---|---|---|
| **Stop** | Session ends | Prints DNA hygiene reminder |
| **PreToolUse(Bash)** | `git push` | Blocks if build command fails (see AGENTIC.md §2) |

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

### 4f. `.claude/agents/[SPRINT_COORDINATOR].md` and `.claude/agents/[TECHNICAL_ARCHITECT].md`

Generate two agent definitions:

**Sprint Coordinator:**
- `name:` → SPRINT_COORDINATOR (lowercase, hyphen-separated if multi-word)
- `description:` → "Sprint Coordinator for [NAME]. Coordination hub — sprint synthesis, routing, sprint interview docs."
- `provider: claude`
- `model: sonnet`
- `tools: Read, Bash`
- Body: Initialization (read AGENTIC.md, plan.md, tracks.md, CLAUDE.md), Core Identity (zero-code coordinator), Routing Protocol (technical → Technical Architect, design → Designer, marketing → Marketing), Specialist dispatch per operating mode, Hard Constraints (no execution files, no domain plans), Sign-Off Protocol, Circuit Breaker.
- Replace "Conductor" references with OWNER throughout.

**Technical Architect:**
- `name:` → TECHNICAL_ARCHITECT (lowercase, hyphen-separated if multi-word)
- `description:` → "Technical Architect for [NAME]. Zero-code planner — owns Red Flag Analysis, Implementation Plans, and Handoff Bridges for technical tracks."
- `provider: claude`
- `model: opus`
- `tools: Read, Write, Edit, Bash, WebFetch`
- Body: Initialization (read AGENTIC.md, plan.md, tracks.md, product.md, INSTALL_CHECKLIST.md — surface any unchecked required items before planning), Core Identity (zero-code planner), Capabilities (Research Phase (§0, mandatory before any plan touching runtime behavior: search https://code.claude.com/docs, cite source URLs, no behavioral claims without documentation, hard stop on "I think"; hard stop if WebFetch unavailable), Red Flag Analysis, Implementation Plan, Handoff Bridge using template from AGENTIC.md §8, Sprint Housekeeping), Hard Constraints (no source file edits; writes to `docs/context/` and `docs/archive/` only; never issue a Bridge with unfilled safety fields; worktree isolation enforced via Specialist frontmatter — verify `isolation: worktree` and `worktree.baseRef: "head"` exist before issuing any Bridge), Sign-Off Protocol, Circuit Breaker.
- Replace "Conductor" references with OWNER throughout.

---

### 4g. `.claude/agents/[QA].md`

Generate a QA agent definition:

- `name:` → QA (lowercase, hyphen-separated if multi-word)
- `description:` → "QA for [NAME]. Zero-write quality gate — issues PASS or BLOCKED verdict."
- `provider: claude`
- `model: sonnet`
- `tools: Read, Bash, WebFetch`
- Body: Initialization, Core Identity (zero-write), Spec Gate (must receive Handoff Bridge before auditing), Quality Gate checks (scope, build passes `[BUILD_CMD]`, no secrets, format), Behavioral Verification Gate (between Quality Gate and Context Gate — requires Specialist to have attached observed output; BLOCKED if absent or vague; check plan doc for Research Basis section on behavioral claim tracks), Context Gate (track hygiene), Hard Constraints (never write or edit; verdict is APPROVED or BLOCKED only), Circuit Breaker.

---

### 4h. `.claude/agents/[SPECIALIST NAME].md` (one per specialist row)

For each specialist parsed from the team table, generate an agent definition:

- `name:` → specialist name (lowercase, hyphen-separated if multi-word)
- `description:` → "[NAME] [DOMAIN] Specialist for [NAME]. Owns [SCOPE]."
- `provider: claude`
- `model: sonnet`
- `isolation: worktree`
- `tools: Read, Write, Edit, Bash, WebFetch`
- Body: Initialization (read DNA files), Core Identity (domain and scope), Capabilities, Hard Constraints (Bridge is the only scope boundary; STOP if Bridge safety fields are unpopulated for auth/schema/payment changes; if implementation relies on undocumented behavior — a tool parameter, runtime guarantee, or API assumption not confirmed in official docs — STOP and flag to the Technical Architect before proceeding), Sign-Off Protocol (Sign-Off must include **Behavioral Verification** field with actual observed output from the Bridge's Verification command — pasted output, not a summary).

---

### 4i. `.claude/settings.json`

If `.claude/settings.json` already exists, merge — do not remove existing entries. If it does not exist, create:

```json
{
  "operatingMode": "gated-approve",
  "worktree": {
    "baseRef": "head"
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "f=\"$CLAUDE_PROJECT_DIR/.agent-os-checked\"; if [ ! -f \"$f\" ]; then echo 'Agent OS health check is overdue — run /check-agent-os.'; exit 0; fi; mtime=$(stat -f %m \"$f\" 2>/dev/null || stat -c %Y \"$f\" 2>/dev/null); now=$(date +%s); if [ -z \"$mtime\" ]; then exit 0; fi; age_days=$(( (now - mtime) / 86400 )); if [ \"$age_days\" -gt 30 ]; then echo 'Agent OS health check is overdue — run /check-agent-os.'; fi; exit 0"
          },
          {
            "type": "command",
            "command": "sanitized=$(echo \"$CLAUDE_PROJECT_DIR\" | sed 's|/|-|g'); mem_dir=\"$HOME/.claude/projects/$sanitized/memory\"; if [ ! -d \"$mem_dir\" ]; then exit 0; fi; newest_mtime=$(find \"$mem_dir\" -maxdepth 1 -type f -exec stat -f %m {} \\; 2>/dev/null | sort -n | tail -1); if [ -z \"$newest_mtime\" ]; then newest_mtime=$(find \"$mem_dir\" -maxdepth 1 -type f -exec stat -c %Y {} \\; 2>/dev/null | sort -n | tail -1); fi; if [ -z \"$newest_mtime\" ]; then exit 0; fi; now=$(date +%s); age_days=$(( (now - newest_mtime) / 86400 )); if [ \"$age_days\" -gt 14 ]; then echo \"Memory hygiene reminder — newest memory entry is $age_days days old. Consider /clean-context or /minify-context.\"; fi; exit 0"
          }
        ]
      }
    ],
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
    "defaultMode": "default",
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(find *)",
      "Bash(grep *)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force *)",
      "Bash(git push -f *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(npx *)",
      "Bash(bunx *)",
      "Bash(uvx *)",
      "Bash(eval *)",
      "Bash(ssh *)"
    ]
  }
}
```

---

---

### 4i-blueprints. Blueprint scaffolding (Claude Code only)

> **If you are running as Claude Code, perform the blueprint-scaffolding step below. If you are running as Gemini CLI, skip this step entirely — blueprints are a Claude Code-only canonical content type this sprint.**

**Claude Code branch only:**

1. Read `blueprints-manifest.json` from the canonical source repo (the same local clone used in Step 4 for skills). If `blueprints-manifest.json` is absent (e.g. the canonical clone predates T19.2), emit a single line:
   > `no blueprints-manifest.json found in canonical source — skipping blueprint scaffolding`
   Then continue to Step 4i-mode. No error, no abort.

2. If `~/.claude/blueprints/` does not exist, create it silently:
   ```bash
   mkdir -p ~/.claude/blueprints/
   ```
   Do not emit any message about the directory creation itself.

3. For each name in the manifest's `blueprints` array, copy `claude/blueprints/<name>.md` from the canonical source to `~/.claude/blueprints/<name>.md`. If a same-named file already exists at the destination, show the diff and ask the user: merge, replace, or skip — identical to the existing Step 4 file-collision pattern.

4. After all entries are processed, emit a single summary line:
   > `Installed N blueprint(s) to ~/.claude/blueprints/`
   Where N is the count of successfully installed blueprints. Skipped or failed files are reported per-file above the summary line.

---

### 4i-mode. Operating mode introduction

After `.claude/settings.json` is written, introduce operating mode to the user and verify the freshly generated `CLAUDE.md` contains the `## Operating Mode` section.

**Agent OS defaults to gated-approve mode on every fresh install.** In gated-approve mode, the Conductor (you) triggers each handoff — the Orchestrator coordinates on request, not autonomously. auto-approve mode is a deliberate posture change made via `/streamline-approvals auto`.

No mode-selection prompt is shown at install time. The default is always manual. Switching modes is always a deliberate, named action.

Verify that the freshly generated `CLAUDE.md` contains a `## Operating Mode` section. If it does not (e.g. because the template predates T17.3), insert the following block immediately after `## Team Architecture` (or at the top of the file if that section is absent):

```markdown
## Operating Mode

Current: MANUAL (autonomous loop inactive — Tim triggers each handoff)

To change approval frequency: run `/streamline-approvals auto` or `/streamline-approvals gated`. See `AGENTIC.md` §3 for the mode-aware dispatch model.
```

Tell the user:
> **Operating mode:** Agent OS is installed in **gated-approve** mode (default). Tim triggers each handoff. To switch to auto-approve mode, run `/streamline-approvals auto`. To return to gated-approve mode, run `/streamline-approvals gated`.


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
Complete at any time. Your Technical Architect will surface unchecked items at the start of each session.

- [ ] Product focus — fill in Current Focus in `docs/context/product.md`
- [ ] Team conventions — update AGENTIC.md §5 with any project-specific workflow rules
```

---

### 4k-designer. Designer-aware setup (Claude Code only)

> **If you are running as Claude Code, perform the designer-aware setup step below. If you are running as Gemini CLI, skip this step entirely.**

**Claude Code branch only:**

**Designer-class detection:** inspect the `SPECIALISTS` list parsed in Step 3. A specialist is Designer-class if:
- Their `name` (lowercase, hyphen-separated) matches `designer`; OR
- Their canonical agent file's `description:` or `name:` frontmatter declares a designer role (e.g. a project-renamed designer agent).

If **no Designer-class agent is found** in the roster, write the AGENTIC.md §2 Design Toolchain section as a stub and skip to the final bullet below:

```yaml
design_tool: none
runtime: N/A
mcp_server_path: N/A
```

Then append to `INSTALL_CHECKLIST.md`:
```
- [ ] MCP: N/A (no design tool configured)
```

Skip the rest of this sub-phase.

---

If **a Designer-class agent is found**, proceed:

**Step 1 — Prompt for design tool and runtime:**

Ask the user:
> "Designer-class agent detected in your roster. Two questions:
> 1. Design tool? [pencil / figma / none / other]
> 2. Runtime? [desktop / vscode-extension / other]
>
> (If `pencil` on `desktop`: you need `/Applications/Pencil.app/` installed. If `pencil` on `vscode-extension`: you need the Pencil extension installed in VS Code.)"

Wait for the user's answers.

**Step 2 — Handle `none` selection:**

If the user selects `none` as the design tool:

1. Write the AGENTIC.md §2 Design Toolchain section as a stub:
   ```yaml
   design_tool: none
   runtime: N/A
   mcp_server_path: N/A
   ```
2. Append to `INSTALL_CHECKLIST.md`:
   ```
   - [ ] MCP: N/A (no design tool configured)
   ```
3. Skip the MCP config block entirely. Proceed to Step 4l.

**Step 3 — Handle `pencil` + `desktop` selection:**

1. Populate the AGENTIC.md §2 Design Toolchain section:
   ```yaml
   design_tool: pencil
   runtime: desktop
   mcp_server_path: /Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64
   ```

2. Surface the following `mcpServers:` config block to the user for **explicit review and confirmation before any write**:

   > "Add the following block to `~/.claude/settings.json` under `mcpServers` to enable Pencil MCP access for the Designer subagent. Review and confirm before applying — do NOT auto-write:"
   >
   > ```json
   > "mcpServers": {
   >   "pencil-desktop": {
   >     "type": "stdio",
   >     "command": "/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64",
   >     "args": ["--app", "desktop"]
   >   }
   > }
   > ```
   >
   > "Paste and merge this into your `~/.claude/settings.json`. Restart Claude Code after editing. Then run the MCP reachability check in `INSTALL_CHECKLIST.md`."

3. Append to `INSTALL_CHECKLIST.md`:
   ```
   - [ ] MCP reachability — confirm `mcp__pencil__get_editor_state` succeeds with a Pencil file open (pencil-desktop shape)
   ```

**Step 4 — Handle `pencil` + `vscode-extension` selection:**

1. Populate the AGENTIC.md §2 Design Toolchain section:
   ```yaml
   design_tool: pencil
   runtime: vscode-extension
   mcp_server_path: ~/.pencil/mcp/visual_studio_code/out/mcp-server-darwin-arm64
   ```

2. Surface the following config block to the user for **explicit review and confirmation before any write**:

   > "Add the following block to `~/.claude/settings.json` under `mcpServers`. Note the known limitation: the Pencil VS Code extension's MCP server is session-only and does NOT propagate to Designer subagents automatically — this explicit registration is required. Review and confirm before applying — do NOT auto-write:"
   >
   > ```json
   > "mcpServers": {
   >   "pencil-vscode": {
   >     "type": "stdio",
   >     "command": "~/.pencil/mcp/visual_studio_code/out/mcp-server-darwin-arm64",
   >     "args": ["--app", "visual_studio_code"]
   >   }
   > }
   > ```
   >
   > "Paste and merge this into your `~/.claude/settings.json`. Restart Claude Code after editing. Then run the MCP reachability check in `INSTALL_CHECKLIST.md`."

3. Append to `INSTALL_CHECKLIST.md`:
   ```
   - [ ] MCP reachability — confirm `mcp__pencil__get_editor_state` succeeds with a Pencil file open (pencil-vscode shape)
   ```

**Step 5 — Handle `figma` or `other` selection:**

1. Populate the AGENTIC.md §2 Design Toolchain section with the user's input:
   ```yaml
   design_tool: figma   # or the user's stated tool name
   runtime: [user's stated runtime]
   mcp_server_path: [user's stated path, or N/A if not yet known]
   ```
2. Tell the user:
   > "Figma / other design tool detected. Consult your design tool's MCP server documentation to configure `mcpServers` in `~/.claude/settings.json`. See `claude/agents/designer.md` for the general MCP registration pattern. Update `INSTALL_CHECKLIST.md` manually with the MCP reachability check once configured."
3. Append to `INSTALL_CHECKLIST.md`:
   ```
   - [ ] MCP reachability — configure `mcpServers` for your design tool and confirm the Designer subagent can reach it
   ```

**Absent-file handling (AGENTIC.md §9.7.1):** `INSTALL_CHECKLIST.md` was created in Step 4k above. If for any reason it does not exist, create it silently before appending:
```bash
touch INSTALL_CHECKLIST.md
```

**AGENTIC.md Design Toolchain write:** the Design Toolchain section already exists as a stub in the generated `AGENTIC.md` (Step 4a generated it as a placeholder block). Replace the stub's `design_tool`, `runtime`, and `mcp_server_path` placeholder values with the chosen values. Field order is binding: `design_tool` first, `runtime` second, `mcp_server_path` third.

---

### 4l. Delete `AgentOS-Setup.md`

After all files are created successfully, delete `AgentOS-Setup.md`.

---

## Step 5: Confirm

```
## Agent OS Installed

**Project:** [NAME]
**Files created:** [count]
**Blueprints installed:** N  <!-- Claude Code branch only: include this line with the count of blueprints installed. Omit this line entirely on Gemini CLI installs or when blueprints-manifest.json was absent. -->

**Your team:**
- @[SPRINT_COORDINATOR] — Sprint Coordinator (routing + sprint synthesis)
- @[TECHNICAL_ARCHITECT] — Technical Architect (planning + Handoff Bridges)
- @[QA] — QA (quality gate)
[For each specialist: - @[NAME] — [DOMAIN] specialist]

**Next steps:**
Your first move: open a sprint session with `@[SPRINT_COORDINATOR]`.

- See `INSTALL_CHECKLIST.md` for any remaining setup items.
- AGENTIC.md is your project's source of truth — your Technical Architect keeps it current.

**Verification:** Run `[BUILD_CMD]` to confirm the build environment is clean.

**Operating mode:** gated-approve (default). To switch to auto-approve mode, run `/streamline-approvals auto`. To return to gated-approve mode, run `/streamline-approvals gated`.


**Activate skills:** Close and reopen your IDE window — installed skills load on session start.
