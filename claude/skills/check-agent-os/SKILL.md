---
name: check-agent-os
description: Runs a read-only health check on the current project's Agent OS installation.
---
# Check Agent OS
Runs a read-only health check on the current project's Agent OS installation. Compares your installed skills against the canonical manifest, verifies every skill reference in `CLAUDE.md` resolves, confirms required `docs/context/` files exist and are non-empty, and checks that all agent frontmatter uses canonical short model names. On a clean pass, writes a `.agent-os-checked` timestamp to the project root so the 30-day session-start reminder knows the check is current. Nothing is auto-fixed — every fail row includes a remediation hint and action is left to you.

## Trigger
When the user runs `/check-agent-os`, execute the following phases in order.

---

## Phase 1: Skill Install Check

1. Resolve the canonical skill names using the same source-of-truth chain as `/refresh-agent-os`:
   - Read `AGENTIC.md` and look for a line matching: `Canonical skills manifest URL: <url>`
   - If the line is present, attempt to fetch the manifest JSON from that URL and read its `skills` array.
   - **Fallback:** if the URL fetch fails (network unavailable, 404, or any HTTP error), fall back to the local canonical clone at `~/Developer/agent-os-private/skills-manifest.json`. Notify the user that the fallback was used.
   - **If neither the URL nor the local clone resolves:** stop and ask the user to supply a path or URL. Do not proceed to Phase 2.
2. Use the manifest's `renames` array to recognize legitimate renames: if a skill name in `~/.claude/skills/` matches a `"to"` value in `renames`, it is correctly installed under the new name — do not flag it as missing.
3. Compare the canonical `skills` array against subdirectory names in `~/.claude/skills/` that contain a `SKILL.md` file (i.e. `~/.claude/skills/<name>/SKILL.md` exists).
4. **Pass:** every canonical skill name has a corresponding `~/.claude/skills/<name>/SKILL.md` (accounting for renames).
5. **Fail rows:** list each canonical skill name that is absent or present only under a stale name. For each fail row, include the remediation hint:
   > Remediation: Run `/refresh-agent-os` to install missing or stale-named skills.

---

## Phase 2: Auto-Trigger / Skill-Reference Check

1. Read the project's `CLAUDE.md` file. Scan the **entire** file — not just the auto-trigger table — for every skill reference. Capture references in:
   - Auto-trigger table rows (e.g. `| User says … | Invoke … |` rows)
   - Inline `/skill-name` mentions anywhere in prose or comments
   - Agent invocation blocks
   - Explicit `~/.claude/skills/<name>/SKILL.md` path literals
2. For each referenced skill name found, verify that `~/.claude/skills/<name>/SKILL.md` exists.
3. **Pass:** every referenced skill name resolves to a file at `~/.claude/skills/<name>/SKILL.md`.
4. **Fail rows:** list each broken reference with its line number and the surrounding context (the full line or row where it appears). For each fail row, include the remediation hint:
   > Remediation: Edit `CLAUDE.md` to remove or rename the reference, or run `/refresh-agent-os` if the skill should be installed.

---

## Phase 3: Required `docs/context/` Check

1. Check for the existence and non-emptiness of each required context file:
   - `docs/context/plan.md`
   - `docs/context/tracks.md`
   - `docs/context/product.md`
2. A file passes if it exists **and** contains at least one non-whitespace character.
3. **Pass:** all three files exist and are non-empty.
4. **Fail rows:** list each file that is missing or empty. For each fail row, include the appropriate remediation hint:
   - For `docs/context/product.md`:
     > Remediation: Run `/onboard-existing-project` to backfill it, or create it manually with a 2–3 sentence description of what this product is and who it serves.
   - For `docs/context/plan.md` or `docs/context/tracks.md`:
     > Remediation: These files must be authored by Peaches at sprint kickoff — escalate to Tim.

---

## Phase 4: Agent Model Format Check

1. List all files matching `.claude/agents/*.md` in the current project.
2. For each file, parse the frontmatter `model:` line.
3. **Pass:** every `model:` value is one of the canonical short forms: `opus`, `sonnet`, or `haiku`.
4. **Fail rows:** list each agent file where `model:` contains a long-form name (e.g. `claude-opus-4-7`, `claude-sonnet-4-6`) rather than the short alias. For each fail row, include the remediation hint:
   > Remediation: Edit `.claude/agents/<name>.md` and change `model:` to the short form (`opus`, `sonnet`, or `haiku`). See `install-agent-scaffold` Step 4 for the role→tier guidance table.

---

## Phase 5: Report

Emit the full report with one clearly-labeled section per phase. Each section states whether the phase **PASSED** or **FAILED**, and if failed, lists every fail row with its remediation hint.

Example structure:

```
### Phase 1: Skill Install Check — PASSED
All canonical skills are installed.

### Phase 2: Auto-Trigger / Skill-Reference Check — FAILED
- Line 14: `/start-sprint` → ~/.claude/skills/start-sprint/SKILL.md not found
  Remediation: Edit `CLAUDE.md` to remove or rename the reference, or run `/refresh-agent-os` if the skill should be installed.

### Phase 3: Required docs/context/ Check — PASSED
All three required context files exist and are non-empty.

### Phase 4: Agent Model Format Check — PASSED
All agent model values use canonical short form.

OVERALL: FAIL (1 issue)
```

The final line of the report **must** be exactly one of:
- `OVERALL: PASS`
- `OVERALL: FAIL (N issues)` — where N is the total count of fail rows across all phases.

---

## Phase 6: Timestamp on Success

- **If `OVERALL: PASS`:** write today's ISO date as a single line (e.g. `2026-05-23`) to `.agent-os-checked` at the project root. Print:
  > `Wrote .agent-os-checked (next reminder in 30 days)`
- **If `OVERALL: FAIL`:** do NOT create or modify `.agent-os-checked`. The 30-day session-start reminder will continue to appear until all issues are resolved and the check passes.

---

## Hard Constraints

- Read-only **except** for the single `.agent-os-checked` write at project root on PASS.
- Never auto-fix; only report. Remediation is up to the user.
- If the canonical source cannot be resolved (URL fails AND local clone absent), stop and ask the user — do not proceed to later phases.
- Each phase has explicit pass/fail criteria and surfaces a remediation hint for every fail row.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source resolved (URL primary, local clone fallback) before Phase 1 ran
- [ ] All four phases executed in order
- [ ] Report ends with explicit `OVERALL: PASS` or `OVERALL: FAIL (N issues)` line
- [ ] On PASS, `.agent-os-checked` was written with today's ISO date (single line)
- [ ] On FAIL, `.agent-os-checked` was NOT created or modified
- [ ] Every fail row in the report includes a remediation hint
