# Blueprint Smoke Test Suite — Historical Reference

> **Note:** These tests were written against the pre-S43 architecture (blueprint→task-executor chain) and are retained as historical reference only. They do not reflect the current execution model.
>
> **Current execution model:** orchestrator → specialist → task agent. New tests should be written against this model, not against the blueprint/task-executor chain documented here.

## Original purpose (pre-S43)

Smoke tests that verified the Blueprint → Role Agent → Task Agent execution chain. Each test validated that a named blueprint spawned correctly, fired its declared tool bindings, and produced output that satisfied its Expected Output Contract (EOC).

## Three test cases (historical)

| Track | Blueprint | Test result file |
|---|---|---|
| T34.F1 | `task-researcher` | `claude/tests/results/blueprint-smoke-researcher-2026-07-09.md` |
| T34.F2 | `task-writer` | `claude/tests/results/blueprint-smoke-writer-2026-07-09.md` |
| T34.F3 | `task-coder` | `claude/tests/results/blueprint-smoke-coder-2026-07-09.md` |

## How tests were run (pre-S43)

1. Skylar read the blueprint body from `claude/blueprints/<name>.md`.
2. Skylar spawned a `task-executor` subagent with the blueprint body + a specced synthetic brief.
3. The Task Agent executed against real sources (local files, URLs as named in the brief).
4. Skylar captured the output and wrote a test report to `claude/tests/results/`.

## Output checks (historical, for reference)

For `task-researcher`:
- Four required sections present: `## Research Question`, `## Synthesis`, `## Sources`, `## Gaps`
- `## Sources` lists the fetched URL with a real HTTP status
- `## Gaps` is non-empty
- No fabricated citations

For `task-writer` and `task-coder`: see their respective result files.

## Scratch output

`claude/tests/output/` is the shared scratch directory for intermediate artifacts produced during test execution. It is version-tracked via `.gitkeep` to ensure the directory persists across worktree checkouts.

## Result file naming convention

`blueprint-smoke-<blueprint-name>-<YYYY-MM-DD>.md`
