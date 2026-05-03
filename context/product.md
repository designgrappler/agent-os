# Product Strategy: Agent OS (v1.0)

## Vision
To transform AI interaction from "unreliable chat" into a structured **Agent Operating System** — enabling any team, dev or non-dev, to manage high-fidelity outcomes through **Structural Enforcement** and **Mechanical Role Integrity**.

## The Evolution: From Narrative to Mechanical to Universal
Conductor OS has moved through three strategic phases:

- **v2.0 (Instructional Age)**: Relied on prompt-based role instructions. Failed due to "Helpful Drift" — models override persona constraints when context grows.
- **v2.1 (Mechanical Age)**: Structural enforcement via Gemini CLI Policy Engine. Tools physically stripped from manifests. Role integrity moved from the brain (unreliable) to the toolbelt (reliable).
- **v1.0 (Universal Age)**: Platform portability and non-dev role support. The same mechanical discipline now applies to any knowledge work team on any supported platform.

## Targeted Problems

1. **Agent Drift** — Prevented by **Mechanical Tool-Masking**. The environment strips unauthorized tools from the agent's manifest at the runtime level.
2. **Context Rot** — Reduced by **Atomic Context Heartbeats** and active context management (`minify-context`, `context-cleaner`). Fresh, scoped context per task.
3. **Instructional Fragility** — Replaced by **Structural Policy Gates** that intercept and block unauthorized tool calls — on Gemini via `policy.toml`, on Claude Code via `tools:` frontmatter.
4. **Setup Friction** — Eliminated by the **Pre-Flight Interview** pattern in `conductor-bundle` and `agent-orchestration-setup`. All questions gathered first; no mid-setup interruptions.
5. **Scope Creep** — Controlled by **Execution Deliverables** locking in `generic-specialist` and the **Quality Gate** scope check. Any undeclared change triggers an automatic BLOCKED verdict.

## Key Product Pillars

- **Predictability over Autonomy**: We prioritize "System Impossibility" over "Model Compliance." If a role is forbidden from writing code, it physically cannot access the write tool.
- **Structural Integrity**: Role isolation enforced at the system level — not through instructions alone.
- **Universal Role Support**: The architecture applies to any knowledge worker role. Dev teams scope to source files; creative and business teams scope to documents, briefs, and designs. Same protocols, same quality gate, same three tiers.
- **Dual-Platform**: Full implementations for both Gemini CLI (`skills/`) and Claude Code (`claude/`). Platform-agnostic concepts documented in `ARCHITECTURE.md`.
- **Sprint Lifecycle**: First-class skills for the full sprint loop — open, execute, review, close, status check — not just the execution phase.

## The Operational Tiers

| Tier | Role | Examples |
|---|---|---|
| **Tier 1 (Meta)** | Orchestration — establishes DNA, blocked from deliverable production | Conductor, Architect |
| **Tier 2 (Strategic)** | Planning — generates Handoff Bridges, manages sprint lifecycle | Architect, Sprint Manager |
| **Tier 3 (Tactical)** | Execution — scoped to declared deliverables only | Frontend Dev, Backend Dev, Designer, PM, Marketing Manager, Content Strategist |
| **Tier 3 (Sentinel)** | Quality — read-only, binary verdict | Quality Gate |

## Target User Personas

**The High-Rigor Orchestrator (Dev Team)**: An engineering lead or solo developer who values process certainty. Uses Conductor OS to manage a fleet of specialist agents with the same rigor as a human engineering team.

**The Cross-Functional Lead (Mixed Team)**: A product manager, founder, or team lead running a mixed team of dev and non-dev roles. Uses Conductor OS to ensure every contributor — engineer, designer, marketer — operates within a declared scope and produces verifiable deliverables.

**The Content/Creative Director (Non-Dev Team)**: A creative lead managing copy, design, and strategy agents. Uses Conductor OS to bring the same structural discipline of software development to knowledge work — briefs, campaigns, and design systems.
