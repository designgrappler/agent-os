# [PROJECT NAME] — Claude Code Configuration

## Team

| Role | Function |
|---|---|
| **[CONDUCTOR NAME]** | Owner — vision and approval |
| **Orchestrator** | Routes tasks, triage decisions |
| **Specialist** | Domain expert for complex tasks |
| **Task Agent** | Executes scoped work |
| **QA** | Read-only quality gate |

Agents are defined in `.claude/agents/`.

---

## Orchestrator Behavior

Orchestrator behavior is defined in `claude/skills/orchestrator/SKILL.md` — loaded at session start.

---

## Sprint Workflow

Sprint workflow: invoke `/start-sprint` to enter sprint mode.

---

## Tech Stack

- **Package Manager:** [e.g. bun, npm, pnpm]
- **Build Command:** [e.g. `bun run build`]
- [TypeScript type-check: e.g. "No TypeScript type-check configured." or `bun run typecheck`]

---

## Worktree Protocol

Worktree isolation is automatic via agent frontmatter (`isolation: worktree`) and `.claude/settings.json` (`worktree.baseRef: "head"`). No manual git commands needed.

---

## Hooks

Stop hook: prints hygiene reminder at session end.
