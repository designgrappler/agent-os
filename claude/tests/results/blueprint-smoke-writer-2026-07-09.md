# Blueprint Smoke Test — task-writer
**Test ID:** blueprint-smoke-writer-2026-07-09
**Track:** T34.F2
**Date:** 2026-07-09
**Blueprint tested:** `claude/blueprints/task-writer.md`
**Spawn mechanic:** Mechanic A (`subagent_type: task-executor`)

---

## Test Brief

Read `claude/blueprints-schema.md` as source material. Author `claude/tests/output/writer-test-output.md` with frontmatter fields `title`, `source`, `generated` and three sections: `## Purpose`, `## Schema Fields`, `## Constraints`. Content drawn from the source file.

**Forces tested:** Read (source material), Write (single declared output path)

---

## Output Check Results

| Check | Expected | Result | PASS/FAIL |
|---|---|---|---|
| File exists at declared path | `claude/tests/output/writer-test-output.md` | File present, 6327 bytes, 47 lines | PASS |
| YAML frontmatter valid | Parses cleanly | Valid YAML block, no malformation | PASS |
| `title` field present | `Blueprint Schema Reference` | Present, correct value | PASS |
| `source` field present | `claude/blueprints-schema.md` | Present, correct value | PASS |
| `generated` field present | `2026-07-09` | Present, correct value | PASS |
| `## Purpose` section present | Required, first | Present, substantive prose content | PASS |
| `## Schema Fields` section present | Required, second | Present, substantive prose content | PASS |
| `## Constraints` section present | Required, third | Present, substantive prose content | PASS |
| Section order | Purpose → Schema Fields → Constraints | Correct order | PASS |
| No placeholder text remaining | Zero `[PLACEHOLDER]`/`[TBD]` values | None found (line 43 reference is prose content about the constraint, not a placeholder value) | PASS |
| Isolation: no other files touched | `git diff --name-only` shows only `claude/tests/` | Only `claude/tests/` in diff — no other files touched | PASS |

**All 11 checks: PASS**

---

## Tool Bindings Observed

The task-writer blueprint declares `tools: [Read, Write, WebFetch]`.

Observed tool calls from the Task Agent execution:
- **Read:** 1 call (read `claude/blueprints-schema.md` source material)
- **Write:** 1 call (wrote output file to declared path)
- **WebFetch:** 0 calls (source was a local file; no URL fetch needed)

All tool calls were within the declared `tools:` allowlist. No tool calls outside that allowlist were observed.

---

## Isolation Assertion

`git diff --name-only` from Skylar's worktree shows ONLY:
```
claude/tests/   (untracked new directory)
```

No file outside `claude/tests/` was modified. The task-writer blueprint's hard constraint ("Never write to files outside the declared output path") was honored.

**Note on worktree path handling:** The task-executor subagent ran in its own isolated worktree (`agent-a3fae4e64e1843a6c`). The Task Agent correctly produced the output file in the structurally equivalent path in its worktree. Skylar (Role Agent) read the output from the Task Agent's worktree and wrote it to the canonical path in the Skylar worktree (`agent-ab14643c7339119df`). This is the expected Role Agent synthesis behavior — the isolation assertion is evaluated on the Skylar worktree diff, which shows only `claude/tests/` as changed.

---

## Task Agent Structured Output

```
Files touched: claude/tests/output/writer-test-output.md (created, +47 lines)
Build result: N/A
Frontmatter fields: title, source, generated
Sections written: ## Purpose, ## Schema Fields, ## Constraints
Sources fetched: none (local file)
Flags: Worktree path correction noted — file written to task agent's own worktree path;
       Role Agent (Skylar) synthesized content into Skylar's worktree canonical path.
```

---

## Verdict

**PASS.** The `task-writer` blueprint fires `Read` and `Write` tool bindings correctly. It produced a valid, isolated `.md` file with correct YAML frontmatter (`title`, `source`, `generated`), all three required sections (`## Purpose`, `## Schema Fields`, `## Constraints`) in the declared order, substantive prose content drawn from the source material, and no placeholder text. No file outside the declared output path was touched. The Expected Output Contract ("Valid, isolated .md file with frontmatter and the documented section structure.") is satisfied.
