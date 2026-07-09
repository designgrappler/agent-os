---
title: Blueprint Schema Reference
source: claude/blueprints-schema.md
generated: 2026-07-09
---

# Blueprint Schema Reference

## Purpose

Agent OS task blueprints are self-contained Markdown files that encode a task-level execution template for spawning a subagent. The blueprint schema specification (`claude/blueprints-schema.md`) defines the canonical structure for these files: what frontmatter fields are required, what the three required body sections mean, how the catalogue is maintained, and what invariants are machine-checkable by the `check-agent-os` health check.

A blueprint maps directly to Claude Code subagent frontmatter and body. The four columns from the blueprint table — Blueprint Profile, System Prompt Strategy, Allowed Tool Bindings, and Expected Output Contract — correspond one-to-one to the `name:`, body content, `tools:`, and `expected_output:` fields. Agent OS adds two schema-specific fields on top of the Claude Code base: `expected_output:` (modeled after CrewAI's prose-description pattern) and `schema_version:` (an integer governing the AGENTIC.md §9.2 compatibility window). The schema is at version 1 for all blueprints conforming to the S19 specification.

## Schema Fields

The blueprint schema defines six frontmatter fields, three of which are required for every blueprint and three of which carry conditional or optional status.

**`name:` (required).** A lowercase string with hyphens for word separation. Must carry the `task-` prefix — this prefix disambiguates blueprints from role agents in `claude/agents/` and makes the system-layer boundary unambiguous. The `name:` value must match the blueprint's filename minus `.md`. Examples: `task-coder`, `task-writer`, `task-researcher`.

**`description:` (required).** A one-line string that serves as the "when to use this" hint for catalogue rendering and agent selection at spawn time. A Role Agent reads `description:` values when choosing which blueprint to spawn. Example: `Use this when a task requires authoring or revising structured Markdown documentation.`

**`tools:` (required).** A YAML array of Claude Code tool names verbatim — the runtime enforces this allowlist, so only the tools listed here are available to the spawned agent. Permitted values include `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Agent`, and MCP server patterns (`mcp__<server>` or `mcp__<server>__*`). Conceptual descriptions of why each tool is in scope belong in the `## Allowed Tool Bindings — Reasoning` body section, not in this array.

**`expected_output:` (required).** A one-line string that is the frontmatter shorthand for what "done" looks like. This field is read by Agent OS tooling for catalogue rendering and QA gates, but is not interpreted by the Claude Code runtime — compliance is a prose contract the spawned agent reads and honors. A machine-checkable sync rule applies: the frontmatter `expected_output:` value must equal the first sentence of the body's `## Expected Output Contract` section verbatim. Phase 7 of `check-agent-os` enforces this invariant.

**`model:` (optional).** A short model tier name: `sonnet`, `opus`, or `haiku`. Defaults per Sprint 5 T3 conventions when absent. Full versioned model names (e.g. `claude-sonnet-4`) are not permitted — only the short tier name.

**`schema_version:` (required).** An integer that must be `1` for all blueprints conforming to the current specification. Future schema changes increment this value. During any schema transition, AGENTIC.md §9.2's two-sprint compatibility window applies: both old and new schema versions must parse cleanly for a minimum of two sprints, missing fields default to documented values, and old schema files produce a warning nudge rather than a hard break after the window closes.

## Constraints

Blueprint authoring is governed by five machine-checkable invariants and several structural constraints that together form the schema's quality gate.

**Naming constraints.** Every `name:` value must carry the `task-` prefix. The filename must be `<name>.md` where `<name>` is the full frontmatter `name:` value. No blueprint may use a bare name without the prefix, regardless of uniqueness in the catalogue.

**Required field completeness.** Every blueprint must declare `name`, `description`, `tools`, `expected_output`, and `schema_version` in its frontmatter. A blueprint missing any of these fields is reported as invalid by the `check-agent-os` health check and cannot pass the QA gate.

**Body section structure.** Every blueprint body must contain exactly three required H2 sections in this order: `## System Prompt Strategy`, `## Expected Output Contract`, and `## Allowed Tool Bindings — Reasoning`. A framing paragraph must appear above these sections, immediately after the H1 title, with no H2 heading. Sections may not be reordered or renamed.

**Expected output sync rule.** The `expected_output:` frontmatter value must equal the first sentence of the `## Expected Output Contract` body section verbatim. This is a machine-checkable invariant enforced by Phase 7 of `check-agent-os`. Divergence between the two surfaces is an invalid state.

**No placeholder text.** No placeholder text (`[PLACEHOLDER]`, `[TBD]`) may remain in a shipped blueprint file. Every section must contain real content. The blueprint file format template in §8 of the schema specification is the canonical starting point for new blueprint authoring; authors copy the template and replace all placeholder values before shipping.

**Catalogue rule.** There is no `catalogue.json` index file. The catalogue is the `claude/blueprints/` directory itself — `ls claude/blueprints/` plus the frontmatter of each file is authoritative at all times. Any rendered table view is generated from the directory contents, never authored separately. This eliminates the entire class of consistency bug where an index file drifts from the actual directory.

**No DRY mechanism in v1.** The schema accepts self-containment as a design goal rather than reuse. If two blueprints share a similar system-prompt scaffold, both blueprints contain that scaffold independently. A partials or include mechanism is a deferred decision, explicitly excluded from the v1 schema until duplication cost is demonstrated at scale.
