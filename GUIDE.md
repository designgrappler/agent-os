# Agent OS: Getting Started

This guide covers your first session and common use cases. For what Agent OS is and why it exists, see [README.md](./README.md). For how each part works, see [CONCEPTS.md](./CONCEPTS.md).

---

## Part 1: Your first session

Mia is a PM working on a new feature. She wants to understand how three competitors handle onboarding before writing her requirements.

She opens a session with the orchestrator and says: "I need a competitive analysis of how Notion, Linear, and Figma handle new user onboarding."

The orchestrator reads the context files — it already knows the product and the work in progress — and routes the request to the researcher. The researcher reads `product.md`, studies the three competitors, and produces a synthesis: what each does, what patterns appear across all three, and where the opportunity is. Before the analysis reaches Mia, the QA specialist reads it against the original request. Does it cover all three competitors? Does it answer the questions asked? QA approves.

Mia receives a reviewed analysis. She did not re-explain the product. She did not have to check whether the work was complete.

**That is what a session looks like.** State your goal. The orchestrator reads your context files — `product.md`, `plan.md`, `tracks.md` — determines what kind of work this is, and routes it to the right specialist. You do not pick the specialist manually. When the specialist finishes, QA reviews the output before it reaches you.

### Install

Tell your AI:

> "Install Agent OS on this project: https://github.com/designgrappler/agent-os"

The install skill runs in two steps:

1. A setup form (`AgentOS-Setup.md`) is created at your project root. Fill in your project name, team members, and tech stack or toolset. The form also includes a connectors table — declare any external tools (Google Workspace, Figma, etc.) you want available at install time.
2. Run the install command again. The skill reads your form and generates all project files: agent definitions in `.claude/agents/`, context files in `docs/context/` (`product.md`, `plan.md`, `tracks.md`), and a `CLAUDE.md` that connects everything.

**Existing project?** Use the onboard path: `"Onboard Agent OS on this existing project: https://github.com/designgrappler/agent-os"` — it reads what you already have and will not overwrite files without your approval.

Once installed, start by stating your goal. The orchestrator handles the rest.

---

## Part 2: Common Use Cases

### Tasks — one-off deliverables

**Research or competitive analysis**
State what you want to know and which sources to cover. The orchestrator routes to the researcher, who reads `product.md` and produces a structured synthesis. QA verifies coverage and completeness before it reaches you.

> "Give me a competitive analysis of how Notion, Linear, and Figma handle new user onboarding."

**Written content — article, brief, campaign copy**
State the goal, audience, and channel. If the content depends on research, the orchestrator runs a research track first and passes the approved output to the writer. QA reviews the result against the original brief.

> "Write a product announcement for our new analytics feature. Audience: existing power users. Channel: email."

**Code feature**
Describe what you need built and where it lives. The orchestrator routes to the appropriate specialist (frontend, backend, or full-stack). QA reviews the implementation against the stated requirements.

> "Add a CSV export button to the reports table. It should download the current filtered view."

### Projects — ongoing work

**Design sprint**
State the brief: goal, user, constraints. The orchestrator routes to the designer. The designer produces multiple distinct directions — directions are not merged or averaged. QA verifies they match the brief and are genuinely distinct. You review approved directions and select one.

**Feature build**
For larger features with multiple moving parts, the orchestrator decomposes the work into tracks — research, design, implementation, review — and routes each to the appropriate specialist. Tracks run in sequence or in parallel depending on dependencies. You check in at each gate.

**Marketing campaign**
State the campaign objective, audience, and channels. The orchestrator opens a strategy track, then a research track if competitive context is needed, then routes to the marketing specialist for copy and channel execution. QA gates each stage.

---

## Part 3: Workflow Configurations

### Sprint workflow

Use the sprint workflow when you have multiple tracks of work running in parallel or sequence and want to track what is open, in progress, blocked, and done.

1. Invoke `/start-sprint`. The orchestrator asks for the sprint objective and creates the first track.
2. Each track routes to the appropriate specialist. Specialists update `tracks.md` as work progresses.
3. Check status at any point: "What is the current status?" — the orchestrator reads `tracks.md` and reports.
4. When all tracks are approved by QA, close the sprint: `/close-sprint`. The orchestrator archives the plan, bumps the version, and resets for the next sprint.

---

### VS Code + Claude Code

Claude Code manages planning, execution, and review in a single IDE. Agent definitions live in `.claude/agents/` and are loaded via the chat interface.

**Prerequisites:** Claude Code installed (`npm install -g @anthropic-ai/claude-code`), a git-initialized repo, root-level write access.

**Conversation hygiene:** Switch agents — orchestrator to specialist, or any specialist to QA — by starting a new chat. Context carries forward through the shared files, not the conversation history.

**Pre-approve routine operations** to reduce approval fatigue. Add to `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(ls *)",
      "Bash(grep *)",
      "Bash(bun run *)"
    ]
  }
}
```

Pre-approve the routine so that real approval prompts get real attention.

---

### Other environments

Agent OS works in any environment that supports reading Markdown files at session start and role-scoped agents with tool restrictions. See [CONTRIBUTING.md](./CONTRIBUTING.md) for setup patterns and how to contribute a new environment configuration.

---

## Part 4: Skills reference

Skills are commands you invoke directly in Claude Code. They extend the default agent behavior with structured multi-step protocols — install routines, sprint lifecycle management, connector setup, maintenance, and more. You never need to remember the steps; the skill handles them.

### Setup

Get Agent OS running on a new or existing project, and scaffold new agents.

| Skill | Description |
|---|---|
| `install-agent-scaffold` | Full one-pass setup for new projects |
| `onboard-existing-project` | Reads your existing project; generates context files without overwriting |
| `create-agent` | Scaffold a new agent file interactively |

### Workflow management

Run and track sprint-based work.

| Skill | Description |
|---|---|
| `start-sprint` | Launch a sprint, set objective, create first track |
| `close-sprint` | Close a sprint, archive completed work, bump version |
| `track-status` | Quick status summary of open sprint tracks |
| `track-close` | Close a single track and mark it done |

### Connectors

Wire up external tools to Claude Code via MCP.

| Skill | Description |
|---|---|
| `setup-connector` | Reads a connector config file and writes MCP entries to `~/.claude/settings.json`. Run `/setup-connector <name>` after filling in `docs/context/connectors/<name>.md`. |

### Maintenance

Keep Agent OS healthy and your context files lean.

| Skill | Description |
|---|---|
| `check-agent-os` | Verify Agent OS installation is healthy and up to date |
| `update-agent-os` | Diff installed skills against canonical manifest; update on confirmation |
| `clean-context` | Archive stale and completed context items |
| `minify-context` | Compress verbose active context files |
| `streamline-approvals` | Reduce approval prompt volume by building a pre-approved allowlist |

### Standalone

These skills work without an Agent OS installation.

| Skill | Description |
|---|---|
| `audit-security` | Security sweep: vulnerabilities, secrets, policy violations |
| `sync-vercel-env` | Sync local environment variables to Vercel |
| `submit-agent-os-feedback` | Submit feedback about Agent OS |
| `editorial-review` | Review written content against editorial standards |

---

*(c) 2026 DZNR VENTURES®*
