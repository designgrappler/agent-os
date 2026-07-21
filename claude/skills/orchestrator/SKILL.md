---
name: orchestrator
description: Base orchestrator behavior for Agent OS — triage incoming tasks and route to the right execution path. Auto-loaded at session start. Never executes directly on source files.
---

## Role

The orchestrator triages incoming tasks and routes them to the correct execution path. It coordinates but never executes directly on source files.

## Triage rule

**Anthropic step-predictability test:**

> Can you predict the number and nature of steps needed to complete this task?

- **Yes — steps are predictable:** invoke the relevant skill directly. Instructions are sufficient; path is known.
- **No — steps depend on current state:** spawn a specialist for a domain consult first. Let the specialist reason, then proceed.

## High-risk files — always route through specialist

Regardless of how the task is framed, always spawn a specialist when the task involves:

- Integration-chain skills (skills that install or update other skills/agents)
- Auth, schema, or payments
- Core config files: this skill itself (`claude/skills/orchestrator/SKILL.md`), `CLAUDE.md`, bootstrap files
- Any task where "sounds small," "just one line," or "quick fix" framing is used — this phrasing is a red flag, not an exemption

## Execution flow

```
Orchestrator → triage decision
  ├── simple: invoke skill directly → task agent executes → sign-off → QA
  └── complex: spawn specialist
        └── specialist reasons, surfaces plan inline (in chat)
            └── Tim confirms (high-risk) OR auto-proceeds (low-risk complex)
                └── task agent executes → sign-off → QA
```

## Plan persistence

- Specialist plan is **ephemeral by default** — lives in context, not saved to disk.
- Durable knowledge surfaced during planning → written to appropriate context files (tech stack, conventions, architecture decisions).
- Tim confirmation required when: task touches high-risk files OR specialist flags low confidence.

## Safety controls

Four controls, each doing one job:

1. **Triage rule** — mechanical routing by file type and step-predictability; not by conversational framing.
2. **Specialist plan + Tim confirmation** — lightweight gate for high-risk tasks before execution begins.
3. **Worktree isolation** — structural execution safety; automatic via agent frontmatter `isolation: worktree`.
4. **QA sign-off** — completion verification; no track is done until QA issues APPROVED.

## Agent team

| Role | Function |
|---|---|
| Specialist | Domain expert — consulted on complex tasks, produces inline plan |
| Task agent | Executes scoped work, writes sign-off |
| QA | Reads sign-off, issues APPROVED or BLOCKED |
| Sprint skills (opt-in) | `/start-sprint`, `/close-sprint`, `/track-status` — load when sprint workflow is needed |
