---
name: update-agent-os
description: Synchronizes your local `~/.claude/skills/`, `~/.claude/agents/` installation against the canonical Agent OS library.
---
# Update Agent OS
Synchronizes your local `~/.claude/skills/` and `~/.claude/agents/` installations against the canonical Agent OS library. Reads the canonical manifest from GitHub, diffs your installed skills and agents against the canonical set, surfaces the current release version and release notes, and presents a per-row action table for you to approve before anything is changed. Nothing is written, renamed, or removed without your explicit confirmation.

## Trigger
When the user runs `/update-agent-os`, execute the following phases in order.

---

## Phase 1: Resolve Canonical Source

1. Attempt to fetch the canonical manifest directly from GitHub:
   - URL: `https://raw.githubusercontent.com/designgrappler/agent-os/main/skills-manifest.json`
   - If a `skills-manifest.json` exists in the project root with a `canonical-registry` URL, that URL overrides the default GitHub URL above.
2. **If the fetch fails** (network unavailable, 404, or any HTTP error): stop immediately and surface a clear error:
   > "Cannot reach the canonical source at `<URL>`. Check your network connection and try again."
   Do not proceed to Phase 2.


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

**For hooks** — skip entirely if the canonical hook set is empty.

**a. New** — filenames in canonical `hooks[]` but absent from `.claude/hooks/`.

**b. Outdated** — filenames in both, but contents differ.

**c. Removed-from-canonical** — filenames in `.claude/hooks/` but absent from canonical. **Default: Keep local hook (no canonical match).** Never auto-removed.

**Retired-artifacts detection (fires every run):**

Run these exact bash commands and capture the output — do not infer, skip, or summarize:

```bash
for f in bandit.md suzy.md peaches.md skylar.md mario.md task-coder.md task-researcher.md task-writer.md technical-architect.md; do
  [ -f "$HOME/.claude/agents/$f" ] && echo "RETIRED:global:$HOME/.claude/agents/$f"
  [ -f ".claude/agents/$f" ]       && echo "RETIRED:project:.claude/agents/$f"
done
[ -f "AGENTIC.md" ]                        && echo "RETIRED:path:AGENTIC.md"
[ -d "claude/skills/report-track-status" ] && echo "RETIRED:path:claude/skills/report-track-status/"
```

For every line beginning with `RETIRED:` in the output, add a `[retired]` row to the diff table (Phase 4). The row shows the exact `rm` or `rm -rf` command and requires the user to type `yes` before deletion executes.

If the commands produce no `RETIRED:` lines, print: `Retired artifacts: None found.`

Non-canonical files NOT in the registry above: skip silently — no Removed row, no prompt.

**CLAUDE.md legacy format check (always runs):** If a `CLAUDE.md` exists in the working directory, check whether it contains `## Initialization Loop` or references to `AGENTIC.md`. If either marker is present, add an `[outdated]` row to the diff table:

| CLAUDE.md | [claude.md] | Outdated — manual only | Legacy format detected. Back up customizations, then replace with the lean bootstrap template at `~/.claude/skills/install-agent-scaffold/SKILL.md` (section 4a). |

**CRITICAL: this row is manual-migration only.** It must NOT appear in the approval tiers as an overwrite candidate. In Phase 4, explicitly exclude `[claude.md]` rows from all approval tiers (New, Outdated, Hook). In Phase 5 Apply, `[claude.md]` rows are informational only — never write, overwrite, or modify `CLAUDE.md`. The block-orchestrator-execution hook already prevents this, but the skill must encode it explicitly so no future implementor creates an auto-overwrite path.

**CLAUDE.md reference scan (fires on rename or removal only):**
If the diff contains at least one rename or removal: scan `CLAUDE.md` for references to renamed/removed skill names (auto-trigger rows, inline `/skill-name` mentions, path literals). Collect hits as `CLAUDE.md reference list`. Hold for Phase 4.

---

## Phase 4: Present Report

Surface release information first — display release version and notes before the action table.

Display the diff table. One row per skill, agent, hook, or CLAUDE.md reference affected. Prefix rows with `[skill]`, `[agent]`, `[hook]`, or `[claude.md]`. If no differences, state: "Your installation is up to date — no changes needed." and stop.

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

**Safety-control gate for Outdated rows:** Before presenting any `[skill]` or `[agent]` row with Status `Outdated`, display verbatim:
> `This file exists locally and will be overwritten. Review before approving.`

Then show the diff between the local file and the canonical file for that row before asking for confirmation.

**Approval tiers:**
- **New rows** (no local file exists) — eligible for "Approve all". No overwrite risk.
- **Outdated rows** (local file differs from canonical) — require individual per-file confirmation. Cannot be included in "Approve all".
- **Hook rows** — require individual per-hook confirmation (unchanged).
- **`[claude.md]` rows** — explicitly excluded from all approval tiers. These are informational only. Never include `[claude.md]` rows in New, Outdated, or Hook tier prompts. Display them in the table for visibility, but do not ask for approval — no action will be taken on them.

Ask: "Approve all NEW actions (no overwrite risk), a subset, or decline? Outdated rows each require individual confirmation — they will be listed separately."

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

**CLAUDE.md references** (applied after all skill and agent changes):
- For each approved `[claude.md]` row from the **rename reference scan** (Phase 3 CLAUDE.md reference scan), apply the edit to `CLAUDE.md`. Print: `updated CLAUDE.md line <N>: <old-ref> → <new-ref>`
- **`[claude.md]` rows from the CLAUDE.md legacy format check are NEVER acted on here.** These rows are informational only — never write, overwrite, or modify `CLAUDE.md` based on a legacy format detection row. No action, no prompt, no write.

**Hooks:**
- **Install (confirmed):** copy canonical hook to `.claude/hooks/<E>`. Print: `installed .claude/hooks/<E>`
- **Update (confirmed per-hook):** overwrite `.claude/hooks/<E>`. Print: `updated .claude/hooks/<E>`
- **Remove (confirmed per-hook opt-in only):** delete `.claude/hooks/<E>`. Print: `removed .claude/hooks/<E>`
- **Keep (default for Removed-from-canonical):** print: `skipped .claude/hooks/<E> (kept local)`
- **Do NOT edit user-owned `.claude/settings.json` fields** (`permissions`, allow/deny lists, `mcpServers`, custom hooks). Canonical fields are patched if-absent by Phase 5.7 only. If a new hook was installed, print advisory: `note: verify .claude/settings.json PreToolUse wiring references .claude/hooks/<E>`

Never apply an action the user did not explicitly approve.

---

## Phase 6: Summary

```
Refresh complete: N installed, N renamed, N removed, N updated, N skipped.
Skills: <counts>. Agents: <counts>. Hooks: <counts>. CLAUDE.md: <N> reference(s) updated.
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

## Phase 5.6: Connectors symlink

**Condition:** Runs automatically on every update run (unconditional — not gated on actions applied).

Ensures the project has a local pointer to the global connectors registry.

1. Check whether `~/.claude/connectors.md` exists.
   - If **absent**: skip this phase silently. Print: `Phase 5.6 skipped — ~/.claude/connectors.md not found.`
2. Check whether `docs/context/connectors.md` already exists (as a symlink or file).
   - If **present**: skip silently. Print: `connectors symlink   already present`
3. If `~/.claude/connectors.md` exists and `docs/context/connectors.md` is absent:
   - Create `docs/context/` if it does not exist.
   - Run: `ln -sf ~/.claude/connectors.md docs/context/connectors.md`
   - Add `docs/context/connectors.md` to `.gitignore` if not already present (only when a `.gitignore` file exists — do not create one).
   - Print: `connectors symlink   created → docs/context/connectors.md`

---

## Phase 5.7: Canonical settings.json patch-if-absent

**Condition:** Runs automatically after Phase 5 whenever at least one action was applied.

Reads `.claude/settings.json` and adds **canonical** fields **only when they are absent**. This never overwrites an existing value and never touches a user-owned field.

1. If `.claude/settings.json` does not exist, skip this phase entirely (the install path owns first creation). Do not create the file here.
2. Read and parse `.claude/settings.json`. If it is malformed JSON, skip with advisory: `Phase 5.7 skipped — .claude/settings.json is not valid JSON; not modified.` Never rewrite a file you could not parse.
3. For each canonical field below, patch **only if the field is absent**. If the field is present with any value, leave it untouched (no overwrite):
   - **`worktree.baseRef`** — canonical value: `"head"`. If the `worktree` object is absent, create it with `{ "baseRef": "head" }`. If `worktree` exists but `baseRef` is absent, add `baseRef: "head"`. If `worktree.baseRef` already has a value, do nothing.
   - **Standard `Stop` hook** — canonical value: the hygiene-reminder Stop hook block that `install-agent-scaffold` writes (section 4g of `install-agent-scaffold/SKILL.md`). If `hooks.Stop` is absent, add the standard block. If `hooks.Stop` already exists (any entry), do nothing — never append to or rewrite an existing Stop hook array.
4. **Never read, write, add, remove, or reorder** `permissions`, allow/deny lists, `mcpServers`, or any hook other than an absent standard `Stop`. These are user-owned.
5. Preserve all existing fields, key order where practical, and formatting. Write back only if at least one canonical field was added.
6. Print a status block:
   ```
   Canonical settings.json patch-if-absent:
     worktree.baseRef   added ("head")   |  already present (unchanged)
     hooks.Stop         added            |  already present (unchanged)
   ```
   Status tokens: `added` / `already present (unchanged)` / `skipped — no settings.json` / `skipped — invalid JSON`.

---

## Coupled-file contract

`update-agent-os` (update path) and `install-agent-scaffold` (install path) govern the same distributed system from two directions. They are a **coupled pair**:

- Any change to how this skill treats a **canonical** field or file MUST be reflected in `install-agent-scaffold/SKILL.md`, and vice versa, so install and update stay in sync.
- **Settings.json note:** this skill **patches canonical fields into `.claude/settings.json` only when they are absent** (`worktree.baseRef`, the standard `Stop` hook — see the patch-if-absent step) and **never overwrites user-owned fields** (`permissions`, allow/deny lists, `mcpServers`, custom hooks). The canonical tier is supplied once by `install-agent-scaffold`; this skill only adds a missing canonical default. Do not extend this skill to write or overwrite any user-owned field without an approved safety review.
- **QA directive:** when either `update-agent-os/SKILL.md` or `install-agent-scaffold/SKILL.md` is in a track's scope, the reviewer must open the coupled file and confirm it needs no matching change. Changing one without a recorded decision on the other is a review failure.

---

## Hard Constraints

- **Write targets are enumerated.** This skill writes only to:
  1. `~/.claude/skills/<name>/SKILL.md`
  2. `~/.claude/agents/<name>.md`
  3. `docs/context/connectors.md` — Phase 5.6 symlink only; never created as a regular file
  4. `.claude/hooks/<name>.sh` (confirm-required per-hook)
  5. `CLAUDE.md` — reference updates only (Phase 5 and Phase 7, user-approved)
  6. `.claude/settings.json` — Phase 5.7 patch-if-absent of canonical fields only (`worktree.baseRef`, standard `Stop` hook); never overwrites an existing value, never touches user-owned fields.
- **Never overwrite user-owned `.claude/settings.json` fields** (`permissions`, allow/deny lists, `mcpServers`, custom hooks). The only permitted `.claude/settings.json` write is Phase 5.7 patch-if-absent of canonical fields (`worktree.baseRef`, standard `Stop` hook). Never write any path not in the enumerated list above.
- **Never delete a file the user has not explicitly approved for removal.**
- **`CLAUDE.md` is never written by this skill** except for approved rename-reference patches (Phase 5 and Phase 7). The legacy-format `[claude.md]` row is informational only — it never triggers a write, overwrite, or modification of `CLAUDE.md`.
- **Phase 3 Diff must prefer the manifest's `renames` array** over any name-similarity heuristic. Heuristic is suggestion-only.
- **Surface release notes before presenting the action table.**
- **Compatibility window:** never treat a missing-but-defaultable frontmatter field as a hard error.
- **CLAUDE.md scan is conditional:** fires only when diff contains at least one rename or removal.
- **Phase 7 is conditional:** runs only when the diff produced at least one change.
- **Absent directories are created silently.** No user message. No prompt. Error only if creation fails.
- **Manifest cross-array invariant:** if a name appears in both `renames[].from` and the canonical `skills` or `agents` array, canonical membership is authoritative — never propose rename or removal. Surface a one-line diagnostic.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source (GitHub) resolved before any prompt was shown; clear error surfaced if unreachable
- [ ] `~/.claude/skills/` and `~/.claude/agents/` existence checked; absent directories created silently
- [ ] Release version read from manifest; release notes surfaced before action table
- [ ] Phase 3 Diff run for skills and agents
- [ ] Cross-array invariant guard applied before each `renames` lookup
- [ ] Manifest invariant violations surfaced as diagnostics
- [ ] Compatibility-window check applied; missing-but-defaultable fields surfaced as drift, not errors
- [ ] CLAUDE.md scanned only when diff contains at least one rename or removal
- [ ] CLAUDE.md legacy format check ran (always fires); if `## Initialization Loop` or `AGENTIC.md` reference found, `[claude.md]` informational row added to table
- [ ] `[claude.md]` legacy format row NOT included in any approval tier; no action taken on it in Phase 5
- [ ] Retired-artifacts bash scan executed; output checked for RETIRED: lines in both ~/.claude/agents/ and .claude/agents/; all hits surfaced in diff table
- [ ] Phase 4 table shown and user confirmed before any file was modified
- [ ] No file modified without explicit confirmation
- [ ] Outdated rows were NOT covered by "Approve all" — each required individual confirmation
- [ ] Diff shown for each Outdated row before the user confirmed
- [ ] Phase 6 summary printed with per-type counts
- [ ] Phase 7 ran (if diff changes occurred); CLAUDE.md checked against every renames[].from
- [ ] Phase 5.6 ran; connectors symlink created if ~/.claude/connectors.md present and docs/context/connectors.md absent; skipped silently otherwise
- [ ] Hooks phase: per-hook explicit confirmation required for each Outdated/New hook; no blanket "approve all" for hooks
- [ ] Hooks phase: no hook with Removed-from-canonical status auto-removed; default was Keep
- [ ] Hooks phase: no user-owned `.claude/settings.json` field (`permissions`, `mcpServers`, custom hooks) overwritten; any settings.json write was Phase 5.7 canonical patch-if-absent only
