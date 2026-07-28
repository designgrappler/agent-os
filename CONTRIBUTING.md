# Contributing to Agent OS

Thank you for your interest in contributing. Agent OS is a framework for reliable multi-agent AI orchestration, built for Claude Code and Gemini CLI. Contributions that improve the skill library, fix documentation, or extend platform support are welcome.

---

## How contributions work

This public repository (`designgrappler/agent-os`) is the distribution target. The maintainer reviews contributions here and integrates accepted changes into the source. The CI system then syncs the source back to this repo.

**The flow:**
1. Fork this repository
2. Make your changes on a branch in your fork
3. Open a pull request against `main`
4. The maintainer reviews, and if accepted, integrates the change into the source

---

## What to contribute

### New skills
The most valuable contributions are new skills — reusable procedures for agent workflows. A skill is a folder with a `SKILL.md` file.

**Gemini CLI skill** (`skills/your-skill-name/SKILL.md`):
```
---
name: your-skill-name
description: One sentence — what does this skill do and when does it activate?
Abbreviation: Ys
Category: [Orchestration | Bundles | Execution | Quality]
Type: [Tier 1 | Tier 2 | Tier 3]
Capabilities: [fs_read, fs_write]
---

# Skill: Your Skill Name

## Description
...

## Trigger
Tell the orchestrator: "..."
```

**Claude Code skill** (`claude/skills/your-skill-name.md`):
```markdown
# Your Skill Name
One-sentence description.

## Trigger
When the user runs `/your-skill-name`, execute the following...

## Step 1: ...
```

### Documentation improvements
Corrections, clarifications, and additions to `ARCHITECTURE.md`, `GUIDE.md`, `EVOLUTION.md`, or any skill file are welcome. If something was confusing to you as a new reader, it will be confusing to the next person — fix it.

### Bug reports
If a skill behaves differently than documented, open an Issue with:
- Which skill and platform (Claude Code or Gemini CLI)
- What you expected
- What actually happened

---

## Skill quality bar

Before submitting a new skill, check:

- [ ] The `description` field clearly states when the skill should activate — this is what the agent reads to decide relevance
- [ ] Instructions are specific enough that the agent can follow them without guessing
- [ ] No placeholders remain in any template output the skill produces
- [ ] The skill has been tested at least once in a real session
- [ ] The Tier level is correct: Tier 1 = orchestration setup, Tier 2 = planning/lifecycle, Tier 3 = execution or quality

---

## What we won't merge

- Skills that require a specific third-party API or paid service without a fallback
- Changes that remove the structural enforcement model (behavioral-rules-only approaches)
- Duplicate skills that overlap significantly with existing ones without a clear improvement
- Undocumented placeholders or `[TODO]` markers in any deliverable

---

## Questions

Open an Issue or start a Discussion. The architecture rationale is documented in [`ARCHITECTURE.md`](./ARCHITECTURE.md) — reading that first will answer most "why does it work this way" questions.

---

*(c) 2026 DZNR VENTURES® — MIT License*
