# Conductor Orchestration: System Architecture
*Framework-agnostic reference for multi-agent system design.*

---

## The Core Problem This Solves

Multi-agent AI systems fail in predictable ways:

- **Context saturation** — The agent forgets constraints as the conversation grows. Early instructions lose weight.
- **Role drift** — An agent abandons its role under persistent pressure, or when crossing a boundary feels helpful in the moment.
- **Hallucination propagation** — One agent's false narrative summary becomes another agent's false premise.
- **Blast radius creep** — A change scoped to one component silently touches another.

Each failure has a specific architectural layer that addresses it. The layers are ordered by reliability: the outer layers handle normal workflow. The inner layers catch failures when the outer layers break.

---

## The Five Layers

```
┌─────────────────────────────────────────────────────┐
│  5. Persistence          Cross-session continuity    │
│  4. Automation           Reusable triggered ops      │
│  3. Physical Barriers    Infrastructure enforcement  │
│  2. Behavioral Rules     Workflow discipline         │
│  1. Roles                Cognitive specialization    │
└─────────────────────────────────────────────────────┘
        Outer ──────────────────────────── Inner
     (can fail)                      (cannot fail)
```

---

### Layer 1: Roles (Cognitive Specialization)

Each agent has a defined identity, responsibility, and tool scope. The body of the agent definition is its system prompt — its identity, responsibilities, and hard constraints.

The key principle is **cognitive specialization through narrow context.** The Architect only thinks about planning. Specialists only think about execution within their domain. The Critic only thinks about whether something passes. Each agent is more precise at its job *because* it carries no context about other jobs. An agent that can also execute will always be tempted to skip planning and just code. Role separation creates the friction that forces quality at each transition.

**Core roles:**
- **Conductor** (human) — Vision, approval, final say
- **Orchestrator** (AI) — Coordinates specialists; never executes directly
- **Architect** (AI) — Plans, analyzes risk, produces Handoff Bridges; zero-code
- **Specialists** (AI) — Execute within a declared scope; one domain each
- **Critic** (AI) — Audits results; read-only; issues binary verdicts

---

### Layer 2: Behavioral Rules (Workflow Discipline)

Behavioral rules are instructions — what agents are told to do and not do. They operate at three levels:

**Orchestrator-level (`CLAUDE.md` / project config):** Instructions for the coordinating agent. Defines the execution chain, escalation protocols, and the "no execution without a Handoff Bridge" gate.

**Agent-level (system prompts):** Each agent's definition contains role-specific constraints. The Architect reads context files before every response. The Critic issues PASS or BLOCKED, nothing else.

**Project-level (`AGENTIC.md`):** The Static DNA that every agent is instructed to read at initialization — tech stack, Definition of Done, team roles, commit convention. Because it's read first, it overwrites the model's general training defaults with project-specific constraints. This is called the **DNA Jolt**: LLMs weight recent tokens most heavily, so loading Static DNA first grounds the agent before any task context is introduced.

**Important distinction:** Keep orchestrator-level instructions separate from project-level DNA. Mixing them causes orchestrator protocols to pollute specialist context, and vice versa.

**The limitation:** Behavioral rules *can* be worn down. A sufficiently persistent prompt, a long context window that dilutes early instructions, or a model with a strong agreeableness bias can cause an agent to bend a behavioral rule. This is why Layer 3 exists.

---

### Layer 3: Physical Barriers (Infrastructure-Level Enforcement)

Physical barriers are constraints enforced at the infrastructure level — not in the prompt, but in the runtime. They cannot be argued past, reasoned around, or forgotten.

**Tool scope locking:** Each agent should only have access to the tools required for its role. A Critic needs read and shell access — not write. Even if explicitly instructed to "just fix this one line," a Critic with no write tool cannot comply. This is the difference between "don't touch the code" (behavioral) and "you have no write tool" (physical). Remove the behavioral rule and the agent might comply anyway. Remove the tool and compliance is irrelevant.

**Workspace isolation:** When multiple tracks are active simultaneously, isolate each in a separate workspace (git worktree, separate working directory, etc.). Cross-track contamination becomes physically impossible, not just prohibited.

**Automated gates:** Pre-push or pre-merge checks (build validation, type checking) run as shell commands triggered by the runtime — not as agent judgment. They pass or block; there is no negotiation.

**The key principle:** Physical barriers define the blast radius. If every behavioral layer fails simultaneously, the physical barriers bound the damage.

**Approval discipline:** Physical barriers are only as strong as the attention paid to them. In high-volume agent workflows, a condition called **approval exhaustion** emerges: when approvals are frequent and routine, users begin approving without reading. At that point the safety guarantee collapses — the approval becomes a reflex, not a checkpoint.

The solution is not fewer approvals overall, but a clear distinction between approvals that require attention and approvals that waste it:

| Approval type | Examples | Policy |
|---|---|---|
| **Must prompt** | `git push`, schema migrations, destructive deletes, any irreversible action | Always require explicit approval — these are the checkpoints that matter |
| **Should auto-approve** | File reads, `git status`, `git diff`, type-check runs, build commands | Pre-approve in settings — routine reads and checks create exhaustion without adding safety |

Pre-approve the noise so that when a real approval appears, it gets real attention. On Claude Code, this is configured in `.claude/settings.local.json` under `permissions.allow`. On Gemini CLI, it is handled by `policy.toml` capability bundles.

---

### Layer 4: Automation (Reusable Triggered Operations)

Skills or macros that automate recurring workflow operations. These aren't agent behaviors or constraints — they're **repeatable procedures** that execute at the right moment in the workflow.

Examples: context archiving at sprint end, project scaffolding for new setups, visual audit triggers, security scans. When the team learns that a certain operation needs to happen at a certain moment, that knowledge gets codified into automation so it doesn't have to be remembered or re-explained each time.

---

### Layer 5: Persistence (Cross-Session Continuity)

Facts that need to survive session resets. Unlike in-session context (which resets) and file state (which you have to explicitly read), persistent memory is available in future sessions without re-discovery.

What's worth persisting: surprising findings, validated preferences, non-obvious project decisions, feedback about what failed and why. What's not: things derivable from reading the code, git history, or current documentation.

---

## How a Task Flows Through the System

```
Conductor (approval)
  → Architect reads Static DNA + Dynamic DNA context    [Behavioral: DNA Jolt]
  → Architect produces Handoff Bridge                   [Behavioral: context compression]
  → Specialist opens isolated workspace for the track   [Physical: isolation]
  → Specialist verifies upstream interface              [Behavioral: Technical Handshake]
  → Specialist implements, scope-locked to declared files [Behavioral + Physical: tool scope]
  → Critic reads diff — cannot write, issues PASS/BLOCKED [Physical: tool lock + binary gate]
  → Automated gate validates build before merge         [Physical: pre-merge check]
  → Conductor approves merge                            [Human: final checkpoint]
```

---

## Two Key Protocols

### The Handoff Bridge (Architect → Specialist)

The Handoff Bridge is the transition mechanism between the planning layer and the execution layer. Rather than asking the Specialist to re-read the full plan and make assumptions, the Architect compresses the relevant state into a structured template:

```markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Static DNA Check:** [Confirmed alignment with AGENTIC.md]
**Dynamic DNA State:**
- Product Context: [1-sentence requirement]
- Current Plan: [step in plan.md]
- Execution Files: [files to modify]
**Verification:** [command or URL]
**Next Step:** [specific task for the Specialist]
```

The bridge does two things: it gives the Specialist exactly what it needs (no more, no less), and it forces the Architect to think through execution requirements before handing off. If you can't write the bridge clearly, the plan isn't ready.

### The Technical Handshake (Specialist → Specialist)

Before accepting work from an upstream specialist, the downstream specialist verifies the interface. This is horizontal peer verification — distinct from the Handoff Bridge (which is vertical, Architect → Specialist):

- **Backend → Database:** "Does this schema support my query logic?"
- **Frontend → Backend:** "Does this API contract match my UI requirements?"

This prevents building against an unverified assumption. A UI built against a hypothetical API that hasn't been finalized yet will produce a working component and a broken integration. The Technical Handshake catches this before implementation begins.

---

## The Dependency Chain

Execution order follows the dependency graph: **Database → Backend → Frontend** (or whatever the equivalent layers are in your stack).

This isn't about hierarchy — it's about what can exist without what. The schema must exist before queries can be written. The API must exist before the UI can consume it. Violating the order doesn't produce a behavioral failure; it produces a *technical* failure later, when the downstream specialist's assumption doesn't match the upstream reality.

---

## The DNA Taxonomy

**Static DNA** lives in a root-level file (typically `AGENTIC.md`). It contains foundational constraints: tech stack, team roles, hard protocols. It changes rarely and is read once per session.

**Dynamic DNA** lives in a context directory (typically `docs/context/`). It contains high-churn task state: active plan, current tracks, product requirements. It changes per-sprint and is refreshed per task.

**Why the split matters:**
1. **Token efficiency** — Dynamic DNA is only loaded when needed; Static DNA is read once at initialization
2. **Drift prevention** — Mixing foundational rules with task details causes agents to weight them equally over time. Static rules need higher "gravity" — placing them at the repo root achieves this because agents prioritize recently-ingested tokens
3. **Archive discipline** — Completed Dynamic DNA can be archived without touching Static DNA, keeping active context lean

---

## System Reliability Model

| Risk | Layer That Catches It |
|---|---|
| Broken build ships | Automated pre-merge gate |
| Critic writes code | Tool scope lock |
| Cross-track contamination | Workspace isolation |
| Agent drifts out of role | Behavioral rules + narrow tool set |
| Context bloat causes hallucination | Dynamic DNA archiving |
| Instructions forgotten cross-session | Persistence layer |
| Wrong interface assumed | Technical Handshake |
| Bad plan handed to specialist | Handoff Bridge |

---

## Graceful Degradation

In order of importance, if components are missing:

1. **Without physical barriers** — The system still works but requires more discipline. Human review at each transition becomes mandatory. This is the "Gemini mode" for highly agreeable models — behavioral rules and manual checkpoints compensate for missing tool locks.
2. **Without workspace isolation** — Single-track development is fine on the main branch directly. Parallel tracks become risky.
3. **Without automated gates** — Build validation must be manual before every merge.
4. **Without automation/skills** — Recurring operations must be performed manually.
5. **Without persistence** — Knowledge resets each session; teams re-discover things they've already learned.

**Minimum viable setup:** One root Static DNA file + a context directory + at least one Architect (zero-code) + one Specialist + one Critic (read-only) + a pre-merge build gate.

---

## Platform Implementations

This architecture is implemented in two ways in this repository:

| Path | Platform | Physical Barriers | Automation |
|---|---|---|---|
| `skills/` | **Gemini CLI** | `policy.toml` tool masking via CLI Policy Engine | Gemini skill invocation |
| `claude/` | **Claude Code** | `tools:` frontmatter + pre-push hooks | Claude Code skills + agent definitions |

The concepts are identical. The enforcement mechanisms differ by platform.

For model-specific behavioral profiles (Gemini agreeableness, GPT-4 scope drift, open-source constraint fidelity), see [`claude/README.md`](claude/README.md).

---

*"The goal is not to have the smartest agent, but the most disciplined system."*
