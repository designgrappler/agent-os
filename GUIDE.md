# Agent OS: Implementation Guide

This guide covers how to set up and operate Agent OS across different environments. For an overview of what Agent OS is and why it exists, start with the [README](./README.md).

**Two things in this repo:**
- **Agent OS** — scaffold installer + workflow skills that read from shared DNA files (`AGENTIC.md`, `plan.md`, `tracks.md`). Workflow skills require Agent OS to be installed first.
- **Standalone Skill Library** — general-purpose utilities that work on any project. Currently: `audit-security`. New skills that don't depend on Agent OS state belong here.

For a platform-agnostic explanation of the architecture, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Step 0: Which Tools Are You Using?

Agent OS is tool-agnostic at its core — the DNA files are plain Markdown, the roles are defined in text, and the workflow runs in any environment. Two patterns cover most setups: single model (one tool handles everything) and split model (one tool plans, another executes). We provide specific instructions for one validated example of each.

---

### Single Model — One Tool Handles Everything
*Example: VS Code + Claude Code*

Claude Code handles planning, execution, and review within a single IDE.

**How Agent OS maps:**
- Agent definitions live in `.claude/agents/` and are loaded via the chat interface — see [Agent Library](#agent-library) for the full role set
- `AGENTIC.md`, `plan.md`, and `tracks.md` are read automatically at session start
- The worktree protocol runs via the VS Code terminal

**Conversation hygiene:**
VS Code Copilot agents enforce fresh context by design — each agent is a new chat. Let it work: don't continue an Architect planning thread into execution. Switch agents, which switches conversations.

**Known gap:** There's no programmatic enforcement of when a user switches agents in the workflow. That discipline is on the user.

---

### Split Model — Planning Tool + Execution Tool
*Example: Antigravity (Gemini) + Claude Extension*

Gemini (via Antigravity's Agent Manager) owns planning and orchestration. Claude (via VS Code's Claude Extension) owns execution.

**How Agent OS maps:**
- Antigravity's Agent Manager is the visual equivalent of Agent OS's orchestration layer — spawn an Architect in one workspace, a Specialist in another
- The Handoff Bridge moves between the two tools — write it in Antigravity, paste it into Claude Extension to start execution
- `AGENTIC.md`, `plan.md`, and `tracks.md` live in the repo and are read by both agents from the same source
- Antigravity's parallel workspaces map directly to the worktree protocol — one workspace per active track
- Antigravity's inline artifact feedback works natively on Handoff Bridges and plan documents

**Conversation hygiene:**
Antigravity's Agent Manager enforces context isolation architecturally — each spawned agent runs in its own workspace. This is the strongest conversation hygiene of any setup described here.

**Why this combination works:**
Gemini's strength is planning, architecture, and structured reasoning across large context. Claude's strength is precise execution with strong instruction-following. Agent OS's role separation — Architect plans, Specialist executes, Critic gates — maps cleanly onto this model split.

**Known gaps:**
- AI tools evolve quickly — always check current documentation for the tools you're using, as features may have changed since this was written.
- Running the Critic role as a Gemini agent in Antigravity vs. Claude Extension is untested. Contributions welcome.
- Integration between Antigravity's knowledge base and Agent OS's DNA files is undocumented. Likely high-value — flagged as a gap pending exploration.

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

## Step 2: The 3-Tier Architecture

All roles — dev and non-dev — map to the same three tiers.

| Tier | Role | Responsibility | Tool Access |
| :--- | :--- | :--- | :--- |
| **Tier 1** | **Orchestration / Conductor** | Establishes project DNA and base context | Blocked from write/exec on source |
| **Tier 2** | **Strategic / Architect** | Plans, schedules, generates Handoff Bridges | Limited to context/docs writes |
| **Tier 3** | **Tactical / Specialist** | Executes declared deliverables — dev roles: `frontend`, `backend`, `database`, `fullstack`; non-dev: `designer`, `pm`, `marketing` | Scoped to Handoff Bridge deliverables |
| **Tier 3** | **Sentinel / Quality Gate** | Audits output, issues PASS/BLOCKED verdict | Read-only |

**Non-dev roles** (product manager, designer, marketing manager, etc.) use the same tier structure. The difference is the *type of deliverable* — documents, briefs, and designs instead of source files. The scope lock, Technical Handshake, and Quality Gate all apply equally.

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
3. **Step 2** — Run `/install-agent-scaffold` again. The skill reads your form, generates all files (`AGENTIC.md`, `CLAUDE.md`, agent definitions, `docs/context/` files, `.claude/settings.json`), then deletes `AgentOS-Setup.md`.

No interview questions — the form captures everything up front so generation runs in one clean pass.

---

## Step 4: The Sprint Workflow

Once initialized, the operational loop is:

```
Sprint Open → Plan → Handoff Bridge → Execute → Quality Gate → Sprint Close
```

| Step | Skill / Command | Trigger |
| :--- | :--- | :--- |
| Open sprint | `start-sprint` (Claude) / `open-sprint` (Gemini) | "Start planning" / "New sprint" |
| Check status | `report-track-status` | "Catch me up" / "Status check" |
| Generate handoff | `optimize-handoff` (Gemini) / *(native)* (Claude) | "Generate handoff for [specialist]" |
| Review output | `audit-deliverables` | "Run quality gate on [specialist]'s output" |
| Archive completed | `clean-context` (Gemini) / *(native)* (Claude) | "Clean context" |
| Compress active files | `minify-context` | "Minify context" |

`start-sprint` / `open-sprint` and `report-track-status` **auto-trigger** on natural language phrases — no explicit command needed when configured via the `CLAUDE.md` Auto-Invocations table (Claude Code) or the Trigger section of each skill (Gemini).

---

## Conversation Hygiene

Agent OS is designed to survive context decay — but it doesn't eliminate the need to manage conversations deliberately.

A long conversation accumulates drift. The model's earlier context gets compressed over time. Instructions read at session start carry less weight by message 40. This is a property of all LLMs, not a failure of Agent OS.

**Start a new conversation when:**
- Switching agents — Architect to Specialist, or any agent to the Critic for review
- A track closes and a new one opens
- You notice the agent referencing outdated state or contradicting earlier outputs
- After a circuit breaker fires — always start fresh after an escalation

**The Handoff Bridge as a reset mechanism**
The Handoff Bridge is not just a communication format — it's a context compression tool. A well-written Bridge contains everything the next agent needs to start clean. In Claude Code, handoffs are handled natively. In Antigravity, copy the Bridge into the new agent's workspace manually. In other environments, paste it into a new conversation rather than continuing the same thread.

**How different environments handle this**

| Environment | How context boundaries work |
| :--- | :--- |
| **VS Code (Copilot agents)** | Each agent is a new chat window — fresh context by design. Switch agents and you get a clean slate automatically. |
| **Antigravity (Agent Manager)** | Each spawned agent runs in its own workspace with its own context. The strongest isolation of any setup described here. |
| **Claude Code / Gemini CLI** | No automatic boundary. Start new conversations manually. Use Handoff Bridges when handing off between agents. |

**Practical hygiene (any environment)**
- Name conversations explicitly: "Track 2 — Planning", "Track 2 — Execution", "Track 2 — Review"
- One agent, one conversation. Never mix planning and execution in the same thread.
- If a conversation exceeds ~30 exchanges, treat it as a signal to close and start fresh with a Handoff Bridge.

---

## Step 5: Handoff Protocol

Before any Tier 3 Specialist begins work, the Architect generates a **Handoff Bridge** via `optimize-handoff` (Gemini) or natively in Claude Code. The bridge contains:

- **Role Identity** — who is waking and what domain they own
- **Specialist** — which domain specialist is assigned (frontend / backend / database / fullstack / designer / pm / marketing)
- **Execution Files (source)** — primary source/canonical files to modify
- **Execution Files (tests)** — test files in scope; `[]` with justification if none apply
- **Execution Files (tooling/config)** — build/config/scaffold files; `[]` if none
- **Migration Safety** — N/A / Reversible / Irreversible; Conductor sign-off required if irreversible
- **Security Review** — N/A / Auth / Payments / Schema; Conductor sign-off required if any
- **Worktree Setup** — automatic via `isolation: worktree` in Specialist frontmatter; manual worktree command only needed for the Architect's chicken-and-egg first run
- **Verification** — how to confirm the work is complete (pasted observed output required for Behavioral Verification Gate)
- **Circuit Breaker** — escalation threshold (3 same-cause failures → Architect)

### RELAY Mode (Claude Code or external model)
The Architect generates a fenced code block. Copy it into your external model to wake the Specialist with full context.

### GEMINI_ONLY Mode
The Architect generates a self-executing wake command: `gemini --skill add-specialist`

---

## Step 6: Security & Isolation

**Tier 1 & 2 (Architect-level)** skills are structurally restricted from modifying production source code or final deliverables. This is enforced at the runtime level — not through instructions alone:

- **Gemini CLI**: `policy.toml` strips unauthorized tools from the manifest
- **Claude Code**: `tools:` frontmatter list is enforced by the Claude Code runtime

**Parallel tracks** each get an isolated workspace via `isolation: worktree` in each Specialist's agent frontmatter — the Claude Code runtime creates and cleans up the worktree automatically. No manual worktree commands required.

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

The template library ships 11 roles across four categories. Copy the files you need into `.claude/agents/` and customize the persona names to fit your team.

**Strategic & Planning**

| File | Role | Tier | Function |
| :--- | :--- | :---: | :--- |
| `strategist.md` | Strategist | 2 | Pre-planning — validates assumptions, stress-tests framing before work is scheduled |
| `architect.md` | Lead Architect | 2 | Plans, Red Flag Analysis, Handoff Bridges — zero code |

**Quality Gates**

| File | Role | Tier | Function |
| :--- | :--- | :---: | :--- |
| `qa.md` | QA | 3 | Conformance gate — PASS / BLOCKED verdict against declared acceptance criteria |
| `critic.md` | Critic | 3 | Adversarial review — APPROVED / CHALLENGED / BLOCKED verdict on ideas, plans, and content |

**Execution — Dev**

| File | Role | Tier | Function |
| :--- | :--- | :---: | :--- |
| `fullstack.md` | Fullstack Specialist | 3 | All layers in one track — mutually exclusive with domain specialists on overlapping tracks |
| `frontend.md` | Frontend Specialist | 3 | Presentation layer only |
| `backend.md` | Backend Specialist | 3 | Server-side logic and API routes only |
| `database.md` | Database Specialist | 3 | Schema, migrations, and queries only |

**Execution — Non-Dev**

| File | Role | Tier | Function |
| :--- | :--- | :---: | :--- |
| `pm.md` | Product Manager | 3 | Requirements, user stories, acceptance criteria |
| `designer.md` | Design Specialist | 3 | UI/UX, design tokens, component specs |
| `marketing.md` | Marketing Specialist | 3 | Copy, positioning, campaign briefs |

> **Fullstack vs. domain specialists:** a user picks one or the other per track — not both. If a project uses individual domain specialists and a layer is uncovered, the Architect opens a new track for that layer rather than expanding an existing specialist's scope.

---

## Skill Library Reference

### Agent OS Skills

All skills below require Agent OS to be initialized via `install-agent-scaffold` or `onboard-existing-project` first.

**Setup**

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `install-agent-scaffold` | ✓ | ✓ | Full one-pass setup — new projects |
| `onboard-existing-project` | ✓ | ✓ | Reads first, generates DNA — existing projects |

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
| `optimize-handoff` | *(native)* | ✓ | Handoff Bridge generation |
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
| `check-agent-os` | ✓ | — | Health check — verifies skills, CLAUDE.md refs, docs, model names, WebFetch in agent tools, and Specialist `isolation: worktree`; emits PASS/FAIL |
| `refresh-agent-os` | ✓ | — | Diffs installed skills against canonical manifest; installs, renames, or removes on confirmation |

---

### Standalone Skill Library

These skills work on any project — no Agent OS installation required.

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `audit-security` | ✓ | ✓ | Security sweep — vulnerabilities, secrets, policy violations |
| `sync-vercel-env` | ✓ | — | Reads `.env`, confirms an exclude list, then pushes remaining keys to Vercel (Production + Preview) |

> New skills that don't depend on `AGENTIC.md`, `tracks.md`, or the Handoff Bridge workflow belong in this library.

---

## Blueprint Decomposition

Blueprint decomposition is a pattern for splitting a Handoff Bridge into discrete, independently-executed tasks. The Role Agent (Skylar, the Skills Engineer) decides whether to decompose when reading the Bridge: if the Bridge names two or more distinct Execution Files, or if it spans both code/config files and documentation files, decomposition is appropriate. Single-file tracks or naturally atomic tracks do not require it — monolithic execution is correct for those.

### How Skylar spawns Task Agents (Mechanic A)

Mechanic A is the only supported spawn path. When decomposing, the Role Agent:

1. Reads the blueprint file at `claude/blueprints/<name>.md`
2. Extracts the body — everything after the closing `---` of the YAML frontmatter
3. Composes a task prompt: the blueprint body plus a task-specific context block that names the Execution Files in scope, a one-sentence task description, the verification command, and any constraints specific to this invocation
4. Spawns the Agent tool with `subagent_type: task-executor` using the composed prompt

Each spawn handles exactly one logical task and returns structured output per the blueprint's Expected Output Contract. The Role Agent collects all Task Agent outputs, then synthesizes the Sign-Off and Task Agent Manifest for QA review.

Blueprints are Markdown templates, not registered subagents — attempting to use a blueprint name as `subagent_type` directly fails with an unknown-subagent error and is not supported.

### Blueprint discovery

Blueprints live at `claude/blueprints/<name>.md` in the repo. Current blueprints:

| Blueprint | Purpose |
| :--- | :--- |
| `task-coder` | Code edits — source file modifications and configuration changes |
| `task-writer` | Documentation authoring — structured Markdown file creation and revision |
| `task-researcher` | Read-only research — analysis and findings without file writes |

Each blueprint has YAML frontmatter (`name`, `description`, `tools`, `expected_output`, `model`, `schema_version`) and three required body sections: System Prompt Strategy, Expected Output Contract, and Allowed Tool Bindings — Reasoning.

---

**Inspired by Google Conductor.**
*(c) 2026 DZNR VENTURES®*
