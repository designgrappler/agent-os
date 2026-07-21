---
name: update-agent-os
description: Synchronizes your local `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/blueprints/` installation against the canonical Agent OS library.
---
# Update Agent OS
Synchronizes your local `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/blueprints/` installations against the canonical Agent OS library. Reads the canonical manifest from a remote URL (with a local clone fallback), diffs your installed skills and agents against the canonical set, surfaces the current release version and release notes, and presents a per-row action table for you to approve before anything is changed. Nothing is written, renamed, or removed without your explicit confirmation.

## Trigger
When the user runs `/update-agent-os`, execute the following phases in order.

---

## Phase 1: Resolve Canonical Source

1. Look for `skills-manifest.json` in the project root. If it has a `canonical-registry` URL, use that to fetch the live manifest.
2. **If the URL fetch fails** (network unavailable, 404, or any HTTP error), fall back to the local canonical clone:
   - Manifest: `~/Developer/agent-os/skills-manifest.json`
   - Skill files: `~/Developer/agent-os/claude/skills/`
   - Agent files: `~/Developer/agent-os/claude/agents/`
   - Notify the user: "Could not reach the canonical URL — using local clone at `~/Developer/agent-os/` as fallback."
3. **If neither the URL nor the local clone resolves:** stop and ask the user to supply a path or URL. Do not proceed to Phase 2 until a canonical source is confirmed.
4. **Blueprints manifest:** Locate `blueprints-manifest.json` at the same level as `skills-manifest.json` in the resolved canonical source. If absent, treat the canonical blueprint set as empty and proceed without error.

---

## Phase 2: Inventory

**Skills:**
1. Check whether `~/.claude/skills/` exists.
   - If **absent**: silently create the directory (`mkdir -p ~/.claude/skills/`). The installed skill set is empty.
   - If **present**: continue.
2. List all `<name>/` subdirectories in `~/.claude/skills/` that contain a `SKILL.md` file. This is the **installed skill set**.
3. Read the `skills` array from the resolved manifest. This is the **canonical skill set**.

**Agents:**
4. Check whether `~/.claude/agents/` exists.
   - If **absent**: silently create the directory (`mkdir -p ~/.claude/agents/`). The installed agent set is empty.
   - If **present**: continue.
5. List all `<name>.md` files in `~/.claude/agents/`. This is the **installed agent set**.
6. Read the `agents` array from the resolved manifest. This is the **canonical agent set**.

**Blueprints:**
7. Check whether `~/.claude/blueprints/` exists.
   - If **absent**: silently create the directory (`mkdir -p ~/.claude/blueprints/`).
   - If **present**: continue.
8. List all `<name>.md` files in `~/.claude/blueprints/`. This is the **installed blueprint set**.
9. Read the `blueprints` array from the resolved `blueprints-manifest.json`. If absent, canonical blueprint set is empty.

**Hooks:**
H1. Read the `hooks[]` array from the resolved `skills-manifest.json`. This is the **canonical hook set** (a list of `.sh` filenames). For each entry, read the canonical hook file contents from `<canonical-source>/claude/hooks/<E>`.
   - **Absent-path:** if the canonical source has no `claude/hooks/` directory OR `skills-manifest.json` has no `hooks[]` key, treat the canonical hook set as empty and **skip the Hooks phase entirely without error**.
H2. Check whether `.claude/hooks/` exists in the working directory.
   - If **absent**: silently create the directory (`mkdir -p .claude/hooks/`). The installed hook set is empty.
   - If **present**: list all `.sh` files in `.claude/hooks/`. The installed hook set is these filenames.

Note: Hooks are **project-scoped** (`.claude/hooks/`). Do NOT inventory or modify `~/.claude/hooks/`.

**Release info:**
- Read `release-version` from the manifest. This is the **canonical release version**.
- Attempt to read the corresponding release note from `docs/releases/<release-version>.md` in the canonical source.

Display neither list yet — hold all data for Phase 3.

---

## Phase 3: Diff

**For skills** — produce three lists by comparing canonical against installed:

**a. New** — present in canonical `skills` array but absent from `~/.claude/skills/`.

**b. Removed** — present in `~/.claude/skills/` but absent from the canonical `skills` array.
- Cross-array invariant guard: if the candidate IS in canonical `skills`, treat as current (no rename, no removal). Surface diagnostic: `Manifest invariant warning: <name> appears in both skills[] and renames[].from. Treating as canonical (no action).`
- Check the manifest `renames` array first (confirmed rename). For unmatched names, apply name-similarity heuristic as **suggestion only** requiring explicit user confirmation.

**c. Outdated** — present in both but file contents differ.

**For agents** — produce three parallel lists with the same logic.

**For blueprints** — produce three parallel lists with the same logic.

**For hooks** — skip entirely if the canonical hook set is empty.

**a. New** — filenames in canonical `hooks[]` but absent from `.claude/hooks/`.

**b. Outdated** — filenames in both, but contents differ.

**c. Removed-from-canonical** — filenames in `.claude/hooks/` but absent from canonical. **Default: Keep local hook (no canonical match).** Never auto-removed.

**CLAUDE.md reference scan (fires on rename or removal only):**
If the diff contains at least one rename or removal: scan `CLAUDE.md` for references to renamed/removed skill names (auto-trigger rows, inline `/skill-name` mentions, path literals). Collect hits as `CLAUDE.md reference list`. Hold for Phase 4.

---

## Phase 4: Present Report

Surface release information first — display release version and notes before the action table.

Display the diff table. One row per skill, agent, blueprint, hook, or CLAUDE.md reference affected. Prefix rows with `[skill]`, `[agent]`, `[blueprint]`, `[hook]`, or `[claude.md]`. If no differences, state: "Your installation is up to date — no changes needed." and stop.

```
| Name                              | Type      | Status                   | Proposed action                                                           |
|-----------------------------------|-----------|--------------------------|---------------------------------------------------------------------------|
| update-agent-os                   | skill     | New                      | Install → ~/.claude/skills/update-agent-os/                               |
| old-skill                         | skill     | Removed                  | Confirmed rename → new-skill (manifest)                                   |
| onboard-existing-project          | skill     | Outdated                 | Update → overwrite with canonical SKILL.md                                |
| technical-architect               | agent     | New                      | Install → ~/.claude/agents/technical-architect.md                         |
| block-orchestrator-execution.sh   | hook      | Outdated                 | Update → overwrite .claude/hooks/block-orchestrator-execution.sh          |
| CLAUDE.md line 14                 | claude.md | Rename ref               | Update /old-skill → /new-skill                                            |
```

**Safety-control gate for hook rows:** Before presenting any `[hook]` row, display verbatim:
> `This is a safety-control hook. Review the diff carefully before approving.`

**Hook rows require individual confirmation.** "Approve all" applies only to non-hook rows.

Ask: "Approve all non-hook actions, a subset (list the names), or decline? For hook rows, each requires a separate confirmation."

Wait for the user's response before proceeding to Phase 5.

---

## Phase 5: Apply

For each action the user approved, execute one at a time:

**Skills:**
- **Install:** create `~/.claude/skills/<name>/` and copy the canonical `SKILL.md`. Print: `installed ~/.claude/skills/<name>/SKILL.md`
- **Rename (confirmed from manifest):** rename directory; overwrite with canonical version. Print: `renamed ~/.claude/skills/<old-name>/ → ~/.claude/skills/<new-name>/`
- **Update:** overwrite `~/.claude/skills/<name>/SKILL.md` with canonical. Print: `updated ~/.claude/skills/<name>/SKILL.md`
- **Remove:** delete `~/.claude/skills/<name>/`. Print: `removed ~/.claude/skills/<name>/`
- **Skip:** print: `skipped <name>`

**Agents:**
- **Install:** create `~/.claude/agents/<name>.md` with canonical content. Print: `installed ~/.claude/agents/<name>.md`
- **Rename (confirmed from manifest):** rename file; overwrite if new name in canonical. Print: `renamed ~/.claude/agents/<old-name>.md → ~/.claude/agents/<new-name>.md`
- **Update:** overwrite `~/.claude/agents/<name>.md` with canonical. Print: `updated ~/.claude/agents/<name>.md`
- **Remove:** delete `~/.claude/agents/<name>.md`. Print: `removed ~/.claude/agents/<name>.md`
- **Skip:** print: `skipped <name>`

**Blueprints:**
- Same install/rename/update/remove/skip pattern as Skills and Agents, using `~/.claude/blueprints/<name>.md`.

**CLAUDE.md references** (applied after all skill and agent changes):
- For each approved `[claude.md]` row, apply the edit to `CLAUDE.md`. Print: `updated CLAUDE.md line <N>: <old-ref> → <new-ref>`

**Hooks:**
- **Install (confirmed):** copy canonical hook to `.claude/hooks/<E>`. Print: `installed .claude/hooks/<E>`
- **Update (confirmed per-hook):** overwrite `.claude/hooks/<E>`. Print: `updated .claude/hooks/<E>`
- **Remove (confirmed per-hook opt-in only):** delete `.claude/hooks/<E>`. Print: `removed .claude/hooks/<E>`
- **Keep (default for Removed-from-canonical):** print: `skipped .claude/hooks/<E> (kept local)`
- **Do NOT edit `.claude/settings.json`.** If a new hook was installed, print advisory: `note: verify .claude/settings.json PreToolUse wiring references .claude/hooks/<E>`

Never apply an action the user did not explicitly approve.

---

## Phase 5.5: Post-Deploy Project-Local Sync

**Condition:** Runs automatically after Phase 5 whenever at least one action was applied.

Re-syncs `.claude/skills/`, `.claude/agents/`, `.claude/blueprints/` against `~/.claude/` equivalents. Global is canonical — any file absent or diverged locally is overwritten with the global copy.

**Skills** (`~/.claude/skills/<name>/SKILL.md` vs `.claude/skills/<name>/SKILL.md`): copy/overwrite as needed.

**Agents** (`~/.claude/agents/<name>.md` vs `.claude/agents/<name>.md`): copy/overwrite as needed.

**Blueprints** (`~/.claude/blueprints/<name>.md` vs `.claude/blueprints/<name>.md`): copy/overwrite as needed.

**Absent-path (§9.7.1):** if a project-local target directory is absent, create it silently. Never crash; never prompt.

Print a status block:
```
Post-deploy project-local sync:
  skills/update-agent-os    synced
  agents/technical-architect synced
```

Status tokens: `synced` / `already-in-sync` / `warning — sync failed: <reason>`

---

## Phase 6: Summary

```
Refresh complete: N installed, N renamed, N removed, N updated, N skipped.
Skills: <counts>. Agents: <counts>. Blueprints: <counts>. Hooks: <counts>. CLAUDE.md: <N> reference(s) updated.
```

---

## Phase 6.5: Post-Update Health Check

Runs automatically after Phase 5 whenever at least one action was applied.

1. Confirm `skills-manifest.json` `release-version` matches the canonical version surfaced in Phase 4.
2. Confirm the orchestrator skill exists at `claude/skills/orchestrator/SKILL.md`.
3. Confirm `CLAUDE.md` contains `## Orchestrator Behavior`.

Print result:
```
Post-update health check: PASS
```
Or if any check fails:
```
Post-update health check: FAIL — [specific check that failed]
```

A FAIL here does not block the summary — it is advisory, prompting the user to run `/check-agent-os` for full diagnosis.

---

## Phase 7: CLAUDE.md Stale Reference Patch

**Condition:** Runs only when the diff produced at least one change this run.

Search `CLAUDE.md` for every `renames[].from` name. For each hit, show the line and proposed replacement. Apply only user-approved patches.

If `CLAUDE.md` is absent: print `No CLAUDE.md in working directory — skipping stale-reference scan.`

---

## Hard Constraints

- **Write targets are enumerated.** This skill writes only to:
  1. `~/.claude/skills/<name>/SKILL.md`
  2. `~/.claude/agents/<name>.md`
  3. `~/.claude/blueprints/<name>.md`
  4. `.claude/skills/<name>/SKILL.md` (Phase 5.5 only)
  5. `.claude/agents/<name>.md` (Phase 5.5 only)
  6. `.claude/blueprints/<name>.md` (Phase 5.5 only)
  7. `.claude/hooks/<name>.sh` (confirm-required per-hook)
  8. `CLAUDE.md` — reference updates only (Phase 5 and Phase 7, user-approved)
- **Never write to `.claude/settings.json`** or any path not in the enumerated list above.
- **Never delete a file the user has not explicitly approved for removal.**
- **Phase 3 Diff must prefer the manifest's `renames` array** over any name-similarity heuristic. Heuristic is suggestion-only.
- **Surface release notes before presenting the action table.**
- **Compatibility window:** never treat a missing-but-defaultable frontmatter field as a hard error.
- **CLAUDE.md scan is conditional:** fires only when diff contains at least one rename or removal.
- **Phase 7 is conditional:** runs only when the diff produced at least one change.
- **Absent directories are created silently.** No user message. No prompt. Error only if creation fails.
- **Manifest cross-array invariant:** if a name appears in both `renames[].from` and the canonical `skills` or `agents` array, canonical membership is authoritative — never propose rename or removal. Surface a one-line diagnostic.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source resolved before any prompt was shown (URL primary, local clone fallback)
- [ ] If fallback used, user was notified
- [ ] `~/.claude/skills/` and `~/.claude/agents/` existence checked; absent directories created silently
- [ ] `~/.claude/blueprints/` existence checked; absent directory created silently
- [ ] Release version read from manifest; release notes surfaced before action table
- [ ] Phase 3 Diff run for skills, agents, blueprints
- [ ] Cross-array invariant guard applied before each `renames` lookup
- [ ] Manifest invariant violations surfaced as diagnostics
- [ ] Compatibility-window check applied; missing-but-defaultable fields surfaced as drift, not errors
- [ ] CLAUDE.md scanned only when diff contains at least one rename or removal
- [ ] Phase 4 table shown and user confirmed before any file was modified
- [ ] No file modified without explicit confirmation
- [ ] Phase 6 summary printed with per-type counts
- [ ] Phase 7 ran (if diff changes occurred); CLAUDE.md checked against every renames[].from
- [ ] Phase 5.5 ran (if at least one action applied); project-local dirs synced; status lines printed
- [ ] Phase 5.5 did NOT modify `.claude/hooks/` or any file outside write targets
- [ ] Hooks phase: per-hook explicit confirmation required for each Outdated/New hook; no blanket "approve all" for hooks
- [ ] Hooks phase: no hook with Removed-from-canonical status auto-removed; default was Keep
- [ ] Hooks phase: no `.claude/settings.json` write performed
