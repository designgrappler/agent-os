# Project Evolution: The Journey to Agent OS v1.0

This document tracks the strategic shifts, technical breakthroughs, and philosophical pivots that have defined the evolution of the Conductor OS framework.

## Phase 1: The Instructional Age (Conductor OS 2.0)
**Strategy**: Middleware Isolation via Prompt Engineering.
**Concept**: We relied on "Double-Lock" instructions. We told the agent it was an Architect and forbid it from touching code. 
**The Failure Mode**: **"Helpful Drift."** In long sessions, the model's inherent drive to be "useful" would eventually override its persona instructions. Architects would start writing CSS or refactoring JS simply because the context window suggested it was the next logical move.

## Phase 2: The Structural Audit (The Paperclip Pivot)
**Trigger**: A deep-dive audit into **Paperclip AI's** orchestration model.
**Discovery**: Paperclip achieves 100% role integrity not through better prompting, but through **State Externalization**. Identity and permissions are stored in a database and enforced at the API/Adapter layer.
**Aha! Moment**: We realized that for an agent to be truly reliable, it must be **structurally unable** to drift, not just "instructed not to."

## Phase 3: The Mechanical Age (Conductor OS 2.1)
**Strategy**: Structural Enforcement via the Gemini CLI Policy Engine.
**Technical Breakthroughs**:
1. **Policy-Based Sandboxing**: Using the Gemini CLI `policy.toml` to mechanically strip `fs_write` from Architect-tier personas. This moves the "Zero-Code Policy" from the brain (unreliable) to the toolbelt (reliable).
2. **Atomic Context Heartbeats**: Implementing "Shadow Handoffs." Instead of one long conversation, we launch fresh specialist processes for every tactical task. This ensures the model starts with a "Zero-Context" signal, focused exclusively on its assignment.
3. **Global State Ledger**: Moving the project's "Source of Truth" from a narrative markdown file to a structured global JSON registry.

## Summary of the Pivot
We have moved from a **Narrative System** (where we ask the AI to play a role) to a **Mechanical System** (where the environment prevents the AI from breaking character). This transition represents the professionalization of the "Team" metaphor into a production-ready Agent Operating System.

## Phase 4: The Universal Age (Agent OS v1.0)
**Strategy**: Platform portability, non-dev role support, and production-hardened protocols.

**Context**: Phase 3 established mechanical enforcement for Gemini CLI. Phase 4 emerged from running the system in a real production environment (Settle App) over an extended sprint cycle and identifying what was missing at scale.

**Technical Breakthroughs**:

1. **Dual-Platform Architecture**: Added a full Claude Code implementation path (`claude/`). The core architecture is now platform-agnostic — identical concepts, different enforcement mechanisms. Gemini CLI uses `policy.toml`; Claude Code uses `tools:` frontmatter. Both achieve the same structural guarantees.

2. **Non-Dev Role Support**: Generalized "Execution Files" to "Execution Deliverables" throughout the skill library. Product managers, designers, marketing managers, and content strategists can now be first-class Implementation Team members. The same three-tier structure, Quality Gate, and Handoff Bridge apply to any knowledge work — not just software.

3. **Production Best Practices Port**: The following patterns were identified from production use and formalized into the skill library:
   - **Technical Handshake** — specialist-to-specialist upstream verification before any implementation begins
   - **Scope Lock** — specialists authorized only for declared deliverables; undeclared changes = automatic Quality Gate block
   - **Circuit Breaker** — 3 consecutive same-cause failures trigger Architect escalation; different error types reset the counter
   - **Sentinel Proof** — never trust a verbal summary; verify with file reads or diff inspection
   - **Binary Quality Gate** — PASS or BLOCKED only; "approved with notes" is not a valid verdict

4. **Quality Gate Skill**: Added `quality-gate` — a dedicated Sentinel-tier skill equivalent to the "Bandit" role in Claude Code projects. Fills the gap that previously had only `security-audit` at the Sentinel tier.

5. **Sprint Lifecycle Skills**: Added `sprint-open` (sprint launcher with pre-flight check and auto-trigger), `track-status` (situational status report with auto-trigger), and `minify-context` (compresses verbose active context files without archiving).

6. **Wizard Fix**: Identified and resolved the conductor-bundle interview fragmentation issue — questions were split across three skills, causing models to lose the thread mid-setup. Consolidated all questions into a single pre-flight interview block in `conductor-bundle` before any file creation begins.

**The Philosophical Expansion**: Phase 3 asked "how do we prevent drift in a dev team?" Phase 4 asks "how do we run *any* knowledge work team with the same mechanical discipline?" The answer: the same architecture applies. Deliverables replace files. Acceptance criteria replace build commands. The roles and protocols are universal.

