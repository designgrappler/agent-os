# Team

> This file is the team definition template for an Agent OS project. Replace all placeholder content with your project's specifics.

<!-- List every person or agent role that participates in this project. The table below defines who owns what. Agents in `.claude/agents/` should map 1-to-1 to rows here. -->

## Roles

| Role | Name | Scope |
|---|---|---|
| **Owner** | `<Owner Name>` | Vision, final approval, and priority calls |
| **Lead Architect** | `<Lead Architect>` | Plans, Handoff Bridges, Red Flag Analysis — zero code |
| **Specialist** | `<Specialist>` | Implementation within declared track scope |
| **QA** | `<QA Agent>` | Read-only quality gate — no code writes |

<!-- Add or remove rows as your team grows. A "role" can be a human or an agent persona defined in `.claude/agents/`. -->

*e.g. The Owner is Ada Lovelace — she sets product direction and gives final approval on all releases.*

*e.g. The Lead Architect is responsible for writing sprint plan docs, issuing Handoff Bridges, and running Red Flag Analysis before any track begins.*

---

## Execution Chain

<!-- Describe how work flows between roles. The default Agent OS chain is: Owner → Lead Architect → Specialist(s) → QA → Owner. Adjust if your team operates differently. -->

`<Owner Name>` → `<Lead Architect>` → `<Specialist>` → `<QA Agent>`

*e.g. No Specialist begins implementation without a Handoff Bridge from the Lead Architect. The QA Agent issues a binary APPROVED or BLOCKED verdict before any branch merges.*

---

## Specialist Selection

<!-- If you have more than one Specialist, list which scenarios each one owns. This table lets the Lead Architect route tracks without ambiguity. -->

| Scenario | Specialist |
|---|---|
| `<Domain or file surface — e.g. frontend components>` | `<Specialist Name>` |
| `<Domain or file surface — e.g. database migrations>` | `<Specialist Name>` |

*e.g. All edits to `src/components/` and `styles/` go to the Frontend Specialist. All edits to `db/` and `prisma/` go to the Database Specialist.*
