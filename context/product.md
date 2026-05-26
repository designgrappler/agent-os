# Product

> This file is the product context template for an Agent OS project. Replace all placeholder content with your project's specifics. The Lead Architect reads this file before planning any sprint — it must be non-empty or planning stops.

<!-- Describe what this product is, who it serves, and what success looks like. A 2–3 sentence vision plus concise answers to each section below is enough to unblock planning. The `/onboard-existing-project` skill can synthesize this file from an existing README or vision doc if you have one. -->

---

## Vision

<!-- A 2–3 sentence description of what this product is and what problem it solves. Focus on the outcome for the user, not the implementation. -->

`<2–3 sentence vision statement>`

*e.g. "This product is a project management tool for small engineering teams that want structured sprint workflows without heavyweight tooling. It gives teams a lightweight, AI-assisted way to plan, track, and close sprints entirely from the command line."*

---

## Users

<!-- Who are the primary users? One sentence per persona is enough. If there are secondary personas, list them after the primary. -->

`<Primary user persona>`

*e.g. Primary: Solo developers and small teams (2–5 engineers) who already use an AI coding assistant and want to formalize their sprint process.*

*e.g. Secondary: Engineering leads at mid-size companies who want to give their team a structured agent workflow without adopting a full project-management platform.*

---

## Goals

<!-- What are the 2–4 concrete outcomes this product is working toward right now? Frame as outcomes, not features. -->

<!-- Keep this list short and honest — it guides the Lead Architect's Red Flag Analysis. If a proposed track doesn't serve any goal here, that's a signal to pause and ask why. -->

1. `<Goal 1>`
2. `<Goal 2>`
3. `<Goal 3>`

*e.g. 1. Reduce the time it takes a new user to run their first sprint from hours to under 20 minutes.*
*e.g. 2. Make drift between installed skills and canonical versions visible and one-command-fixable.*

---

## Non-Goals

<!-- What is explicitly out of scope? Stating non-goals prevents scope creep and gives the QA agent a clear boundary for blocking undeclared changes. -->

*e.g. This product does not aim to replace a full project-management platform (Jira, Linear, etc.) — it complements them.*

*e.g. Multi-tenant SaaS hosting is not a goal for this phase; the product runs locally or in a single-team environment.*

---

## Success Metrics

<!-- How will you know the goals above have been achieved? List 2–4 measurable signals. Qualitative signals (e.g. "users can complete the setup flow without asking for help") are fine alongside quantitative ones. -->

*e.g. A new user can complete `/install-agent-scaffold` and open their first sprint in under 20 minutes with no external help.*

*e.g. `/check-agent-os` returns `OVERALL: PASS` on a fresh install with no manual fixup required.*
