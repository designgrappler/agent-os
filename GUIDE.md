# Agent OS: Implementation Guide

This guide covers how to set up and operate Agent OS across different environments. For an overview of what Agent OS is and why it exists, start with the [README](./README.md).

**Two things in this repo:**
- **Agent OS** — scaffold installer + workflow skills that read from shared context files (`docs/context/product.md`, `plan.md`, `tracks.md`). Workflow skills require Agent OS to be installed first.
- **Standalone Skill Library** — general-purpose utilities that work on any project. Currently: `audit-security`. New skills that don't depend on Agent OS state belong here.

For a platform-agnostic explanation of the architecture, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Step 0: Which Tools Are You Using?

Agent OS is tool-agnostic at its core — the context files are plain Markdown, the roles are defined in text, and the workflow runs in any environment. Two patterns cover most setups: single model (one tool handles everything) and split model (one tool plans, another executes). We provide specific instructions for one validated example of each.

---

### Single Model — One Tool Handles Everything
*Example: VS Code + Claude Code*

Claude Code handles planning, execution, and review within a single IDE.

**How Agent OS maps:**
- Agent definitions live in `.claude/agents/` and are loaded via the chat interface — see [Agent Library](#agent-library) for the full role set
- Context files (`docs/context/product.md`, `plan.md`, `tracks.md`) are read automatically at session start
- The worktree protocol runs via the VS Code terminal

**Conversation hygiene:**
VS Code Copilot agents enforce fresh context by design — each agent is a new chat. Let it work: don't continue an orchestrator planning thread into execution. Switch agents, which switches conversations.

**Known gap:** There's no programmatic enforcement of when a user switches agents in the workflow. That discipline is on the user.

---

### Split Model — Planning Tool + Execution Tool
*Example: Antigravity (Gemini) + Claude Extension*

Gemini (via Antigravity's Agent Manager) owns planning and orchestration. Claude (via VS Code's Claude Extension) owns execution.

**How Agent OS maps:**
- Antigravity's Agent Manager is the visual equivalent of Agent OS's orchestration layer — spawn an orchestrator in one workspace, a specialist in another
- Context files move between the two tools — write the task context in Antigravity, paste it into Claude Extension to start execution
- Context files (`docs/context/product.md`, `plan.md`, `tracks.md`) live in the repo and are read by both agents from the same source
- Antigravity's parallel workspaces map directly to the worktree protocol — one workspace per active track
- Antigravity's inline artifact feedback works natively on context files and plan documents

**Conversation hygiene:**
Antigravity's Agent Manager enforces context isolation architecturally — each spawned agent runs in its own workspace. This is the strongest conversation hygiene of any setup described here.

**Why this combination works:**
Gemini's strength is planning, architecture, and structured reasoning across large context. Claude's strength is precise execution with strong instruction-following. Agent OS's role separation — orchestrator plans, specialist executes, QA specialist gates — maps cleanly onto this model split.

**Known gaps:**
- AI tools evolve quickly — always check current documentation for the tools you're using, as features may have changed since this was written.
- Running the QA specialist role as a Gemini agent in Antigravity vs. Claude Extension is untested. Contributions welcome.
- Integration between Antigravity's knowledge base and Agent OS's context files is undocumented. Likely high-value — flagged as a gap pending exploration.

---

### Other Environments

Agent OS applies to any tool that supports: (1) reading Markdown files at session start, (2) role-scoped agents with tool restrictions, and (3) structured handoff artifacts. The two examples above cover the single model and split model patterns — use them as a reference for adapting to other combinations. If you validate a new setup, contributions are welcome via [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## Step 1: Prerequisite Audit

> **New project or existing project?** If your project already has code, files, or history — run `onboard-existing-project` (Gemini) or `/onboard-existing-project` (Claude Code) before anything else. It reads what you already have and won't overwrite files without your approval. `install-agent-scaffold` assumes a blank slate.

| Situation | Gemini CLI | Claude Code |
| :--- | :--- | :--- |
| **New project** | `install-agent-scaffold` | `/install-agent-scaffold` |
| **Existing project** | `onboard-existing-project` | `/onboard-existing-project` |

Ensure your environment meets the following before initializing.

### Gemini CLI Path
| Component | Requirement |
| :--- | :--- |
| **CLI** | `gemini` CLI installed (`npm install -g @google/gemini-cli`) |
| **Policy Hub** | `~/.gemini/policies/conductor_enforcement.toml` initialized |
| **Workspace** | Root-level directory write access |

### Claude Code Path
| Component | Requirement |
| :--- | :--- |
| **CLI** | Claude Code installed (`npm install -g @anthropic-ai/claude-code`) |
| **Workspace** | Root-level directory write access |
| **Git** | Repository initialized (hooks require git) |

---

## Step 2: Role Architecture

All roles — dev and non-dev — map to one of three roles.

| Role | Responsibility | Tool Access |
| :--- | :--- | :--- |
| **Orchestrator** | Routes tasks, tracks sprint state, manages context files | Blocked from write/exec on source files |
| **Specialist** | Executes declared deliverables — dev: `frontend`, `backend`, `database`; non-dev: `designer`, `pm`, `marketing` | Scoped to declared task deliverables |
| **QA Specialist** | Audits output, issues PASS/BLOCKED verdict | Read-only |

**Non-dev roles** (product manager, designer, marketing manager, etc.) use the same role structure. The difference is the *type of deliverable* — documents, briefs, and designs instead of source files. The scope lock, Technical Handshake, and Quality Gate all apply equally.

---

## Step 3: Initialization Flow

### Gemini CLI
```bash
# Deploy the full setup bundle in one pass:
gemini skills install https://github.com/designgrappler/agent-os --path skills/install-agent-scaffold
```
Then trigger: *"Install the agent scaffold for this project."*

The bundle runs a **Pre-Flight Interview** — all questions are gathered first, no files created until the interview is complete:
1. Project name and description
2. Tech stack or toolset
3. Team type (dev / creative / mixed)
4. Personnel names for all roles
5. Workflow mode (`GEMINI_ONLY` or `RELAY`)

### Claude Code
Tell Claude:

> "Install Agent OS on this project: https://github.com/designgrappler/agent-os"

Claude fetches the install skill from the repo and runs it. The skill runs in two steps:

1. **Step 1** — Creates `AgentOS-Setup.md` at your project root and stops.
2. **Fill in `AgentOS-Setup.md`** — Set your project name, fill in the team table with agent names, and confirm your tech stack (defaults are pre-selected; replace any value you want to change).
3. **Step 2** — Run `/install-agent-scaffold` again. The skill reads your form, generates all files (`CLAUDE.md`, agent definitions, `docs/context/` files (including `product.md`, `plan.md`, `tracks.md`), `.claude/settings.json`), then deletes `AgentOS-Setup.md`.

No interview questions — the form captures everything up front so generation runs in one clean pass.

---

## Step 4: The Sprint Workflow

Once initialized, the operational loop is:

```
Sprint Open → Plan → Execute → Quality Gate → Sprint Close
```

| Step | Skill / Command | Trigger |
| :--- | :--- | :--- |
| Open sprint | `start-sprint` (Claude) / `open-sprint` (Gemini) | "Start planning" / "New sprint" |
| Check status | `report-track-status` | "Catch me up" / "Status check" |
| Review output | `audit-deliverables` | "Run quality gate on [specialist]'s output" |
| Archive completed | `clean-context` (Gemini) / *(native)* (Claude) | "Clean context" |
| Compress active files | `minify-context` | "Minify context" |

`start-sprint` / `open-sprint` and `report-track-status` **auto-trigger** on natural language phrases — no explicit command needed when configured via the `CLAUDE.md` Auto-Invocations table (Claude Code) or the Trigger section of each skill (Gemini).

---

## Conversation Hygiene

Agent OS is designed to survive context decay — but it doesn't eliminate the need to manage conversations deliberately.

A long conversation accumulates drift. The model's earlier context gets compressed over time. Instructions read at session start carry less weight by message 40. This is a property of all LLMs, not a failure of Agent OS.

**Start a new conversation when:**
- Switching agents — orchestrator to specialist, or any agent to the QA specialist for review
- A track closes and a new one opens
- You notice the agent referencing outdated state or contradicting earlier outputs
- After a circuit breaker fires — always start fresh after an escalation

**Context handoffs as a reset mechanism**
When switching agents or starting a new track, carry context forward explicitly. In Claude Code, the next agent reads the context files (`docs/context/product.md`, `plan.md`, `tracks.md`) at session start. In Antigravity, paste the relevant task context into the new workspace. In other environments, start a fresh conversation with a concise context block summarizing what the next agent needs.

**How different environments handle this**

| Environment | How context boundaries work |
| :--- | :--- |
| **VS Code (Copilot agents)** | Each agent is a new chat window — fresh context by design. Switch agents and you get a clean slate automatically. |
| **Antigravity (Agent Manager)** | Each spawned agent runs in its own workspace with its own context. The strongest isolation of any setup described here. |
| **Claude Code / Gemini CLI** | No automatic boundary. Start new conversations manually. Pass context explicitly when handing off between agents. |

**Practical hygiene (any environment)**
- Name conversations explicitly: "Track 2 — Planning", "Track 2 — Execution", "Track 2 — Review"
- One agent, one conversation. Never mix planning and execution in the same thread.
- If a conversation exceeds ~30 exchanges, treat it as a signal to close and start fresh, passing a concise context summary to the next conversation.

---

## Step 5: Task Context

When the orchestrator routes a task to a specialist, it provides the task context in-session. This is not a formal artifact — it's the information the specialist needs to begin: what files are in scope, what the task is, how to verify completion, and any constraints.

The context is passed differently depending on the environment:

### RELAY Mode (Claude Code or external model)
The orchestrator writes a task context block. Copy it into your external model to start the specialist with full context.

### GEMINI_ONLY Mode
The orchestrator generates a self-executing wake command: `gemini --skill add-specialist`

---

## Step 6: Security & Isolation

**Orchestrator and planning-tier** skills are structurally restricted from modifying production source code or final deliverables. This is enforced at the runtime level — not through instructions alone:

- **Gemini CLI**: `policy.toml` strips unauthorized tools from the manifest
- **Claude Code**: `tools:` frontmatter list is enforced by the Claude Code runtime

**Parallel tracks** each get an isolated workspace via `isolation: worktree` in each specialist's agent frontmatter — the Claude Code runtime creates and cleans up the worktree automatically. No manual worktree commands required.

### Approval Discipline

In multi-agent workflows, **approval exhaustion** is a real failure mode. When the system prompts for approval too frequently, users start approving without reading — and the safety guarantee disappears.

The fix is not to disable approvals, but to sort them correctly:

| Approval type | Examples | Policy |
| :--- | :--- | :--- |
| **Must prompt** | `git push`, schema migrations, destructive operations | Always require approval — these are the checkpoints that matter |
| **Auto-approve** | File reads, `git status`, `git diff`, type-check runs, build commands | Pre-approve — routine operations create exhaustion without adding safety |

**Claude Code** — add to `.claude/settings.local.json`:
```json
{
  "permissions": {
    "allow": [
      "Read",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git branch *)",
      "Bash(ls *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(bunx tsc --noEmit)",
      "Bash(bun run *)"
    ]
  }
}
```

**Gemini CLI** — configure read-only and build operations as pre-approved capability bundles in `policy.toml`. Keep `git push` and any write operations outside the pre-approved set.

The principle: pre-approve the noise so that when a real approval appears, it gets real attention.

---

## Agent Library

The template library ships roles across four categories. Copy the files you need into `.claude/agents/` and customize the persona names to fit your team.

**Strategic & Planning**

| File | Role | Function |
| :--- | :--- | :--- |
| `strategist.md` | Strategist | Upstream thinking partner — product strategy, market analysis, and idea generation before planning begins |
| `technical.md` | Technical Specialist | Consulted on complex technical tasks — reads codebase state, surfaces inline plan, hands off to a task agent |

**Quality Gates**

| File | Role | Function |
| :--- | :--- | :--- |
| `qa.md` | QA Specialist | Read-only quality gate — reads task agent sign-off and issues a verdict |
| `critic.md` | Critic | Adversarial review — APPROVED / CHALLENGED / BLOCKED verdict on ideas, plans, and content |

**Execution — Dev**

| File | Role | Function |
| :--- | :--- | :--- |
| `frontend.md` | Frontend Specialist | Implements UI components, interaction flows, and presentation logic — never touches backend or database |
| `backend.md` | Backend Specialist | Implements API routes, business logic, and server-side services — never touches frontend or schema |
| `database.md` | Database Specialist | Implements schema changes, migrations, and query logic — every change must be reversible |
| `mobile.md` | Mobile Specialist | Capacitor bridge, native permissions, push notifications, device token lifecycle, and native plugin integration |
| `ops.md` | Operations Specialist | Deployment, infrastructure, observability, runbook authorship, and incident response |

**Execution — Non-Dev**

| File | Role | Function |
| :--- | :--- | :--- |
| `pm.md` | Product Manager | Converts strategy into prioritized requirements — defines the What and When |
| `designer.md` | Design Specialist | UI/UX, design tokens, and component specs — two-phase: design tool approval then handoff artifacts |
| `marketing.md` | Marketing Specialist | Translates strategy into channel-specific copy and campaigns — never invents features |
| `researcher.md` | Researcher | Evidence-backed insights from user research synthesis, competitive analysis, and literature review |

> **Domain specialists:** a user picks the appropriate specialist per track. If a project uses individual domain specialists and a layer is uncovered, the orchestrator opens a new track for that layer rather than expanding an existing specialist's scope.

---

## Skill Library Reference

### Agent OS Skills

All skills below require Agent OS to be initialized via `install-agent-scaffold` or `onboard-existing-project` first.

**Setup**

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `install-agent-scaffold` | ✓ | ✓ | Full one-pass setup — new projects |
| `onboard-existing-project` | ✓ | ✓ | Reads first, generates context files — existing projects |

**Sprint**

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `start-sprint` | ✓ | — | Launch a sprint, set objective, create first track (Claude Code) |
| `open-sprint` | — | ✓ | Launch a sprint, set objective, create first track (Gemini CLI) |
| `report-track-status` | ✓ | ✓ | Situational status report across all active tracks |

**Execution**

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `add-specialist` | *(built-in)* | ✓ | Add a specialist agent to an existing team |
| `audit-deliverables` | *(built-in)* | ✓ | Binary PASS/BLOCKED verdict — dev and non-dev |

**Maintenance**

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `clean-context` | *(native)* | ✓ | Archive stale and completed items |
| `minify-context` | ✓ | ✓ | Compress verbose active context files |
| `index-memory` | *(native)* | ✓ | Long-term decision and milestone archival |
| `sync-design` | ✓ | ✓ | UI alignment with design tokens |

**Lifecycle**

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `check-agent-os` | ✓ | — | Health check — verifies skills, CLAUDE.md refs, docs, model names, WebFetch in agent tools, and specialist `isolation: worktree`; emits PASS/FAIL |
| `update-agent-os` | ✓ | — | Diffs installed skills against canonical manifest; installs, renames, or removes on confirmation |

---

### Standalone Skill Library

These skills work on any project — no Agent OS installation required.

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `audit-security` | ✓ | ✓ | Security sweep — vulnerabilities, secrets, policy violations |
| `sync-vercel-env` | ✓ | — | Reads `.env`, confirms an exclude list, then pushes remaining keys to Vercel (Production + Preview) |

> New skills that don't depend on the context files or sprint workflow belong in this library.

---

**Inspired by Google Conductor.**
*(c) 2026 DZNR VENTURES®*
