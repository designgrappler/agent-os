# Blueprint Smoke Test Suite

This directory contains the Agent OS blueprint smoke test suite. Each test validates that a named blueprint spawns correctly, fires its declared tool bindings, and produces output that satisfies its Expected Output Contract (EOC).

## Purpose

Blueprint smoke tests verify end-to-end wiring of the Blueprint → Role Agent → Task Agent execution chain (AGENTIC.md §11). A smoke test is not a unit test — it exercises the full spawn path in a real Task Agent context and checks the four required EOC sections against the blueprint's contract.

## Three test cases

| Track | Blueprint | Test result file |
|---|---|---|
| T34.F1 | `task-researcher` | `claude/tests/results/blueprint-smoke-researcher-2026-07-09.md` |
| T34.F2 | `task-writer` | `claude/tests/results/blueprint-smoke-writer-2026-07-09.md` |
| T34.F3 | `task-coder` | `claude/tests/results/blueprint-smoke-coder-2026-07-09.md` |

## How to run

Each smoke test is a Skylar track. The test is executed by:

1. Skylar reads the blueprint body from `claude/blueprints/<name>.md`.
2. Skylar spawns a `task-executor` subagent (Mechanic A per AGENTIC.md §11.2) with the blueprint body + a specced synthetic brief.
3. The Task Agent executes against real sources (local files, URLs as named in the brief).
4. Skylar captures the output and writes a test report to `claude/tests/results/`.

## Output checks (all must hold for PASS)

For `task-researcher`:
- Four required sections present: `## Research Question`, `## Synthesis`, `## Sources`, `## Gaps`
- `## Sources` lists the fetched URL with a real HTTP status
- `## Gaps` is non-empty
- No fabricated citations

For `task-writer` and `task-coder`: see their respective Bridge documents.

## Scratch output

`claude/tests/output/` is the shared scratch directory for intermediate artifacts produced during test execution. It is version-tracked via `.gitkeep` to ensure the directory persists across worktree checkouts. Agents write intermediate files here during research; final test reports land in `claude/tests/results/`.

## Result file naming convention

`blueprint-smoke-<blueprint-name>-<YYYY-MM-DD>.md`
