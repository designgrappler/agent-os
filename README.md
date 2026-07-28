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
Each agent has a defined role and can only use the tools that role allows. An orchestrator routes and plans but never executes on your files. A QA specialist reviews but cannot write. This isn't a rule you ask them to follow — it's enforced at the runtime level. Roles don't drift because they structurally can't. The template library covers both dev and non-dev team functions: planning, execution, QA, design, product, strategy, and marketing. See [Agent Library](./GUIDE.md#agent-library) in the Implementation Guide.

**3. A quality gate before work ships**
No task is complete until a dedicated QA specialist reviews it and issues a binary verdict: approved or blocked. QA is read-only by design — it can't fix what it finds, which means problems have to go back to the specialist before anything ships. This independent checkpoint is what stops bad work from compounding.

Agent OS adapts to how work is structured: **single-task** for one-off jobs, **multi-agent** for work that spans several roles, and **sprint** for complex multi-track projects. The same three-part backbone — shared context, defined roles, quality gate — holds in every mode.

---

## Conversation Hygiene

A long AI conversation accumulates drift — earlier instructions carry less weight as the conversation grows. Agent OS is designed to survive this, but good habits make it more reliable.

**Start a new conversation when:**
- Switching from planning to execution, or from execution to review
- Opening a new piece of work
- A task finishes and a new one begins
- Something goes consistently wrong — always start fresh after a failure

**A new session is your reset.** Because state lives in files, nothing is lost when you start fresh: agents read the context files (`product.md`, `plan.md`, `tracks.md`) at the start of every session and pick up exactly where the work stands.

For a one-line fix, skip the ceremony. For anything that touches multiple areas, involves multiple agents, or needs to survive a context reset — the structure pays for itself.

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
Gemini (via Antigravity's Agent Manager) handles planning and orchestration. Claude (via VS Code's Claude Extension) handles execution. Work moves between them through the shared Markdown context files, which both tools read.
→ [Split model setup in the Implementation Guide](./GUIDE.md#split-model--planning-tool--execution-tool)

Using a different combination? The two patterns above cover most setups — use them as a reference for adapting to your tools. [See other environments →](./GUIDE.md#other-environments)

---

## 🗺️ Agent OS Skills

Skills are organized by phase and map to a stage in the workflow. All are invoked as slash commands in Claude Code.

### Setup
Run once to initialize Agent OS on your project.

| Goal                     | Command                       |
| :----------------------- | :---------------------------- |
| Scaffold new project     | `/install-agent-scaffold`     |
| Onboard existing project | `/onboard-existing-project`   |

### Sprint
Define and track a unit of work. A sprint is a focused period with a clear objective and one or more active tasks (tracks).

| Goal                     | Command             |
| :----------------------- | :------------------ |
| Open a sprint            | `/start-sprint`     |
| Check track status       | `/track-status`     |
| Close a completed track  | `/track-close`      |
| Close the sprint         | `/close-sprint`     |

### Context & Maintenance
Keep the system healthy. Archive completed work and compress context files.

| Goal                     | Command             |
| :----------------------- | :------------------ |
| Clean context            | `/clean-context`    |
| Compress active context  | `/minify-context`   |

### Lifecycle
Keep your Agent OS installation healthy and up to date.

| Goal                     | Command             |
| :----------------------- | :------------------ |
| Health check             | `/check-agent-os`   |
| Update installed skills  | `/update-agent-os`  |
| Scaffold a new agent     | `/create-agent`     |

### Feedback
Improve Agent OS itself.

| Goal                     | Command                       |
| :----------------------- | :---------------------------- |
| Submit feedback upstream | `/submit-agent-os-feedback`   |
| Triage collected feedback| `/triage-feedback`            |

> The orchestrator skill loads automatically at session start to handle triage and routing — it is not invoked directly.

---

## 🧰 Standalone Skill Library

These skills work on any project — no Agent OS installation required.

| Skill | Purpose |
| :--- | :--- |
| [`audit-security`](./skills/audit-security/SKILL.md) | Security sweep — scans for vulnerabilities, hardcoded secrets, and policy violations |
| [`streamline-approvals`](./skills/streamline-approvals/SKILL.md) | Scans transcripts, builds a read-only allowlist, writes it to `.claude/settings.json`, enables VS Code Auto mode |
| [`sync-vercel-env`](./skills/sync-vercel-env/SKILL.md) | Syncs local environment variables to a Vercel project |

> This library grows independently of Agent OS. Skills that don't depend on shared DNA state belong here.

---

## 🧩 Technical Reference

- [Implementation Guide](./GUIDE.md) — setup, IDE paths, conversation hygiene, security & isolation
- [System Architecture](./ARCHITECTURE.md) — the five layers, key protocols, and reliability model
- [Contributing](./CONTRIBUTING.md) — adding skills, validating new environments, expanding agent types

---

*(c) 2026 DZNR VENTURES®*
