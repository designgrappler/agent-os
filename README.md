# Agent OS (v1.0)

Agent OS is a multi-agent workflow system for **Claude** (Claude Code) and **Gemini** (Gemini CLI). It is not a collection of independent prompts — it is a coordinated system where agents share a common state and hand work off to each other in a defined sequence.

When you install Agent OS, it creates a set of **DNA files** (`AGENTIC.md`, `plan.md`, `tracks.md`) that define your project, team, and active work. Every workflow skill reads from and writes to this shared state. This is what makes the system coherent — agents don't lose context between sessions because the context lives in files, not in conversation history.

**This repository contains two things:**

1. **Agent OS** — the full workflow system. A scaffold installer plus a set of skills that operate on the shared DNA state. These skills only work once Agent OS is installed.
2. **Standalone Skill Library** — general-purpose utilities that work on any project, with or without Agent OS. A growing collection — new skills that don't require Agent OS state belong here.

---

## 🚀 Quick Start

| Situation | Action |
|---|---|
| **New project** | Run `install-agent-scaffold` (Gemini) or `/install-agent-scaffold` (Claude Code) |
| **Existing project** | Run `onboard-existing-project` (Gemini) or `/onboard-existing-project` (Claude Code) — reads your project first |

> ⚠️ **Existing project?** Run `onboard-existing-project` before anything else. It discovers your stack, pre-fills the interview with what it finds, and will not overwrite files without your approval. `install-agent-scaffold` assumes a blank slate.

---

## 🗺️ Agent OS Skills

All skills below the Setup phase require Agent OS to be initialized first.

| Phase | Goal | Claude Code | Gemini CLI |
| :--- | :--- | :--- | :--- |
| **Setup** | Scaffold new project | `install-agent-scaffold` | `install-agent-scaffold` |
| **Setup** | Onboard existing project | `onboard-existing-project` | `onboard-existing-project` |
| **Sprint** | Open a sprint | `open-sprint` | `open-sprint` |
| **Sprint** | Check track status | `report-track-status` | `report-track-status` |
| **Execution** | Add specialist agent | *(built-in)* | `add-specialist` |
| **Execution** | Optimize handoff | *(native)* | `optimize-handoff` |
| **Execution** | Audit deliverables | `audit-deliverables` | `audit-deliverables` |
| **Maintenance** | Clean context | *(native)* | `clean-context` |
| **Maintenance** | Compress active context | `minify-context` | `minify-context` |
| **Maintenance** | Index memory | *(native)* | `index-memory` |
| **Maintenance** | Sync design | `sync-design` | `sync-design` |

> **Claude Code** handles handoff generation, context cleanup, and specialist onboarding natively. **Gemini CLI** uses explicit skills for each operation.

---

## 🧰 Standalone Skill Library

These skills work on any project — no Agent OS installation required.

| Skill | Claude Code | Gemini CLI | Purpose |
| :--- | :---: | :---: | :--- |
| `audit-security` | ✓ | ✓ | Security sweep — scans for vulnerabilities, hardcoded secrets, and policy violations |

> This library grows independently of Agent OS. Skills that don't depend on `AGENTIC.md`, `tracks.md`, or the Handoff Bridge workflow belong here.

---

## 📦 Platform Implementations

The same concepts run on two runtimes. The enforcement mechanisms differ.

### Gemini CLI (`skills/`)
Uses the **Gemini CLI Policy Engine** (`policy.toml`) for structural tool masking. Skills deployed via `gemini skills install`.

**Setup skills:**
| Skill | Purpose |
| :--- | :--- |
| [install-agent-scaffold](./skills/install-agent-scaffold/SKILL.md) | One-pass OS initialization — new projects |
| [onboard-existing-project](./skills/onboard-existing-project/SKILL.md) | Reads first, generates DNA files — existing projects |

**Sprint skills:**
| Skill | Purpose |
| :--- | :--- |
| [open-sprint](./skills/open-sprint/SKILL.md) | Launch a new sprint with clean setup |
| [report-track-status](./skills/report-track-status/SKILL.md) | Situational status report — all active tracks |

**Execution skills:**
| Skill | Purpose |
| :--- | :--- |
| [add-specialist](./skills/add-specialist/SKILL.md) | Add a new specialist agent to an existing team |
| [optimize-handoff](./skills/optimize-handoff/SKILL.md) | Structured Handoff Bridge generation |
| [audit-deliverables](./skills/audit-deliverables/SKILL.md) | Binary PASS/BLOCKED verdict — dev and non-dev |

**Maintenance skills:**
| Skill | Purpose |
| :--- | :--- |
| [clean-context](./skills/clean-context/SKILL.md) | Archive stale and completed items |
| [minify-context](./skills/minify-context/SKILL.md) | Compress verbose active context files |
| [index-memory](./skills/index-memory/SKILL.md) | Long-term decision and milestone archival |
| [sync-design](./skills/sync-design/SKILL.md) | UI alignment with design tokens |

**Standalone:**
| Skill | Purpose |
| :--- | :--- |
| [audit-security](./skills/audit-security/SKILL.md) | Security sweeps — works on any project |

```bash
# Install Gemini CLI, then deploy Agent OS:
gemini skills install https://github.com/designgrappler/agent-skills --path skills/install-agent-scaffold
```

---

### Claude Code (`claude/`)
Uses **Claude Code's `.claude/agents/` system** with `tools:` frontmatter enforcement and `settings.json` hooks. See [`claude/README.md`](./claude/README.md) for platform differences.

**Skill files** (copy to `.claude/skills/` in your project):
| Skill | Purpose |
| :--- | :--- |
| [install-agent-scaffold](./claude/skills/install-agent-scaffold.md) | One-pass OS initialization — new projects |
| [onboard-existing-project](./claude/skills/onboard-existing-project.md) | Reads first, generates DNA files — existing projects |
| [open-sprint](./claude/skills/open-sprint.md) | Launch a new sprint with clean setup |
| [report-track-status](./claude/skills/report-track-status.md) | Situational status report |
| [minify-context](./claude/skills/minify-context.md) | Compress active context files |

**Agent templates** (copy to `.claude/agents/` in your project):
| Template | Purpose |
| :--- | :--- |
| [architect](./claude/agents/architect.md) | Lead Architect — zero-code, Opus model |
| [specialist](./claude/agents/specialist.md) | Specialist template — rename per domain |
| [critic](./claude/agents/critic.md) | QA Critic — read-only, binary gate |

**DNA templates:**
| Template | Purpose |
| :--- | :--- |
| [AGENTIC.md](./claude/templates/AGENTIC.md) | Static DNA starter |
| [CLAUDE.md](./claude/templates/CLAUDE.md) | Orchestrator config starter |

**Setup:** Copy `claude/skills/install-agent-scaffold.md` to `.claude/skills/` and run `/install-agent-scaffold`. Existing project? Use `onboard-existing-project` instead.

---

## 🧩 The Core Framework

- **[System Architecture](./ARCHITECTURE.md)**: Framework-agnostic reference — the five layers, key protocols, and reliability model.
- **[Product Strategy](./context/product.md)**: The vision of **Mechanical Predictability**.
- **[Technical Spec](./context/techstack.md)**: Requirements for **Structural Policy Gates**.
- **[Team Hierarchy](./context/team.md)**: The **Enforceable 3-Tier model**.
- **[Project Evolution](./EVOLUTION.md)**: The journey from "Instructional Governance" to "Hardware-Locked Roles."
- **[Implementation Guide](./GUIDE.md)**: How to integrate Agent OS into your workspace.

---

*(c) 2026 DZNR VENTURES®*
