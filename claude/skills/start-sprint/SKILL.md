---
name: start-sprint
description: Opens a new sprint — sets sprint goal, defines tracks, initializes plan.md and tracks.md.
whenToUse: When the user wants to start a new sprint or begin a structured work session with multiple tracks.
---

## Instructions

### Step 1 — Gather sprint context

**Infrastructure check (run first):** Review the proposed sprint tracks. If any track touches `claude/skills/`, `claude/agents/`, or lifecycle skills (`/start-sprint`, `/close-sprint`, `/clean-context`), run a lightweight system scan before proceeding: check `docs/` root for temp file accumulation, check `docs/archive/plan-docs/` against the 3-sprint window, and surface any structural issues before asking for the sprint goal.

**Backlog check (always run first):** Check whether `docs/backlog.md` exists. If it does, read it and surface candidate items grouped by section before asking for the sprint goal. Present each section as a brief bullet — section name + top item(s) in one sentence. Frame the output as: "Here's what's in the backlog — what's the goal for this sprint?" This replaces the blank prompt. If `docs/backlog.md` does not exist, proceed as if the file is absent — no error, no mention.

**Systemic-drift triage (run right after the backlog check):** Before asking for the sprint goal, scan the backlog items just surfaced and ask: *"Does any open backlog item represent an architectural spec that agents are actively following incorrectly?"* If yes, that item heads the sprint. Distinguish the two cases:
- **Stop-and-fix** — the issue causes active drift on every sprint that runs. It heads the current sprint.
- **Queue** — a missing improvement that does not get worse with time. It stays in the backlog.

Check whether a temp plan doc already exists at `docs/temp-sprint*.md` (glob pattern). If one is found, read it and extract the sprint goal and track list from it — skip to Step 2. (A temp plan doc takes precedence over the backlog prompt; if a temp plan doc exists, surface it rather than the raw backlog.)

If no temp plan doc exists and no backlog file exists, ask the user:

1. What is the sprint goal? (one sentence)
2. What tracks will this sprint include? (list each track with a short description and owner if known)

Wait for the user's response before continuing.

### Step 1a — Write orchestrator-owned plan doc

Write `docs/temp-sprint<N>-plan.md` with the orchestrator-owned top section:
- Header block: Sprint ID, Status: OPEN, Authored-by: Orchestrator, Date, Release target
- Sprint Objective
- Tracks table (one row per track: Track ID | Description | Owner | Status)
- Constraints — include explicit exclusions/non-goals
- Sequencing — dependency order across tracks
- Sprint Close Conditions
- Sentinel: `<!-- ORCHESTRATOR SECTION END — do not edit above this line -->`

Immediately after the sentinel, append one Element (c) stub per Tracks table row:

```
## T<N> — <Track Description>

**Owner:** <role-key>
**Status:** STUB

<!-- <role-key>: fill this section before executing -->

**Description:**

**Scope:**

**Key files:**

**Verification criteria:**
```

Do not write any track content. The stub is the full orchestrator contribution below the sentinel.

Format defined in `docs/context/plan-doc-format.md`.

### Step 1b — Identify domains involved

From the sprint goal and proposed tracks surfaced in Step 1, identify which domain agents are relevant. Match tracks to agent roles:

- Design work → `designer`
- Product requirements / user stories → `pm`
- Technical architecture / complex decisions → `technical`
- Research / competitive analysis → `researcher`
- Strategic direction / opportunity framing → `strategist`

This step repeats if Tim's feedback on sub-plans changes sprint scope — re-identify affected domains and re-spawn those agents before proceeding.

### Step 1c — Spawn domain agents in planning mode (parallel)

Instruct each domain agent to fill their assigned stub section in-place in `docs/temp-sprint<N>-plan.md` before executing. Each agent reads the full top section (above the sentinel), fills only their own stub (Description, Scope, Key files, Verification criteria), and flips Status from STUB to FILLED. No separate per-domain files.

Domain agents run in parallel where independent. Run sequentially where one domain's scope depends on another (e.g. strategist or pm before technical or frontend).

**Gap coverage rule (hard):** If a proposed track has no matching domain agent, the sprint always blocks for Tim input — the orchestrator does not fill the gap. Surface explicitly:
> "Track [X] has no domain agent. Define its scope manually or remove it before proceeding."

### Step 1d — Tim review gate (soft gate)

Once all domain agents have filled their assigned stubs, surface the plan doc to Tim:

> "Domain agent stubs filled. Plan doc ready for review:
> - [docs/temp-sprint\<N>-plan.md](docs/temp-sprint\<N>-plan.md)
> Review each track's filled section, confirm scope and verification criteria, then confirm to proceed."

If Tim's feedback changes scope for any domain, re-spawn those domain agents with updated context to re-fill their stubs. Repeat until Tim confirms the full set.

**Do not proceed to Step 2 until Tim confirms.**

### Step 2 — Determine sprint ID

Read `docs/context/plan.md` if it exists. Find the highest sprint number currently referenced (look for `## Current Sprint: S<N>` or `## Completed Sprint: S<N>`). The new sprint ID is that number plus one. If no prior sprint is found, start at S1.

### Step 2b — Prior-sprint open-PR pre-check (warn-only)

Before opening the new sprint, check whether any pull requests from the prior sprint
are still open against `feature/*` branches. This is a **warning only** — it never
blocks sprint open, and it degrades silently when GitHub CLI is unavailable.

1. If `gh` is not installed, skip this step entirely — no output:
   ```bash
   command -v gh >/dev/null 2>&1 || :   # skip silently when gh absent
   ```

2. Otherwise, query open feature-branch PRs (stderr suppressed so an
   unauthenticated `gh`, a repo with no GitHub remote, or any other failure
   produces no output):
   ```bash
   gh pr list --state open \
     --json number,title,headRefName,url \
     --limit 100 \
     --jq '.[] | select(.headRefName | startswith("feature/")) | "  #\(.number)  \(.headRefName)  —  \(.title)  (\(.url))"' \
     2>/dev/null
   ```

3. If the command produced no output (no matching PRs, gh not authenticated,
   no GitHub remote, or any error) — emit nothing and continue to Step 3.

4. If the command produced one or more lines, print this warning, then continue
   to Step 3 (the sprint still opens — this does not block):
   ```
   These PRs from the prior sprint are still open — merge or close them before opening the new sprint:

   <captured lines>
   ```

### Step 3 — Write `docs/context/plan.md`

Create or overwrite the Current Sprint section at the top of `docs/context/plan.md`:

```markdown
## Current Sprint: S<N> — <sprint goal>

### Sprint Goals:
- [ ] <Track ID> — <description> — <owner or TBD>

---
*Last updated: <today's date>*
```

If the file already contains completed sprint entries (lines matching `## Completed Sprint: S<N> ✓`), preserve them below the new current sprint section.

If `docs/` does not exist, create it silently before writing.

### Step 4 — Write `docs/context/tracks.md`

**Determine collaboration mode (read once).** Read `agent-setup.yml` from the project root and take the top-level `mode:` value (trim whitespace, strip inline `#` comments). Defaulting — never error: file absent, key absent, blank, `single-user`, or any unrecognized value → treat as **`single-user`**; only the exact value `multi-user` → **`multi-user`**. This is the T47.2 Canonical Read Contract.

Add one entry per track to `docs/context/tracks.md`. Each entry follows this shape:

```markdown
## Track <ID>: <Task Name>
- **Owner:** <OWNER_VALUE>
- **Status:** OPEN
- **Sprint:** S<N>
- **Opened:** <today's date>
- **Exit Record**
  - **Status:**
  - **What happened:**
  - **Next steps:**
```

Resolve `<OWNER_VALUE>` by mode:
- **`single-user` (default):** emit exactly `<agent name, or null if unclaimed>` — i.e. **identical to the prior behavior**; write `null` when unclaimed. Do **not** prompt. (This is byte-for-byte the pre-T47.3 line.)
- **`multi-user`:** before writing each track entry, prompt the user: `Owner for Track <ID> — GitHub handle, or leave blank to claim later:`. If a handle is given, use it verbatim as `<OWNER_VALUE>`. If the user leaves it blank, use `null` (claim-later is valid).

If the file already has entries from a prior sprint, append the new entries below them.

### Step 4b — Backlog promotion (mandatory move operation)

This step is **mandatory and non-skippable.** When a backlog item enters a sprint, it is moved — not copied. The backlog must reflect only work that has not yet been pulled into a sprint. This step is the mechanism for that move.

Read `docs/backlog.md`. For every item in the file, ask: *"Is this work being done in this sprint?"* Match on ANY of the following signals — be liberal, not conservative:
- Item is explicitly tagged with the track ID (e.g. `(T54.1)`)
- Item title closely matches a track description or sprint goal keyword
- Item describes a feature, bug, or capability that the sprint tracks are implementing — **same domain and intent counts, even if the exact wording differs**
- Item is in a backlog section whose heading corresponds to this sprint's domain

**When in doubt, surface the item.** A false positive costs one confirmation. A missed item leaves completed work in the backlog indefinitely — that is the failure mode to avoid.

**If matches found**, surface them:
> "These backlog items correspond to work in this sprint and should be removed from the backlog. Confirm?
> - [B<n>] [item title]"
> Wait for confirmation, then remove the matched line(s). Do not remove section headers or surrounding items.

**If no matches found**, state explicitly: "Backlog scan complete — no items match the tracks in this sprint." Do not skip silently. The confirmation that the scan ran is part of the sprint open record.

### Step 5 — Confirm

Output a short confirmation when all steps complete.

**The "Sprint plan:" line must use markdown link syntax — `[path](path)` — not plain text.**

```
Sprint S<N> open.

Goal: <sprint goal>
Tracks: <count> track(s) added to docs/context/tracks.md
Plan: docs/context/plan.md updated
Sprint plan: [docs/temp-sprint<N>-plan.md](docs/temp-sprint<N>-plan.md)

Next step: review the tracks, then dispatch work.
```

Format defined in `docs/context/plan-doc-format.md`.