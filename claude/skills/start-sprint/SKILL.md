---
name: start-sprint
description: Unified sprint-start skill with two modes — Mode A (sprint-setup) opens a new sprint, calls the Sprint Coordinator (Peaches) to author the plan doc, and updates context files; Mode B (parallel-kickoff) reads tracks.md and outputs a parallel tab kickoff card for all OPEN tracks.
---
# Start Sprint
Unified sprint-start skill with two modes. **Mode A (sprint-setup)** opens a new sprint with a clean setup — surfaces unresolved prior work, calls the Sprint Coordinator (Peaches) to author the sprint plan doc, and updates context files. **Mode B (parallel-kickoff)** reads `docs/context/tracks.md`, finds all OPEN tracks (no dependency blockers), and outputs a parallel tab kickoff card — one entry per open track with a tab name and a ready-to-paste opening prompt. BLOCKED tracks are listed separately with their blocker noted.

## Auto-Trigger
Invoke when the user says:
- "start planning", "new sprint", "let's plan", "begin planning"
- "what are we working on next", "ready to start"
- Any message that signals intent to begin a new planning cycle
- "start sprint", "kick off sprint", "launch sprint", "start the sprint"
- "open tabs", "parallel kickoff", "start parallel tracks"

---

## Mode Routing

Before executing any steps, read `docs/context/plan.md` and `docs/context/tracks.md` to determine which mode to run.

**Decision rule (binary, deterministic):**

- **Mode A — Sprint Setup:** if `plan.md` has no Current Sprint section, OR the Current Sprint is marked complete, OR `tracks.md` has zero non-archived tracks for the current/next sprint number.
- **Mode B — Parallel Kickoff:** if `plan.md` has an active Current Sprint section AND `tracks.md` has at least one track for that sprint with a non-archived status.
- **Ambiguous case:** if the state is unclear (e.g. `plan.md` names one sprint, `tracks.md` references a different one), surface a one-line summary of what was found and ask the user which mode to run. Do not infer.

**Announce the selected mode before executing:**

> Running **[Mode A: Sprint Setup / Mode B: Parallel Kickoff]** because [reason — e.g. "plan.md has no active Current Sprint section" / "tracks.md has 3 open tracks for Sprint 15"].

---

## Mode A — Sprint Setup

Opens a new sprint. Surfaces unresolved work, calls the Sprint Coordinator (Peaches) to author the plan doc, and updates context files. The counterpart to `clean-context`.

### Step 1 — Prior Sprint Check

Read `docs/context/tracks.md` and `docs/context/plan.md`.

If `docs/context/tracks.md` does not exist, treat it as empty and proceed — do not error.

If any tracks are marked **in progress** or **blocked**, surface them:

> *"There are [N] unresolved tracks: [list]. Carry them forward, close them, or archive them before opening the new sprint?"*

Wait for confirmation before continuing.

### Step 1b — Trim Prior Sprint

After Tim confirms all unresolved tracks in Step 1 are resolved, check whether the prior sprint still has full content in `docs/context/plan.md` and `docs/context/tracks.md`.

**Prior sprint identification:** The prior sprint is the sprint whose number is one less than the sprint being opened (e.g., if opening S33, the prior sprint is S32).

**Check order — run these three cases in sequence (stop at the first that applies):**

- **Case 1 — Prior sprint section is absent from plan.md entirely:** If no section for the prior sprint exists in `plan.md` (e.g., no `## Completed Sprint: S<N>` or `## Current Sprint: S<N>` heading for that sprint number), emit the following one-line warning to the operator and insert the closed pointer before continuing:

  > *Warning: Prior sprint S<N> has no section in plan.md — adding closed pointer.*

  Insert the closed pointer `## Completed Sprint: S<N> ✓ — see docs/archive/plan-docs/S<N>.md` into `plan.md` at the correct position:
  - If `plan.md` already contains one or more `## Completed Sprint:` pointer lines, insert the new pointer in numerical order alongside them (highest sprint number first).
  - If no `## Completed Sprint:` pointer lines exist, insert the new pointer under a `## Sprint History` heading (create the heading if absent) at the end of the file.
  - Do NOT touch the current-sprint section or any other content.

- **Case 2 — Prior sprint section is present with full content:** If the prior sprint section exists and contains more than a one-line pointer entry, collapse it in both `plan.md` and `tracks.md` to a one-line pointer:
  ```
  ## Completed Sprint: S<N> ✓ — see docs/archive/plan-docs/S<N>.md
  ```
  Replace the entire prior sprint section (all headings, goals, task lines, and trailing content under it) with this single line. Apply the same collapse to the corresponding sprint section in `docs/context/tracks.md`.

- **Case 3 — Prior sprint section is already a one-line pointer:** Skip silently — no edit, no message.

This step runs only after Step 1 confirmation. It must not fire before Tim has confirmed all prior tracks are resolved. It must not touch any content belonging to the new (current) sprint being opened.

### Step 1a — Canonical Sync Sweep

Run a git log sweep to surface merged changes that may need canonical sync. This step is read-only — the Sprint Coordinator does not make canonicality judgments here; it ensures nothing is invisible to Tim.

**Find the last sprint-close anchor:**
```
git log --oneline --grep="sprint close" | head -1
```
Extract the SHA from the first matching line. If no match is found, fall back to the last 30 commits and note the fallback: *"No sprint-close anchor found — showing last 30 commits for manual triage."*

**Run the sweep:**
```
git log <anchor-sha>..HEAD --oneline
```

**Surface the results** as a triage block:
```
Canonical sync triage — commits since S<N> sprint close:
  <sha> <message>
  <sha> <message>
  ...
Review: do any of these touch skills, agents, AGENTIC.md, CLAUDE.md, or settings.json?
If yes, queue a canonical-sync track before dispatching Specialists.
```

The Sprint Coordinator does not make the canonicality judgment — it ensures Tim sees the list before sprint planning begins.

### Step 2 — Call Sprint Coordinator (Peaches)

Call Peaches (Sprint Coordinator role agent) to author the sprint plan doc.

Peaches authors `docs/temp-sprintN-plan.md` (where `N` is the sprint number, inferred from the track IDs or the sprint objective context; if ambiguous, use the next sequential number after the highest sprint number found in `docs/context/tracks.md`).

Peaches' plan doc must cover all four required sections:

1. **Sprint objective** — What is the primary goal? (1–2 sentences)
2. **Proposed tracks** — Each track with a brief description and the specialist owner (or "TBD").
3. **Open questions for Tim** — Any unresolved decisions, tradeoffs, or risks Tim should weigh in on before planning starts.
4. **Red flags surfaced** — Any architectural, security, or sequencing concerns to flag for the Technical Architect.

The Sprint Coordinator (this skill) waits for Peaches' doc to be written before continuing.

### Step 2a — Backlog Migration Triage

If `docs/backlog.md` exists, read it and surface any items that are candidates for promotion into the new sprint as a triage list for Tim. The Sprint Coordinator does not promote items unilaterally — it surfaces candidates.

> *"docs/backlog.md contains [N] items. Review and identify any to promote into Sprint [N] tracks."*

Wait for Tim's direction. If Tim identifies items for promotion, Skylar migrates them into the active tracks section of `docs/context/tracks.md` (Skylar does the actual `tracks.md` write — Sprint Coordinator does not write to `docs/context/**` directly).

If `docs/backlog.md` does not exist, print: `docs/backlog.md not found — skipping backlog triage.` and continue.

### Step 3 — Update Context Files

**`docs/context/plan.md`:**
```markdown
## Current Sprint: [Sprint Objective]

### Sprint Goals:
- [ ] [First task] — [Owner] — Track [N]

---
*Last updated: [DATE]*
```

**`docs/context/tracks.md`** — add new track entry for each proposed track:
```markdown
## Track [N]: [Task Name]
- **Owner:** [Specialist]
- **Status:** Ready for Handoff Bridge
- **Sprint:** [Sprint Objective]
- **Opened:** [DATE]
- **Exit Record**
  - **Status:** 
  - **What happened:** 
  - **Next steps:** 
```

**Confirm `AGENTIC.md`** is current — read and flag any stale fields. Do not modify without explicit direction.

If `docs/` does not exist, create it silently (no user message, no prompt) before writing any files under it.

### Step 4 — Sprint Summary

Output a 1–2 sentence summary of the path forward: confirm the plan doc has been written at `docs/temp-sprintN-plan.md`, and state what the next step is (e.g. Tim reviews the plan doc before the Technical Architect issues Bridges).

```
## Sprint [N] Open

**Objective:** [Sprint objective from Peaches' plan doc]
**Plan doc:** docs/temp-sprint<N>-plan.md
**Next step:** Tim reviews `docs/temp-sprint<N>-plan.md`; Technical Architect issues Bridges upon approval.
```

---

## Mode B — Parallel Kickoff

Reads `docs/context/tracks.md` and outputs a parallel tab kickoff card for all OPEN tracks. **Read-only — no files are modified.**

### Rules

- **Read-only.** No files are modified.
- **Parse tracks.md exactly as written.** Do not infer status — read the `Status` field.
- A track is **OPEN** if its status is `Ready`, `Ready for Handoff Bridge`, `In Progress`, or equivalent active state with no blocker line.
- A track is **BLOCKED** if its status contains `Blocked` or if a `Blocked until` / `Depends on` field is present and unresolved.
- Tab letter suffix (`a`, `b`, `c`…) is assigned by track order in tracks.md.
- Sprint number is inferred from the track IDs (e.g., `T22a` → sprint 22). If tracks have mixed sprint numbers, use the majority; flag the outlier.

### Step 1 — Read context

Read `docs/context/tracks.md`.

If the file has no tracks, is empty, or does not exist, output:

> No tracks found in `docs/context/tracks.md`. Run `/start-sprint` (Mode A) to define tracks first.

### Step 2 — Classify tracks

Separate tracks into:
- **OPEN** — ready to start now, no unresolved blockers
- **BLOCKED** — has a blocker or dependency that is not yet resolved

### Step 3 — Resolve plan file

The plan file follows the pattern `docs/context/t##-plan.md` where `##` is the sprint number (e.g., sprint 22 → `docs/context/t22-plan.md`). Use this path in every prompt.



### Step 4 — Build tab names

Tab naming convention: `@agent T##x theme`

- `@agent` — the specialist assigned to the track (from the Owner field); use the agent's name in lowercase (e.g., `@lucy`, `@max`, `@peaches`)
- `T##x` — sprint number + letter suffix in order (e.g., `T22a`, `T22b`)
- `theme` — 1–3 word slug from the track name (lowercase, hyphenated if multi-word)

### Step 5 — Build opening prompts

For each OPEN track, the prompt follows this template:

```
"You are [Agent]. First: git worktree add .claude/worktrees/track-[##x-theme] -b track/[##x-theme]. Work exclusively inside that worktree. Read [docs/context/t##-plan.md] [T##x] section and execute."
```

- `[Agent]` — the agent's display name (capitalized, e.g., `Lucy`)
- Branch name: `track/[##x-theme]` — sprint number + letter + hyphenated theme slug (e.g., `track/22a-schema`)
- The `git worktree add` command MUST be the first instruction in every prompt — before any plan-section read, file read, or edit instruction. This enforces worktree isolation when parallel tabs are open.
- If the track has a specific Handoff Bridge or additional context file noted, append: `Handoff Bridge is in [file].`

### Step 6 — Output the kickoff card

Output one card per track. OPEN tracks first, then BLOCKED tracks. Separate each card with `---`.

**For each OPEN track**, output exactly this shape:

**T##x — slug**

Tab name:
```
@agent T##x slug
```

Prompt:
```
[ready-to-paste opening prompt from Step 5]
```

---

**For each BLOCKED track**, output the same two-fenced-blocks shape with a `← blocked until [condition]` annotation on the line immediately after the bolded track header:

**T##x — slug**
← blocked until [condition]

Tab name:
```
@agent T##x slug
```

Prompt:
```
[ready-to-paste opening prompt from Step 5]
```

---

Both fenced blocks are present for BLOCKED tracks so the user can copy-paste once the blocker clears.

If there are no BLOCKED tracks, omit all BLOCKED cards entirely.
If all tracks are blocked, output all BLOCKED cards and add a closing note: `No tracks are ready to start. Resolve blockers first.`

After all cards, output:
```
Open one tab per OPEN track via Cmd+Shift+Esc, paste the prompt, name the tab.
```
