---
name: check-agent-os
description: Runs a read-only health check on the current project's Agent OS installation.
---
# Check Agent OS
Runs a read-only health check on the current project's Agent OS installation. Verifies the orchestrator skill is present, confirms CLAUDE.md is the lean bootstrap, checks agent definitions are in place, and confirms AGENTIC.md and the retired `report-track-status` skill do NOT exist. On a clean pass, writes a `.agent-os-checked` timestamp to the project root so the 30-day session-start reminder knows the check is current. Nothing is auto-fixed — every fail row includes a remediation hint and action is left to you.

## Trigger
When the user runs `/check-agent-os`, execute the following phases in order.

---

## Phase 1: Skill Install Check

1. Resolve the canonical skill names using the same source chain as `/update-agent-os`:
   - Check `skills-manifest.json` in the project root for a `canonical-registry` URL.
   - If present, attempt to fetch the manifest JSON from that URL and read its `skills` array.
   - **Fallback:** if the URL fetch fails, fall back to the local canonical clone at `~/Developer/agent-os-private/skills-manifest.json`. Notify the user that the fallback was used.
   - **If neither resolves:** stop and ask the user to supply a path or URL. Do not proceed to Phase 2.
2. Use the manifest's `renames` array to recognize legitimate renames: if a skill name in `~/.claude/skills/` matches a `"to"` value in `renames`, it is correctly installed — do not flag it as missing.
3. Compare the canonical `skills` array against subdirectory names in `~/.claude/skills/` that contain a `SKILL.md` file.
4. **Pass:** every canonical skill name has a corresponding `~/.claude/skills/<name>/SKILL.md` (accounting for renames).
5. **Fail rows:** list each canonical skill name that is absent or present only under a stale name. Remediation hint:
   > Run `/update-agent-os` to install missing or stale-named skills.

---

## Phase 2: Orchestrator Skill Check

1. Confirm `claude/skills/orchestrator/SKILL.md` exists in the project.
2. **Pass:** the file exists and is non-empty.
3. **Fail rows:** if absent or empty. Remediation hint:
   > Run `/onboard-existing-project` or `/install-agent-scaffold` to install the orchestrator skill.

---

## Phase 3: CLAUDE.md Bootstrap Check

1. Confirm `CLAUDE.md` exists at the project root.
2. Check that it does NOT contain the old 181-line heavy-ceremony format (indicators: contains `## Initialization Loop`, references to `AGENTIC.md`, or contains `Sprint Coordinator constraint`).
3. **Pass:** `CLAUDE.md` exists and is the lean bootstrap format (contains `## Team`, `## Orchestrator Behavior`, and `## Tech Stack` sections; does not reference AGENTIC.md or Sprint Coordinator constraints).
4. **Fail rows:** if absent, or if it matches the old heavy format. Remediation hint:
   > Run `/update-agent-os` to sync CLAUDE.md to the lean bootstrap template. Back up any project-specific customizations first.

---

## Phase 4: Agent Definitions Check

### 4a: Expected Agents Present

1. List all files matching `.claude/agents/*.md` in the current project.
2. Confirm the following canonical agents are present:
   - `technical-architect.md`
   - `qa.md`
   - `task-coder.md`
   - `task-researcher.md`
   - `task-writer.md`
3. **Pass:** all five files exist.
4. **Fail rows:** list each missing agent. Remediation hint:
   > Run `/update-agent-os` to install missing canonical agents.

### 4b: Model Format Check

1. For each file matching `.claude/agents/*.md`, parse the frontmatter `model:` line.
2. **Pass:** every `model:` value is one of the canonical short forms: `opus`, `sonnet`, or `haiku`.
3. **Fail rows:** list each agent where `model:` contains a long-form name. Remediation hint:
   > Edit `.claude/agents/<name>.md` and change `model:` to the short form (`opus`, `sonnet`, or `haiku`).

**Note on `provider:` field:** `provider:` is an optional frontmatter field. Its absence is correct for the default Anthropic setup. Do NOT flag a missing `provider:` field as an error.

**Note on `mode:` field:** `mode:` is an optional field in `agent-setup.yml` (not agent frontmatter). Its absence or a blank value is correct and means `single-user`. Do NOT flag a missing, blank, or `single-user` `mode:` value as an error. (The non-blocking multi-user warning is added in T47.3.)

### 4c: WebFetch Tools Frontmatter Check

1. For each file matching `.claude/agents/*.md`, parse the frontmatter `tools:` list.
2. **Pass:** every agent file includes `WebFetch` in its `tools:` list.
3. **Fail rows:** list each agent where `WebFetch` is absent. Remediation hint:
   > Run `/update-agent-os` to sync with canonical.

### 4d: Specialist `isolation: worktree` Check

1. For each file matching `.claude/agents/*.md`, determine whether the agent is a Specialist by checking for a `## Sign-Off Protocol` section that contains both `**Track:**` and `**Completed:**` fields.
2. For each identified Specialist, confirm `isolation: worktree` appears in frontmatter.
3. **Pass:** every Specialist agent has `isolation: worktree`.
4. **Fail rows:** list each Specialist agent where `isolation: worktree` is absent. Remediation hint:
   > Run `/update-agent-os` to sync with canonical.

---

## Phase 5: Retirement Verification

### 5a: AGENTIC.md Does NOT Exist

1. Check whether `AGENTIC.md` exists at the project root.
2. **Pass:** `AGENTIC.md` does NOT exist.
3. **Fail row:** if `AGENTIC.md` exists. Remediation hint:
   > `AGENTIC.md` is a retired file from the old Agent OS model. Delete it — its content has been replaced by `CLAUDE.md` and the orchestrator skill.

### 5b: `report-track-status` Does NOT Exist

1. Check whether `claude/skills/report-track-status/` exists in the project.
2. **Pass:** the directory does NOT exist.
3. **Fail row:** if `claude/skills/report-track-status/` exists. Remediation hint:
   > `report-track-status` is a retired skill. Delete `claude/skills/report-track-status/` — it has been replaced by `/track-status`.

---

## Phase 6: Required `docs/context/` Check

1. Check for the existence and non-emptiness of each required context file:
   - `docs/context/plan.md`
   - `docs/context/tracks.md`
2. A file passes if it exists **and** contains at least one non-whitespace character.
3. **Pass:** both files exist and are non-empty.
4. **Fail rows:** list each file that is missing or empty. Remediation hint:
   - For `docs/context/plan.md` or `docs/context/tracks.md`:
     > These files must be authored at sprint kickoff. Run `/start-sprint` to initialize them.

---

## Phase 6b: Multi-User `Owner:` Enforcement (informational — does not affect OVERALL)

This phase is **advisory only**. It never contributes a fail row and never changes `OVERALL`.

1. Read `agent-setup.yml` from the project root and take the top-level `mode:` value (trim whitespace, strip inline `#` comments). Apply the T47.2 defaulting: file absent / key absent / blank / `single-user` / any unrecognized value → `single-user`; only `multi-user` → `multi-user`.
2. **If mode resolves to `single-user`:** emit `Phase 6b: Multi-User Owner Enforcement — N/A (single-user mode)` and exit the phase. No enforcement in single-user.
3. **If mode resolves to `multi-user`:** read `docs/context/tracks.md`. For each track whose `**Status:**` is `IN_PROGRESS` or `DONE`, check its `**Owner:**` value. If the owner is blank or `null`, emit one warning line:
   > `⚠ Track <ID> is <STATUS> but has no Owner (blank/null). Assign a GitHub handle in docs/context/tracks.md, or leave it if intentional. (Non-blocking.)`
4. If no such tracks exist (or `tracks.md` is absent), emit `Phase 6b: Multi-User Owner Enforcement — PASS (all in-flight tracks owned)`.

These warnings are surfaced for visibility only. Do **not** count them in the `OVERALL: FAIL (N issues)` total — the FAIL count remains "fail rows across Phases 1–6" as defined in Phase 8.

---

## Phase 7: Claude Code Version Notice (informational only — does not affect OVERALL)

Run `claude --version` defensively:
```bash
version_output=$(claude --version 2>/dev/null)
```

Extract the version string (first whitespace-delimited token). Compare to threshold `2.1.172`.

- **version >= 2.1.172:** emit: `Claude Code version OK (v<X.Y.Z>)`
- **version < 2.1.172:** emit: `Claude Code v2.1.172+ recommended for autonomous mode (detected: v<X.Y.Z>)`
- **parse failed:** emit: `Claude Code v2.1.172+ recommended for autonomous mode (could not detect installed version)`

---

## Phase 8: Report

Emit one clearly-labeled section per phase. Each section states **PASSED** or **FAILED**, with fail rows and remediation hints. Phase 7 and Phase 6b notices are informational — they do NOT affect OVERALL.

```
### Phase 1: Skill Install Check — PASSED
### Phase 2: Orchestrator Skill Check — PASSED
### Phase 3: CLAUDE.md Bootstrap Check — PASSED
### Phase 4: Agent Definitions Check
#### 4a: Expected Agents Present — PASSED
#### 4b: Model Format Check — PASSED
#### 4c: WebFetch Tools Frontmatter Check — PASSED
#### 4d: Specialist isolation: worktree Check — PASSED
### Phase 5: Retirement Verification
#### 5a: AGENTIC.md Does NOT Exist — PASSED
#### 5b: report-track-status Does NOT Exist — PASSED
### Phase 6: Required docs/context/ Check — PASSED
### Phase 6b: Multi-User Owner Enforcement — N/A (single-user mode)
### Phase 7: Claude Code Version Notice (informational)
Claude Code version OK (v2.1.200)

OVERALL: PASS
```

The final line **must** be exactly one of:
- `OVERALL: PASS`
- `OVERALL: FAIL (N issues)` — where N is the total count of fail rows across Phases 1–6 (Phase 7 and Phase 6b excluded, both informational).

---

## Phase 9: Timestamp on Success

- **If `OVERALL: PASS`:** write today's ISO date (e.g. `2026-07-20`) to `.agent-os-checked` at the project root. Print:
  > `Wrote .agent-os-checked (next reminder in 30 days)`
- **If `OVERALL: FAIL`:** do NOT create or modify `.agent-os-checked`.

---

## Hard Constraints

- Read-only **except** for the single `.agent-os-checked` write at project root on PASS.
- Never auto-fix; only report. Remediation is up to the user.
- If the canonical source cannot be resolved, stop and ask the user before proceeding.
- Every fail row surfaces a remediation hint.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source resolved before Phase 1 ran
- [ ] All phases (1–8) executed in order; Phase 8 Report and Phase 9 Timestamp run last
- [ ] Report ends with explicit `OVERALL: PASS` or `OVERALL: FAIL (N issues)` line
- [ ] On PASS, `.agent-os-checked` written with today's ISO date
- [ ] On FAIL, `.agent-os-checked` NOT created or modified
- [ ] Every fail row includes a remediation hint
- [ ] Phase 5a: AGENTIC.md existence checked; presence is a FAIL
- [ ] Phase 5b: report-track-status existence checked; presence is a FAIL
- [ ] Phase 7: `claude --version` invoked defensively; never contributes fail rows to OVERALL
- [ ] Phase 6b: mode read; single-user → N/A; multi-user → advisory warnings only, never counted in OVERALL
