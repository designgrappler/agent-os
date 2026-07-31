# Agent OS: Core Concepts

Five concepts. Once you understand these, the system's behavior makes sense and you can put it to work immediately.

---

## Orchestrator

The orchestrator is not a separate program — it is the primary model you are already talking to. Claude, Gemini, or whichever LLM you have configured: that model, given a defined role, a set of constraints, and the ability to coordinate work.

When you describe a task, the orchestrator reads the context files for your project, determines what kind of work is needed, and routes it to the right specialist with the relevant background already attached. You do not configure this routing manually.

This matters because the same model that answers questions in a generic chat becomes a structured coordinator when given a defined role. The orchestrator knows what it is for, what to delegate, and when to bring a decision back to you.

**What it is not:** A general-purpose assistant you prompt directly for answers. The orchestrator routes and coordinates — it does not execute the work itself.

---

## Specialists

Specialists are domain experts — each with a defined role, specific constraints, and access to the tools their domain actually requires.

What distinguishes specialists is not just knowledge: it is tool access. A researcher can run web searches and pull documents. A frontend specialist reads and edits code files. A designer generates and modifies Figma designs. An ops specialist queries deployment logs and infrastructure APIs. Each specialist is equipped with the tools their work needs — MCP servers, code execution, search, design tooling, external APIs — not a generic set of everything.

When the orchestrator hands a task to a specialist, that specialist brings domain judgment and follows its own principles about scope. Specialists do not drift into each other's domains.

**Examples of specialists and their tools:**

| Specialist | Domain | Tools they use |
|---|---|---|
| **Researcher** | Synthesis and analysis | Web search, document fetch |
| **Designer** | Visual and UX work | Figma MCP, design export |
| **Frontend** | UI and interaction logic | File read/write, build tools |
| **Backend** | APIs and server-side logic | File read/write, shell execution |
| **Ops** | Deployment and infrastructure | Shell, logs, infrastructure APIs |
| **Strategist** | Product and market thinking | Web search, document synthesis |
| **Critic** | Adversarial review | Read-only — no execution |
| **QA** | Quality gate | Read-only — no modifications |

**Example (non-dev):** You ask for a competitive analysis of three marketing tools. A researcher specialist runs web searches, pulls the relevant pages, and synthesizes findings into a brief. A strategist specialist reads that synthesis and frames the strategic opportunity. Each works within their domain and does not touch the other's output.

**Example (dev):** A frontend specialist implements a new settings page. A backend specialist writes the API route it needs. Each is scoped to their layer — neither touches the other's files.

**What they are not:** Interchangeable. Each specialist is scoped to its domain. The orchestrator routes requests to the right one — you do not have to choose.

---

## QA Gate

The QA gate is an iteration loop, not a one-shot approval step. Work runs through it until it matches the plan — and only then does it reach you.

A dedicated QA specialist reviews completed work. QA is read-only: it cannot modify what it reviews. It reads the output against the original plan and issues one of two verdicts:

- **Approved** — the work matches the plan; it moves forward
- **Blocked** — the work does not match the plan; a specific reason is given and it returns to the specialist

When work is blocked, QA states the exact reason. The specialist receives that feedback, addresses it, and resubmits. QA re-reviews. The loop continues until the work is approved. It does not reach you until it has passed.

The loop matters because agents can miss things. QA provides a second pass with defined criteria, run by an agent that has no stake in the output and cannot accidentally change what it is evaluating. QA is not checking whether something is good — it is checking whether it matches what was agreed.

**Example:** A researcher submits a competitive analysis. QA reads it against the brief: Did it cover the specified competitors? Does it answer the framing question from the plan? One section is thin. QA blocks with a specific note. The researcher expands that section and resubmits. QA approves. The work reaches you.

**What it is not:** A final polish step or a rubber stamp. Incomplete or misaligned work does not pass through because an agent got close. The loop catches it.

---

## Context Files

Context files are the persistent memory of your project — instructions, constraints, active work state, and project identity that every agent reads before acting.

This is richer than "notes." A context file is the ground truth the entire system operates from. When it says the product targets enterprise buyers, every specialist works from that fact. When it says the current goal is onboarding, that focus applies everywhere. When it records that a research track is complete and a design track is in progress, no agent asks you to re-explain where things stand.

Context is actively managed to avoid bloat. Files stay focused on what is current and relevant — stale content is removed, not accumulated.

**Two types of context file:**

- **`product.md`** — persistent project memory: what the product is, who it is for, the problem it solves, and the constraints that apply. Used for ongoing work across multiple sessions.
- **`task.md`** — one-off task context: the specific deliverable, the scope, and the criteria for done. Used when the work is discrete and does not belong to an ongoing product.

Use `product.md` when you are working on something that spans multiple sessions — a product, a codebase, a campaign. Use `task.md` when you have a one-off deliverable and do not need persistent memory after it is done.

**Example:** You open a new session and ask for help revising onboarding copy. The orchestrator reads `product.md` — it knows the product, the users, and the voice. It reads `plan.md` — it knows the onboarding redesign is in progress. No re-briefing required.

**What they are not:** Conversation history. Context files are plain Markdown files that persist across sessions, readable by every agent. They are not a transcript — they are the stable, updatable ground truth for the project.

---

## Connectors

Connectors are the external tools and services your skills can access — web search, APIs, MCP servers, and other integrations — registered once and available across all your projects.

Skills declare what tools they need via a `requires:` field. When you invoke a skill, the orchestrator checks your connector registry (`~/.claude/connectors.md`) to see if the required tool is available. If it is, the skill runs without interruption. If it is not, you are prompted once: provide the connection details, the orchestrator writes the config to your registry, and the task continues. You never configure this manually mid-task again.

Agents can also use connected tools opportunistically — if a connected tool is relevant to the work, an agent can use it without a hard `requires:` declaration.

**Example:** A research skill declares `requires: brave-search`. The first time you invoke that skill, the orchestrator checks your registry. Brave Search is not there. The orchestrator asks for the server details, writes the config, and continues with the task. Every subsequent skill that needs web search finds it already registered.

**What it is not:** Per-project configuration. Connectors are registered globally. A tool you connect in one project is available in all of them.

---

## One integrated system

These five concepts are not independent features — they form one loop. The orchestrator directs. Specialists execute using the tools their domain requires. QA enforces the plan before anything reaches you. Context files give every agent the same understanding of the project. Connectors supply external capabilities where they are needed, without mid-task setup.

Here is what that loop looks like — once for a content project, once for a development project.

**Content: redesigning a product onboarding email sequence**

`product.md` describes a SaaS product for small business owners. `plan.md` states the goal: a new onboarding email sequence for users who signed up but never activated. A researcher specialist runs web searches on onboarding patterns, pulls competitor examples, and synthesizes a brief. QA reviews it against the plan — blocks once because a user segment specified in the plan is missing. The researcher addresses it and resubmits. QA approves. A marketing specialist reads the approved brief and writes three email variants. QA reviews those against the brief. Approved. Two email variants and the brief reach you, already verified.

**Development: adding a new API endpoint and a dashboard component**

`task.md` defines the work: add a `/status` endpoint and expose it in the dashboard header. A backend specialist implements the route, scoped to the server layer. A frontend specialist reads the endpoint spec and implements the header component, scoped to the UI layer. QA reviews both against the task definition and approves. Work reaches you.

In both cases: you described the goal once. Every agent read the same context. Specialists used the tools specific to their domain. QA ran a loop until the output matched the plan. Connectors supplied the search and API access specialists needed without mid-task configuration.

That is the system.
