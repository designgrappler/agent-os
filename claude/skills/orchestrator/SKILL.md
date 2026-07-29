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

## Context mode detection

After checking plan.md, determine the context mode for this session:

1. Check whether `docs/context/task.md` exists and contains `Status: active`. If yes → **ephemeral mode**.
2. If `docs/context/product.md` exists and the user's request references the project by name or references prior sprint/track work → **persistent mode**.
3. If neither condition is met → infer from request framing using this table:

| Signal in the request | Inferred mode |
|---|---|
| Bounded deliverable ("write," "build," "fix," "analyze") | Ephemeral |
| "Continue working on..." / references to prior sprint | Persistent |
| References to a named project, product, or sprint | Persistent |
| Ambiguous / no prior context file | Ephemeral (default) |

**Confirm the inferred mode in one sentence before proceeding:**

For ephemeral:
> "Treating this as a standalone task — [one-sentence restatement of goal]. Tell me if this is part of something larger."

For persistent (when product.md exists):
> "Working in [project name] context. [one-sentence sprint state from plan.md if available]."

**Read `docs/context/task.md` when in ephemeral mode** (alongside product.md if present).

**The rule is: infer and confirm, never configure.** Do not ask "is this a one-off task or an ongoing project?" — that is a configuration prompt. State the framing; the user corrects if wrong.

## Creating task.md (ephemeral mode)

When ephemeral mode is active and a new task begins, before creating `docs/context/task.md`:

1. Check whether `docs/context/task.md` already exists.
2. **If `docs/archive/tasks/` directory exists:** set `Status: done` in the current `task.md`, then move it to `docs/archive/tasks/YYYY-MM-DD-[slug].md` where slug is the first five words of the task title, hyphenated.
3. **If `docs/archive/tasks/` does not exist:** overwrite `task.md` silently, but add this line to the new file's `## Agent notes` section: "Prior task.md overwritten. To keep task history, create docs/archive/tasks/."
4. Create the new `task.md` with the current task's content.

## Recurring topic observation

After creating a new `task.md`, check `docs/archive/tasks/` for prior task files (if the directory exists). If three or more archived tasks share a domain keyword with the current task and no `docs/context/product.md` exists, surface this observation — do not ask a question requiring an answer:

> "You've worked on [topic] a few times. If this is becoming an ongoing effort, I can set it up as a project."

This fires at most once per session and only when the archive directory exists with sufficient history.

## Task promotion (task.md → product.md)

When the user signals that a task has grown into an ongoing project — via phrases like "this is turning into a project," "let's make this ongoing," "I want to keep working on this," "can we make this a project," or similar — run the promotion path:

1. Read `docs/context/task.md`.
2. Ask the user: "I'll convert this to a project context. What should I call it?" (one question, wait for response).
3. Create `docs/context/product.md` synthesized from `task.md`:
   - Task title → project name (in the document header)
   - `## Goal` content → vision / what this project is for
   - `## Scope` content → current focus
   - `## Constraints` content → relevant context / constraints
   - Set "Who it's for" to unknown — prompt the user to fill in if needed
4. Archive `task.md`: set `Status: done`, move to `docs/archive/tasks/YYYY-MM-DD-[slug].md` (create `docs/archive/tasks/` if absent).
5. Confirm: "Project context created — [name]. product.md is now the persistent context. You can fill in 'Who it's for' when ready."

**This path does not replace `/onboard-existing-project`.** That skill handles full project scaffolding. This is a lightweight shortcut for the specific case where `task.md` exists and the user wants to graduate it to a project.

**Do not auto-detect promotion.** The signal must come from the user — do not infer promotion from session count or task length.

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

**Before dispatching to QA:** Check whether the track involves high-risk files (integration-chain skills, auth, schema, payments, core config). If so, surface to Tim for confirmation before dispatching Bandit.

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

## Writer specialist dispatch

When routing to the writer specialist, include this instruction in the task brief:

> "Read the brief, confirm your output meets its tone, structure, and audience standard, and include that assessment in your sign-off."

**Editorial self-assessment is required in the sign-off for every writer specialist dispatch.** The assessment must state specifically how the output meets the brief's tone, structure, and audience standard — not just that the brief was read.

## BLOCKED resolution

When QA issues a BLOCKED verdict:
1. Read the BLOCKED reason — identify the specific failure.
2. Surface to Tim: one sentence describing what failed and what decision is needed.
3. Wait for direction before re-dispatching the task agent.
4. Do not attempt to resolve a BLOCKED verdict autonomously.
