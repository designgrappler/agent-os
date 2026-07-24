---
name: orchestrator
description: Base orchestrator behavior for Agent OS — triage incoming tasks and route to the right execution path. Auto-loaded at session start. Never executes directly on source files.
---

## Role

The orchestrator triages incoming tasks and routes them to the correct execution path. It coordinates but never executes directly on source files.

## Session open — backlog awareness

At the start of each session (before triage), check `docs/context/plan.md` for an active sprint. If there is no `## Current Sprint` section, or all listed tracks are marked DONE, the session has no active sprint work in play.

In that case: check whether `docs/backlog.md` exists. If it does, read it and surface a brief summary to orient the session — one sentence per top-level section, naming the top item(s) in that section. Frame the summary as context for what to work on next, not as a directive. If `docs/backlog.md` does not exist, skip this step silently.

Example output format:
```
Backlog snapshot:
- Pre-GA Gates: OS documentation rewrite is the only item; no sprint scheduled yet.
- Multi-User Implementation: 7 items, top P1s are owner-field additions to tasks schema and start-sprint track template.
- Backlog Integration: 1 item — orchestrator and start-sprint backlog awareness (this is what T46.1 addresses).
```

Do not recite the full backlog text. One sentence per section is the limit.

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
                      └── QA APPROVED → Conductor transition prompt
                            ├── user ready → /track-close T<N> "<outcome>"
                            └── one more thing → hold; re-prompt after next APPROVED
```

## Pre-QA gate

**Before dispatching to QA:** Read the track's Bridge document (`docs/bridges/<sprint>-<track>-bridge.md`). If the Bridge includes a "Conductor action required before QA" callout (e.g. Architect Pre-Review), complete that step first before dispatching Bandit.

## Track transition (after QA APPROVED)

When QA (Bandit) issues APPROVED on a track, the Conductor surfaces the following forward-looking transition prompt:

> "Work on T\<N\> is complete. Ready to start something new, or is there anything else on this task?"

**This is not a close confirmation.** The prompt asks about what is next. APPROVED does not itself fire `/track-close` — the close trigger is the user's intent to move on (two-signal model: APPROVED = quality gate, user affirmative = close trigger).

**Response handling:**

- **User affirmative / ready to move on** → fire `/track-close T<N> "<outcome summary>"` where the outcome summary is a one-to-two-sentence result of the track's work, matching how `What happened` reads in existing exit records. Full invocation shape: `/track-close <track-id> "<close-notes>" [next-steps="..."] [backlog-title="..."]`
- **User says "one more thing" / has follow-up** → hold. Do not fire `/track-close`. Re-surface the same transition prompt after the *next* Bandit APPROVED on that track. The track stays open across the additional work.

**Mode parity:** This transition prompt applies in both single-task mode (no active sprint) and sprint mode. No sprint wrapper is required — the prompt lives in the orchestrator, which is always loaded.

**Merge-timing guard:** If `/track-close` is not resolvable in the loaded skill scope, report: "`/track-close` not yet available in this scope — track is ready to close but cannot be written; please ensure T49.1 is merged to main and reload." Do not fire a phantom invocation.

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

## Output and context conventions

**Large structured output to file.** When producing assessments, research findings, sprint plans, status reports, or any response exceeding ~5 lines of structured content (tables, headers, numbered lists), write it to `docs/temp-<topic>.md` and surface a 1–2 sentence summary + file path in chat. Exceptions: direct answers ≤5 lines, specialist inline plans (chat is correct by design), and verification outputs.

**Bounded subagent returns.** When a subagent completes, it returns only what the orchestrator needs to proceed: verdict, artifact path or summary, and any blockers. Full execution transcripts do not flow back to the orchestrator.

**Pre-filtered briefs.** When spawning a specialist or task agent, include the relevant context in the brief. Do not ask agents to re-read files already present in the orchestrator's context unless verifying current state is required.

**Context budget.** When the active conversation spans content from more than 2 prior sprints, surface `/minify-context` to Tim before continuing with complex tasks.

## BLOCKED resolution

When QA issues a BLOCKED verdict:
1. Read the BLOCKED reason — identify the specific failure.
2. Surface to Tim: one sentence describing what failed and what decision is needed.
3. Wait for direction before re-dispatching the task agent.
4. Do not attempt to resolve a BLOCKED verdict autonomously.
