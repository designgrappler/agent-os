# Concepts

Agent OS is built on four concepts. Once you understand these, the system's behavior makes sense and you can put it to work without knowing how it's built under the hood.

---

## Orchestrator

The orchestrator is the agent that receives your request and routes it to the right specialist.

When you describe a task, the orchestrator reads the context files for your project, determines which specialist is the right fit, and hands off with the relevant background already attached. You do not configure this routing manually.

**Example:** You ask for a competitive analysis of three tools in your market. The orchestrator determines a researcher is the right specialist, packages the request with your product context, and hands it off. The researcher begins without you having to explain the project from scratch.

**What it is not:** A general-purpose assistant you prompt directly for answers. The orchestrator routes and coordinates -- it does not execute the work itself.

---

## Specialists

Specialists are domain experts with defined roles and specific constraints. Each carries judgment about how to do work in their domain -- not just what to produce, but how to scope it and what to stay out of.

When the orchestrator hands a task to a specialist, that specialist brings domain knowledge and follows its own set of principles. Specialists do not drift into each other's domains.

**Canonical specialist roster:**

| Role | What they do |
|---|---|
| **Technical** | Complex technical tasks -- reads codebase state, surfaces a plan, and coordinates implementation |
| **Designer** | User experience and visual work -- produces design directions and handoff artifacts |
| **Researcher** | Evidence-backed synthesis -- competitive analysis, literature review, and user research |
| **Marketing** | Channel-specific copy and campaigns -- translates strategy into words |
| **Frontend** | UI components and interaction logic -- scoped to the presentation layer |
| **Backend** | API routes, business logic, and server-side services |
| **Database** | Schema changes, migrations, and query logic -- every change reversible by default |
| **Mobile** | Native device integration, push notifications, and platform-specific behavior |
| **Ops** | Deployment, infrastructure, and incident response |
| **PM** | Translates strategy into prioritized requirements -- defines what and when |
| **Strategist** | Upstream thinking partner -- market analysis, product strategy, and opportunity framing |
| **Critic** | Adversarial review -- stress-tests plans and surfaces failure modes before execution |
| **QA** | Read-only quality gate -- issues a binary verdict on completed work |

**Example:** A designer specialist produces three visual directions for a new onboarding flow. A researcher specialist reads competitor sites and synthesizes findings into a brief. Each works within their domain and does not touch the other's output.

**What they are not:** Interchangeable. Each specialist is scoped to its domain. Asking a designer for backend implementation or a researcher for final copy is outside their defined role -- the orchestrator routes those requests to the right specialist instead.

---

## QA Gate

The QA gate is the review step that verifies work matches what was agreed before it reaches you.

Every completed task passes through a dedicated QA specialist -- a read-only agent that cannot modify what it reviews. QA reads the completed work against the original plan and issues one of two verdicts: approved or blocked. Blocked work goes back for revision. Approved work comes to you.

This matters especially for non-engineering work, where "done" is not always obvious. QA is not checking code syntax -- it is checking whether the output matches the plan. Did the researcher address the right questions? Does the design match the stated brief? QA answers those questions before the work reaches you.

**Example:** Your researcher produces a competitive analysis. Your designer uses it to produce three onboarding directions. Before either piece of work reaches you, QA verifies the competitive analysis answers the brief and that the design directions are responsive to the research findings. Work that does not meet the criteria comes back for revision -- not to you to fix.

**What it is not:** A final polish step or a rubber stamp. QA blocks work that does not meet the criteria and sends it back. The system does not pass incomplete or misaligned work through because an agent got close.

---

## Context Files

Context files are shared notes that every agent reads at the start of each session.

There are three:

- **`product.md`** -- what the project is, who it is for, and what problem it solves
- **`plan.md`** -- what is currently in progress: the active sprint or current work
- **`tracks.md`** -- the status of each piece of work: done, in progress, or blocked

Every agent reads all three before doing anything. The result is that agents carry the same understanding of the project without you having to re-explain it each session.

**Example:** You close a session mid-way through a design sprint. Next session, you describe a new task. The orchestrator, researcher, designer, and QA each read the same three context files before acting -- they know what the project is, where work stands, and what has already been completed. No re-briefing required.

**What they are not:** Conversation history. Context files are plain Markdown files that persist across sessions and are identical for every agent. They are not a transcript of what was said -- they are the stable, updatable ground truth for the project.

---

## How these work together

Here is a complete flow for a non-engineering example: designing a new onboarding experience for a SaaS product.

**Setup:** Three context files exist. `product.md` describes the product and its target users. `plan.md` notes that the current goal is a redesigned onboarding flow. `tracks.md` shows a research track and a design track, both not yet started.

**Step 1 -- You describe the work.** You tell the orchestrator you want to redesign onboarding based on what competitors are doing well. The orchestrator reads the context files, identifies two pieces of work (competitive research first, then design), and routes the first task to the researcher.

**Step 2 -- Research.** The researcher reads `product.md` to understand the product context, then studies competitor onboarding flows and synthesizes findings. The output is a brief: what competitors do well, what patterns appear, and where opportunities exist.

**Step 3 -- QA reviews the research.** Before the brief reaches you or the designer, QA reads the research against the original ask. Did it cover the right competitors? Does it answer the questions the plan called for? If yes, QA approves. If not, QA sends it back with what is missing.

**Step 4 -- Design.** The designer reads the approved research brief and `product.md`, then produces three distinct onboarding direction concepts. Each is separate and fully formed.

**Step 5 -- QA reviews the design.** QA reads the three design directions against the research brief and the plan. Are the directions responsive to the research findings? Do they address the brief? QA approves or blocks accordingly.

**Step 6 -- Work reaches you.** You receive the approved research brief and the approved design directions. The work has already been verified to match what was planned. Your job is to make a decision -- not to check whether the work was done correctly.

Throughout this flow, every agent read the same context files. No agent had to ask you to re-explain the project. The QA gate ran twice and caught anything that did not match the plan before it reached you.
