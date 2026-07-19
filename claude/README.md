# Claude Code Implementation
*The Conductor Orchestration system, implemented for the Claude Code runtime.*

---

## How Claude Code Differs from Gemini CLI

Both implement the same architecture (see [`ARCHITECTURE.md`](../ARCHITECTURE.md)), but the enforcement mechanisms are different:

| Concern | Gemini CLI | Claude Code |
|---|---|---|
| **Tool locking** | `policy.toml` via CLI Policy Engine | `tools:` list in agent frontmatter |
| **Agent definitions** | Gemini skill format (`SKILL.md`) | Markdown with YAML frontmatter (`.claude/agents/`) |
| **Automation / Skills** | `gemini skills install` | `/skill-name` commands (`.claude/skills/`) |
| **State ledger** | `~/.gemini/conductor/ledgers/*.json` | `docs/context/` directory |
| **Pre-merge gates** | External CI / manual | `settings.json` hooks (PreToolUse intercept) |
| **Cross-session memory** | External memory / manual | `.claude/projects/*/memory/` auto-memory |
| **Agent invocation** | Fresh isolated process per Tier 3 task | Subprocess with dedicated context |

The key difference: Claude Code's `.claude/agents/` system spawns agents as subprocesses with their own context window and tool set. The `tools:` frontmatter list is enforced by the Claude Code runtime — an agent without `Write` in its list cannot write files, regardless of what it's instructed to do.

---

## What's in This Directory

```
claude/
├── README.md                     ← This file
├── agents/
│   ├── architect.md              ← Lead Architect template (zero-code, Opus)
│   ├── specialist.md             ← Generic Specialist template (rename for each domain)
│   ├── qa.md                     ← QA template (read-only, binary gate)
│   └── critic.md                 ← Critic template (adversarial review, ideas and plans)
├── skills/
│   ├── install-agent-scaffold/
│   │   └── SKILL.md              ← Bootstraps a full Claude Code project from scratch
│   ├── start-sprint/
│   │   └── SKILL.md              ← Opens a new sprint (auto-triggers on planning prompts)
│   ├── report-track-status/
│   │   └── SKILL.md              ← Status report (auto-triggers on catch-up prompts)
│   ├── minify-context/
│   │   └── SKILL.md              ← Compresses verbose active context files
│   └── [other skills: check-agent-os, update-agent-os, onboard-existing-project, ...]
└── templates/
    ├── AGENTIC.md                ← Fill-in-the-blanks Static DNA starter
    └── CLAUDE.md                 ← Fill-in-the-blanks orchestrator config (includes auto-trigger rules)
```

---

## Quick Start

**Option A — Automated (recommended):**
Copy `skills/install-agent-scaffold/SKILL.md` to `.claude/skills/install-agent-scaffold/SKILL.md` in your project, then run `/install-agent-scaffold`. The skill will ask for your project details and generate everything.

**Option B — Manual:**
1. Copy `templates/AGENTIC.md` → `AGENTIC.md` at your project root. Fill in placeholders.
2. Copy `templates/CLAUDE.md` → `CLAUDE.md` at your project root. Fill in placeholders.
3. Create `docs/context/plan.md`, `docs/context/tracks.md`, `docs/context/product.md`.
4. Copy `agents/architect.md`, `agents/specialist.md`, `agents/qa.md` → `.claude/agents/`. Rename and customize each.
5. Create `.claude/settings.json` with a pre-push build hook.

---

## Model Behavioral Profiles

Understanding how each model fails under pressure determines which compensations to build in.

### Claude (Anthropic) — Native to this path
**Failure mode:** Behavioral rules can be worn down by persistent prompting or context saturation.
**Compensation:** Physical tool locks and pre-push hooks are built into Claude Code. The DNA Jolt re-injects Static DNA at session start.
**Reliability:** High role fidelity. Physical barriers catch edge cases behavioral rules miss.

### GPT-4 / GPT-4o
**Failure mode:** Helpfulness drift — will attempt to fix things outside its declared scope if it sees an obvious problem.
**Compensation:** Explicit negative framing ("do not modify anything outside declared Execution Files"). Manual human checkpoint at role transitions. No native `.claude/agents/` equivalent — orchestrate via separate API calls with full system-prompt re-injection per turn.

### Gemini
**Failure mode:** Agreeableness bias — will affirm a constraint and then violate it under light pressure. Behavioral rules alone are **not reliable**.
**Compensation required:**
- Physical barriers become mandatory. Without native tool locking, you need manual human handoffs at every agent boundary.
- Re-inject the Handoff Bridge at every transition — don't assume a role constraint from earlier in the conversation is still active.
- Use explicit negative framing: "you must NOT write code" is more durable than "your role is planning only."
- The Gemini CLI path (`../skills/`) uses `policy.toml` for tool masking — this is the equivalent of Claude Code's `tools:` frontmatter. Without one of these, Gemini requires human checkpoints at each boundary.

### Open-Source Models (Llama, Mistral, etc.)
**Failure mode:** Role fidelity degrades over long sessions. Multi-role discipline from turn 1 may be negligible by turn 20.
**Compensation:** Very short system prompts (3-5 critical constraints only). Explicit single-task scoping per call. Physical barriers become the entire system — treat behavioral rules as advisory. Human review at every transition.

---

## IDE Support

Claude Code is runtime-first. The agent and hook system runs identically across:
- **VS Code** (native extension) — adds clickable file links, inline diff acceptance
- **JetBrains** (plugin) — same runtime, slightly different rendering
- **Terminal (CLI)** — full functionality, no visual rendering
- **Claude.ai/code (web)** — browser-based Claude Code instance

Cursor, Windsurf, and GitHub Copilot do not support `.claude/agents/` or Claude Code hooks. See `ARCHITECTURE.md §Graceful Degradation` for porting those environments.

---

*For the full architectural rationale, see [`ARCHITECTURE.md`](../ARCHITECTURE.md).*
