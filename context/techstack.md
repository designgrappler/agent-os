# Tech Stack

> This file is the tech stack definition template for an Agent OS project. Replace all placeholder content with your project's specifics.

<!-- Document the tools and technologies your project relies on. Agents read this file to understand what commands to run, what runtime to target, and what guardrails apply. Be specific — "Node.js 20" is more useful than "JavaScript". -->

---

## Language / Runtime

<!-- State the primary language and runtime version. If multiple languages are in play, list the primary one first. -->

*e.g. TypeScript 5.x on Node.js 20 (LTS).*

*e.g. Python 3.12 managed via `pyenv`.*

---

## Package Manager

<!-- Name the package manager and, if relevant, the version. Only one package manager should own installs — note it here so agents never reach for the wrong one. -->

*e.g. `bun` — all install, run, and build commands use `bun`, never `npm` or `yarn`.*

*e.g. `pnpm` — lockfile is `pnpm-lock.yaml`; do not commit a `package-lock.json`.*

---

## Build Command

<!-- The single command that compiles, bundles, or type-checks the project. This must exit zero before any PR merges. Agents run this as a verification step after every change. -->

*e.g. `bun run build` — must exit 0 before any branch merges.*

*e.g. `pnpm build && pnpm typecheck` — both must pass; typecheck is not optional.*

---

## Framework

<!-- Name the primary application framework, if any. If the project is a library or CLI with no framework, say so. -->

*e.g. Next.js 14 (App Router) — pages live in `app/`; API routes live in `app/api/`.*

*e.g. No framework — this is a plain Node.js CLI.*

---

## Deployment Target

<!-- Where does the built artifact run? This informs agents about environment constraints (e.g. Edge runtime limitations, serverless cold-start budgets, container image size). -->

*e.g. Vercel — Edge runtime for middleware, Node.js runtime for API routes.*

*e.g. Docker container on a self-hosted VPS — no serverless constraints; long-running processes are fine.*

---

## Quality Tooling

<!-- List linters, formatters, test runners, and any type-checkers in use. Include the commands agents should run. If a tool is not configured, say "not configured" rather than leaving this blank — agents need to know what NOT to run. -->

<!-- Both Claude Code and Gemini CLI users: list the tools you actually have wired up. Example for Claude Code users: the `tools:` field in each agent's frontmatter can restrict which commands the agent is allowed to run. Example for Gemini CLI users: the `policy.toml` capability bundles control which tool categories are available per tier. Either way, the tooling listed here should match what your CI/CD pipeline enforces. -->

*e.g. ESLint (`bun run lint`), Prettier (`bun run format`), Vitest (`bun run test`). No TypeScript type-check configured separately — type errors surface via `bun run build`.*

*e.g. Ruff (lint + format), pytest (`python -m pytest`). Type-check: `pyright` — run with `pyright .` before merge.*
