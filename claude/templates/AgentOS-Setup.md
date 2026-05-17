# Agent OS Setup

Fill in the fields below, then run `/install-agent-scaffold` in Claude Code.
This file will be deleted automatically when setup is complete.

---

## Project

**Project name:** 
**Short description:** 

---

## Set Up Your Team

Edit the table below to define which roles you need for your project. Specify an agent name, their role, and key responsibilities. Ask your primary agent if you have questions.

Agents can be invoked by typing their name via `@[architect-name]`, `@[qa-name]`, etc. Agent profiles are located in `.claude/agents/` and can be edited at any time.

| Agent Name | Role | Scope and Responsibilities |
|---|---|---|
| **[YOUR NAME]** | Conductor | Vision & Approval |
| **[YOUR AI]** | Orchestrator | Coordinates specialists, no direct execution | <!-- e.g., Claude, Gemini -->
| **[ARCHITECT NAME]** | Lead Architect | Plans, Red Flag Analysis, Handoff Bridges — zero code |
| **[SPECIALIST 1 NAME]** | [Domain 1] Specialist | `[file scope — e.g., src/components/]` |
| **[SPECIALIST 2 NAME]** | [Domain 2] Specialist | `[file scope — e.g., api/, server.ts]` |
| **[SPECIALIST 3 NAME]** | [Domain 3] Specialist | `[file scope — e.g., supabase/migrations/]` |
| **[QA NAME]** | QA | Read-only quality gate — no code writes |

---

## Define Your Tech Stack

Defaults are pre-selected. Replace any value you want to change. Leave blank to skip optional fields.

**Runtime:** Node.js <!-- alternatives: Bun · Python · Go · Deno -->
**Framework:** Express <!-- alternatives: Hono · FastAPI (Python) · Gin (Go) · Koa -->
**Database:** PostgreSQL via Supabase <!-- alternatives: PlanetScale · MongoDB · SQLite · leave blank if none -->
**Frontend framework:** React + Vite <!-- alternatives: Next.js · SvelteKit · Nuxt · Remix · leave blank if none -->
**Styling:** Tailwind CSS <!-- alternatives: CSS Modules · Styled Components · Sass · leave blank if none -->
**Build command:** npm run build <!-- alternatives: bun run build · python -m build -->
**Type check command:** <!-- e.g. bunx tsc --noEmit · mypy · leave blank if none -->
**Linter:** ESLint + Prettier <!-- alternatives: Biome · Ruff (Python) · leave blank if none -->

---

## Existing docs to migrate *(optional)*

Update the paths below to match your actual files. Delete rows that don't apply.

| Current file | Maps to |
|---|---|
| README.md | docs/context/product.md |
| [roadmap, backlog, or requirements doc] | docs/context/plan.md |
| [design spec or product brief] | docs/context/product.md |
| [sprint notes or task list] | docs/context/tracks.md |
