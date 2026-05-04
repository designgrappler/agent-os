# Agent OS (v1.0)

A curated library of surgical, high-fidelity capabilities for an **Agent Operating System** designed for use with **Claude** (via Claude Code) and **Gemini** (via Gemini CLI). This repository establishes the standard for reliable, multi-agent orchestration through **Structural Enforcement** and **Atomic State Management.**

---

## 🚀 Quick Start

**Choose your path:**

| Situation | Action |
|---|---|
| **New project** (no existing files) | Run `install-agent-scaffold` (Gemini) or `/install-agent-scaffold` (Claude Code) |
| **Existing project** (code already written) | Run `project-adopt` (Gemini) or `/project-adopt` (Claude Code) — reads your project first |

> ⚠️ **Existing project?** Run `project-adopt` *before* any other setup skill. It discovers your stack, pre-fills the interview with what it finds, and will not overwrite existing files without your approval. Starting with `install-agent-scaffold` on an existing project will treat it as a blank slate.

---

## 🧩 The Core Framework
This library is more than a set of prompts; it is a **Technical System Specification** designed for professional agentic workflows.

- **[System Architecture](./ARCHITECTURE.md)**: Framework-agnostic reference — the five layers, key protocols, and reliability model.
- **[Product Strategy](./context/product.md)**: The vision of **Mechanical Predictability**.
- **[Technical Spec](./context/techstack.md)**: Requirements for **Structural Policy Gates**.
- **[Team Hierarchy](./context/team.md)**: The **Enforceable 3-Tier model** (Orchestration, Strategic, Tactical).
- **[Project Evolution](./EVOLUTION.md)**: The journey from "Instructional Governance" to "Hardware-Locked Roles."
- **[Implementation Guide](./GUIDE.md)**: How to integrate Agent OS into your workspace.

## 🚀 Key Architectural Pillars (v1.0)
1.  **Structural Enforcement**: Professional-grade role discipline via physical tool locking — tools are removed from agent manifests, not just prohibited in prompts.
2.  **Atomic Context Heartbeats**: Zero context-bloat by scoping each agent to only the DNA it needs for its role.
3.  **Global Task Ledger**: Intent carried via persistent state rather than narrative history.

---

## 🗺️ Cross-Platform Skill Map

| Goal | Claude Code | Gemini CLI |
| :--- | :--- | :--- |
| Scaffold new project + team | `install-agent-scaffold` | `install-agent-scaffold` |
| Onboard existing project | `project-adopt` | `project-adopt` |
| Add specialist agent | *(built-in)* | `add-specialist` |
| Open a sprint | `sprint-open` | `sprint-open` |
| Check track status | `track-status` | `track-status` |
| Optimize handoff | *(native)* | `optimize-handoff` |
| Clean context | *(native)* | `clean-context` |
| Compress active context | `minify-context` | `minify-context` |
| Long-term archival | *(native)* | `memory-indexer` |
| Security sweep | `security-audit` | `security-audit` |
| Design token audit | `design-sync` | `design-sync` |
| Quality gate | `quality-gate` | `quality-gate` |

> **Claude Code** handles handoff generation, context cleanup, and specialist onboarding natively — no skill file required. **Gemini CLI** uses explicit skills for each operation via `gemini skills install`.

---

## 📦 Platform Implementations

The Conductor architecture is implemented for two runtimes. The concepts are identical; the enforcement mechanisms differ.

### Gemini CLI (`skills/`)
Uses the **Gemini CLI Policy Engine** (`policy.toml`) for structural tool masking. Skills are deployed via `gemini skills install`.

| Skill | Tier | Mission |
| :--- | :--- | :--- |
| [install-agent-scaffold](./skills/install-agent-scaffold/SKILL.md) | 1 | One-click OS initialization — **new projects** |
| [Project Adopt](./skills/project-adopt/SKILL.md) | 1 | Onboard an **existing project** — reads first, never blindly overwrites |
| [add-specialist](./skills/add-specialist/SKILL.md) | 1 | Add a new specialist agent to an existing team |
| [optimize-handoff](./skills/optimize-handoff/SKILL.md) | 2 | Structured Handoff Bridge generation |
| [Sprint Open](./skills/sprint-open/SKILL.md) | 2 | Launch a new sprint with clean setup |
| [Track Status](./skills/track-status/SKILL.md) | 2 | Situational status report — all active tracks |
| [clean-context](./skills/clean-context/SKILL.md) | 3 | Archive stale and completed items |
| [Minify Context](./skills/minify-context/SKILL.md) | 2 | Compress verbose active context files |
| [Memory Indexer](./skills/memory-indexer/SKILL.md) | 3 | Long-term decision and milestone archival |
| [Security Audit](./skills/security-audit/SKILL.md) | 3 | Security sweeps and structural policy audit |
| [Design Sync](./skills/design-sync/SKILL.md) | 3 | UI alignment with design tokens |
| [Quality Gate](./skills/quality-gate/SKILL.md) | 3 | Binary PASS/BLOCKED verdict — dev and non-dev |

**Setup:**
```bash
# Install Gemini CLI, then deploy the full bundle:
gemini skills install https://github.com/designgrappler/agent-skills --path skills/install-agent-scaffold
```

---

### Claude Code (`claude/`)
Uses **Claude Code's `.claude/agents/` system** for agent definitions with `tools:` frontmatter enforcement, and `settings.json` hooks for pre-push build gates. See [`claude/README.md`](./claude/README.md) for platform differences.

| Component | Purpose |
| :--- | :--- |
| [install-agent-scaffold](./claude/skills/install-agent-scaffold.md) | Bootstraps a full Claude Code project from scratch — **new projects** |
| [project-adopt](./claude/skills/project-adopt.md) | Onboard an **existing project** — reads first, never blindly overwrites |
| [architect](./claude/agents/architect.md) | Lead Architect template — zero-code, Opus model |
| [specialist](./claude/agents/specialist.md) | Generic Specialist template — rename per domain |
| [critic](./claude/agents/critic.md) | QA Critic template — read-only, binary gate |
| [AGENTIC.md template](./claude/templates/AGENTIC.md) | Fill-in-the-blanks Static DNA starter |
| [CLAUDE.md template](./claude/templates/CLAUDE.md) | Fill-in-the-blanks orchestrator config starter |

**Setup:**
Copy `claude/skills/install-agent-scaffold.md` to `.claude/skills/install-agent-scaffold.md` in your project, then run `/install-agent-scaffold`. The skill prompts for project details and generates all files.

**Existing project?** Copy `claude/skills/project-adopt.md` to `.claude/skills/project-adopt.md` and run `/project-adopt` instead.

---

## 📚 Conceptual Reference

For a platform-agnostic explanation of why this system works — the five layers, key protocols (Handoff Bridge, Technical Handshake), the DNA taxonomy, and the reliability model — see **[ARCHITECTURE.md](./ARCHITECTURE.md)**.

---

**Inspired by Google Conductor.**
*(c) 2026 DZNR VENTURES®*
