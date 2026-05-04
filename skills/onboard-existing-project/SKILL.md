---
name: onboard-existing-project
description: Onboards an existing project into Conductor OS by discovering the current structure, pre-populating the setup interview, and generating the DNA files without overwriting what's already there.
Abbreviation: Pa
Category: Orchestration
Type: Tier 1
Bundle: ARCHITECT
Capabilities: [fs_read, fs_write, net_fetch]
---

# Skill: Onboard Existing Project

## Description
The onboarding path for **existing projects**. Instead of asking for details you already have, this skill reads your project first — README, package.json, existing docs, folder structure — and pre-fills the setup interview with what it finds. You confirm or correct; it generates the DNA files. Nothing is overwritten without your approval.

> **New project?** Use `install-agent-scaffold` instead. This skill is only for projects that already have files and history.

## Operational Rules
- **Read First, Write Second**: Run the full discovery phase before asking any questions or creating any files.
- **Never Overwrite Silently**: If a file that would be created already exists, flag it explicitly and ask whether to merge, replace, or skip.
- **No Placeholders**: Every value in the generated files must be confirmed by the user. Pre-filled values from discovery are proposals, not facts.
- **Identity Header**: Every message MUST lead with the Identity Header: **[Name] ([Role])**

---

## Phase 1: Discovery (Run Before Asking Anything)

Read the following files silently. Do not ask questions yet. Extract as much as possible.

| File / Path | Extract |
|---|---|
| `README.md` | Project name, description, tech stack hints |
| `package.json` / `pyproject.toml` / `Cargo.toml` | Project name, dependencies → infer stack |
| `src/` / `app/` / `lib/` structure | Frontend framework, language |
| `api/` / `server.ts` / `routes/` | Backend runtime/framework |
| `supabase/` / `prisma/` / `db/` | Database |
| `.env.example` | Services in use |
| `docs/` or `context/` | Any existing planning or context docs |
| `.agent/context/AGENTIC.md` | Whether Conductor OS is already initialized |
| `CLAUDE.md` or `AGENTIC.md` at root | Claude Code / prior Conductor setup |
| `.gitignore` | Worktree path convention already in place |

After reading, assemble a **Discovery Report** internally — do not show it yet.

---

## Phase 2: Conflict Check

Before asking any questions, evaluate:

1. **Already initialized?** If `.agent/context/AGENTIC.md` exists → warn the user and ask if they want to re-initialize or exit.
2. **Partial setup?** If only some DNA files exist (e.g., `AGENTIC.md` but no `tracks.md`) → note which files are missing and will be created.
3. **Existing docs to map?** If a `docs/` or `context/` folder exists → identify which files could serve as `plan.md`, `tracks.md`, or `product.md` and propose the mapping.

---

## Phase 3: Pre-Populated Interview

Present the following as a single numbered list. Pre-fill any value discovered in Phase 1 as a **proposal in parentheses** — the user can confirm or correct each one. **Wait for all answers before creating any files.**

> I've read your project files. Here's what I found — please confirm or correct each value:
>
> 1. **Project name** — *(Proposed: [discovered name or "Not found — please provide"])*
> 2. **One-sentence description** — *(Proposed: [discovered description or "Not found"])*
> 3. **Tech stack / Toolset** — *(Proposed: [inferred stack, e.g., "React + Bun + Supabase" or "Not found"])*
> 4. **Team type** — Is this a **dev team** (building software), a **creative/business team** (producing docs, designs, campaigns), or a **mixed team**? *(Proposed: [inferred from stack, e.g., "Dev team" if package.json found])*
> 5. **Conductor name** — What is your name? (You are the human Owner/Conductor.) *(No default — required)*
> 6. **Architect name** — What should the Lead Architect agent be called? *(No default — required)*
> 7. **Implementation Team** — How many specialist roles do you need, and what are their names and domains? *(Proposed: [inferred from folder structure, e.g., "Frontend (src/), Backend (api/), Database (supabase/)"])*
> 8. **Critic name** — What should the Quality Gate agent be called? *(No default — required)*
> 9. **Workflow mode** — Are you using an external model (like Claude) for implementation? Answer `RELAY` if yes, `GEMINI_ONLY` if no.
> 10. **Build / verification command** — What command confirms a clean build? *(Proposed: [inferred from package.json scripts, e.g., "npm run build" or "Not found — please provide"])*
>
> **Existing docs mapping** (if applicable):
> If I found existing planning documents, I'll list them here and propose how they map to the DNA taxonomy. Confirm or reject each mapping.

---

## Phase 4: File Generation

After all answers are confirmed, generate the following. For each file:
- If it **does not exist** → create it.
- If it **already exists** → show a diff of proposed changes and ask: merge, replace, or skip.

### Files to generate:
1. `.agent/context/AGENTIC.md` — using the full template from `conductor-setup`
2. `.agent/context/tracks.md` — initialize with "Project adoption complete."
3. `.agent/rules/handoff-protocol.md` — standard handoff protocol

### Existing docs migration (if applicable):
If the user confirmed doc mappings in Phase 3:
- Copy (do not delete) identified files to `.agent/context/plan.md`, `.agent/context/product.md`, etc.
- Note at the top of each copied file: `# Migrated from [original path] — review and update.`

---

## Phase 5: Adoption Summary

After all files are created, output:

```
## Project Adoption Complete

**Project:** [PROJECT NAME]
**Files created / updated:** [list]
**Skipped (already exists, no changes):** [list or "None"]

**Existing docs migrated:**
[list of original → new path mappings, or "None"]

**Your team:**
- [ARCHITECT NAME] — Lead Architect
- [SPECIALIST NAMES] — [domains]
- [CRITIC NAME] — Quality Gate

**Next steps:**
1. Review AGENTIC.md — confirm the protocols match your project's conventions.
2. Review any migrated docs and update stale content.
3. Call [ARCHITECT NAME] to open your first sprint.
```

---

## Verification
1. **Discovery First**: Confirm the skill read project files before asking any questions.
2. **No Blind Overwrites**: Confirm no existing files were replaced without explicit user approval.
3. **No Placeholders**: Confirm every field contains a real confirmed value — no `[TBD]` or `[placeholder]`.
4. **Migration Notes**: Confirm migrated docs include the `# Migrated from` header.

## Stats
- **Overhead**: ~1200 Tokens (Discovery + Interview + Generation)
- **Operational Level**: Level 1 (Meta-Orchestration)
- **Benefit**: Existing projects get full Conductor OS setup without losing history or being asked details the codebase already contains.

## Trigger
Tell Architect: "Adopt this project into Conductor OS." or "Set up agent orchestration for my existing project."
