---
name: onboard-existing-project
description: Onboards an existing project into Agent OS by discovering the current structure, filling only the genuine gaps, and generating the full set of DNA files without overwriting anything without approval.
Abbreviation: Pa
Category: Orchestration
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write, net_fetch]
---

# Skill: Onboard Existing Project

## Description
The onboarding path for **existing projects**. Instead of asking for details you already have, this skill reads your project first — README, package.json, existing docs, folder structure — and pre-fills the setup with what it finds. Only genuine gaps get questions. It then generates the full Agent OS file set. Nothing is overwritten without your approval.

> **New project?** Use `install-agent-scaffold` instead. This skill is only for projects that already have files and history.

## Operational Rules
- **Read First, Write Second**: Run the full discovery phase before asking any questions or creating any files.
- **Never Overwrite Silently**: If a file that would be created already exists, flag it explicitly and ask whether to merge, replace, or skip.
- **No Placeholders**: Every value in the generated files must be confirmed. Pre-filled values from discovery are proposals, not facts.
- **Gap-Only Questions**: If a value was already found in an existing file, do not ask about it again.

---

## Phase 1: Discovery (Run Silently — No Questions Yet)

Read the following files and paths. Do not ask any questions. Extract as much as possible to pre-fill the gaps interview.

| File / Path | Extract |
|---|---|
| `README.md` | Project name, description, tech stack hints |
| `package.json` / `pyproject.toml` / `Cargo.toml` | Name, dependencies → infer stack |
| `src/` / `app/` / `lib/` structure | Frontend framework, language |
| `api/` / `server.ts` / `routes/` | Backend runtime/framework |
| `supabase/` / `prisma/` / `db/` | Database |
| `.env.example` | Services and integrations in use |
| `docs/` or `context/` | Any existing planning or context docs |
| `AGENTIC.md` | Whether Agent OS is already initialized |
| `CLAUDE.md` | Existing Claude Code configuration |
| `.claude/agents/` | Existing agent definitions |
| `.claude/settings.json` | Existing hooks |
| `.gitignore` | Worktree path convention in place |

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
>
> **Existing docs** (if found and not yet mapped): I'll list any docs found and propose how they map to `docs/context/`. Confirm or reject each mapping. *(Skip if docs/context/ already has plan.md, tracks.md, product.md.)*

---

## Phase 4: Generate Files

After all answers are confirmed, create or update the following. For each file:
- **Does not exist** → create it.
- **Already exists** → show what would change and ask: merge, replace, or skip.

### 4a. `AGENTIC.md` (root)

Use the same template as `install-agent-scaffold`. Replace all placeholders with confirmed values. No `[PLACEHOLDER]` may remain.

### 4b. `CLAUDE.md` (root)

Use the same zero-setup template as `install-agent-scaffold`. Include the Auto-Invocations table for open-sprint and report-track-status.

### 4c. `docs/context/plan.md`

If the user approved a doc migration, copy the source file and prepend:
```
<!-- Migrated from [original path] — review and update stale content. -->
```
Otherwise create the standard blank template.

### 4d. `docs/context/tracks.md`

Initialize with: `Project adoption — Agent OS initialized.`

### 4e. `docs/context/product.md`

Standard blank template if no source doc was identified.

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
**Files created:** [list]
**Files updated:** [list, or "None"]
**Skipped (no changes needed):** [list, or "None"]

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
```

---

## Verification Checklist (Internal — Run Before Reporting Complete)
- [ ] Discovery phase ran before any questions were asked
- [ ] No existing file was replaced without explicit user approval
- [ ] No `[PLACEHOLDER]` values remain in any generated file
- [ ] Migrated docs include the `<!-- Migrated from -->` header
- [ ] `.claude/settings.json` merge preserved any pre-existing hooks

## Stats
- **Overhead**: ~1000 Tokens (Discovery + Gap Interview + Generation)
- **Operational Level**: Level 1 (Meta-Orchestration)
- **Benefit**: Existing projects get full Agent OS setup without losing history or being asked details the codebase already contains.

## Trigger
Tell your AI: "Onboard this project into Agent OS: https://github.com/designgrappler/agent-skills" or run `onboard-existing-project`.
