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
   - This is the **only** write this skill ever makes to `AGENTIC.md` — and it only happens on first run after explicit user confirmation. See the Hard Constraints section for the full enumerated write-target list.
   - Continue to step 3.
3. **If the line is present:** attempt to fetch the JSON from the URL.
4. **Fallback:** if the URL fetch fails (network unavailable, 404, or any HTTP error), fall back to the local canonical clone:
   - Manifest: `~/Developer/agent-os/skills-manifest.json`
   - Skill files: `~/Developer/agent-os/claude/skills/` (each skill lives at `~/Developer/agent-os/claude/skills/<name>/SKILL.md`)
   - Agent files: `~/Developer/agent-os/claude/agents/` (each agent lives at `~/Developer/agent-os/claude/agents/<name>.md`)
   - Notify the user: "Could not reach the canonical URL — using local clone at `~/Developer/agent-os/` as fallback."
5. **If neither the URL nor the local clone resolves:** stop and ask the user to supply a path or URL. Do not proceed to Phase 2 until a canonical source is confirmed.
6. **Blueprints manifest:** Locate `blueprints-manifest.json` at the same level as `skills-manifest.json` in the resolved canonical source (local clone path: `~/Developer/agent-os/blueprints-manifest.json`). If the file is absent (e.g. running against an older canonical clone that predates T19.2), treat the canonical blueprint set as empty and proceed without error — no URL fetch attempt is made for this manifest in S19 (canonical URL extension deferred to a future sprint).

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

**c. Outdated** — names present in both `~/.claude/skills/` and the canonical set, but whose file contents differ (a `diff` of the two `SKILL.md` files is non-empty). These are installed skills that have diverged from the canonical version.

**For agents** — produce three parallel lists by comparing the canonical agent set against the installed agent set:

**a. New** — names present in the canonical `agents` array but absent from `~/.claude/agents/`.
These are agents available in canonical that you do not have installed.

**b. Removed** — names present in `~/.claude/agents/` but absent from the canonical `agents` array.
Apply the same rename-check logic as for skills: **cross-array invariant guard first** — when matching a candidate against the `renames` array, confirm the candidate is NOT present in the canonical `agents` array. If the candidate IS in canonical `agents`, skip the `renames` match entirely — treat the candidate as "current" (no rename, no removal) and surface: `Manifest invariant warning: <name> appears in both agents[] and renames[].from. Treating as canonical (no action).` Then check `renames` array first (confirmed rename), then heuristic-as-suggestion only.

**c. Outdated** — names present in both `~/.claude/agents/` and the canonical set, but whose file contents differ (a `diff` of the two agent `.md` files is non-empty). These are installed agents that have diverged from the canonical version.

**Compatibility window check:** When diffing agents, if the canonical agent has a frontmatter field absent from the user's installed agent (e.g. `provider:`), surface this as a **outdated** entry with the note "new frontmatter field available — missing field defaults to `<value>` per compatibility window." Do not treat a missing-but-defaultable field as a breaking diff.

**For blueprints** — produce three parallel lists by comparing the canonical blueprint set against the installed blueprint set:

**a. New** — names present in the canonical `blueprints` array but absent from `~/.claude/blueprints/`.
These are blueprints available in canonical that you do not have installed.

**b. Removed** — names present in `~/.claude/blueprints/` but absent from the canonical `blueprints` array.
Apply the same rename-check logic as for skills and agents: **cross-array invariant guard first** — when matching a candidate against the `renames` array, confirm the candidate is NOT present in the canonical `blueprints` array. If the candidate IS in canonical `blueprints`, skip the `renames` match entirely — treat the candidate as "current" (no rename, no removal) and surface: `Manifest invariant warning: <name> appears in both blueprints[] and renames[].from. Treating as canonical (no action).` Then check `renames` array first (confirmed rename), then heuristic-as-suggestion only.

**c. Outdated** — names present in both `~/.claude/blueprints/` and the canonical set, but whose file contents differ (a `diff` of the two `<name>.md` files is non-empty). These are installed blueprints that have diverged from the canonical version.

**Compatibility window check (blueprints):** if the canonical blueprint has a frontmatter field absent from the user's installed blueprint (e.g. a future `verification_command:` field), surface this as a **outdated** entry with the note "new frontmatter field available — missing field defaults to `<value>` per compatibility window." Do not treat a missing-but-defaultable field as a breaking diff. (For S19, no such optional fields exist — this clause is forward-compatible scaffolding only.)

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
| onboard-existing-project          | skill     | Outdated     | Update → overwrite with canonical SKILL.md                   |
| audit-security                    | skill     | Current     | Skip (no changes)                                            |
| researcher                        | agent     | New         | Install → ~/.claude/agents/researcher.md                     |
| ops                               | agent     | Outdated     | Update → overwrite with canonical ops.md                     |
| sprint-coordinator                | agent     | New         | Install → ~/.claude/agents/sprint-coordinator.md             |
| technical-architect               | agent     | New         | Install → ~/.claude/agents/technical-architect.md            |
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

## Phase 5.5: Post-Deploy Project-Local Sync

**Condition:** Runs automatically after Phase 5 (Apply) completes, whenever at least one action was applied. If no actions were applied (all skipped or no diff), skip Phase 5.5 silently.

This phase re-syncs the project-local artifact directories (`.claude/skills/`, `.claude/agents/`, `.claude/blueprints/`) against the global install directories (`~/.claude/skills/`, `~/.claude/agents/`, `~/.claude/blueprints/`). Global is canonical — any file present in global but absent or diverged locally is overwritten with the global copy.

### Step 1 — Determine project-local root

Identify whether a `.claude/` directory exists in the working directory. If absent, skip Phase 5.5 silently — the project has no project-local artifact directories to sync.

### Step 2 — Check project-local target directories

For each of the three artifact types, check whether the project-local directory exists:

- `.claude/skills/` — project-local skills directory
- `.claude/agents/` — project-local agents directory
- `.claude/blueprints/` — project-local blueprints directory (if applicable)

**Absent-path handling (§9.7.1 binding):** if a project-local target directory is absent, create it silently (`mkdir -p .claude/<dir>/`). Treat the local install as empty — all artifacts that exist globally will sync in. Never crash on an absent local directory. Never prompt the user about the creation.

### Step 3 — Diff global against project-local and sync

For each artifact type:

**Skills** (`~/.claude/skills/<name>/SKILL.md` vs `.claude/skills/<name>/SKILL.md`):
- For each skill present in `~/.claude/skills/`:
  - If `.claude/skills/<name>/SKILL.md` is **absent**: copy the global file to the project-local path. Create the subdirectory (`mkdir -p .claude/skills/<name>/`) if needed.
  - If `.claude/skills/<name>/SKILL.md` is **present but diverged** (diff is non-empty): overwrite the local file with the global version.
  - If **in sync** (diff is empty): no action.

**Agents** (`~/.claude/agents/<name>.md` vs `.claude/agents/<name>.md`):
- For each agent present in `~/.claude/agents/`:
  - If `.claude/agents/<name>.md` is **absent**: copy the global file to the project-local path.
  - If `.claude/agents/<name>.md` is **present but diverged** (diff is non-empty): overwrite the local file with the global version.
  - If **in sync** (diff is empty): no action.

**Blueprints** (`~/.claude/blueprints/<name>.md` vs `.claude/blueprints/<name>.md`):
- For each blueprint present in `~/.claude/blueprints/`:
  - If `.claude/blueprints/<name>.md` is **absent**: copy the global file to the project-local path.
  - If `.claude/blueprints/<name>.md` is **present but diverged** (diff is non-empty): overwrite the local file with the global version.
  - If **in sync** (diff is empty): no action.

### Step 4 — Surface per-artifact status lines

After processing all three artifact types, print a status block:

```
Post-deploy project-local sync:
  skills/refresh-agent-os    synced
  skills/start-sprint        already-in-sync
  agents/skylar              synced
  agents/bandit              already-in-sync
  blueprints/task-coder      already-in-sync
```

Each line uses exactly one of three status tokens:

- **`synced`** — the global copy was written to the project-local path (either because the file was absent or diverged).
- **`already-in-sync`** — the project-local file was already identical to the global file; no write performed.
- **`warning — sync failed: <reason>`** — the copy operation failed (e.g. permission error, disk full). The reason is appended. This is a non-fatal warning — Phase 5.5 continues with the next artifact.

If a project-local `.claude/` directory did not exist (and was created in Step 2), prepend the status block with:
```
  (created .claude/<dir>/ — no prior local install)
```

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

- **Write targets are enumerated.** This skill writes only to the following paths:
  1. `~/.claude/skills/<name>/SKILL.md` — global skill install (Phases 2–5)
  2. `~/.claude/agents/<name>.md` — global agent install (Phases 2–5)
  3. `~/.claude/blueprints/<name>.md` — global blueprint install (Phases 2–5)
  4. `.claude/skills/<name>/SKILL.md` — project-local skill sync (Phase 5.5 only, for artifacts that exist in global)
  5. `.claude/agents/<name>.md` — project-local agent sync (Phase 5.5 only, for artifacts that exist in global)
  6. `.claude/blueprints/<name>.md` — project-local blueprint sync (Phase 5.5 only, for artifacts that exist in global, if directory is used)
  7. `AGENTIC.md` — adding the `Canonical skills manifest URL:` line on first run only, after explicit user confirmation
  8. `CLAUDE.md` — reference updates (Phase 5) when explicitly approved by the user in Phase 4

  The Phase 5.5 project-local sync writes (items 4–6) are unconditional once Phase 5 applies at least one change — they do not require additional user confirmation. They are bounded to artifacts that exist in global (`~/.claude/`) and are never used to introduce new content that was not already applied globally.

  **Never write to any other path**, including but not limited to: `AGENTIC.md` (except the one-time first-run URL write), other project config files, `.claude/hooks/`, or any path outside the explicitly enumerated list above.
- **Phase 5.5 absent-path handling (§9.7.1 binding):** if `.claude/skills/`, `.claude/agents/`, or `.claude/blueprints/` is absent when Phase 5.5 runs, create the directory silently (`mkdir -p`) and treat the local install as empty. Never crash on an absent project-local directory. Never prompt the user. Surface an error only if directory creation itself fails.
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

## Audit Scope and Known Boundaries

### What refresh-agent-os covers

This skill manages exactly three global directories and their project-local mirrors:

**Global install directories (Phases 2–5):**
1. `~/.claude/skills/` — canonical skill files (`<name>/SKILL.md`)
2. `~/.claude/agents/` — canonical agent files (`<name>.md`)
3. `~/.claude/blueprints/` — canonical blueprint files (`<name>.md`)

**Project-local directories (Phase 5.5 only — sync from global, post-deploy):**
4. `.claude/skills/` — project-local skill files (`<name>/SKILL.md`)
5. `.claude/agents/` — project-local agent files (`<name>.md`)
6. `.claude/blueprints/` — project-local blueprint files (`<name>.md`, if the directory is used)

All diff, install, update, rename, and remove logic in Phases 2–5 operates exclusively on the three global directories. Phase 5.5 is the only phase that writes to project-local directories, and only to sync them from global (global is canonical).

### What refresh-agent-os does NOT cover — and why

**`~/.claude/hooks/` (global hooks)**
Currently empty by design. The Agent OS canonical install (`install-agent-scaffold`) does not install any global hooks — all hooks are installed at the project level (`.claude/hooks/`). Therefore `~/.claude/hooks/` has no canonical content to refresh against. If future canonical global hooks are introduced, this boundary must be revisited and a new Phase added.

**`.claude/hooks/` (project-level hooks)**
**No refresh path. Update via sprint track only.** These are load-bearing safety controls:
- `block-orchestrator-execution.sh` — guards execution files from Sprint Coordinator writes
- `block-manual-agent-spawn.sh` — controls Agent spawn approval flow in manual mode
- `block-mode-violation.sh` — prevents config edits during tasks-in-flight

Auto-refresh without Conductor review would risk silently modifying a safety control. A stale hook is a protocol gap, not a style gap. The correct update path is a sprint track with a Handoff Bridge authored by the Technical Architect, reviewed by the Conductor, and executed by a Specialist. This boundary is **unchanged** by the Phase 5.5 project-local sync addition — Phase 5.5 explicitly excludes `.claude/hooks/` from its write scope.

**`AGENTIC.md`, `CLAUDE.md` (project configuration files)**
Update via sprint track only. These files contain project-specific configuration, operating mode settings, sprint history references, and team-specific protocol language. A global refresh tool overwriting them would silently destroy project customizations. Canonical templates (`claude/templates/AGENTIC.md`, `claude/templates/CLAUDE.md`) are the reference for new installs; live project files diverge intentionally over time.

### Conductor note — project-level hook updates

If `.claude/hooks/` are out of date with canonical (e.g. a hook's exit behavior has changed), open a sprint track to update them. The canonical source for each hook change is the Handoff Bridge from the sprint that last modified the hook (e.g. `docs/bridges/S<N>-bridges.md`). Do not attempt to update hooks by running `/refresh-agent-os` — hooks are not in scope and the command will not surface them.

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
- [ ] Phase 5.5 ran (if at least one action was applied in Phase 5); project-local `.claude/skills/`, `.claude/agents/`, `.claude/blueprints/` checked for absent dirs (silently created) and diverged files (overwritten from global); per-artifact status lines printed (`synced` / `already-in-sync` / `warning — sync failed: <reason>`)
- [ ] Phase 5.5 did NOT modify `.claude/hooks/` or any file outside the explicitly enumerated write targets
