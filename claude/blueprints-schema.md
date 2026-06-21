# Blueprint Schema Specification — Agent OS v1

**Schema version:** 1
**Status:** CANONICAL — governed by AGENTIC.md §9.2 compatibility window
**Author:** Architect (Peaches) / Specialist (Skylar)
**Sprint:** S19 Track 19.1
**Related:** `AGENTIC.md` §1 DNA Taxonomy (cross-reference), `AGENTIC.md` §9.2 (compatibility window), `claude/blueprints/` (blueprint files)

---

## Purpose

This document is the canonical specification for Agent OS task blueprints. It governs how blueprint files are authored, what fields are required, what the three required body sections mean, and what decisions were intentionally deferred. Every track that authors or validates blueprints references this document.

A **blueprint** is a self-contained Markdown file that encodes a task-level execution template for spawning a subagent. The four columns of Tim's blueprint table map directly to Claude Code subagent frontmatter and body, with one Agent OS-specific addition (`expected_output`).

---

## 1. The Four-Column Schema

Tim's blueprint table defines the canonical mental model. Each row in the table is one complete blueprint. The four columns are the schema:

| Tim's column | What it is | Maps to (Claude Code subagent frontmatter) |
|---|---|---|
| `Blueprint Profile` | Name / identity of the blueprint | `name:` (required, lowercase + hyphens) |
| `System Prompt Strategy` | System prompt content — what the agent focuses on | Markdown body (which IS the system prompt at spawn time) + `description:` (one-line "when to use this") |
| `Allowed Tool Bindings` | Tool allowlist for this blueprint | `tools:` (frontmatter array — Claude Code tool names verbatim) |
| `Expected Output Contract` | Definition of done — what "done" looks like | `expected_output:` frontmatter (one-line shorthand) + `## Expected Output Contract` body section (full contract) |

**Blueprint Profile column → `name:`.** Required. Lowercase, hyphens for word-separation. Must match the filename minus `.md`. Must carry the `task-` prefix (see §4 Naming Convention).

**System Prompt Strategy column → body + `description:`.** The body of the blueprint file IS the system prompt at spawn time — exactly as Claude Code subagent files work. `description:` is the one-line "when to use this" that appears in catalogue renders and helps a Role Agent select the right blueprint. Both are required.

**Allowed Tool Bindings column → `tools:`.** The `tools:` frontmatter array contains Claude Code tool names verbatim — `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Agent`, or MCP server patterns `mcp__<server>` / `mcp__<server>__*`. Conceptual categories (e.g. 'web search', 'file write') belong in the Allowed Tool Bindings — Reasoning body section, not in the `tools:` array. Tim's table lists conceptual names (`file_write`, `web_search`, `terminal`) as a reference; the blueprint file translates those to their Claude Code equivalents.

**Expected Output Contract column → `expected_output:` + body section.** Required in both places, with a binding sync rule (see §3.3).

---

## 2. Field-by-Field Reference

### `name:` — Blueprint Profile

**Required.** Lowercase string, hyphens for word-separation. Must match the filename minus `.md`.

Must carry the `task-` prefix (see §4). Example: `task-coder`.

**Source:** Claude Code subagent docs — `name` is a required frontmatter field. Agent OS adds the `task-` prefix requirement.

---

### `description:` — When-to-use hint

**Required.** One-line string. Serves as the "when a Role Agent should pick this blueprint" hint for catalogue rendering and agent selection at spawn time.

Example: `Use this when a task requires writing or editing source code against a clear spec.`

**Source:** Claude Code subagent docs — `description` is a required frontmatter field.

---

### `tools:` — Allowed Tool Bindings

**Required.** YAML array of Claude Code tool names verbatim. The runtime enforces this allowlist — only the tools listed here are available to the spawned agent.

Permitted values: `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Agent`, or MCP server patterns `mcp__<server>` / `mcp__<server>__*`.

Conceptual descriptions of tool purpose belong in the `## Allowed Tool Bindings — Reasoning` body section. The `tools:` array is for literal runtime values only.

**Source:** Claude Code subagent docs — `tools` is a supported frontmatter field, runtime-enforced.

---

### `expected_output:` — Output contract shorthand

**Required.** One-line string. The frontmatter shorthand for what "done" looks like.

The `expected_output:` frontmatter field is read by Agent OS tooling (catalogue rendering, QA gates) but is not interpreted by the Claude Code runtime. It is advisory content that informs the spawned agent's behavior via the body's Expected Output Contract section. The runtime does not validate output against this field.

Tool allowlists (`tools:` / `disallowedTools:`) are runtime-enforced by Claude Code. Output contracts (`expected_output:` + body section) are not — they are prose contracts the spawned agent reads and is expected to honor; verification of compliance is the spawning agent's responsibility post-execution.

**Sync rule (machine-checkable):** The frontmatter `expected_output:` value MUST equal the first sentence of the body's `## Expected Output Contract` section, verbatim. This is a machine-checkable invariant — Phase 7 of the `check-agent-os` health check enforces it.

**Source:** Agent OS-specific addition. No equivalent exists in Claude Code subagent docs. Modeled after CrewAI's `expected_output` field (prose-description pattern, not schema-validated).

---

### `model:` — Model tier

**Optional.** Short model name: `sonnet`, `opus`, or `haiku`. Defaults per Sprint 5 T3 conventions when absent.

Example: `model: sonnet`

Do not use full versioned model names (e.g. `claude-sonnet-4`) — use the short tier name only, per Sprint 5 T3 invariant.

**Source:** Claude Code subagent docs — `model` is a supported frontmatter field. Agent OS restricts values to short tier names per Sprint 5 T3.

---

### `schema_version:` — Blueprint schema version

**Required.** Integer. Must be `1` for all blueprints conforming to this specification.

Future schema changes (new required fields, renamed fields, removed fields) increment this value. During any schema transition, AGENTIC.md §9.2's binding 2-sprint compatibility window applies: both old and new schema versions must parse cleanly for a minimum of 2 sprints, missing fields default to documented values, and old schema files produce a warning nudge (not a hard break) after the window closes.

**Source:** Agent OS-specific addition. Modeled after the `frontmatter-version` field in `skills-manifest.json`, governed by the existing §9.2 compatibility window.

---

## 3. Required Body Sections

Every blueprint body must contain exactly three required H2 sections, in this order, plus a one-paragraph framing block above them.

### 3.0 Framing paragraph (required, no H2 heading)

One paragraph immediately after the H1 title. States what this blueprint is for, in plain language. Mirrors the system prompt framing the user would give a human collaborator. This paragraph is part of the system prompt body the spawned agent reads.

### 3.1 `## System Prompt Strategy`

The system prompt body. This section IS the agent's system prompt at spawn time — exactly as Claude Code subagent files already work. Long-form Markdown. The author's discretion governs sub-structure within this section, but typical structure follows the T7.4 hardened canonical-template pattern: Identity, Operational Rules, Hard Constraints, Communication style.

This section encodes the `System Prompt Strategy` column from Tim's table. The `description:` frontmatter is the one-line summary; this section is the full operational definition.

### 3.2 `## Expected Output Contract`

Full definition of done. The first sentence of this section MUST match the frontmatter `expected_output:` value verbatim (the sync rule from §2). The remainder of the section is the extended contract: what valid output looks like, at least one concrete positive example, and any negative examples or anti-patterns that help the spawned agent distinguish a done artifact from an incomplete one.

The frontmatter `expected_output:` is the catalogue-render shorthand. This section is the human-readable and agent-readable full contract. Both surfaces are required; they serve different consumers. Neither is optional.

### 3.3 `## Allowed Tool Bindings — Reasoning`

One paragraph per tool listed in the `tools:` frontmatter array. Each paragraph names the tool and explains in concrete terms why it is in scope: what behavior it enables, what it would not be possible to accomplish without it. This is the Agent OS audit trail for tool allowlists.

A blueprint without this section cannot pass the QA gate.

---

## 4. Naming Convention

Every blueprint name carries the `task-` prefix. This is a schema-level constraint, not a style suggestion.

**Rationale:** the `task-` prefix disambiguates blueprints (task-level execution templates) from role agents (team-level members in `claude/agents/`). Without the prefix, naming collisions are inevitable as both the blueprint catalogue and the role-agent library grow. The `task-` prefix makes the layer boundary unambiguous on every name in the catalogue and reinforces the system hierarchy for users who read or edit blueprint files directly.

**Examples:** `task-coder`, `task-writer`, `task-researcher`. Never bare `coder`, `writer`, `researcher`.

**Filename rule:** the blueprint filename is `<name>.md` where `<name>` is the full `name:` frontmatter value including the `task-` prefix. The `name:` value must match the filename minus `.md`.

---

## 5. Catalogue Rule — Directory IS the Catalogue

There is no `catalogue.json` index file. The catalogue is `ls claude/blueprints/` plus the frontmatter of each file.

If a rendered table view is wanted (for documentation, a `/list-blueprints` skill, or any UI), it is **generated** from the directory contents — not authored separately. The four columns of the rendered table correspond directly to the four frontmatter fields: `name`, `description`, `tools`, `expected_output`. The source of truth is always the files themselves.

This eliminates an entire class of consistency bug: a `catalogue.json` that drifts from the actual directory. Under the directory-as-catalogue rule, `ls claude/blueprints/` is authoritative at all times.

---

## 6. Delegation Strategies

Agent OS supports two complementary delegation strategies. (a) Named blueprints — pre-authored files in `claude/blueprints/` that this schema governs. (b) Dynamic delegation — the spawning agent composes an ad-hoc delegation message at runtime, using no pre-authored blueprint. This is Claude Code's native fallback behavior and is not encoded by the blueprint schema. S19 ships strategy (a). Strategy (b) is supported by the runtime independently. Future sprints may add an impromptu-to-named promotion path.

The blueprint schema governs strategy (a) exclusively. Strategy (b) requires no authoring artifact and no schema conformance check.

---

## 7. Duplication Trade-Off

Blueprint authoring accepts self-containment as a design goal rather than reuse. If two blueprints both want a similar system prompt scaffold (e.g. two research-flavored blueprints), both blueprints contain that scaffold independently. There is no DRY mechanism in the v1 schema.

This is a deliberate trade-off. Two consequences:

1. **Authoring discipline is the only check against needless duplication.** When a new blueprint is authored that overlaps with an existing one, the authoring step should include a "is this distinct enough to warrant a new blueprint?" check. Duplication is acceptable; redundancy without distinction is not.
2. **Drift across similar blueprints is possible.** If a system prompt scaffold is updated in one blueprint, it is not automatically updated in similar blueprints. Existing drift is a known limitation documented here; the QA gate at authoring time catches new divergence.

Both consequences are acceptable for an MVP foundation sprint with three blueprints. If duplication cost becomes painful in practice, a future sprint can add a partials/include mechanism (see §11).

---

## 8. Blueprint File Format Template

Authors must copy this template when creating a new blueprint. No placeholder text (`[PLACEHOLDER]`, `[TBD]`) may remain in a shipped blueprint file.

```markdown
---
name: task-<name>                       # column 1: Blueprint Profile — must use task- prefix
description: <one-line invocation hint> # when a Role Agent should pick this blueprint
tools:                                  # column 3: Allowed Tool Bindings — Claude Code tool names verbatim
  - <ToolName>
expected_output: <one-line shorthand>   # column 4: Expected Output Contract (frontmatter shorthand)
model: <sonnet|opus|haiku>              # optional, defaults per Sprint 5 T3 conventions
schema_version: 1                       # blueprint schema version, governed by AGENTIC.md §9.2
---

# <Blueprint Name>

<One-paragraph framing: what this blueprint is for.>

## System Prompt Strategy

<The system prompt body. Becomes the agent's system prompt at spawn time.>

## Expected Output Contract

<Full definition of done. First sentence must match frontmatter `expected_output:` verbatim.>

## Allowed Tool Bindings — Reasoning

<One paragraph per tool listed in `tools:` frontmatter, naming why it is in scope.>
```

---

## 9. Validation Invariants

The following invariants are machine-checkable by Phase 7 of `check-agent-os`:

1. **Filename ↔ `name:` match.** The `name:` frontmatter value must equal the filename minus `.md`.
2. **`task-` prefix present.** Every `name:` value in `~/.claude/blueprints/` must start with `task-`.
3. **Required fields present.** `name`, `description`, `tools`, `expected_output`, `schema_version` must all be present in the frontmatter of every blueprint.
4. **`expected_output:` sync rule.** The frontmatter `expected_output:` value must equal the first sentence of the body's `## Expected Output Contract` section, verbatim.
5. **Required body sections present.** Each blueprint must contain `## System Prompt Strategy`, `## Expected Output Contract`, and `## Allowed Tool Bindings — Reasoning`.

Any file failing one or more of these invariants is reported as "invalid" by the health check. The check reports and continues — it does not crash on a single invalid file.

---

## 10. Per-Row Example (S19 initial set)

The three S19 blueprints use the `task-` prefix convention established by Q3 closure:

| `name:` | `description:` | `tools:` | `expected_output:` |
|---|---|---|---|
| `task-coder` | Use this when a task requires writing or editing source code against a clear spec. | `Write`, `Edit`, `Read`, `Bash` | Markdown code blocks or structured file diffs against named files. |
| `task-writer` | Use this when a task requires authoring or revising structured Markdown documentation. | `Read`, `Write`, `WebFetch` | Valid, isolated .md file with frontmatter and the documented section structure. |
| `task-researcher` | Use this when a task requires evidence-backed investigation against primary sources. | `WebFetch`, `Read`, `Grep` | Structured Markdown research brief with cited sources, gaps, and synthesis. |

These are illustrative outlines. The full blueprint files are authored in Track 19.2.

---

## 11. Deferred Decisions

The following items were intentionally excluded from the v1 schema. They are not oversights — they are explicit trade-offs acknowledged here so contributors know what is TBD and what is stable.

1. **Partials/include mechanism.** No DRY mechanism exists in v1. If duplication across similar blueprints becomes painful in practice (likely after the blueprint count exceeds ~10 with shared system-prompt scaffolds), a future sprint can introduce a `partials:` include syntax. The resolver would expand partials before passing the body to the runtime. This requires a parser-layer addition not in scope for S19.

2. **Runtime enforcement of `expected_output:`.** In v1, `expected_output:` is advisory prose. The spawned agent reads it and attempts to comply; the spawning agent is responsible for post-execution verification. A future sprint may add JSON Schema or Pydantic-style validation for structured output contracts, giving the runtime a pre-condition to enforce rather than a description to honor. This is deferred until use cases demonstrate the need and the Claude Code runtime provides a documented hook for output schema enforcement.

3. **Impromptu-to-named promotion path.** Dynamic delegation (strategy (b) in §6) can produce ad-hoc delegations that succeed and should be captured as named blueprints. A future sprint may add a `/promote-blueprint` skill that reads an impromptu delegation message and scaffolds a blueprint file from it. S19 ships the named-blueprint path (strategy a) only; promotion automation is deferred to a post-S20 sprint once the runtime is exercised.

4. **Per-blueprint version field.** In v1, all blueprints share `schema_version` governance via the single integer field in their frontmatter, governed by AGENTIC.md §9.2. There is no per-file version field tracking individual blueprint content changes. If the catalogue grows large enough that per-file change tracking (e.g. `content_version: 3`) becomes valuable for incremental refresh, a future sprint can add it as a backward-compatible frontmatter addition under the §9.2 window.

5. **DoD enforcement / asset-path verification.** The `expected_output:` field declares what a blueprint produces, but S19 ships no mechanism to verify the artifact exists at the declared path after a spawn completes. This is an S20 runtime concern: the spawning agent reads `expected_output:` post-execution and asserts the named artifact or path exists. Asset-path conventions for non-Markdown outputs (e.g. image assets from a future `task-asset-generator` blueprint) are also deferred until the relevant MCP tooling exists.

---

*Specification authored: 2026-06-20 (S19 T19.1). Governed by AGENTIC.md §9.2 compatibility window. Schema version 1.*
