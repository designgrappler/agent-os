---
name: onboard-existing-project
description: Onboards an existing project into Agent OS.
---
# Onboard Existing Project
Onboards an existing project into Agent OS. Reads the current project structure first, pre-fills what it finds, and generates required files without overwriting anything without your approval.

> **New project?** Use `/install-agent-scaffold` instead. This skill is only for projects that already have files and history.

## Trigger
When the user runs `/onboard-existing-project`, execute the following phases in order.

---

## Phase 0: Git Detection

Before any discovery, check whether the current folder is inside a git repository:

```bash
git rev-parse --git-dir 2>/dev/null
```

- **If the command succeeds (exit 0):** set `GIT_PRESENT=true` and proceed to Phase 1 normally.
- **If the command fails (non-zero exit):** set `GIT_PRESENT=false`. Continue with the following adjustments active for the rest of this skill run:
  - In Phase 4 (`CLAUDE.md` generation): omit the `## Worktree Protocol` section and the `## Sprint Workflow` section. Replace them with a single note block:
    ```
    > **Git not detected** — Agent OS works best with version control. A git repo unlocks sprint workflow, safe parallel agents (worktree isolation), and Beads issue tracking. Run `git init` when you're ready — no reinstall needed.
    ```
  - In Phase 4 (`.claude/settings.json` generation): omit the `worktree.baseRef` field.
  - In Phase 4g (`.gitignore` additions): skip this step entirely — there is no `.gitignore` to update without a git repo.
  - In Phase 5 (Adoption Summary): add a notice line: `**Git not detected** — Agent OS works best with version control. A git repo unlocks sprint workflow, safe parallel agents (worktree isolation), and Beads issue tracking. Run \`git init\` when you're ready — no reinstall needed.`

---

## Phase 1: Discovery (Run Silently — No Questions Yet)

Read the following files and paths. Do not ask any questions. Extract as much as possible to pre-fill.

| File / Path | Extract |
|---|---|
| `README.md` | Project name, description, tech stack hints |
| `package.json` / `pyproject.toml` / `Cargo.toml` | Name, dependencies → infer stack |
| `src/` / `app/` / `lib/` structure | Frontend framework, language |
| `api/` / `server.ts` / `routes/` | Backend runtime/framework |
| `supabase/` / `prisma/` / `db/` | Database |
| `.env.example` | Services and integrations in use |
| `docs/` or `context/` | Any existing planning or context docs |
| `CLAUDE.md` | Existing Claude Code configuration |
| `.claude/agents/` | Existing agent definitions |
| `.claude/settings.json` | Existing hooks |
| `.gitignore` | Worktree path convention in place |

**Product vision candidates sweep.** After reading the table above, scan for: `README.md`, `north-star.md`, `vision.md`, `PRODUCT.md`, `docs/product.md`, `docs/vision.md`, `docs/north-star.md`. For each that contains meaningful product prose, capture its path into `PRODUCT_CANDIDATES`. If none exist, set `PRODUCT_CANDIDATES` to empty.

**Optional design context files.** Also check for `DESIGN.md` and `PRODUCT.md` in the project root. If absent, note them as optional files the user can author later — `DESIGN.md` for brand tokens and project-specific design anti-patterns, `PRODUCT.md` for product principles and persona definitions — to give the Designer agent project-specific context beyond the defaults.

Assemble a Discovery Report internally — do not display it yet.

---

## Phase 2: Conflict Check

Before asking any questions, evaluate:

1. **Already initialized?** If `CLAUDE.md` exists and contains Agent OS content → warn: "This project already has Agent OS initialized. Do you want to re-initialize, or just add missing pieces?"
2. **Partial setup?** If some files exist but others are missing (e.g., no `.claude/agents/`) → note which files will be created vs. which already exist.
3. **Existing docs to migrate?** If `docs/` or a `context/` folder exists → identify files that could serve as `plan.md`, `tracks.md`, or `product.md` and propose the mapping.

---

## Phase 3: Focused Interview

**Rule: Only ask about what is genuinely missing or ambiguous.** For each value below, if it was found in an existing file, mark it CONFIRMED — do not ask again.

Present confirmed values as a silent summary block first:

> **Already established (no changes needed):**
> - Project name: [value from CLAUDE.md or README]
> - Tech stack: [value from CLAUDE.md]
> - Build command: [value from CLAUDE.md or package.json]

Then present **only the gaps** as a numbered list. **Wait for all answers before creating any files.**

> **What I still need from you:**
>
> [Only include items that were not found. If all are found, skip this block and proceed to Phase 4.]
>
> - **One-sentence description** — *(Only if not found in README)*
> - **Product vision** — If `docs/context/product.md` already exists and is non-empty, mark CONFIRMED and skip. Otherwise: if `PRODUCT_CANDIDATES` is non-empty, list them numbered and ask: "Fill in `product.md` now? Pick a candidate number to synthesize, or type your own 2–3 sentence description. Or type 'skip' to leave the placeholder." If `PRODUCT_CANDIDATES` is empty, ask: "Fill in `product.md` now? Type a 2–3 sentence description of what this product is and who it serves, or type 'skip'."
>
> **Existing docs** (if found and not yet mapped): list docs found and propose how they map to `docs/context/`. Confirm or reject each mapping. *(Skip if docs/context/ already has plan.md, tracks.md, product.md.)*
>
> - **Connectors (optional)** — Check whether `~/.claude/connectors.md` exists:
>   - **If it exists:** mark CONFIRMED and skip — do not ask about connectors.
>   - **If it does not exist:** ask: "Do you use any external tools (web search, image generation, docs)? I can add them to your connectors registry at `~/.claude/connectors.md`. Type a comma-separated list of tool names, or 'skip' to add later."
>     - If the user provides names: create `~/.claude/connectors.md` with one section per name (Type and Purpose left blank for the user to fill in, Status: active):
      ```markdown
      ## [connector-name]
      - **Type:**
      - **Command:**
      - **Purpose:**
      - **Status:** active
      - **Notes:**
      ```
>     - If the user types 'skip' or leaves blank: skip silently.

---

## Phase 4: Generate Files

After all answers are confirmed, create or update the following. For each file:
- **Does not exist** → create it.
- **Already exists** → show what would change and ask: merge, replace, or skip.

### 4a. `CLAUDE.md` (root)

Use the lean bootstrap template from `install-agent-scaffold` Step 4a. Include tech stack section with confirmed values. No `[PLACEHOLDER]` may remain.

**When `CLAUDE.md` already exists:** after confirming the merge/replace/skip decision, run the **Skill-reference drift check** sub-flow below before writing any changes.

#### Skill-reference drift check

1. **Full-file scan.** Collect every skill reference from `CLAUDE.md` (auto-trigger rows, inline `/skill-name` mentions, path literals).

2. **Resolve each reference.** Check whether `~/.claude/skills/<name>/SKILL.md` exists for each collected skill name. Skills present in `~/.claude/skills/` but absent from the canonical Agent OS repo are NOT flagged.

3. **Report.** If no unresolvable references: state "All skill references resolve — no drift detected." and proceed.

   If unresolvable references found:
   ```
   Skill-reference drift detected in CLAUDE.md:
   | Skill name   | Line | Context                       |
   |--------------|------|-------------------------------|
   | old-skill    | 42   | `| User says ... | /old-skill` |
   ```

4. **Per-reference targeted patches.** For each unresolvable reference, offer a specific fix. Present each patch individually — confirm or decline before moving to the next.

5. **Apply.** Apply only confirmed patches. All other content preserved verbatim.

### 4b. `claude/skills/orchestrator/SKILL.md`

If this file does not exist in the project, create it by copying from the canonical source. If it already exists and is current, skip silently.

### 4c. `.claude/agents/` — Role agent files

Fetch the following agent files and write them to `.claude/agents/` if not already present:

- `technical-architect.md`
- `qa.md`
- `task-coder.md`
- `task-researcher.md`
- `task-writer.md`

**Fetch strategy — for each file, in order:**

1. **GitHub (primary):** fetch from `https://raw.githubusercontent.com/designgrappler/agent-os/main/claude/agents/<name>.md`
2. **Local cache (fallback):** if the GitHub fetch fails (network unavailable, non-200 response), read from `~/.claude/agents/<name>.md`
3. **Failure:** if both sources fail, surface a clear error:
   > `Could not fetch <name>.md from GitHub or ~/.claude/agents/. Check your network connection or run /update-agent-os to populate the local cache.`
   Do not silently skip.

For each file that already exists locally, show the diff and ask: replace, or skip.

Write each successfully fetched file to `.claude/agents/<name>.md`. Create the directory if it does not exist.

### 4d. `docs/context/plan.md`

If the user approved a doc migration, copy the source file and prepend:
```
<!-- Migrated from [original path] — review and update stale content. -->
```
Otherwise create the standard blank template.

### 4e. `docs/context/tracks.md`

Initialize with:

```markdown
## Track 0 — Project adoption

**Status:** DONE — adopted into Agent OS ([TODAY'S DATE])

**Goal:** Onboard existing project into Agent OS.

**Files:**
- `CLAUDE.md` (new or updated)
- `docs/context/plan.md` (new)
- `docs/context/tracks.md` (new)
- `docs/context/product.md` (new)
- `.claude/agents/` (populated)
- `.claude/settings.json` (new or updated)
```

### 4f. `docs/context/product.md`

Apply exactly one of the following branches:

1. **Already exists and is non-empty** — Leave untouched.

2. **Does not exist** — Create the skeleton first, then apply the user's Phase 3 response:

   Skeleton:
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

   - **User picked a candidate file** → Synthesize a 2–3 sentence summary, overwrite the skeleton placeholders, prepend `<!-- Synthesized from [candidate path] — review and refine. -->`. End-state: `created (filled)`.
   - **User typed a description** → Overwrite the skeleton placeholders with the user's text verbatim. End-state: `created (filled)`.
   - **User deferred ('skip')** → Leave skeleton in place. End-state: `created (skeleton — needs fill)`.

### 4g. `.claude/settings.json`

If already exists: merge — do not remove existing entries.

If does not exist, create with the standard template from `install-agent-scaffold` Step 4g.

**Canonical field patch (when `GIT_PRESENT=true`):** After merge or create, check whether `worktree.baseRef` is present in the resulting file. If absent, add it:
```json
"worktree": {
  "baseRef": "head"
}
```
This ensures users who ran `git init` after a no-git install get the correct worktree config without needing to run `/update-agent-os`.

### 4g-b. Connectors symlink

1. Create symlink: `ln -sf ~/.claude/connectors.md docs/context/connectors.md` — skip if already exists.
2. Add `docs/context/connectors.md` to `.gitignore` if not already present.

### 4h. `.gitignore` additions

Append `.worktrees/` and `.claude/settings.local.json` if not already present.

---

## Phase 5: Adoption Summary

```
## Project Adoption Complete

**Project:** [PROJECT NAME]
**Files created:** [list]
**Files updated:** [list, or "None"]
**Skipped (no changes needed):** [list]

**Existing docs migrated:**
[list of original path → docs/context/X.md, or "None"]

**Next steps:**
1. Review CLAUDE.md — confirm the tech stack and configuration are correct.
2. Update docs/context/plan.md with your current sprint objective.
3. Review any migrated docs and remove stale content.
4. Add your tools: if you skipped connectors, run `/install-agent-scaffold` or add entries manually to `~/.claude/connectors.md`. *(only include this line if connectors.md was not created during onboarding)*
5. Run `/start-sprint` to open your first sprint.

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
- [ ] If CLAUDE.md was preserved, every skill reference resolved or was offered a targeted patch
- [ ] Phase 4f produced a `docs/context/product.md` in one of three valid end-states
- [ ] Phase 5 Adoption Summary labels the `docs/context/product.md` end-state explicitly
- [ ] If connectors.md was not created, step 4 of the Adoption Summary includes the add-tools prompt
