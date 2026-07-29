# Agent OS: Implementation Guide

This guide covers two things: starting your first session and running common workflows. For what Agent OS is and why it exists, see [README.md](./README.md). For how each part works, see [CONCEPTS.md](./CONCEPTS.md).

---

## Part 1: Your first session

### What does a session look like?

**Example: a researcher produces a competitive analysis**

Mia is a PM working on a new feature. She wants to understand how three competitors handle onboarding before writing her requirements.

1. Mia opens a session with the orchestrator and says: "I need a competitive analysis of how Notion, Linear, and Figma handle new user onboarding."
2. The orchestrator reads the context files — it already knows the product and what work is in progress — and routes the request to the researcher.
3. The researcher reads `product.md`, studies the three competitors, and produces a synthesis: what each does, what patterns appear across all three, and where the opportunity is.
4. Before the analysis reaches Mia, the QA specialist reads it against the original request. Does it cover all three competitors? Does it answer the questions asked? QA approves it.
5. Mia receives an approved analysis. She did not re-explain the product. She did not have to check whether the work was complete.

### How do I install it?

Tell your AI:

> "Install Agent OS on this project: https://github.com/designgrappler/agent-os"

The install skill runs in two steps:

1. A setup form (`AgentOS-Setup.md`) is created at your project root. Fill in your project name, team member names, and tech stack or toolset.
2. Run the install command again. The skill reads your form and generates all project files: agent definitions in `.claude/agents/`, context files in `docs/context/` (`product.md`, `plan.md`, `tracks.md`), and a `CLAUDE.md` that connects everything.

**Existing project?** Use the onboard path: `"Onboard Agent OS on this existing project: https://github.com/designgrappler/agent-os"` — it reads what you already have and will not overwrite files without your approval.

### What do I do first?

State your goal. The orchestrator reads your context files and routes the task to the right specialist. You do not pick the specialist manually.

---

## Part 2: Common workflows

### Research project

**When to use:** You need to gather, evaluate, and synthesize information before making a decision. Examples: competitive analysis, market research, literature review, user research synthesis.

1. State the research goal to the orchestrator: what you want to know and, if relevant, which sources or competitors to cover.
2. The orchestrator routes to the researcher. The researcher reads `product.md` and produces a structured synthesis.
3. The QA specialist reviews the output against the brief: does it cover the right sources? does it answer the questions asked? QA approves or sends back for revision.
4. You receive an approved synthesis, ready to brief the next specialist or use directly.

---

### Design sprint

**When to use:** You have a new surface, feature, or experience to design and want the work to run from brief through multiple directions to a reviewed output.

1. State the design brief to the orchestrator: the goal, the user, any constraints.
2. The orchestrator routes to the designer. If research is needed first, it opens a research track before the design track.
3. The designer produces multiple distinct directions. Each is fully formed; directions are not merged or averaged.
4. The QA specialist verifies the directions match the brief: are they distinct? do they address the stated goal? QA approves or sends back for revision.
5. You review approved directions and select one.

---

### Content brief to draft

**When to use:** You need written content — campaign copy, a product brief, an article — where quality means matching what was planned.

1. State the content goal to the orchestrator: audience, message, channel.
2. If the content depends on research, the orchestrator opens a research track first. The QA specialist reviews the research before it moves to writing.
3. The marketing specialist reads the approved research and produces the content.
4. The QA specialist reviews the content against the brief: right channel, right audience, right message? QA approves or sends back for revision.
5. You receive approved content.

---

### Sprint workflow

**When to use:** A larger body of work with multiple specialists running in parallel or sequence. The sprint workflow tracks what is open, in progress, blocked, and done.

1. Open a sprint: tell the orchestrator "Start a sprint" or invoke `/start-sprint`. The orchestrator asks for the sprint objective and creates the first track.
2. The orchestrator routes each track to the appropriate specialist. Specialists update `tracks.md` as work progresses.
3. Check status at any point: "What is the current status?" — the orchestrator reads `tracks.md` and reports.
4. When all tracks are approved by QA, close the sprint: `/close-sprint`. The orchestrator archives the plan, bumps the version, and resets for the next sprint.

---

## Part 3: Setup

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

### Antigravity + Claude Extension

Gemini (via Antigravity's Agent Manager) handles planning and orchestration. Claude (via VS Code's Claude Extension) handles execution. Context files live in the repo; both tools read from the same source.

- Antigravity's Agent Manager is the orchestration layer. Spawn one workspace per active track.
- Claude Extension is the execution layer. Paste task context from Antigravity to start a specialist with full context.
- Context isolation is architectural: each Antigravity workspace runs in its own agent context.

**Known gaps:** Running the QA specialist as a Gemini agent in Antigravity vs. Claude Extension is untested. Integration between Antigravity's knowledge base and Agent OS context files is undocumented.

---

### Other environments

Agent OS applies to any tool that supports reading Markdown files at session start, role-scoped agents with tool restrictions, and structured handoffs. Use the two setups above as reference patterns for adapting to other combinations. If you validate a new environment, contributions are welcome via [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## Part 4: Skills reference

All Agent OS skills require initialization via `install-agent-scaffold` or `onboard-existing-project`.

| Skill | Description |
|---|---|
| `install-agent-scaffold` | Full one-pass setup for new projects |
| `onboard-existing-project` | Reads your existing project; generates context files without overwriting |
| `start-sprint` | Launch a sprint, set objective, create first track |
| `close-sprint` | Close a sprint, archive completed work, bump version |
| `track-status` | Quick status summary of open sprint tracks |
| `track-close` | Close a single track and mark it done |
| `create-agent` | Scaffold a new agent file interactively |
| `check-agent-os` | Verify Agent OS installation is healthy and up to date |
| `update-agent-os` | Diff installed skills against canonical manifest; update on confirmation |
| `clean-context` | Archive stale and completed context items |
| `minify-context` | Compress verbose active context files |
| `streamline-approvals` | Reduce approval prompt volume by building a pre-approved allowlist |
| `orchestrator` | Loaded automatically at session start — not user-invoked directly |

**Standalone skills** (no Agent OS installation required):

| Skill | Description |
|---|---|
| `audit-security` | Security sweep: vulnerabilities, secrets, policy violations |
| `sync-vercel-env` | Sync local environment variables to Vercel |
| `submit-agent-os-feedback` | Submit feedback about Agent OS |

---

*(c) 2026 DZNR VENTURES®*
