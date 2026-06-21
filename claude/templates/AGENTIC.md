# AGENTIC DNA — [PROJECT NAME]

[PROJECT DESCRIPTION]

This document is the root source of truth for this project. All agents read it before any work begins. Edit via your primary agent — do not edit directly.

---

## 2. Tech Stack

### Backend
- **Runtime:** [RUNTIME]
- **Framework:** [FRAMEWORK]
- **Database:** [DATABASE]
- **Transport:** [TRANSPORT]

### Frontend
- **Framework:** [FRONTEND FRAMEWORK]
- **Styling:** [STYLING]
- **Design System:** [DESIGN SYSTEM]

### Quality & Automation
- **Type Checking:** [TYPE CHECK COMMAND]
- **Build:** [BUILD COMMAND]
- **Linting:** [LINTER]

---

## 3. Project Team

- **[CONDUCTOR NAME] (Conductor):** Vision & Approval.
- **Claude (Orchestrator):** Coordinates specialists, no direct execution.
- **[ARCHITECT NAME] (Lead Architect):** Context Owner. Zero-code. Plans and produces Handoff Bridges.
- **[SPECIALIST 1 NAME] ([Domain 1] Specialist):** Owns [scope].
- **[SPECIALIST 2 NAME] ([Domain 2] Specialist):** Owns [scope].
- **[SPECIALIST 3 NAME] ([Domain 3] Specialist):** Owns [scope].
- **[QA NAME] (QA):** Build verification and quality gate. Read-only.

### Orchestrator Constraints (binding)

The Orchestrator coordinates specialists. It does not plan.

- **FORBIDDEN:** Drafting track specs, scope definitions, Red Flag Analysis, Handoff Bridges, or any planning artifact — even as "rough scaffolding" or a "starting point."
- **FORBIDDEN:** Writing planning content to `docs/context/plan.md`, `docs/context/tracks.md`, or any sprint plan doc. Only the Architect writes planning content; the Conductor approves; the Orchestrator coordinates the handoff.
- **REQUIRED:** After any context-setup step (e.g. `/start-sprint`, `/onboard-existing-project`), the next action is to invoke the Architect. If sprint scope was discussed in chat, summarize it as a one-line briefing to the Architect — do not translate it into track specs.
- **FORBIDDEN:** Direct execution of any kind on execution files (`AGENTIC.md`, `CLAUDE.md`, `claude/**`, `.claude/agents/**`, `.claude/skills/**`, `docs/tasks.json`, `docs/context/**`) — even when a Specialist is blocked, even when the fix is "obvious", even when the urgency feels high. The Orchestrator coordinates; it does not edit.
- **REQUIRED (when a Specialist is blocked):** The only two valid Orchestrator moves are (1) surface the blocker to the Conductor, or (2) call the Architect for an unblock plan. Direct execution is forbidden regardless of urgency.

Violations of this rule bypass the Phase 3a plan-doc gate (§5) and produce unreviewed plans that look official but aren't. This is a protocol violation and is treated as a circuit-breaker event.

**Tool-layer enforcement:** This rule is also enforced at the tool layer by the `PreToolUse` hook at `.claude/hooks/block-orchestrator-execution.sh`. The hook blocks Orchestrator-authored Edit/Write calls to execution files (`AGENTIC.md`, `CLAUDE.md`, `claude/**`, `.claude/agents/**`, `.claude/skills/**`, `docs/tasks.json`, `docs/context/**`) regardless of model state. See `docs/bridges/S18.1-em-execution-hook.md` for the Bridge and known bypass vectors.

**Mode-switch tool-layer enforcement:** The `/switch-workflow-mode` skill's
Phase 1 feasibility gate (no Edit/Write while any task is `CLAIMED` or
`IN_PROGRESS`) is also enforced at the tool layer by the `PreToolUse` hook at
`.claude/hooks/block-mode-violation.sh`. The hook reads `docs/tasks.json` on
every Edit/Write call and exits code 2 if any task is in flight, blocking
the modification regardless of which agent (Orchestrator, Specialist,
Architect, QA) initiated it. This pairs with the skill-layer gate (the
user-facing explanation) to provide identity-independent runtime enforcement
of the mode-switch invariant. See `claude/skills/switch-workflow-mode/SKILL.md`
for the skill-layer rule and the hook script for the tool-layer
implementation.

---

## 7. Definition of Done

A track is **Done** only when ALL of the following are true:

- [ ] `[BUILD COMMAND]` exits with zero errors
- [ ] All changes are within the declared track scope (no scope drift)
- [ ] No `console.log`, `debugger`, or hardcoded secrets in the diff
- [ ] `docs/context/plan.md` and `tracks.md` updated to reflect the completed track
- [ ] [QA NAME] has issued a **PASS** verdict
- [ ] [CONDUCTOR NAME] has given final approval (for tracks touching auth, schema, or payments)

### Skill Update DoD

When a track modifies or adds a skill, ALL of the following must also be true:

- [ ] Source-of-truth repo file (`agent-os-private`) updated
- [ ] Global copy at `~/.claude/skills/<name>.md` synced (`diff` returns empty)
- [ ] Dual-ownership check: if the skill exists in the mirror, it's downstream-only — no work done there
- [ ] Behavioral verification in a project outside the source repo, exercising the changed behavior path
- [ ] If the skill writes to settings, verify write target matches stated scope (global vs project)
- [ ] `plan.md` and `tracks.md` updated; commit uses Conventional Commits

---
---

# How Your Agents Operate

> **For reference only.** The sections below describe how your agents behave.

---

## 1. DNA Taxonomy
- **Static DNA:** Foundational tech, team roles, and protocol constraints (this file).
- **Dynamic DNA:** High-churn task state, roadmap, and requirements (`docs/context/`).
- **Blueprint schema:** `claude/blueprints-schema.md` — canonical specification for task blueprint files (four-column schema, field reference, naming convention, deferred decisions).

### Memory Authoring Convention

Every `project_*.md` memory file MUST include a `**Created:** YYYY-MM-DD` line in its first content block (immediately after the frontmatter, before the body text). Rules:

- **The `Created:` date never changes after the file is first written.** It records when the memory was authored, not when it was last meaningful.
- A `**Updated:** YYYY-MM-DD` line is allowed (record the date of the most recent edit) but not required.
- This convention is **forward-going only.** Pre-existing memory files that were authored before this convention was established are not retroactively datestamped. Sub-item B of the memory hygiene track handles pre-existing undatable files as a separate "stale-undatable" category.

---

## 4. Worktree Protocol

Each Specialist agent definition includes `isolation: worktree` in its frontmatter. Combined with `worktree.baseRef: "head"` in `.claude/settings.json`, every Specialist invocation automatically gets an isolated copy of the repo branched from the current session HEAD.

- `isolation: worktree` provides CWD isolation — the Specialist's working directory is the worktree. Claude's built-in file tools (`Read`, `Edit`, `Write`) are governed by the permission system, not the worktree CWD, so they can write outside the worktree if permissions allow
- `worktree.baseRef: "head"` is required — without it, worktrees branch from `origin/HEAD` and cannot see uncommitted context files
- Branch naming: managed automatically by the Agent tool runtime
- Never work directly on the main branch when 2+ tracks are active in parallel
- Worktree removed only after QA issues PASS verdict
- **Post-setup smoke:** After first enabling `worktree.baseRef: "head"`, invoke a Specialist on a no-op task and confirm the worktree contains uncommitted context files — verifies the setting is honoured (a misconfigured value falls back silently to `origin/HEAD`)

---

## 5. Conductor Protocols

### Stability Rules
- **Circuit Breaker:** 3 consecutive failures with the same root cause → STOP and escalate to the Conductor. Any single destructive or security-related failure triggers an immediate stop regardless of count.
- **Same-pattern circuit breaker (binding).** If the same intervention pattern recurs 3 or more times within a single sprint — regardless of whether the triggering errors differ — it counts as the same root cause. The sprint threshold is 3 same-pattern interventions (not 3 consecutive failures). The canonical example: an Orchestrator-fills-the-gap pattern recurring 9–10 times in S17 across different tracks was the same root cause (protocol drift) despite varying surface triggers. When the threshold is hit, STOP and call the Architect for a Red Flag Analysis before any further dispatch. The detection mechanism (automated pattern recognition) is deferred to a research-first follow-up track; until then, the Conductor applies this rule manually by reviewing the sprint's intervention history at each circuit-breaker check.
- **Git Hygiene:** No commits unless directed. Use `git add` for staging only.
- **Sentinel Proof:** Never trust an agent's verbal summary. Verify with `git diff` or direct file reads.

**Commit-before-dispatch (binding).** Before dispatching a Specialist on any track, the Conductor must commit all staged changes on `main`. Uncommitted working-tree changes on `main` do **not** reach Specialist worktrees: `worktree.baseRef: "head"` branches the worktree from the current HEAD **commit**, not from the working tree. Dispatching with uncommitted state silently strands the Specialist on a stale baseline. Verify with `git status` (clean working tree) immediately before invoking the Specialist.

**`.claude/` is worktree-unsafe (binding).** Worktree isolation (`isolation: worktree` + `worktree.baseRef: "head"`) covers the project CWD only. `.claude/settings.json` and `.claude/hooks/**` are read by the Claude Code runtime from a path that is **not** isolated by the worktree CWD. Any track that requires changes to `.claude/settings.json` or `.claude/hooks/**` must make those changes directly on `main` (absolute path against the source repo, not the worktree). The Bridge for any such track must call out the `.claude/`-on-main exception in its Execution Files block.

**Pre-staging hygiene check (binding).** Before staging any track's files for commit (`git add`), run `git status` and confirm no unrelated dirty files are present in the working tree. If unrelated changes exist, commit or stash them on a separate branch or commit **first**. This prevents accidental co-mingling of unrelated work in a track commit and preserves the per-track authorship record S18.3 relies on.

### Handoff Logic
- **Phase 1 (Verify):** Downstream specialist verifies upstream interface before any implementation begins.
- **Phase 2 (Align):** Synchronize with `AGENTIC.md` and `tracks.md`.
- **Phase 3 (Draft):** Architect drafts implementation plan.
- **Phase 3a (Plan Doc):** Before any Bridge is issued, a plan doc must exist at `docs/sprint-plan-<sprint-id>.md` and must be approved by [CONDUCTOR NAME]. The plan doc must cover: (1) sprint scope, (2) tracks, (3) Red Flag Analysis, and (4) open questions for [CONDUCTOR NAME]. Any role may author it; the Architect is the default author. This step is mandatory for all sprints — including single-track sprints. An agent that issues a Bridge without a [CONDUCTOR NAME]-approved plan doc has violated protocol and is subject to removal from the team.

  **Antigravity exception:** If antigravity automatically produces a plan doc covering all four required sections (scope, tracks, Red Flags, open questions for [CONDUCTOR NAME]), that document satisfies this requirement without a separate Agent-OS plan doc. If antigravity's output does not cover all four sections, produce a plan doc at `docs/sprint-plan-<sprint-id>.md` regardless.

  **Lifecycle:** After sprint close, plan docs are archived to `docs/archive/plan-docs/<sprint-id>.md`. They are not deleted.

- **Phase 4 (Bridge):** Architect compresses Dynamic DNA into a Handoff Bridge for the Specialist. Before issuing the Bridge, the Architect must explicitly evaluate:
  - Does this track involve destructive or irreversible migrations? → populate `Migration Safety` and obtain Conductor acceptance if irreversible.
  - Does this track touch auth, payments, or schema? → populate `Security Review` and obtain Conductor acceptance.
  - Both fields must be explicitly set (not left as template placeholders) before the Bridge is issued.

**No-Bridge rule (binding):** Any execution touching `src/`, `supabase/`, config files, agent profiles, skills, `CLAUDE.md`, or `AGENTIC.md` requires a Bridge first. "Sounds small", "it's just one line", and "quick fix" are not exemptions. Clarification questions are fine; execution is not.

**Continuous improvement loop:** Fix locally → confirm it works → if it works, queue a targeted backlog item naming the specific canonical file to update → process that item as a normal sprint track. An improvement is not shipped until canonical reflects it. See §5.1 for the full enforcement rule.

**Orchestrator no-execution cross-reference:** §3 Orchestrator Constraints defines a binding role-scoped rule that forbids the Orchestrator from any direct execution on execution files, even when a Specialist is blocked. The only two valid Orchestrator moves in that case are (1) surface to Conductor, or (2) call Architect for unblock plan. The rule is enforced at the protocol layer here (§3 / §5) and at the tool layer via the `PreToolUse` hook documented in `docs/bridges/S18.1-em-execution-hook.md`. See AGENTIC.md §3 for the canonical rule text — this cross-reference does not duplicate it.

### 5.1 Canonical Sync Before Sprint Close

Every improvement made during a sprint to a **project-level artifact** — `.claude/agents/*.md`, `.claude/settings.json`, the live `AGENTIC.md` or `CLAUDE.md`, or any project-level config — must have its **canonical owner** identified before the sprint closes. The canonical owner is the file in `claude/agents/`, `claude/templates/`, or `claude/skills/` that a fresh `install-agent-scaffold` run reads from to produce the equivalent improvement on a new install.

If the canonical owner is not yet updated to reflect the improvement, the Conductor must:

1. **Queue a canonical-update track** for the current sprint or the next sprint (Conductor's call based on sprint capacity).
2. **Mark the improvement as "canonical-sync pending"** in the sprint's plan doc until the canonical track lands.
3. **Block sprint close** if a canonical-sync-pending item exists and no canonical-update track has been queued.

The improvement does not count as "shipped" until the canonical owner reflects it. Project-level fixes that never propagate are protocol drift — they degrade the fresh-install experience silently and break the `install once → improve forever` contract Agent OS promises its users.

**Scope note:** Project-specific configuration that should NOT lift to canonical (e.g. agent-name overrides like `peaches`/`skylar`/`bandit`, repo paths, working-directory references) is exempt — but the exemption must be stated explicitly in the sprint plan doc, not left implicit.

**I/O contracts:** see `docs/context/io-contracts.md` for the result.json schema, role-agent structured output schema, and Bridge file schema.

### Sprint-close `/clean-context` step (binding)

After QA (Bandit) issues a final APPROVED verdict on the last track of a sprint, the Conductor must run `/clean-context` before the sprint is marked complete. This consolidates context archival, memory pruning, and worktree cleanup at sprint close so the next sprint opens against a clean baseline. The step runs after §5.1's canonical-sync gate is satisfied; together they define the two binding sprint-close prerequisites.

---

## 6. Commit Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

feat(auth): add OAuth redirect handler
fix(items): correct rounding on split calculation
chore(deps): upgrade dependency
refactor(ui): extract component into standalone file
```

**Types:** `feat` · `fix` · `chore` · `refactor` · `docs` · `style` · `perf` · `test`
**Breaking changes:** append `!` after type and include `BREAKING CHANGE:` in the body.

---

## 8. Handoff Bridge Template

```markdown
### HANDOFF BRIDGE
**Topic:** [Feature/Bug Name]
**Track:** [ID from tracks.md]
**Specialist:** [specialist name]
**Static DNA Check:** [Confirm alignment with AGENTIC.md tech/roles]
**Dynamic DNA State:**
- **Product Context:** [1-sentence summary of requirement]
- **Current Plan:** [step in plan.md]
- **Execution Files:** [list of files to modify]
**Migration Safety:** [N/A / Reversible / Irreversible — Conductor acceptance: YES (date) if irreversible]
**Security Review:** [N/A / Auth / Payments / Schema — Conductor acceptance: YES (date) if any]
**Worktree Setup:** Automatic — `isolation: worktree` in Specialist frontmatter + `worktree.baseRef: "head"` in `.claude/settings.json`. Verify both are present before Specialist begins. (`isolation: worktree` is a CWD setting — built-in file tools are governed by the permission system, not the worktree CWD; Bridge Execution Files scope is the protocol-layer compensating control.)
**`.claude/` exception:** `.claude/settings.json` and `.claude/hooks/**` are not worktree-isolated. If this Bridge's Execution Files include either path, the Specialist edits them directly on `main` (absolute path). Note this explicitly in the Execution Files list when it applies.
**Verification:** [specific command or URL]
**Next Step:** [specific task for the Specialist]
```

---

## 9. Canonical-Update Protocol

This section governs how Agent OS ships updates to users' installed skills and agent files over time. It is distinct from §5 (Conductor Protocols), which governs how sprints are run internally. §9 governs distribution and versioning — what happens after a sprint merges.

### 9.1 What Counts as a Canonical Change

A **canonical change** is any modification to a file that is distributed to user installs:

- Any edit to a `claude/skills/<name>/SKILL.md` file.
- Any edit to a `claude/agents/<name>.md` file (including frontmatter additions, section rewrites, or removals).
- Any change to `skills-manifest.json` (schema extension, new agent or skill entry, rename record, version bump).

Changes to `AGENTIC.md`, `docs/`, and internal config files (`.claude/settings.json`) are **not** canonical changes — they affect the repo but are not distributed to user installs via the refresh tool.

### 9.2 Compatibility Window (Binding Minimum: 2 Sprints)

When a canonical change introduces a new field, renames an existing field, or removes a field from agent frontmatter or skill format:

1. **The minimum compatibility window is 2 sprints. This is binding, not advisory.** Specific changes may declare a longer window but never a shorter one.
2. During the compatibility window, both the old format and the new format must parse cleanly. Agent OS must not require the new field to be present.
3. Missing fields must default to a documented value. For example: `provider:` absent → defaults to `claude` (per T9.2's confirmed shape).
4. After the window closes, the old format is deprecated. Users who have not run `/refresh-agent-os` will see a warning nudge — not a hard break.
5. The sprint that introduces the change starts the window clock. The window closes after 2 full sprints have completed with both formats valid.

### 9.3 Upgrade Path

The canonical upgrade path for user installs mirrors the existing skill-refresh flow:

1. **Manifest read** — `/refresh-agent-os` reads `skills-manifest.json` from the canonical source (URL primary, local clone fallback).
2. **Diff** — the skill inventories canonical skills and agents against the user's `~/.claude/skills/` and `~/.claude/agents/` installs, producing new / renamed / removed / drifted lists for both.
3. **Confirm** — the skill presents a report table and asks the user to approve actions. Nothing is applied without explicit per-file confirmation.
4. **Apply** — approved actions are applied one at a time. Release version and release notes are surfaced before any writes occur.

### 9.4 Release Versioning

Agent OS uses **semver-style versioning** (`v<major>.<minor>.<patch>`):

- **Major:** breaking changes that require manual user action even within the compatibility window.
- **Minor:** new features, new skills, new agents, new frontmatter fields (always backward-compatible when introduced within the compatibility window).
- **Patch:** bug fixes, copy corrections, non-behavioral edits to existing files.

The current release version is tracked in `skills-manifest.json` under the key `"release-version"`.

Rules for bumping:
- Any canonical change requires at least a patch bump before merge.
- Adding a new skill, agent, or frontmatter field bumps minor.
- A change that deprecates an old format (compatibility window closes) bumps major.

### 9.5 Release Notes

Release notes live at `docs/releases/v<semver>.md`. Each release note covers:

1. **Version** — the semver tag (e.g. `v0.9.0`).
2. **Date** — ISO date of the sprint that cut the release.
3. **Summary** — one-paragraph plain-English description of what changed.
4. **Changed files** — list of canonical files modified.
5. **Compatibility window** — if any new frontmatter fields were added, state the window duration and the default values for missing fields.
6. **User action required** — either "Run `/refresh-agent-os` to apply" or "No action required" if the release is source-repo only.

### 9.6 Manifest Version Fields

`skills-manifest.json` carries two version fields:

- `"frontmatter-version"` — an integer that increments any time an agent frontmatter field is added, renamed, or removed. Consumers compare this value against what they last processed to know whether a frontmatter migration is available. Starts at `1`.
- `"release-version"` — the semver string of the current canonical release (e.g. `"v0.9.0"`). The refresh tool surfaces this value in Phase 4 when offering updates.

Both fields are additive — old consumers that only read `skills` and `renames` are unaffected.

### 9.7 Bridge Verification Requirements (canonical-change patterns)

These two rules are **binding**. Any Bridge that triggers either condition must include the corresponding verification criterion before being issued. Failure to include it fails the Bridge Self-Check in `claude/agents/architect.md`.

#### 9.7.1 Absent-path precondition

Any Bridge step that introduces a new filesystem path read or write — including reads of `~/.claude/<dir>/` or writes to a previously optional directory — must include a verification criterion confirming that the skill handles the absent-directory or absent-file case gracefully. Acceptable handling: create the directory silently (no user message, no prompt) and treat the installed set as empty; or treat the file as empty. Surface an error only if creation itself fails.

A Bridge that lists a `~/.claude/<dir>/` path in its Verification field without an absent-path criterion has failed the Self-Check gate.

#### 9.7.2 Cross-array mutual exclusion (`skills-manifest.json`)

Any Bridge touching `skills-manifest.json` must include a verification criterion asserting the cross-array invariant: `skills ∩ renames[].from = ∅`. No skill name may appear in both the `skills` array and as a `from` value in the `renames` array — these semantics are contradictory (`skills` is prescriptive; a `renames[].from` value names a deprecated skill that no longer belongs in `skills`).

The same invariant extends to the `agents` array if a future rename record targets agent names.

### 9.8 Blueprints (canonical content type)

Task blueprints are the third canonical content type Agent OS distributes to user installs, alongside skills (`claude/skills/<name>/SKILL.md`) and agents (`claude/agents/<name>.md`). A blueprint is a single self-contained Markdown file with YAML frontmatter and three required body sections, conforming to the schema at `claude/blueprints-schema.md`. The schema is the binding contract; this section governs distribution and versioning.

**Distribution path:** canonical blueprints live at `claude/blueprints/<name>.md` in the source repo and are distributed to user installs at `~/.claude/blueprints/<name>.md` (user scope, parallel to `~/.claude/skills/` and `~/.claude/agents/`). The `install-agent-scaffold` skill scaffolds the user-scope directory on fresh installs; the `refresh-agent-os` skill governs ongoing diff/install/rename/remove against canonical.

**Manifest:** `blueprints-manifest.json` at the repo root is the canonical source of truth for blueprint names and rename history, mirroring the structural role of `skills-manifest.json` for skills and agents. The manifest carries three keys: `blueprints` (array of canonical blueprint names), `renames` (array of `{from, to}` records), and `schema-version` (integer). It does NOT carry a `release-version` field — release-version lives in `skills-manifest.json` per §9.6 and is the single source of truth for the canonical distribution as a whole.

**Per-blueprint schema versioning:** every blueprint frontmatter carries a `schema_version:` integer field that names which version of the blueprint schema the file conforms to. Schema-version evolution is governed by §9.2's binding 2-sprint compatibility window — the same window that governs agent frontmatter evolution. The `schema_version:` field is the per-blueprint migration handle, parallel to `provider:` for agents.

**§9.7 invariants extended to blueprints:**
- **§9.7.1 Absent-path precondition** applies to `~/.claude/blueprints/` the same way it applies to `~/.claude/skills/` and `~/.claude/agents/`. Any Bridge step introducing a read or write of `~/.claude/blueprints/<name>.md` must include a verification criterion that the absent-directory and absent-file cases are handled gracefully (silent `mkdir -p` for the directory; treat absent file as "not installed"). The `refresh-agent-os` skill MUST NOT crash on the absent-`~/.claude/blueprints/` precondition.
- **§9.7.2 Cross-array mutual exclusion** extends to `blueprints-manifest.json` symmetrically: any Bridge touching `blueprints-manifest.json` must include a verification criterion asserting `blueprints ∩ renames[].from = ∅`. No blueprint name may appear in both the `blueprints` array and as a `from` value in the `renames` array — these semantics are contradictory (same reasoning as for skills and agents). When the `refresh-agent-os` skill's diff phase encounters a §9.7.2 violation in `blueprints-manifest.json`, it surfaces a one-line diagnostic (`Manifest invariant warning: <name> appears in both blueprints[] and renames[].from. Treating as canonical (no action).`) and treats canonical `blueprints` membership as authoritative — the same defensive runtime guard already implemented for skills and agents.

**Schema reference:** the binding schema specification for blueprint files is at `claude/blueprints-schema.md`. The schema governs the four-column frontmatter contract (`name`, body+`description`, `tools`, `expected_output`), the three required body sections (System Prompt Strategy, Expected Output Contract, Allowed Tool Bindings — Reasoning), the uniform `task-` prefix naming convention, the frontmatter `expected_output:` ↔ body `## Expected Output Contract` first-sentence sync rule, and the §11 Deferred decisions list. §9.8 governs distribution of blueprints conforming to that schema; it does not redefine the schema. Schema evolution proceeds per §9.2 (compatibility window) and is reflected in the per-blueprint `schema_version:` field.
