# Conductor OS: Implementation Guide

This guide provides the technical and operational framework for deploying the **Conductor-compatible Agent Orchestration** system across supported platforms.

---

## Step 0: Choose Your Platform

The Conductor OS architecture is implemented for two runtimes. The concepts are identical; the enforcement mechanisms differ.

| Platform | Tool Enforcement | Skills Format | Setup Path |
| :--- | :--- | :--- | :--- |
| **Gemini CLI** | `policy.toml` via CLI Policy Engine | `SKILL.md` in `skills/` | `install-agent-scaffold` skill |
| **Claude Code** | `tools:` frontmatter in `.claude/agents/` | Markdown in `claude/skills/` | `/install-agent-scaffold` skill |

For a platform-agnostic explanation of why the architecture works, see [`ARCHITECTURE.md`](./ARCHITECTURE.md).

### New project or existing project?

> **If your project already has code, files, or history — stop here.**
> Run `project-adopt` (Gemini) or `/project-adopt` (Claude Code) **before** any other setup skill.
> It reads your project first, pre-fills the interview from what it finds, and will not overwrite existing files without your approval.
> The standard setup skill (`install-agent-scaffold`) is greenfield-first — it assumes an empty slate.

| Situation | Gemini CLI | Claude Code |
| :--- | :--- | :--- |
| **New project** | `install-agent-scaffold` | `/install-agent-scaffold` |
| **Existing project** | `project-adopt` | `/project-adopt` |

---

## Step 1: Prerequisite Audit

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
| **Tier 1 (Blue)** | **Orchestration / Conductor** | Establishes project DNA and base context | Blocked from write/exec on source |
| **Tier 2 (Purple)** | **Strategic / Architect** | Plans, schedules, generates Handoff Bridges | Limited to context/docs writes |
| **Tier 3 (Orange)** | **Tactical / Specialist** | Executes declared deliverables | Scoped to Handoff Bridge deliverables |
| **Tier 3 (Red)** | **Sentinel / Quality Gate** | Audits output, issues PASS/BLOCKED verdict | Read-only |

**Non-dev roles** (product manager, designer, marketing manager, etc.) use the same tier structure. The difference is the *type of deliverable* — documents, briefs, and designs instead of source files. The scope lock, Technical Handshake, and Quality Gate all apply equally.

---

## Step 3: Initialization Flow

### Gemini CLI
```bash
# Deploy the full setup bundle in one pass:
gemini skills install https://github.com/designgrappler/agent-skills --path skills/install-agent-scaffold
```
Then trigger: *"Install the agent scaffold for this project."*

The bundle runs a **Pre-Flight Interview** — all questions are gathered first, no files created until the interview is complete:
1. Project name and description
2. Tech stack or toolset
3. Team type (dev / creative / mixed)
4. Personnel names for all roles
5. Workflow mode (`GEMINI_ONLY` or `RELAY`)

### Claude Code
Copy `claude/skills/install-agent-scaffold.md` to `.claude/skills/` in your project, then run `/install-agent-scaffold`. Same pre-flight interview, same output.

---

## Step 4: The Sprint Workflow

Once initialized, the operational loop is:

```
Sprint Open → Plan → Handoff Bridge → Execute → Quality Gate → Sprint Close
```

| Step | Skill / Command | Trigger |
| :--- | :--- | :--- |
| Open sprint | `sprint-open` | "Start planning" / "New sprint" |
| Check status | `track-status` | "Catch me up" / "Status check" |
| Generate handoff | `optimize-handoff` (Gemini) / *(native)* (Claude) | "Generate handoff for [specialist]" |
| Review output | `quality-gate` | "Run quality gate on [specialist]'s output" |
| Archive completed | `clean-context` (Gemini) / *(native)* (Claude) | "Clean context" |
| Compress active files | `minify-context` | "Minify context" |

`sprint-open` and `track-status` **auto-trigger** on natural language phrases — no explicit command needed when configured via the `CLAUDE.md` Auto-Invocations table (Claude Code) or the Trigger section of each skill (Gemini).

---

## Step 5: Handoff Protocol

Before any Tier 3 Specialist begins work, the Architect generates a **Handoff Bridge** via `optimize-handoff` (Gemini) or natively in Claude Code. The bridge contains:

- **Role Identity** — who is waking and what domain they own
- **Execution Deliverables** — the exact files or documents to produce/modify
- **Upstream Verified** — confirmation the Technical Handshake was completed
- **Acceptance Criteria** — how to verify the work is complete
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

**Parallel tracks** each get an isolated workspace (git worktree or equivalent) to prevent cross-track contamination.

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

## Skill Library Reference

| Skill | Tier | Claude Code | Gemini CLI | Purpose |
| :--- | :--- | :---: | :---: | :--- |
| `install-agent-scaffold` | 1 | ✓ | ✓ | Full one-pass setup — **new projects** |
| `project-adopt` | 1 | ✓ | ✓ | Onboard an **existing project** — reads first |
| `add-specialist` | 1 | *(built-in)* | ✓ | Add a specialist agent to an existing team |
| `optimize-handoff` | 2 | *(native)* | ✓ | Handoff Bridge generation |
| `sprint-open` | 2 | ✓ | ✓ | Sprint launch |
| `track-status` | 2 | ✓ | ✓ | Situational status report |
| `minify-context` | 2 | ✓ | ✓ | Compress active context files |
| `clean-context` | 3 | *(native)* | ✓ | Archive stale/completed items |
| `quality-gate` | 3 | ✓ | ✓ | Binary PASS/BLOCKED verdict |
| `memory-indexer` | 3 | *(native)* | ✓ | Long-term knowledge archival |
| `security-audit` | 3 | ✓ | ✓ | Security sweep |
| `design-sync` | 3 | ✓ | ✓ | Visual design audit |

---

**Inspired by Google Conductor.**
*(c) 2026 DZNR VENTURES®*
