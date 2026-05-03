# AGENTIC DNA (Static DNA)
*Fill in all [PLACEHOLDERS] before using. Delete this line when done.*

This document contains the foundational constraints, identities, and protocols for **[PROJECT NAME]**. It is the root "Source of Truth" (Static DNA) and must be ingested by all agents before any actions are taken.

---

## 1. DNA Taxonomy
- **Static DNA:** Foundational tech, team roles, and protocol constraints (this file).
- **Dynamic DNA:** High-churn task state, roadmap, and requirements (`docs/context/`).

---

## 2. Tech Stack (Static DNA)

### Backend
- **Runtime:** [YOUR RUNTIME — e.g., Bun, Node.js, Python, Go]
- **Framework:** [YOUR FRAMEWORK — e.g., Hono, Express, FastAPI, Gin]
- **Database:** [YOUR DATABASE — e.g., Supabase PostgreSQL, PlanetScale, MongoDB]
- **Transport:** [PROTOCOL CONSTRAINTS — e.g., "JSON only, no multipart/form-data"]

### Frontend
- **Framework:** [YOUR FRONTEND FRAMEWORK — e.g., React 19 + Vite, Next.js, SvelteKit]
- **Styling:** [YOUR CSS APPROACH — e.g., Tailwind CSS 4, CSS Modules, Styled Components]
- **Design System:** [YOUR DESIGN SYSTEM — e.g., shadcn/ui, Material UI, "Custom — see FIGMA_URL"]

### Quality & Automation
- **Type Checking:** [e.g., TypeScript strict mode via `bunx tsc --noEmit`]
- **Build:** [e.g., `bun run build` or `npm run build`]
- **Linting:** [e.g., ESLint, Biome, Ruff]

---

## 3. Team Architecture

### Core Org Chart
- **[CONDUCTOR NAME] (Conductor):** Vision & Approval.
- **Claude (Orchestrator):** Coordinates specialists, no direct execution.
- **[ARCHITECT NAME] (Lead Architect):** Context Owner. Zero-code. Plans and produces Handoff Bridges.
- **[SPECIALIST 1 NAME] ([Domain 1] Specialist):** Owns [scope — e.g., "src/components/, src/pages/, src/hooks/"].
- **[SPECIALIST 2 NAME] ([Domain 2] Specialist):** Owns [scope — e.g., "api/, server.ts, auth flow"].
- **[SPECIALIST 3 NAME] ([Domain 3] Specialist):** Owns [scope — e.g., "supabase/migrations/, src/types/"].
- **[CRITIC NAME] (Quality Critic):** QA, build verification. Read-only.

*Add or remove specialists as needed for your team.*

---

## 4. Worktree Protocol

Each Track gets an isolated git worktree to prevent cross-track contamination:

```bash
# Open a new track
git worktree add .worktrees/track-N track/N-short-description

# Specialist works inside that worktree only
# Critic reviews the diff before merge back to main branch
git worktree remove .worktrees/track-N
```

- Worktrees live in `.worktrees/` (add to `.gitignore`)
- Branch naming: `track/N-short-description`
- Never work directly on the main branch when 2+ tracks are active in parallel
- Worktree removed only after Critic issues PASS verdict

---

## 5. Conductor Protocols

### Stability Rules
- **Circuit Breaker:** 3 consecutive failures with the **same root cause** → STOP and escalate to [CONDUCTOR NAME]. Different error types reset the counter. Any single destructive or security-related failure triggers an immediate stop regardless of count.
- **Git Hygiene:** No commits unless directed. Use `git add` for staging only.
- **Sentinel Proof:** Never trust an agent's verbal summary. Verify with `git diff` or direct file reads.

### Handoff Logic
- **Phase 1 (Verify):** Downstream specialist verifies upstream interface before any implementation begins.
- **Phase 2 (Align):** Synchronize with `AGENTIC.md` and `tracks.md`.
- **Phase 3 (Draft):** Architect drafts implementation plan.
- **Phase 4 (Bridge):** Architect compresses Dynamic DNA into a Handoff Bridge for the Specialist.

---

## 6. Commit Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

feat(auth): add OAuth redirect handler
fix(items): correct rounding on split calculation
chore(deps): upgrade dependency
refactor(ui): extract component into standalone file
```

**Types:** `feat` · `fix` · `chore` · `refactor` · `docs` · `style` · `perf` · `test`
**Breaking changes:** append `!` after type and include `BREAKING CHANGE:` in the body.

---

## 7. Definition of Done

A track is **Done** only when ALL of the following are true:

- [ ] `[BUILD COMMAND]` exits with zero errors
- [ ] All changes are within the declared track scope (no scope drift)
- [ ] No `console.log`, `debugger`, or hardcoded secrets in the diff
- [ ] `docs/context/plan.md` and `tracks.md` updated to reflect the completed track
- [ ] [CRITIC NAME] has issued a **PASS** verdict
- [ ] [CONDUCTOR NAME] has given final approval (for tracks touching auth, schema, or payments)

---

## 8. Handoff Bridge Template

```markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Static DNA Check:** [Confirm alignment with AGENTIC.md tech/roles]
**Dynamic DNA State:**
- **Product Context:** [1-sentence summary of requirement]
- **Current Plan:** [step in plan.md]
- **Execution Files:** [list of files to modify]
**Worktree Setup:** [git worktree command, or "N/A — single active track"]
**Verification:** [specific command or URL]
**Next Step:** [specific task for the Specialist]
```

---

*Fill in all placeholders before your first session. This file rarely changes after initial setup.*
