# Agent OS

If you've used AI agents for any serious project, you've probably hit the same wall: the agent starts confidently, makes progress, then slowly drifts — repeating itself, contradicting earlier decisions, or losing track of what it was supposed to do. On multi-step work with multiple agents, this compounds fast.

Agent OS is our take on making that reliable. It's a workflow that gives every agent a defined role, a readable source of truth, and a quality gate before work is considered done. It runs inside whatever tool you're already using — VS Code, Antigravity, any CLI — because the governance layer is plain Markdown, not platform-specific.

**Who it's for:** Anyone already using AI agents who wants their work to stop going sideways. Not just developers — the same pattern works for writing, research, design, and operations. If your project has a clear pattern of work and a desired outcome, Agent OS fits.

**What it's not:** A replacement for your AI tool. It runs alongside Claude, Gemini, or any model you're already using.

---

## How It Works

**1. Shared memory your agents can trust**
Agent OS creates a set of plain Markdown files — your project description, active work, and team setup — that every agent reads at the start of each session. This is what keeps agents consistent across conversations. Context lives in files, not in conversation history.

**2. Roles with real constraints**
Each agent has a defined role and can only use the tools that role allows. An Architect plans but cannot touch your files. A Critic reviews but cannot write. This isn't a rule you ask them to follow — it's enforced at the runtime level. Roles don't drift because they structurally can't. The template library covers both dev and non-dev team functions: planning, execution, QA, design, product, strategy, and marketing. See [Agent Library](./GUIDE.md#agent-library) in the Implementation Guide.

**3. A quality gate before work ships**
No task is complete until a dedicated QA reviews it and issues a binary verdict: PASS or BLOCKED. QA is read-only by design — it can't fix what it finds, which means problems have to go back to the specialist before anything ships. This is the checkpoint that stops bad work from compounding.

---

## Conversation Hygiene

A long AI conversation accumulates drift — earlier instructions carry less weight as the conversation grows. Agent OS is designed to survive this, but good habits make it more reliable.

**Start a new conversation when:**
- Switching from planning to execution, or from execution to review
- Opening a new piece of work
- A task finishes and a new one begins
- Something goes consistently wrong — always start fresh after a failure

**The Handoff Bridge is your reset tool.** When passing work from one agent to another, the system generates a structured summary of everything the next agent needs to start clean. In Claude Code this happens natively. In Antigravity, copy the Bridge into the new agent's workspace manually.

For a one-line fix, skip the protocol. For anything that touches multiple areas, involves multiple agents, or needs to survive a context reset — the structure pays for itself.

---

## 🚀 Quick Start

Tell your AI:

> "Install Agent OS on this project: https://github.com/designgrappler/agent-os"

That's it. Your AI fetches the install skill from the repo and runs it. For new projects it scaffolds everything from scratch; for existing projects it reads what you already have and won't overwrite files without your approval.

For setup details and IDE-specific paths, see the [Implementation Guide](./GUIDE.md).

---

## Your Setup

Agent OS runs inside the tools you're already using. We provide specific setup instructions for two patterns — single model and split model — with one validated example of each.

**Single model — VS Code + Claude Code**
Claude Code manages planning, execution, and review within a single IDE. Agent definitions live in `.claude/agents/` and are invoked directly from the chat interface.
→ [Single model setup in the Implementation Guide](./GUIDE.md#single-model--one-tool-handles-everything)

**Split model — Antigravity + Claude Extension**
Gemini (via Antigravity's Agent Manager) handles planning and orchestration. Claude (via VS Code's Claude Extension) handles execution. The Handoff Bridge moves work between them.
→ [Split model setup in the Implementation Guide](./GUIDE.md#split-model--planning-tool--execution-tool)

Using a different combination? The two patterns above cover most setups — use them as a reference for adapting to your tools. [See other environments →](./GUIDE.md#other-environments)

---

## 🗺️ Agent OS Skills

Skills are organized by phase and map to a stage in the workflow.

### Setup
Run once to initialize Agent OS on your project. Generates the DNA files and agent definitions.

| Goal                     | Claude Code                   | Gemini CLI                   |
| :----------------------- | :---------------------------- | :--------------------------- |
| Scaffold new project     | `/install-agent-scaffold`     | `install-agent-scaffold`     |
| Onboard existing project | `/onboard-existing-project`   | `onboard-existing-project`   |

### Sprint
Define and track a unit of work. A sprint is a focused period with a clear objective and one or more active tasks (tracks).

| Goal                     | Claude Code                   | Gemini CLI                   |
| :----------------------- | :---------------------------- | :--------------------------- |
| Open a sprint            | `/start-sprint`               | `open-sprint`                |
| Check track status       | `/report-track-status`        | `report-track-status`        |

### Execution
The active work phase. Generate handoffs for specialists, run work, and review output before it's considered done.

| Goal                     | Claude Code                   | Gemini CLI                   |
| :----------------------- | :---------------------------- | :--------------------------- |
| Add specialist agent     | *(built-in)*                  | `add-specialist`             |
| Optimize handoff         | *(native)*                    | `optimize-handoff`           |
| Audit deliverables       | *(built-in)*                  | `audit-deliverables`         |

### Maintenance
Keep the system healthy. Archive completed work, compress context files, and sync state between sessions.

| Goal                     | Claude Code                   | Gemini CLI                   |
| :----------------------- | :---------------------------- | :--------------------------- |
| Clean context            | *(native)*                    | `clean-context`              |
| Compress active context  | `/minify-context`             | `minify-context`             |
| Index memory             | *(native)*                    | `index-memory`               |
| Sync design              | `/sync-design`                | `sync-design`                |

### Lifecycle
Keep your Agent OS installation healthy and up to date.

| Goal                     | Claude Code                   | Gemini CLI                   |
| :----------------------- | :---------------------------- | :--------------------------- |
| Health check             | `/check-agent-os`             | —                            |
| Refresh installed skills | `/refresh-agent-os`           | —                            |

> **Claude Code** handles handoff generation, context cleanup, and specialist onboarding natively. **Gemini CLI** uses explicit skills for each operation.

---

## 🧰 Standalone Skill Library

These skills work on any project — no Agent OS installation required.

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| [`audit-security`](./skills/audit-security/SKILL.md) | ✓ | ✓ | Security sweep — scans for vulnerabilities, hardcoded secrets, and policy violations |
| [`streamline-approvals`](./skills/streamline-approvals/SKILL.md) | ✓ | — | Scans transcripts, builds a read-only allowlist, writes it to `.claude/settings.json`, enables VS Code Auto mode |

> This library grows independently of Agent OS. Skills that don't depend on shared DNA state belong here.

---

## 🧩 Technical Reference

- [Implementation Guide](./GUIDE.md) — setup, IDE paths, conversation hygiene, security & isolation
- [System Architecture](./ARCHITECTURE.md) — the five layers, key protocols, and reliability model
- [Contributing](./CONTRIBUTING.md) — adding skills, validating new environments, expanding agent types

---

*(c) 2026 DZNR VENTURES®*
