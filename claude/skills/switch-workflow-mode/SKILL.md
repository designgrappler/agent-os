---
name: switch-workflow-mode
description: Switch Agent OS between MANUAL and AUTONOMOUS operating modes. Runs a feasibility gate, requires explicit YES confirmation, writes to three locations, and prints a summary card. Invoke with /switch-workflow-mode manual or /switch-workflow-mode autonomous.
argument-hint: "[manual|autonomous]"
disable-model-invocation: true
tools: Agent
---

# Switch Workflow Mode

Switch Agent OS operating posture between **MANUAL** and **AUTONOMOUS** mode.

- **MANUAL** (default): Tim triggers each handoff. The Orchestrator coordinates on request, not by autonomously spawning agents.
- **AUTONOMOUS**: The Orchestrator drives the pipeline — Architect → Specialist → QA — automatically. Tim approves sprint scope and handles escalations only. Phase 2 runtime behavior; activating this mode now prepares the config for when that runtime exists.

This skill owns the entire mode-change ceremony. It does not share this responsibility with any installer or other skill.

**Usage:** `/switch-workflow-mode manual` or `/switch-workflow-mode autonomous`

**Research Phase §0 basis (T17.3 — 2026-06-16, updated Sprint 17 close):**

*Claim 1 — Skill fail-closed semantics:* A Claude Code skill body is a prompt-based instruction set enforced at the model layer, not the runtime layer. Source: `https://code.claude.com/docs/en/skills` and `https://code.claude.com/docs/en/permissions` — the runtime tool layer is unaware of prompt-level restrictions; if the model fails to follow skill instructions, the tool layer will still execute file modifications if user permissions allow them.

**Documented bypass vectors for prompt-layer gates (Phase 2 must account for these):**
- Instruction drift in long sessions (model deprioritises skill instructions vs newer prompts)
- Explicit user override ("ignore the skill logic")
- `--dangerously-skip-permissions` flag or `bypassPermissions` mode (removes standard interactive prompts; triggers a warning only for `.claude/` directory writes as of v2.1.78)
- `skillOverrides` in settings.json (can set skill to `"off"` or `"user-invocable-only"`)
- Subagents spawned in `bypassPermissions` mode bypass user-defined hooks and prompt boundaries

The feasibility gate in this skill is a **protocol-layer compensating control** — it is not fail-safe against all bypass vectors.

**Tool-layer enforcement (active as of T19.6):** The skill-layer feasibility gate
(Phase 1 below) is now backed by a `PreToolUse` hook at
`.claude/hooks/block-mode-violation.sh` that reads `docs/tasks.json` and exits
code 2 on every Edit/Write call if any task is `CLAIMED` or `IN_PROGRESS`. The
hook enforces the same rule as Phase 1 Check 2 of this skill, but at the tool
layer — independent of model state and unaffected by prompt-layer bypass
vectors. The skill remains the user-facing explanation layer; the hook is the
runtime backstop. Source: `https://code.claude.com/docs/en/hooks` (PreToolUse
exit-code-2 contract, verified 2026-06-20). See AGENTIC.md §3 for the paired
enforcement model.

*Claim 2 — Settings.json hand-edit prevention:* Claude Code does not use OS-level filesystem locks to prevent direct hand-editing of `.claude/settings.json`. A local user with write access can edit the file with any text editor. Sources: `https://code.claude.com/docs/en/settings` and `https://code.claude.com/docs/en/permissions`.

**Compensating controls that exist (updated finding):**
- **ConfigChange hook** (new finding, Sprint 17 close): If `.claude/settings.json` is modified during an active session, the runtime triggers a `ConfigChange` hook. A hook script exiting with code 2 or returning `{"decision": "block"}` can reject the change within the active session. Limitation: this only applies during an active CLI session — it cannot prevent offline modifications made when Claude Code is closed.
- **Managed settings tier**: For enterprise deployments, `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS) or `/etc/claude-code/managed-settings.json` (Linux) at root-protected paths override all local settings. `allowManagedPermissionRulesOnly: true` ignores all local permission rules.
- **CLAUDE.md mismatch-detection step** (implemented in T17.3): Compares `operatingMode` in settings.json against the `## Operating Mode` section in CLAUDE.md at every session start; surfaces a one-line warning on divergence. This is the primary compensating control for direct hand-edits in Agent OS's single-user non-enterprise deployment model.

Source: `https://code.claude.com/docs/en/hooks`, research synthesis in `docs/context/temp-architectural-assessment.md`.

---

## Phase 1 — Feasibility Gate (fail-closed, hard block)

Before any write occurs, perform all three checks. If any check fails, stop immediately, surface the specific reason, and do not proceed.

### Check 1: tasks.json readable and parseable

Read `docs/tasks.json`.

- If the file does not exist: **STOP.** Output: `Mode change blocked: docs/tasks.json not found. The feasibility gate requires tasks.json to confirm no sprint work is in flight. Create tasks.json or resolve the missing file before switching modes.`
- If the file exists but is not valid JSON (cannot be parsed): **STOP.** Output: `Mode change blocked: docs/tasks.json is not valid JSON. Fix the file before switching modes.`

### Check 2: No CLAIMED or IN_PROGRESS tasks

Parse the `tasks` array in `docs/tasks.json`. For each task, check the `status` field.

- If any task has `status: "CLAIMED"` or `status: "IN_PROGRESS"`: **STOP.** Output: `Mode change blocked: [task-id] is [status]. Resolve all in-flight tasks before switching modes. (Tip: run /sync-tasks-to-tracks to see the current human view.)`
  - List **every** blocking task ID — do not stop at the first one.
  - Example: `Mode change blocked: T17.1 is IN_PROGRESS, T17.3 is CLAIMED. Resolve all in-flight tasks before switching modes.`

### Check 3: tasks.json and tracks.md in sync

Read both `docs/tasks.json` and `docs/context/tracks.md`. Compare the task IDs and status values that appear in the active-tracks section of `tracks.md` against the corresponding entries in `tasks.json`.

- If the active-tracks section of `docs/context/tracks.md` lists statuses that differ from `docs/tasks.json` for any task: **STOP.** Output: `Mode change blocked: docs/tasks.json and docs/context/tracks.md are out of sync. Run /sync-tasks-to-tracks to regenerate tracks.md from tasks.json, then retry.`
- If the tracks.md active-tracks section cannot be read or does not exist: treat as out-of-sync and block with the same message.

**All three checks must pass before proceeding. If any fails, the skill terminates here.**

---

## Phase 2 — Explanation

If all three gate checks pass, explain what will change in one paragraph. Tailor the explanation to the direction:

**If switching to AUTONOMOUS:**
> You are about to switch Agent OS to AUTONOMOUS mode. In this mode, the Orchestrator will drive the Architect -> Specialist -> QA pipeline automatically -- Tim's role shifts to approving sprint scope and handling escalations only. The three writes are: (1) `.claude/settings.json` will have `operatingMode` set to `"autonomous"`; (2) `CLAUDE.md` `## Operating Mode` section will be updated to reflect `AUTONOMOUS`; (3) a timestamped entry will be appended to `docs/mode-changes.log`. This change takes effect at the next sprint boundary.

**If switching to MANUAL:**
> You are about to switch Agent OS to MANUAL mode. In this mode, Tim triggers each handoff -- the Orchestrator coordinates on request, not autonomously. The three writes are: (1) `.claude/settings.json` will have `operatingMode` set to `"manual"`; (2) `CLAUDE.md` `## Operating Mode` section will be updated to reflect `MANUAL`; (3) a timestamped entry will be appended to `docs/mode-changes.log`. This change takes effect at the next sprint boundary.

---

## Phase 3 -- Explicit YES Confirmation

After the explanation, prompt:

```
Type YES to confirm the mode switch, or anything else to cancel.
```

- If the user types exactly `YES` (case-sensitive): proceed to Phase 4.
- If the user types anything else (including `yes`, `y`, `Yes`, or just presses Enter): **cancel.** Output: `Mode switch cancelled. No changes made.` Then stop.

---

## Phase 4 -- Three Writes (only after YES confirmation)

Execute all three writes in order. If any write fails, report the failure and do not attempt the remaining writes.

### Write 1: `.claude/settings.json` -- `operatingMode` field

Read `.claude/settings.json`. Set (or add) the top-level field:
- For autonomous: `"operatingMode": "autonomous"`
- For manual: `"operatingMode": "manual"`

Preserve all existing fields. Write the updated JSON back to `.claude/settings.json`.

### Write 2: `CLAUDE.md` -- `## Operating Mode` section (subagent dispatch)

**Why subagent dispatch:** The S18.1 PreToolUse hook (`.claude/hooks/block-orchestrator-execution.sh`) blocks main-thread Edit/Write calls to `CLAUDE.md`. The hook allows calls from subagents (`agent_id` present in hook stdin). Dispatching a subagent is the correct mediated write path per `docs/temp-s18-hook-conflict-analysis.md` Option 2 (Tim-approved 2026-06-18). The subagent is tightly scoped — it edits only the `Current:` line under `## Operating Mode`.

Dispatch a subagent via the Agent tool with the following prompt (substitute `<NEW_CURRENT_LINE>` with the mode-appropriate string):

> Update the `Current:` line under the `## Operating Mode` section in `CLAUDE.md` to read exactly:
> `<NEW_CURRENT_LINE>`
> If the `## Operating Mode` section does not exist, insert it immediately after `## Team Architecture` as a new section containing only the `Current:` line. Edit no other content.

Mode-appropriate strings:
- For autonomous: `Current: AUTONOMOUS (orchestrator drives the pipeline — escalations only)`
- For manual: `Current: MANUAL (autonomous loop inactive — Tim triggers each handoff)`

Wait for the subagent to confirm the edit succeeded before proceeding to Write 3. If the subagent reports a failure or the hook blocks the write, surface the failure and do not proceed.

### Write 3: `docs/mode-changes.log` -- append audit entry

If the file does not exist, create it with a header comment block followed by the first entry:

```
# Agent OS -- Operating Mode Change Log
# Format: ISO timestamp | from -> to | reason: <text or ->
```

Append a new line in this format:
```
<ISO timestamp> | <from-mode> -> <to-mode> | reason: <reason or ->
```

Example: `2026-06-16T14:30:00Z | manual -> autonomous | reason: -`

The `reason` value comes from any text the user provided after the mode argument (e.g. `/switch-workflow-mode autonomous starting Sprint 18` means reason: `starting Sprint 18`). If no reason was provided, use `-`.

Do **not** pre-create this file -- it is created only by this skill on first switch.

---

## Phase 5 -- Summary Card

After all three writes succeed, print the following summary card (substituting actual values):

```
Operating Mode: [AUTONOMOUS | MANUAL]
-------------------------------------------------
What changed:   [manual -> autonomous | autonomous -> manual]
Effective:      next sprint boundary
Tim's role:     [AUTONOMOUS: approve sprint scope + handle escalations only | MANUAL: Tim triggers each handoff]
Orchestrator:   [AUTONOMOUS: drives Architect -> Specialist -> QA automatically | MANUAL: coordinates on request only]
To switch back: /switch-workflow-mode [manual | autonomous] (sprint boundary only)
Change logged:  docs/mode-changes.log
-------------------------------------------------
```

---

## Hard Constraints

- Never skip Phase 1. The feasibility gate is not advisory.
- Never proceed past Phase 3 without an exact `YES` confirmation.
- Never write to any file before receiving `YES`.
- Never create `docs/mode-changes.log` outside of Phase 4 Write 3.
- Specific-reason surfacing is required on every gate failure -- generic refusals are forbidden.
- If tasks.json is missing or unparseable, fail closed. Do not assume the gate passes.
