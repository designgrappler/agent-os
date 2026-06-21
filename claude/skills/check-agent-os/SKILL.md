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

## Phase 4: Agent Frontmatter Check

### 4a: Model Format Check

1. List all files matching `.claude/agents/*.md` in the current project.
2. For each file, parse the frontmatter `model:` line.
3. **Pass:** every `model:` value is one of the canonical short forms: `opus`, `sonnet`, or `haiku`.
4. **Fail rows:** list each agent file where `model:` contains a long-form name (e.g. `claude-opus-4-7`, `claude-sonnet-4-6`) rather than the short alias. For each fail row, include the remediation hint:
   > Remediation: Edit `.claude/agents/<name>.md` and change `model:` to the short form (`opus`, `sonnet`, or `haiku`). See `install-agent-scaffold` Step 4 for the role→tier guidance table.

### 4b: WebFetch Tools Frontmatter Check

1. For each file matching `.claude/agents/*.md` in the current project, parse the frontmatter `tools:` list.
2. **Pass:** every agent file includes `WebFetch` in its `tools:` list.
3. **Fail rows:** list each agent file where `WebFetch` is absent from `tools:`. For each fail row, include the remediation hint:
   > Remediation: Run `/refresh-agent-os` to sync with canonical.

### 4c: Specialist `isolation: worktree` Check

1. For each file matching `.claude/agents/*.md` in the current project, determine whether the agent is a Specialist by checking for a `## Sign-Off Protocol` section that contains both a `**Track:**` field and a `**Completed:**` field. Agents meeting this criterion are Specialists.
2. For each identified Specialist, parse the frontmatter and confirm `isolation: worktree` appears.
3. **Pass:** every Specialist agent has `isolation: worktree` in its frontmatter.
4. **Fail rows:** list each Specialist agent where `isolation: worktree` is absent from frontmatter. For each fail row, include the remediation hint:
   > Remediation: Run `/refresh-agent-os` to sync with canonical.

---

## Phase 7: Blueprint Frontmatter Validity Check

**Note:** Phase 7 fail rows contribute to the OVERALL fail count in Phase 9.

### 7.1 Absent-directory precondition

If `~/.claude/blueprints/` does not exist, emit a single PASS line:

> `Phase 7: Blueprint Frontmatter Validity Check — PASS (no blueprints installed — run /refresh-agent-os to install)`

Exit Phase 7 cleanly. No fail row, no error, no auto-create.

### 7.2 File enumeration

If `~/.claude/blueprints/` exists, enumerate all files matching `~/.claude/blueprints/*.md` (top level only — no recursion). For each file, run the per-file validation block below. An error in one file does not abort the phase — continue to the next file.

### 7.3 Per-file validation block

For each `~/.claude/blueprints/<filename>.md`:

**a. Frontmatter parse.** Read the file and parse the YAML frontmatter (delimited by `---` lines). If the frontmatter is missing or malformed (no opening `---`, no closing `---`, or invalid YAML that cannot be parsed), emit a fail row:

> `<filename>: invalid or missing frontmatter (could not parse YAML)`
> Remediation: Re-author the file per `claude/blueprints-schema.md` §8 file format template, or run `/refresh-agent-os` to restore the canonical version.

Continue to the next file. Do NOT crash the phase.

**b. Required field presence.** Confirm the parsed frontmatter contains all six required fields: `name`, `description`, `tools`, `expected_output`, `model`, `schema_version`. For each missing field, emit a fail row:

> `<filename>: required frontmatter field absent: <field>`
> Remediation: Add the missing field per `claude/blueprints-schema.md` §2 field reference.

**c. `name:` ↔ filename invariant.** Confirm the frontmatter `name:` value equals the filename minus the `.md` extension (e.g. `task-coder.md` must have `name: task-coder`). If mismatch, emit a fail row:

> `<filename>: name field "<value>" does not match filename`
> Remediation: Rename the file or update the name field so they match exactly (filename minus .md).

**d. `task-` prefix invariant.** Confirm the frontmatter `name:` value starts with `task-`. If not, emit a fail row:

> `<filename>: name "<value>" does not start with the required task- prefix`
> Remediation: Rename the file and update the name field to use the task- prefix per `claude/blueprints-schema.md` §4 naming convention.

**e. `expected_output:` first-sentence sync rule.** Locate the H2 section heading exactly matching `## Expected Output Contract` (case-sensitive, exact whitespace) in the file body. If the section is absent, emit a fail row:

> `<filename>: required body section "## Expected Output Contract" absent`
> Remediation: Add the section per `claude/blueprints-schema.md` §3 required body sections, ensuring the first sentence equals the frontmatter expected_output: value.

Skip the sync-rule check for this file (already failed on absent section).

If the section is present, extract the first sentence of the section body — defined as the text from the start of the section body (first non-blank line after the heading) up to and including the first period (`.`) that ends a sentence, excluding periods inside inline code spans (`` `...` ``). Trim leading and trailing whitespace on both the extracted first sentence and the frontmatter `expected_output:` value. Compare character-for-character. If they do not match exactly, emit a fail row:

> `<filename>: expected_output sync rule violation — frontmatter value does not match first sentence of body's ## Expected Output Contract section`
> Frontmatter: <frontmatter value>
> Body first sentence: <extracted first sentence>
> Remediation: Update the frontmatter expected_output: value to equal the first sentence of the body's ## Expected Output Contract section verbatim, OR update the body to match the frontmatter. The two surfaces must agree per `claude/blueprints-schema.md` §3 sync rule.

### 7.4 Pass condition

Phase 7 passes if every enumerated file passes every check in §7.3 (or if `~/.claude/blueprints/` is absent — see §7.1).

---

## Phase 8: Claude Code Version Notice

**Phase 8 is informational and does not affect OVERALL.** All output from Phase 8 is passive notice — no fail rows, no contribution to the OVERALL fail count.

**Rationale:** The v2.1.172 threshold is a recommendation for tier-2 autonomous-mode spawning (per Q0 research), not a hard correctness requirement. Because `claude --version`'s output format is not separately versioned by Anthropic, a future format change should not break the health check. Phase 8 therefore degrades gracefully on any parse failure and never flips the OVERALL verdict.

**Source:** `claude --version` (`claude -v`) is documented as a stable CLI flag at `https://code.claude.com/docs/en/cli-reference`. Defensive parsing is used because the output format (`<semver> (Claude Code)`) is not separately specified as a stability contract.

### 8.1 Invocation

Run `claude --version` in a defensive subshell that does not abort Phase 8 on non-zero exit:

```bash
version_output=$(claude --version 2>/dev/null)
exit_code=$?
```

### 8.2 Parse

Extract the version string by taking the first whitespace-delimited token of the first line of stdout. Apply a permissive regex (`^[0-9]+\.[0-9]+\.[0-9]+`) to accept prerelease suffixes (e.g. `2.1.172-beta.1` parses as `2.1.172`).

### 8.3 Threshold comparison

Compare the parsed `major.minor.patch` tuple to the threshold `2.1.172` element-wise: version is at-or-above threshold if major > 2, OR (major == 2 AND minor > 1), OR (major == 2 AND minor == 1 AND patch >= 172).

### 8.4 Output cases (notice only — never fail rows)

**Case a — Parse succeeded AND version >= 2.1.172:** emit:
> `Claude Code version OK (v<X.Y.Z>)`

**Case b — Parse succeeded AND version < 2.1.172:** emit:
> `Claude Code v2.1.172+ recommended for autonomous mode (detected: v<X.Y.Z>)`

**Case c — Parse failed** (binary unavailable, exit code != 0, output does not match the version regex, or stdout is empty): emit:
> `Claude Code v2.1.172+ recommended for autonomous mode (could not detect installed version)`

---

## Phase 9: Report

Emit the full report with one clearly-labeled section per phase. Each section states whether the phase **PASSED** or **FAILED**, and if failed, lists every fail row with its remediation hint. Phase 4 has three sub-checks (4a model format, 4b WebFetch, 4c isolation); each sub-check contributes its fail rows to the overall count. Phase 7 fail rows are included in the OVERALL count. **Phase 8 notices are NOT included in the OVERALL fail count — Phase 8 is informational only.**

Example structure:

```
### Phase 1: Skill Install Check — PASSED
All canonical skills are installed.

### Phase 2: Auto-Trigger / Skill-Reference Check — FAILED
- Line 14: `/start-sprint` → ~/.claude/skills/start-sprint/SKILL.md not found
  Remediation: Edit `CLAUDE.md` to remove or rename the reference, or run `/refresh-agent-os` if the skill should be installed.

### Phase 3: Required docs/context/ Check — PASSED
All three required context files exist and are non-empty.

### Phase 4: Agent Frontmatter Check

#### 4a: Model Format Check — PASSED
All agent model values use canonical short form.

#### 4b: WebFetch Tools Frontmatter Check — PASSED
All agent files include WebFetch in their tools list.

#### 4c: Specialist isolation: worktree Check — PASSED
All Specialist agents have isolation: worktree in frontmatter.

### Phase 7: Blueprint Frontmatter Validity Check — PASSED
All installed blueprints have valid frontmatter and pass all invariants.

### Phase 8: Claude Code Version Notice (informational — does not affect OVERALL)
Claude Code v2.1.172+ recommended for autonomous mode (detected: v2.1.150)

OVERALL: FAIL (1 issue)
```

The final line of the report **must** be exactly one of:
- `OVERALL: PASS`
- `OVERALL: FAIL (N issues)` — where N is the total count of fail rows across all phases and sub-checks (Phases 1, 2, 3, 4, and 7). Phase 8 notices are never counted.

---

## Phase 10: Timestamp on Success

- **If `OVERALL: PASS`:** write today's ISO date as a single line (e.g. `2026-05-23`) to `.agent-os-checked` at the project root. Print:
  > `Wrote .agent-os-checked (next reminder in 30 days)`
- **If `OVERALL: FAIL`:** do NOT create or modify `.agent-os-checked`. The 30-day session-start reminder will continue to appear until all issues are resolved and the check passes.

Phase 10 fires after Phase 9 regardless of Phase 8's notice content — the timestamp is written on every OVERALL PASS even when Phase 8 emits a version advisory.

---

## Hard Constraints

- Read-only **except** for the single `.agent-os-checked` write at project root on PASS.
- Never auto-fix; only report. Remediation is up to the user.
- If the canonical source cannot be resolved (URL fails AND local clone absent), stop and ask the user — do not proceed to later phases.
- Each phase has explicit pass/fail criteria and surfaces a remediation hint for every fail row.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source resolved (URL primary, local clone fallback) before Phase 1 ran
- [ ] All phases (1, 2, 3, 4, 7, 8) executed in order; Phase 9 Report and Phase 10 Timestamp run last
- [ ] Report ends with explicit `OVERALL: PASS` or `OVERALL: FAIL (N issues)` line
- [ ] On PASS, `.agent-os-checked` was written with today's ISO date (single line)
- [ ] On FAIL, `.agent-os-checked` was NOT created or modified
- [ ] Every fail row in the report includes a remediation hint
- [ ] Phase 4b: every `.claude/agents/*.md` was checked for `WebFetch` in the `tools:` list; any absent entries are FAIL rows with remediation "Run `/refresh-agent-os` to sync with canonical."
- [ ] Phase 4c: each agent identified as a Specialist (has `## Sign-Off Protocol` with `**Track:**` and `**Completed:**` fields) was checked for `isolation: worktree` in frontmatter; any absent entries are FAIL rows with the same remediation hint
- [ ] Phase 7: `~/.claude/blueprints/` absent-directory case handled as PASS with notice (no fail row, no auto-create)
- [ ] Phase 7: each `~/.claude/blueprints/*.md` checked for all six required fields, name/filename match, task- prefix, and expected_output: first-sentence sync rule; malformed frontmatter emits a fail row and continues (does not crash)
- [ ] Phase 8: `claude --version` invoked with defensive parsing; one of the three output cases emitted as a notice line; Phase 8 does not contribute any fail rows to OVERALL
- [ ] Phase 9 OVERALL count includes fail rows from Phases 1, 2, 3, 4, and 7 only (Phase 8 notices excluded)
