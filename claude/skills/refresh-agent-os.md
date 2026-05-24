# Refresh Agent OS
Synchronizes your local `~/.claude/skills/` installation against the canonical Agent OS skill library. Reads the canonical manifest from a remote URL stored in `AGENTIC.md` (with a local clone fallback), diffs your installed skills against the canonical set, and presents a per-row action table for you to approve before anything is changed. Nothing is written, renamed, or removed without your explicit confirmation.

## Trigger
When the user runs `/refresh-agent-os`, execute the following phases in order.

---

## Phase 1: Resolve Canonical Source

1. Read `AGENTIC.md` and look for a line matching: `Canonical skills manifest URL: <url>`
2. **If the line is absent:**
   - Ask the user: "No canonical manifest URL found in `AGENTIC.md`. Please confirm the URL for `skills-manifest.json` (e.g. `https://raw.githubusercontent.com/<owner>/agent-os/main/skills-manifest.json`)."
   - Once the user confirms, write the following line to `AGENTIC.md` immediately after the `Dynamic DNA` bullet under §1 DNA Taxonomy: `- **Canonical skills manifest URL:** \`<confirmed-url>\``
   - This is the **only** write this skill ever makes outside `~/.claude/skills/`, and it only happens on first run after explicit user confirmation.
   - Continue to step 3.
3. **If the line is present:** attempt to fetch the JSON from the URL.
4. **Fallback:** if the URL fetch fails (network unavailable, 404, or any HTTP error), fall back to the local canonical clone:
   - Manifest: `~/Developer/agent-os-private/skills-manifest.json`
   - Skill files: `~/Developer/agent-os-private/claude/skills/`
   - Notify the user: "Could not reach the canonical URL — using local clone at `~/Developer/agent-os-private/` as fallback."
5. **If neither the URL nor the local clone resolves:** stop and ask the user to supply a path or URL. Do not proceed to Phase 2 until a canonical source is confirmed.

---

## Phase 2: Inventory

1. List all filenames in `~/.claude/skills/` (strip the `.md` extension to get bare skill names). This is the **installed set**.
2. Read the `skills` array from the resolved manifest. This is the **canonical set**.
3. Display neither list yet — hold both for Phase 3.

---

## Phase 3: Diff

Produce three lists by comparing the canonical set against the installed set:

**a. New** — names present in the canonical `skills` array but absent from `~/.claude/skills/`.
These are skills available in canonical that you do not have installed.

**b. Removed** — names present in `~/.claude/skills/` but absent from the canonical `skills` array.
For each removed name:
- First, check the manifest `renames` array. If an entry `{ "from": "<name>", "to": "<new-name>" }` matches, surface it as a **confirmed rename** (no guessing required).
- For removed names not covered by any `renames` entry, apply a name-similarity heuristic (e.g. Levenshtein distance, shared prefix/suffix) as a **suggestion only**. Label it clearly as "possible rename" and require explicit user confirmation before treating it as a rename.

**c. Drifted** — names present in both `~/.claude/skills/` and the canonical set, but whose file contents differ (a `diff` of the two files is non-empty). These are installed skills that have diverged from the canonical version.

---

## Phase 4: Present Report

Display a single table summarizing all findings. One row per skill name affected. If there are no differences, state: "Your installation is up to date — no changes needed." and stop.

```
| Skill name              | Status   | Proposed action                          |
|-------------------------|----------|------------------------------------------|
| refresh-agent-os        | New      | Install → ~/.claude/skills/              |
| start-sprint            | Removed  | Confirmed rename → open-sprint (manifest)|
| old-skill               | Removed  | Possible rename → new-skill (suggestion) |
| onboard-existing-project| Drifted  | Update → overwrite with canonical        |
| audit-security          | Current  | Skip (no changes)                        |
```

Ask: "Approve all actions, a subset (list the names), or decline?"

Wait for the user's response before proceeding to Phase 5. Do not apply any changes without this confirmation.

---

## Phase 5: Apply

For each action the user approved, execute it one at a time:

- **Install:** copy the canonical skill file to `~/.claude/skills/<name>.md`. Print: `installed ~/.claude/skills/<name>.md`
- **Rename (confirmed from manifest):** rename `~/.claude/skills/<old-name>.md` to `~/.claude/skills/<new-name>.md` and, if the new name is in the canonical set, overwrite with the canonical version. Print: `renamed ~/.claude/skills/<old-name>.md → ~/.claude/skills/<new-name>.md`
- **Rename (user-confirmed suggestion):** same as above, but only after the user has explicitly confirmed the suggestion in Phase 4.
- **Remove:** delete `~/.claude/skills/<name>.md`. Print: `removed ~/.claude/skills/<name>.md`
- **Update:** overwrite `~/.claude/skills/<name>.md` with the canonical version. Print: `updated ~/.claude/skills/<name>.md`
- **Skip:** take no action. Print: `skipped <name>`

Never apply an action the user did not explicitly approve.

---

## Phase 6: Summary

After all approved actions are complete, print a one-line summary:

```
Refresh complete: N installed, N renamed, N removed, N updated, N skipped.
```

---

## Hard Constraints

- **Never write outside `~/.claude/skills/`**, with the **single** documented exception of adding the `Canonical skills manifest URL:` line to `AGENTIC.md` on first run — and only after explicit user confirmation.
- **Never delete a file the user has not explicitly approved for removal.** A file in the Removed list is not deleted until the user says so.
- **If neither the canonical URL nor the local clone resolves**, stop and ask the user to supply a path or URL. Do not proceed without a confirmed source.
- **Phase 3 Diff must prefer the manifest's `renames` array over any name-similarity heuristic.** The heuristic is suggestion-only and requires user confirmation before any rename action is taken.

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Canonical source resolved before any prompt was shown (URL primary, local clone fallback)
- [ ] If fallback was used, user was notified
- [ ] If URL was absent, user confirmed it before writing to AGENTIC.md
- [ ] Phase 3 Diff cross-checked the manifest `renames` array before applying heuristic
- [ ] Phase 4 table shown and user confirmed before any file was modified
- [ ] No file was modified without explicit confirmation
- [ ] Rename source identified (manifest-confirmed vs. user-confirmed suggestion) is visible in the report
- [ ] Phase 6 summary printed at end
