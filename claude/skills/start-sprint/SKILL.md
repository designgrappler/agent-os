---
name: start-sprint
description: Opens a new sprint — sets sprint goal, defines tracks, initializes plan.md and tracks.md.
whenToUse: When the user wants to start a new sprint or begin a structured work session with multiple tracks.
---

## Instructions

### Step 1 — Gather sprint context

**Infrastructure check (run first):** Review the proposed sprint tracks. If any track touches `claude/skills/`, `claude/agents/`, or lifecycle skills (`/start-sprint`, `/close-sprint`, `/clean-context`), run a lightweight system scan before proceeding: check `docs/` root for temp file accumulation, check `docs/archive/plan-docs/` against the 3-sprint window, and surface any structural issues before asking for the sprint goal.

**Backlog check (always run first):** Check whether `docs/backlog.md` exists. If it does, read it and surface candidate items grouped by section before asking for the sprint goal. Present each section as a brief bullet — section name + top item(s) in one sentence. Frame the output as: "Here's what's in the backlog — what's the goal for this sprint?" This replaces the blank prompt. If `docs/backlog.md` does not exist, proceed as if the file is absent — no error, no mention.

Check whether a temp plan doc already exists at `docs/temp-sprint*.md` (glob pattern). If one is found, read it and extract the sprint goal and track list from it — skip to Step 2. (A temp plan doc takes precedence over the backlog prompt; if a temp plan doc exists, surface it rather than the raw backlog.)

If no temp plan doc exists and no backlog file exists, ask the user:

1. What is the sprint goal? (one sentence)
2. What tracks will this sprint include? (list each track with a short description and owner if known)

Wait for the user's response before continuing.

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

### Step 4b — Backlog promotion

After tracks are written to `docs/context/tracks.md`, scan `docs/backlog.md` for items that correspond to the tracks just opened.

Match on: items explicitly tagged with the track ID (e.g. `(T54.1)`), or items whose title closely matches a track description from the sprint goal.

**If matches found:** surface them to the user:
> "The following backlog items appear to correspond to tracks opened in this sprint. Remove them?
> - [item title]"
> Wait for confirmation before removing.

**If confirmed:** remove the matched line(s) from `docs/backlog.md`. Do not remove section headers or surrounding items.

**If no matches found:** skip silently.

### Step 5 — Confirm

Output a short confirmation after Step 6 completes (so the plan doc link is accurate):

```
Sprint S<N> open.

Goal: <sprint goal>
Tracks: <count> track(s) added to docs/context/tracks.md
Plan: docs/context/plan.md updated
Sprint plan: [docs/temp-sprint<N>-plan.md](docs/temp-sprint<N>-plan.md)

Next step: review the tracks, then dispatch work.
```

### Step 6 — Write sprint plan doc

Produce a narrative plan doc at `docs/temp-sprint<N>-plan.md` using the following format:

- **Title:** `# Sprint <N> Plan — <sprint goal>`
- **Header:** Sprint ID, Status (DRAFT), Authored by, Date, Prior sprint, Release target
- **Section 1 — Sprint Objective:** 1–2 paragraph summary of what this sprint clears and why
- **Section 2 — Tracks:** One subsection per track with: Description, Scope (numbered steps), Key files, Verification criteria
- **Section 3 — Release Target:** version + one-line description
- **Section 4 — Sprint Close Conditions:** numbered checklist
- **Section 5 — Sequencing:** code block showing track order and dependencies

See `docs/temp-sprint48-plan.md` for a reference example of this format.
