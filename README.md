# Agent OS

If you've used AI agents for any serious project, you've probably hit the same wall: the agent starts confidently, makes progress, then slowly drifts — repeating itself, contradicting earlier decisions, or losing track of what it was supposed to do. On multi-step work with multiple agents, this compounds fast.

Agent OS makes that reliable. It gives every agent a defined role, a readable source of truth, and a quality gate before work is considered done. The governance layer is plain Markdown, so it runs inside whatever tool you're already using.

**Who it's for:** Anyone using AI agents who wants their work to stop going sideways. The pattern works for development, writing, research, design, and operations.

**What it's not:** A replacement for your AI tool. It runs alongside Claude, Gemini, or any model you're already using.

---

## How It Works

**1. Shared memory your agents can trust**
Agent OS creates plain Markdown context files every agent reads at the start of each session. For persistent projects, `product.md` carries the long-lived context. For one-off tasks, `task.md` carries the scoped brief. State lives in files, not conversation history — which is what keeps agents consistent across sessions and context resets.

**2. Roles with real constraints**
Each agent has a defined role and can only use the tools that role allows. An orchestrator routes and plans but never executes on your files. A QA specialist reviews but cannot write. Roles don't drift because they structurally can't.

**3. A quality gate before work ships**
No task is complete until a dedicated QA specialist reviews it and issues a binary verdict: approved or blocked. QA is read-only by design, so it can't fix what it finds — problems go back to the specialist before anything ships.

**4. External tools via connectors**
Skills declare what external tools they need. The orchestrator checks your connector registry at `~/.claude/connectors.md` and prompts to connect any missing tools before the skill runs.

For a full explanation of each part, see [CONCEPTS.md](./CONCEPTS.md).

---

## Quick Start

Tell your AI:

> "Install Agent OS on this project: https://github.com/designgrappler/agent-os"

Your AI fetches the install skill from the repo and runs it. For new projects it scaffolds everything from scratch; for existing projects it reads what you already have and won't overwrite files without your approval. After install completes, your project has context files in place and agent definitions ready — open a new conversation and tell your orchestrator what you want to work on.

For setup details and IDE-specific paths, see the [Implementation Guide](./GUIDE.md).

---

## Technical Reference

- [Concepts](./CONCEPTS.md) — core concepts: orchestrator, specialists, QA gate, context files
- [Implementation Guide](./GUIDE.md) — setup, IDE paths, available skills, security and isolation
- [System Architecture](./ARCHITECTURE.md) — the five layers, key protocols, and reliability model
- [Contributing](./CONTRIBUTING.md) — adding skills, validating new environments, expanding agent types

---
*(c) 2026 DZNR VENTURES®*
