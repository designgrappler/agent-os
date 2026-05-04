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

Assemble a Discovery Report internally — do not display it yet.

---

## Phase 2: Conflict Check

Before asking any questions, evaluate:

1. **Already initialized?** If `AGENTIC.md` exists at root and contains "Static DNA" → warn: "This project already has Conductor OS initialized. Do you want to re-initialize, or just add missing pieces?"
2. **Partial setup?** If some files exist but others are missing (e.g., no `.claude/agents/`) → note which files will be created vs. which already exist.
3. **Existing docs to migrate?** If `docs/` or a `context/` folder exists → identify files that could serve as `plan.md`, `tracks.md`, or `product.md` and propose the mapping.

---

## Phase 3: Pre-Populated Interview

Present the following as a **single numbered list**. Pre-fill discovered values as proposals in parentheses. **Wait for all answers before creating any files.**

> I've read your project. Here's what I found — please confirm or correct each value:
>
> 1. **Project name** — *(Proposed: [discovered name or "Not found — please provide"])*
> 2. **One-sentence description** — *(Proposed: [discovered description or "Not found"])*
> 3. **Tech stack** — Backend runtime/framework, frontend framework, database. *(Proposed: [inferred stack or "Not found"])*
> 4. **Team type** — **Dev team** (building software), **creative/business team** (documents/designs/campaigns), or **mixed**? *(Proposed: [inferred — "Dev team" if package.json found])*
> 5. **Conductor name** — Your name as the human owner/approver. *(No default — required)*
> 6. **Architect agent name** — What should the Lead Architect be called? *(No default — required)*
> 7. **Specialist roles** — How many specialists, and what are their names and domains? *(Proposed: [inferred from folder structure — e.g., "Frontend (src/), Backend (api/), Database (supabase/)"])*
> 8. **Critic agent name** — What should the QA Critic be called? *(No default — required)*
> 9. **Build / type-check command** — Command that confirms a clean build. *(Proposed: [inferred from package.json scripts — e.g., "npm run build" or "Not found — please provide"])*
>
> **Existing docs** (if found): I'll list any docs I found and propose how they map to `docs/context/`. Confirm or reject each mapping.

---

## Phase 4: Generate Files

After all answers are confirmed, create or update the following. For each file:
- **Does not exist** → create it.
- **Already exists** → show what would change and ask: merge, replace, or skip.

### 4a. `AGENTIC.md` (root)

Use the same template as `install-agent-scaffold` Step 2a. Replace all placeholders with confirmed values. No `[PLACEHOLDER]` may remain.

### 4b. `CLAUDE.md` (root)

Use the same template as `install-agent-scaffold` Step 2b. Include the Auto-Invocations table for open-sprint and report-track-status.

### 4c. `docs/context/plan.md`

If the user approved a doc migration, copy the source file and prepend:
```
<!-- Migrated from [original path] — review and update stale content. -->
```
Otherwise create the standard blank template.

### 4d. `docs/context/tracks.md`

Initialize with: `Project adoption — Conductor OS initialized.`

### 4e. `docs/context/product.md`

Standard blank template if no source doc was identified.

### 4f. `.claude/agents/[architect-name].md`

Use the architect template. Update name, description, and tech stack reference section.

### 4g. `.claude/agents/[specialist-name].md` (one per specialist)

Use the specialist template. Update name, domain, and scope section.

### 4h. `.claude/agents/[critic-name].md`

Use the critic template. Update name and build command.

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
- [CRITIC NAME] — invoke with @[critic-name]

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
