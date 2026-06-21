---
name: refresh-agent-os
description: Synchronizes your local `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/blueprints/` installation against the canonical Agent OS skill, agent, and blueprint library.
---
# Refresh Agent OS
Synchronizes your local `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/blueprints/` installations against the canonical Agent OS library. Reads the canonical manifest from a remote URL stored in `AGENTIC.md` (with a local clone fallback), diffs your installed skills, agents, and blueprints against the canonical set, surfaces the current release version and release notes, and presents a per-row action table for you to approve before anything is changed. Nothing is written, renamed, or removed without your explicit confirmation.

## Trigger
When the user runs `/refresh-agent-os`, execute the following phases in order.

---

## Phase 1: Resolve Canonical Source

1. Read `AGENTIC.md` and look for a line matching: `Canonical skills manifest URL: <url>`
2. **If the line is absent:**
   - Ask the user: "No canonical manifest URL found in `AGENTIC.md`. Please confirm the URL for `skills-manifest.json` (e.g. `https://raw.githubusercontent.com/<owner>/agent-os/main/skills-manifest.json`)."
   - Once the user confirms, write the following line to `AGENTIC.md` immediately after the `Dynamic DNA` bullet under §1 DNA Taxonomy: `- **Canonical skills manifest URL:** \`<confirmed-url>\``
   - This is the **only** write this skill ever makes outside `~/.claude/skills/` and `~/.claude/agents/`, and it only happens on first run after explicit user confirmation.
   - Continue to step 3.
3. **If the line is present:** attempt to fetch the JSON from the URL.
4. **Fallback:** if the URL fetch fails (network unavailable, 404, or any HTTP error), fall back to the local canonical clone:
   - Manifest: `~/Developer/agent-os-private/skills-manifest.json`
   - Skill files: `~/Developer/agent-os-private/claude/skills/` (each skill lives at `~/Developer/agent-os-private/claude/skills/<name>/SKILL.md`)
   - Agent files: `~/Developer/agent-os-private/claude/agents/` (each agent lives at `~/Developer/agent-os-private/claude/agents/<name>.md`)
   - Notify the user: "Could not reach the canonical URL — using local clone at `~/Developer/agent-os-private/` as fallback."
5. **If neither the URL nor the local clone resolves:** stop and ask the user to supply a path or URL. Do not proceed to Phase 2 until a canonical source is confirmed.
6. **Blueprints manifest:** Locate `blueprints-manifest.json` at the same level as `skills-manifest.json` in the resolved canonical source (local clone path: `~/Developer/agent-os-private/blueprints-manifest.json`). If the file is absent (e.g. running against an older canonical clone that predates T19.2), treat the canonical blueprint set as empty and proceed without error — no URL fetch attempt is made for this manifest in S19 (canonical URL extension deferred to a future sprint).

---

## Phase 2: Inventory

**Skills:**
1. Check whether `~/.claude/skills/` exists.
   - If **absent**: silently create the directory (`mkdir -p ~/.claude/skills/`). The installed skill set is empty. Do not display any message about the directory's prior absence. Proceed to step 2.
   - If **present**: continue to step 2.
2. List all `<name>/` subdirectories in `~/.claude/skills/` that contain a `SKILL.md` file (i.e. `~/.claude/skills/<name>/SKILL.md` exists). Strip the directory name to get bare skill names. This is the **installed skill set**.
3. Read the `skills` array from the resolved manifest. This is the **canonical skill set**.

**Agents:**
4. Check whether `~/.claude/agents/` exists.
   - If **absent**: silently create the directory (`mkdir -p ~/.claude/agents/`). The installed agent set is empty. Do not display any message about the directory's prior absence. Proceed to step 5.
   - If **present**: continue to step 5.
5. List all `<name>.md` files in `~/.claude/agents/` (i.e. `~/.claude/agents/<name>.md` exists). Strip the extension to get bare agent names. This is the **installed agent set**.
6. Read the `agents` array from the resolved manifest. This is the **canonical agent set**.

**Blueprints:**
4-blueprints. Check whether `~/.claude/blueprints/` exists.
   - If **absent**: silently create the directory (`mkdir -p ~/.claude/blueprints/`). The installed blueprint set is empty. Do not display any message about the directory's prior absence. Proceed to step 5-blueprints.
   - If **present**: continue to step 5-blueprints.
5-blueprints. List all `<name>.md` files in `~/.claude/blueprints/` (i.e. `~/.claude/blueprints/<name>.md` exists). Strip the extension to get bare blueprint names. This is the **installed blueprint set**.
6-blueprints. Read the `blueprints` array from the resolved `blueprints-manifest.json`. This is the **canonical blueprint set**. If `blueprints-manifest.json` was not resolved in Phase 1, the canonical blueprint set is empty.

**Release info:**
7. Read `release-version` from the manifest. This is the **canonical release version**.
8. Attempt to read the corresponding release note from `docs/releases/<release-version>.md` in the canonical source. Hold it for Phase 4.

Display neither list yet — hold all data for Phase 3.

---

## Phase 3: Diff

**For skills** — produce three lists by comparing the canonical skill set against the installed skill set:

**a. New** — names present in the canonical `skills` array but absent from `~/.claude/skills/`.
These are skills available in canonical that you do not have installed.

**b. Removed** — names present in `~/.claude/skills/` but absent from the canonical `skills` array.
For each removed name:
- **Cross-array invariant guard (fires before the rename lookup):** Check whether the candidate name is present in the canonical `skills` array. Because the candidate is already defined as a name absent from canonical `skills`, this guard is vacuously true for a clean manifest — but if a §9.7.2 manifest invariant violation exists (the name appears in both `skills` and `renames[].from`), the candidate will pass the initial "absent from canonical `skills`" filter incorrectly. Therefore: when matching a candidate against the `renames` array, **first confirm the candidate is NOT present in the canonical `skills` array**. If the candidate IS in canonical `skills`, skip the `renames` match entirely — treat the candidate as "current" (no rename, no removal). Surface the one-line diagnostic: `Manifest invariant warning: <name> appears in both skills[] and renames[].from. Treating as canonical (no action).`
- First, check the manifest `renames` array. If an entry `{ "from": "<name>", "to": "<new-name>" }` matches (and the guard above did not fire), surface it as a **confirmed rename** (no guessing required).
- For removed names not covered by any `renames` entry, apply a name-similarity heuristic (e.g. Levenshtein distance, shared prefix/suffix) as a **suggestion only**. Label it clearly as "possible rename" and require explicit user confirmation before treating it as a rename.

**c. Drifted** — names present in both `~/.claude/skills/` and the canonical set, but whose file contents differ (a `diff` of the two `SKILL.md` files is non-empty). These are installed skills that have diverged from the canonical version.

**For agents** — produce three parallel lists by comparing the canonical agent set against the installed agent set:

**a. New** — names present in the canonical `agents` array but absent from `~/.claude/agents/`.
These are agents available in canonical that you do not have installed.

**b. Removed** — names present in `~/.claude/agents/` but absent from the canonical `agents` array.
Apply the same rename-check logic as for skills: **cross-array invariant guard first** — when matching a candidate against the `renames` array, confirm the candidate is NOT present in the canonical `agents` array. If the candidate IS in canonical `agents`, skip the `renames` match entirely — treat the candidate as "current" (no rename, no removal) and surface: `Manifest invariant warning: <name> appears in both agents[] and renames[].from. Treating as canonical (no action).` Then check `renames` array first (confirmed rename), then heuristic-as-suggestion only.

**c. Drifted** — names present in both `~/.claude/agents/` and the canonical set, but whose file contents differ (a `diff` of the two agent `.md` files is non-empty). These are installed agents that have diverged from the canonical version.

**Compatibility window check:** When diffing agents, if the canonical agent has a frontmatter field absent from the user's installed agent (e.g. `provider:`), surface this as a **drifted** entry with the note "new frontmatter field available — missing field defaults to `<value>` per compatibility window." Do not treat a missing-but-defaultable field as a breaking diff.

**For blueprints** — produce three parallel lists by comparing the canonical blueprint set against the installed blueprint set:

**a. New** — names present in the canonical `blueprints` array but absent from `~/.claude/blueprints/`.
These are blueprints available in canonical that you do not have installed.

**b. Removed** — names present in `~/.claude/blueprints/` but absent from the canonical `blueprints` array.
Apply the same rename-check logic as for skills and agents: **cross-array invariant guard first** — when matching a candidate against the `renames` array, confirm the candidate is NOT present in the canonical `blueprints` array. If the candidate IS in canonical `blueprints`, skip the `renames` match entirely — treat the candidate as "current" (no rename, no removal) and surface: `Manifest invariant warning: <name> appears in both blueprints[] and renames[].from. Treating as canonical (no action).` Then check `renames` array first (confirmed rename), then heuristic-as-suggestion only.

**c. Drifted** — names present in both `~/.claude/blueprints/` and the canonical set, but whose file contents differ (a `diff` of the two `<name>.md` files is non-empty). These are installed blueprints that have diverged from the canonical version.

**Compatibility window check (blueprints):** if the canonical blueprint has a frontmatter field absent from the user's installed blueprint (e.g. a future `verification_command:` field), surface this as a **drifted** entry with the note "new frontmatter field available — missing field defaults to `<value>` per compatibility window." Do not treat a missing-but-defaultable field as a breaking diff. (For S19, no such optional fields exist — this clause is forward-compatible scaffolding only.)

**CLAUDE.md reference scan (fires on rename or removal only):**

If and only if the diff contains at least one rename or removal (for skills or agents) — **not** on install-only or update-only runs — perform the following:

1. Check whether a `CLAUDE.md` file exists in the working directory. If absent, skip this scan (vacuous pass — no output required).
2. If present, scan the `CLAUDE.md` for references to any skill name that appears in the Removed or Renamed buckets. Search the following surfaces:
   - Auto-trigger table rows (e.g. `| ... | /skill-name | ...` or `| User says... | Invoke skill-name |`)
   - Inline `/skill-name` mentions in prose
   - Explicit `~/.claude/skills/<name>/SKILL.md` path literals
3. For each hit, record: the line number, the old reference text, and the proposed replacement (e.g. update `/open-sprint` → `/start-sprint`, or remove a row whose skill has been deleted from canonical).
4. Collect all hits as the **`CLAUDE.md reference list`**. If no hits, the list is empty (no output needed).
5. Hold the `CLAUDE.md reference list` for Phase 4. Do not display or modify anything yet.

---

## Phase 4: Present Report

**Surface release information first:**

If the canonical release version differs from the last-applied version (or if the user has no recorded last-applied version), display:

```
Agent OS canonical release: v0.9.0
Release notes:
  [content of docs/releases/v0.9.0.md, or "Release notes not available." if the file could not be read]
```

Then display the diff table. One row per skill, agent, blueprint, or CLAUDE.md reference affected. Prefix agent rows with `[agent]`, skill rows with `[skill]`, blueprint rows with `[blueprint]`, and CLAUDE.md reference rows with `[claude.md]` for clarity. If there are no differences across skills, agents, blueprints, and CLAUDE.md references, state: "Your installation is up to date — no changes needed." and stop.

```
| Name                              | Type      | Status      | Proposed action                                              |
|-----------------------------------|-----------|-------------|--------------------------------------------------------------|
| refresh-agent-os                  | skill     | New         | Install → ~/.claude/skills/refresh-agent-os/                 |
| start-sprint                      | skill     | Removed     | Confirmed rename → open-sprint (manifest)                    |
| old-skill                         | skill     | Removed     | Possible rename → new-skill (suggestion)                     |
| onboard-existing-project          | skill     | Drifted     | Update → overwrite with canonical SKILL.md                   |
| audit-security                    | skill     | Current     | Skip (no changes)                                            |
| researcher                        | agent     | New         | Install → ~/.claude/agents/researcher.md                     |
| ops                               | agent     | Drifted     | Update → overwrite with canonical ops.md                     |
| architect                         | agent     | Drifted     | Update → add provider: field (compatibility window)          |
| task-coder                        | blueprint | New         | Install → ~/.claude/blueprints/task-coder.md                 |
| CLAUDE.md line 14                 | claude.md | Rename ref  | Update /open-sprint → /start-sprint                          |
```

Ask: "Approve all actions, a subset (list the names), or decline?"

Wait for the user's response before proceeding to Phase 5. Do not apply any changes without this confirmation.

---

## Phase 5: Apply

For each action the user approved, execute it one at a time:

**Skills:**
- **Install:** create the directory `~/.claude/skills/<name>/` and copy the canonical `SKILL.md` into it. Print: `installed ~/.claude/skills/<name>/SKILL.md`
- **Rename (confirmed from manifest):** rename `~/.claude/skills/<old-name>/` to `~/.claude/skills/<new-name>/` and, if the new name is in the canonical set, overwrite `~/.claude/skills/<new-name>/SKILL.md` with the canonical version. Print: `renamed ~/.claude/skills/<old-name>/ → ~/.claude/skills/<new-name>/`
- **Rename (user-confirmed suggestion):** same as above, but only after the user has explicitly confirmed the suggestion in Phase 4.
- **Remove:** delete the `~/.claude/skills/<name>/` directory (including its `SKILL.md`). Print: `removed ~/.claude/skills/<name>/`
- **Update:** overwrite `~/.claude/skills/<name>/SKILL.md` with the canonical version. Print: `updated ~/.claude/skills/<name>/SKILL.md`
- **Skip:** take no action. Print: `skipped <name>`

**Agents:**
- **Install:** create `~/.claude/agents/<name>.md` and copy the canonical agent file into it. Print: `installed ~/.claude/agents/<name>.md`
- **Rename (confirmed from manifest):** rename `~/.claude/agents/<old-name>.md` to `~/.claude/agents/<new-name>.md` and, if the new name is in the canonical set, overwrite it with the canonical version. Print: `renamed ~/.claude/agents/<old-name>.md → ~/.claude/agents/<new-name>.md`
- **Rename (user-confirmed suggestion):** same as above, but only after the user has explicitly confirmed the suggestion in Phase 4.
- **Remove:** delete `~/.claude/agents/<name>.md`. Print: `removed ~/.claude/agents/<name>.md`
- **Update:** overwrite `~/.claude/agents/<name>.md` with the canonical version. Print: `updated ~/.claude/agents/<name>.md`
- **Skip:** take no action. Print: `skipped <name>`

**Blueprints:**
- **Install:** create `~/.claude/blueprints/<name>.md` and copy the canonical blueprint file into it. Print: `installed ~/.claude/blueprints/<name>.md`
- **Rename (confirmed from manifest):** rename `~/.claude/blueprints/<old-name>.md` to `~/.claude/blueprints/<new-name>.md` and, if the new name is in the canonical set, overwrite it with the canonical version. Print: `renamed ~/.claude/blueprints/<old-name>.md → ~/.claude/blueprints/<new-name>.md`
- **Rename (user-confirmed suggestion):** same as above, but only after the user has explicitly confirmed the suggestion in Phase 4.
- **Remove:** delete `~/.claude/blueprints/<name>.md`. Print: `removed ~/.claude/blueprints/<name>.md`
- **Update:** overwrite `~/.claude/blueprints/<name>.md` with the canonical version. Print: `updated ~/.claude/blueprints/<name>.md`
- **Skip:** take no action. Print: `skipped <name>`

**CLAUDE.md references** (applied after all skill and agent changes):
- For each `[claude.md]` row the user approved in Phase 4, apply the proposed edit to `CLAUDE.md` — update the old reference to the proposed replacement. Print: `updated CLAUDE.md line <N>: <old-ref> → <new-ref>`
- No additional user-approval gate is required. Phase 4 approval covers these changes.

Never apply an action the user did not explicitly approve.

---

## Phase 6: Summary

After all approved actions are complete, print a one-line summary:

```
Refresh complete: N installed, N renamed, N removed, N updated, N skipped.
Skills: <counts>. Agents: <counts>. Blueprints: <counts>. CLAUDE.md: <N> reference(s) updated.
```

---

## Phase 7: CLAUDE.md Stale Reference Patch

**Condition:** Runs only when the diff produced at least one change this run (any install, rename, or removal for skills or agents). If no diff changes occurred, skip Phase 7 silently.

1. Check whether a `CLAUDE.md` file exists in the working directory.
   - If **absent**: print `No CLAUDE.md in working directory — skipping stale-reference scan.` and return from Phase 7.
   - If **present**: continue to step 2.

2. For each entry in the `renames[]` array from `skills-manifest.json`, search `CLAUDE.md` for occurrences of the `from` name. Search the following surfaces:
   - Auto-trigger table rows containing `/from-name` (e.g. `| User says... | /from-name | ...`)
   - Inline `/from-name` mentions in prose
   - Explicit `~/.claude/skills/from-name/SKILL.md` path literals
   - Any cell in an auto-trigger table that references the bare `from-name`

3. Collect all hits. For each hit, record: the line number, the full line context, and the proposed rewrite (replace the `from` name with the corresponding `to` name from the `renames[]` entry).

4. **If hits were found:** present each one in turn using the same UX as Phase 5 CLAUDE.md reference updates:
   - Show: line number, current line text, and proposed rewrite.
   - Ask the user to approve, decline, or provide an edited replacement for each hit individually.
   - Apply only the user-approved patches. Do not apply any patch the user declined.
   - Print for each applied patch: `updated CLAUDE.md line <N>: <old-ref> → <new-ref>`

5. **If no hits were found** across all `renames[]` entries: print `No stale skill references found in CLAUDE.md.` and return from Phase 7.

---

## Hard Constraints

- **Never write outside `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/blueprints/`**, with the **single** documented exception of adding the `Canonical skills manifest URL:` line to `AGENTIC.md` on first run — and only after explicit user confirmation. CLAUDE.md reference updates (Phase 5) are an additional in-scope write when explicitly approved by the user in Phase 4.
- **Never delete a file or directory the user has not explicitly approved for removal.** A skill or agent in the Removed list is not deleted until the user says so.
- **If neither the canonical URL nor the local clone resolves**, stop and ask the user to supply a path or URL. Do not proceed without a confirmed source.
- **Phase 3 Diff must prefer the manifest's `renames` array over any name-similarity heuristic.** The heuristic is suggestion-only and requires user confirmation before any rename action is taken.
- **Surface release notes before presenting the action table.** The user must see what changed before being asked to approve writes.
- **Compatibility window:** never treat a missing-but-defaultable frontmatter field as a hard error. Surface it as a drift item with the documented default value. The minimum compatibility window is 2 sprints per AGENTIC.md §9.2.
- **CLAUDE.md scan is conditional:** Phase 3 scans `CLAUDE.md` only when the diff contains at least one rename or removal. It does not fire on install-only or update-only runs. If no `CLAUDE.md` exists, the scan is skipped silently.
- **Phase 7 is conditional:** Phase 7 runs only when the diff produced at least one change this run (any install, rename, or removal). It does not run on a no-change invocation. If `CLAUDE.md` is absent from the working directory, Phase 7 prints the absent-path message and returns. Phase 7 checks `CLAUDE.md` against every `renames[].from` value in the manifest — not just the renames from the current diff — so long-dormant stale references are also caught.
- **Absent directories are created silently:** If `~/.claude/skills/`, `~/.claude/agents/`, or `~/.claude/blueprints/` is absent at Phase 2, create it silently and treat the installed set as empty. No user message. No prompt. Surface an error only if directory creation fails.
- **Manifest cross-array invariant (AGENTIC.md §9.7.2):** If a skill name appears in both `renames[].from` and the canonical `skills` array (a §9.7.2 invariant violation in the manifest), canonical `skills` membership is authoritative. The skill MUST NOT propose a rename or removal action for that name. Surface a one-line diagnostic to the user: `Manifest invariant warning: <name> appears in both skills[] and renames[].from. Treating as canonical (no action).` The same rule applies symmetrically to agent names: if a name appears in both `renames[].from` and the canonical `agents` array, canonical `agents` membership is authoritative and no rename or removal is proposed. The same rule applies symmetrically to blueprint names: if a name appears in both `renames[].from` and the canonical `blueprints` array, canonical `blueprints` membership is authoritative and no rename or removal is proposed. This is a runtime defense against the §9.7.2 contract being violated by a future manifest edit — in a clean manifest the guard fires vacuously and has no effect.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source resolved before any prompt was shown (URL primary, local clone fallback)
- [ ] If fallback was used, user was notified
- [ ] If URL was absent, user confirmed it before writing to AGENTIC.md
- [ ] `~/.claude/skills/` and `~/.claude/agents/` existence checked; absent directories created silently with no user message
- [ ] `~/.claude/blueprints/` existence checked; absent directory created silently with no user message
- [ ] Release version read from manifest and release notes fetched (or "not available" noted)
- [ ] Release notes surfaced to user before the action table was shown
- [ ] Phase 3 Diff run for both skills (`~/.claude/skills/`) and agents (`~/.claude/agents/`)
- [ ] Phase 3 Diff run for blueprints (`~/.claude/blueprints/`) against canonical blueprints array
- [ ] Phase 3 Diff cross-checked the manifest `renames` array before applying heuristic (for both skills and agents)
- [ ] Phase 3 Diff cross-checked the manifest renames array before applying heuristic (for blueprints)
- [ ] Cross-array invariant guard applied before each `renames` lookup: for skills, confirmed candidate is NOT in canonical `skills` before matching against `renames`; for agents, confirmed candidate is NOT in canonical `agents` before matching against `renames`; for blueprints, confirmed candidate is NOT in canonical `blueprints` before matching against `renames`
- [ ] Manifest cross-array invariant violation (if any) was detected and surfaced as a diagnostic (`Manifest invariant warning: <name> appears in both skills[] and renames[].from. Treating as canonical (no action).`), and no rename/removal action was proposed for the colliding name
- [ ] Compatibility-window check applied: missing-but-defaultable agent frontmatter fields surfaced as drift with documented default, not as errors
- [ ] If diff contains at least one rename or removal: CLAUDE.md scanned for stale references (auto-trigger rows, inline `/skill-name` mentions, path literals); results held for Phase 4
- [ ] If diff contains install-only or update-only changes: CLAUDE.md scan did NOT fire; no `[claude.md]` rows in Phase 4 table
- [ ] Phase 4 table shown and user confirmed before any file was modified; `[claude.md]` rows included if CLAUDE.md scan produced hits
- [ ] No file was modified without explicit confirmation
- [ ] Rename source identified (manifest-confirmed vs. user-confirmed suggestion) is visible in the report
- [ ] CLAUDE.md updates applied after skill/agent changes in Phase 5 (if any were approved)
- [ ] Phase 6 summary printed at end with per-type counts including CLAUDE.md reference count
- [ ] Phase 7 ran (if diff changes occurred); CLAUDE.md checked against every renames[].from value; user-approved patches applied
