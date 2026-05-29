---
name: onboard-existing-project
description: Onboards an existing project into the Claude Code orchestration system.
---
# Onboard Existing Project
Onboards an existing project into the Claude Code orchestration system. Reads the current project structure first, pre-fills the setup interview with what it finds, and generates all required files without overwriting anything without your approval.

> **New project?** Use `/install-agent-scaffold` instead. This skill is only for projects that already have files and history.

## Trigger
When the user runs `/onboard-existing-project`, execute the following phases in order.

---

## Phase 1: Discovery (Run Silently — No Questions Yet)

Read the following files and paths. Do not ask any questions. Extract as much as possible to pre-fill the interview.

| File / Path | Extract |
|---|---|
| `README.md` | Project name, description, tech stack hints |
| `package.json` / `pyproject.toml` / `Cargo.toml` | Name, dependencies → infer stack |
| `src/` / `app/` / `lib/` structure | Frontend framework, language |
| `api/` / `server.ts` / `routes/` | Backend runtime/framework |
| `supabase/` / `prisma/` / `db/` | Database |
| `.env.example` | Services and integrations in use |
| `docs/` or `context/` | Any existing planning or context docs |
| `AGENTIC.md` | Whether orchestration is already initialized |
| `CLAUDE.md` | Existing Claude Code configuration |
| `.claude/agents/` | Existing agent definitions |
| `.claude/settings.json` | Existing hooks |
| `.gitignore` | Worktree path convention in place |

**Product vision candidates sweep.** After reading the table above, scan for the following files: `README.md`, `north-star.md`, `vision.md`, `PRODUCT.md`, `docs/product.md`, `docs/vision.md`, `docs/north-star.md`. For each that exists and contains prose that could serve as a product vision source (at least one paragraph of non-boilerplate description), capture its path into `PRODUCT_CANDIDATES`. If none exist, set `PRODUCT_CANDIDATES` to empty.

Assemble a Discovery Report internally — do not display it yet.

---

## Phase 2: Conflict Check

Before asking any questions, evaluate:

1. **Already initialized?** If `AGENTIC.md` exists at root and contains "Static DNA" → warn: "This project already has Agent OS initialized. Do you want to re-initialize, or just add missing pieces?"
2. **Partial setup?** If some files exist but others are missing (e.g., no `.claude/agents/`) → note which files will be created vs. which already exist.
3. **Existing docs to migrate?** If `docs/` or a `context/` folder exists → identify files that could serve as `plan.md`, `tracks.md`, or `product.md` and propose the mapping.

---

## Phase 3: Focused Interview

**Rule: Only ask about what is genuinely missing or ambiguous.** For each value below, if it was found in an existing file (`AGENTIC.md`, `CLAUDE.md`, `README.md`, `package.json`, `.claude/agents/`), mark it ✓ CONFIRMED — do not ask again. Only present questions where the answer was not found or is incomplete.

Present confirmed values as a silent summary block first:

> **Already established (no changes needed):**
> - Project name: [value from AGENTIC.md or README]
> - Tech stack: [value from AGENTIC.md]
> - Build command: [value from AGENTIC.md or package.json]
> - Conductor: [value from AGENTIC.md]
> - Architect: [name from .claude/agents/]
> - QA: [name from .claude/agents/]

Then present **only the gaps** as a numbered list. **Wait for all answers before creating any files.**

> **What I still need from you:**
>
> [Only include items below that were not found. If all are found, skip this block entirely and proceed to Phase 4.]
>
> - **Specialist roles** — What specialist agent(s) should be added? What are their names and domains? *(Proposed: [inferred from folder structure, or "Not found — please provide"])*
> - **One-sentence description** — *(Only if not found in README or AGENTIC.md)*
> - **Team type** — Dev team, creative/business team, or mixed? *(Only if genuinely ambiguous)*
> - **Product vision** — If `docs/context/product.md` already exists and is non-empty, mark ✓ CONFIRMED and skip. Otherwise: `product.md` will be created with a skeleton placeholder automatically in Phase 4e. If `PRODUCT_CANDIDATES` is non-empty, list them numbered and ask: "Fill in `product.md` now? Pick a candidate number to synthesize, or type your own 2–3 sentence description of what this product is and who it serves. Or type 'skip' to leave the placeholder and fill it in later." If `PRODUCT_CANDIDATES` is empty, ask: "Fill in `product.md` now? Type a 2–3 sentence description of what this product is and who it serves, or type 'skip' to leave the placeholder and fill it in later."
>
> **Existing docs** (if found and not yet mapped): I'll list any docs found and propose how they map to `docs/context/`. Confirm or reject each mapping. *(Skip if docs/context/ already has plan.md, tracks.md, product.md.)*

---

## Phase 4: Generate Files

After all answers are confirmed, create or update the following. For each file:
- **Does not exist** → create it.
- **Already exists** → show what would change and ask: merge, replace, or skip.

### 4a. `AGENTIC.md` (root)

Use the same template as `install-agent-scaffold` Step 2a. Replace all placeholders with confirmed values. No `[PLACEHOLDER]` may remain.

### 4b. `CLAUDE.md` (root)

Use the same template as `install-agent-scaffold` Step 2b. Include the Auto-Invocations table for open-sprint and report-track-status.

**When `CLAUDE.md` already exists:** after confirming the merge/replace/skip decision with the user, run the **Skill-reference drift check** sub-flow below before writing any changes.

#### Skill-reference drift check

This sub-flow fires whenever `CLAUDE.md` already exists (regardless of whether the user chose merge, replace, or skip). It scans the entire file for every skill reference and verifies each one resolves to a real file on disk.

**Step 1 — Full-file scan.** Read the entire existing `CLAUDE.md` and collect every skill reference from all locations, including:
- Auto-trigger table rows (`| User says... | Invoke |` pattern — extract the skill name from the Invoke column)
- Inline `/skill-name` mentions anywhere in prose
- Agent invocation blocks that name a skill
- Explicit `~/.claude/skills/<name>/SKILL.md` paths

Build a deduplicated list of skill names with their line numbers and surrounding context.

**Step 2 — Resolve each reference.** For each collected skill name, check whether `~/.claude/skills/<name>/SKILL.md` exists.

- Skills that resolve: silently pass.
- Skills **not** present in `~/.claude/skills/<name>/SKILL.md`: add to the unresolvable list.
- Skills present in `~/.claude/skills/` but absent from the canonical Agent OS repo (`agent-os-private/claude/skills/`) are **NOT flagged** — they may have been installed outside Agent OS and are intentionally kept.

**Step 3 — Report.** If no unresolvable references were found, state: "All skill references in `CLAUDE.md` resolve — no drift detected." and proceed.

If unresolvable references were found, present a report in this format before making any file changes:

```
Skill-reference drift detected in CLAUDE.md:

| Skill name        | Line | Context                                      |
|-------------------|------|----------------------------------------------|
| start-sprint      | 42   | `| User says "open sprint" | /start-sprint |` |
| deploy-preview    | 67   | Inline mention: "run /deploy-preview to..."  |
```

**Step 4 — Per-reference targeted patches.** For each unresolvable reference, offer a specific fix. Examples:
- "Remove line 42 (this skill no longer exists)"
- "Rename `/start-sprint` → `/open-sprint` to match the installed canonical name"
- "Replace this row with the canonical equivalent from the Auto-Invocations template"

Present each patch individually and wait for the user to confirm or decline before moving to the next. Do **not** apply patches in bulk. If the user declines a patch, skip it silently — no further prompting for that reference.

**Step 5 — Apply.** Apply only the patches the user explicitly confirmed. All other `CLAUDE.md` content is preserved verbatim.

**Step 6 — Auto-trigger table diff.** After applying any per-reference patches from Steps 1–5, run this scoped sub-step to detect drift in the Auto-Invocations table specifically.

1. **Locate the table.** Find the Auto-Invocations table in the existing `CLAUDE.md` (rows matching `| User says... | Invoke |` — look for the header row with those two columns, then collect the data rows beneath it).

2. **Load canonical table.** The canonical table has exactly these two rows (from `install-agent-scaffold` Step 4b):

   | User says... | Invoke |
   |---|---|
   | "start planning", "new sprint", "let's plan", "begin planning", "what are we working on next" | `/sprint-open` |
   | "catch me up", "what's the status", "where are we", "status check", "quick update" | `/track-status` |

3. **Produce a structured diff.** Compare the existing table rows against the canonical table row-by-row:
   - Rows present in canonical but **missing locally** → `MISSING` (skill not yet in local table)
   - Rows present locally but whose `Invoke` value **differs from canonical** → `RENAMED` (e.g. `/start-sprint` vs `/sprint-open`)
   - Rows present locally but **absent from canonical** → `EXTRA` (skill added locally or removed from canonical)
   - If no differences: state "Auto-trigger table matches canonical — no drift detected." and skip Steps 4–6.

4. **Present the diff** in this format before making any changes:

   ```
   Auto-trigger table drift detected:

   | Status  | User says pattern                          | Local Invoke    | Canonical Invoke |
   |---------|--------------------------------------------|-----------------|------------------|
   | RENAMED | "start planning", "new sprint", ...        | /start-sprint   | /sprint-open     |
   | MISSING | "catch me up", "what's the status", ...    | —               | /track-status    |
   | EXTRA   | "deploy now"                               | /deploy         | (not in canonical) |
   ```

5. **Offer a single table-level patch.** Offer to replace the entire Auto-Invocations table with the canonical version. Do **not** offer per-cell patches — table replacement only. Present the offer as:

   > "Apply canonical Auto-Invocations table? This will replace the table with the two-row canonical version (sprint-open, track-status). Your other CLAUDE.md content is untouched."

   Wait for the user to confirm or decline.

6. **Apply or skip.** If the user confirms, replace the Auto-Invocations table block with the canonical two-row table. All other `CLAUDE.md` content is preserved verbatim. If the user declines, log the diff as a note and move on — no silent rewrite, no re-prompting.

### 4c. `docs/context/plan.md`

If the user approved a doc migration, copy the source file and prepend:
```
<!-- Migrated from [original path] — review and update stale content. -->
```
Otherwise create the standard blank template.

### 4d. `docs/context/tracks.md`

Initialize with: `Project adoption — Agent OS initialized.`

### 4e. `docs/context/product.md`

Apply exactly one of the following branches based on the outcome of Phase 3:

1. **`docs/context/product.md` already exists and is non-empty** — Leave it untouched. (Unchanged from prior behaviour.)

2. **`docs/context/product.md` does not exist (all other cases)** — **Create the skeleton file first**, then apply the user's Phase 3 response:

   The skeleton template is:

   ```markdown
   # Product Context

   <!-- TODO: fill in product context — what is this product, who does it serve, why now? -->

   ## Vision
   [To be filled in.]

   ## Current Focus
   [To be filled in.]

   ---

   *Last updated: [TODAY'S DATE]*
   ```

   Write this skeleton to `docs/context/product.md` immediately (before checking the user's Phase 3 answer), then:

   - **User picked a candidate file** → Read the candidate, generate a 2–3 sentence summary that captures what the product is and who it serves. Overwrite the skeleton's `<!-- TODO -->` comment and `[To be filled in.]` Vision placeholder with the generated summary. Prepend the file with `<!-- Synthesized from [candidate path] — review and refine. -->`. End-state: `created (filled)`.

   - **User typed a description** → Overwrite the skeleton's `<!-- TODO -->` comment and `[To be filled in.]` Vision placeholder with the user's text verbatim. End-state: `created (filled)`.

   - **User deferred (typed 'skip' or declined)** → Leave the skeleton in place with the `<!-- TODO: fill in product context -->` marker. End-state: `created (skeleton — needs fill)`.

   The file exists in all three end-states. The `<!-- TODO: fill in product context -->` marker signals to downstream agents (Architect HARD STOP) that context is still needed.

### 4f. `.claude/agents/[architect-name].md`

Use the architect template. Update name, description, and tech stack reference section.

### 4g. `.claude/agents/[specialist-name].md` (one per specialist)

Use the specialist template. Update name, domain, and scope section.

### 4h. `.claude/agents/[qa-name].md`

Use the QA template. Update name and build command.

### 4i. `.claude/settings.json`

If `.claude/settings.json` already exists:
- Read it first.
- Merge the pre-push build hook and Stop hook into the existing config.
- Do not remove any hooks already present.

If it does not exist, create it with the standard hooks from `install-agent-scaffold`.

### 4j. `.gitignore` additions

Append `.worktrees/` and `.claude/settings.local.json` if not already present.

---

## Phase 5: Adoption Summary

After all files are generated, output:

```
## Project Adoption Complete

**Project:** [PROJECT NAME]
**Files created:** [list — always include docs/context/product.md here if it was created or synthesized in this run; label with end-state: `created (filled)`, `created (skeleton — needs fill)`, or `pre-existing`]
**Files updated:** [list, or "None"]
**Skipped (no changes needed):** [list — always include docs/context/product.md here if it already existed and was left untouched, labeled `pre-existing`]

**Existing docs migrated:**
[list of original path → docs/context/X.md, or "None"]

**Your team:**
- [ARCHITECT NAME] — invoke with @[architect-name]
- [SPECIALIST NAMES] — invoke with @[name]
- [QA NAME] — invoke with @[qa-name]

**Next steps:**
1. Review AGENTIC.md — confirm the protocols match your project's conventions.
2. Update docs/context/plan.md with your current sprint objective.
3. Review any migrated docs and remove stale content.
4. Call @[architect-name] to open your first sprint.

**Verification:** Run [BUILD COMMAND] to confirm the build is clean before starting work.

**Activate skills:** Close and reopen your IDE window — installed skills load on session start.
```

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Discovery phase ran before any questions were asked
- [ ] No existing file was replaced without explicit user approval
- [ ] No `[PLACEHOLDER]` values remain in any generated file
- [ ] Migrated docs include the `<!-- Migrated from -->` header
- [ ] `.claude/settings.json` merge preserved any pre-existing hooks
- [ ] If CLAUDE.md was preserved, every skill reference in the file resolved to `~/.claude/skills/<name>/SKILL.md`, or the user was offered a targeted patch for each unresolvable reference.
- [ ] If CLAUDE.md was preserved, the auto-trigger table diff (Phase 4b Step 6) ran; any drift was presented as a structured diff and the user was offered a table-level patch; only confirmed patches were applied.
- [ ] Phase 4e produced a `docs/context/product.md` in one of three valid end-states: `pre-existing` (untouched), `created (filled)` (synthesized or user-typed), or `created (skeleton — needs fill)` (user deferred). The file must exist in all three cases — never absent after onboarding completes.
- [ ] Phase 5 Adoption Summary labels the `docs/context/product.md` end-state explicitly (`pre-existing`, `created (filled)`, or `created (skeleton — needs fill)`).
