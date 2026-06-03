---
name: start-sprint
description: Reads `docs/context/tracks.md`, finds all OPEN tracks (no dependency blockers), and outputs a parallel tab kickoff card — one entry per open track with a tab name and a ready-to-paste opening prompt.
---
# Start Sprint
Reads `docs/context/tracks.md`, finds all OPEN tracks (no dependency blockers), and outputs a parallel tab kickoff card — one entry per open track with a tab name and a ready-to-paste opening prompt. BLOCKED tracks are listed separately with their blocker noted.

## Auto-Trigger
Invoke when the user says:
- "start sprint", "kick off sprint", "launch sprint", "start the sprint"
- "open tabs", "parallel kickoff", "start parallel tracks"

---

## Rules
- **Read-only.** No files are modified.
- **Parse tracks.md exactly as written.** Do not infer status — read the `Status` field.
- A track is **OPEN** if its status is `Ready`, `Ready for Handoff Bridge`, `In Progress`, or equivalent active state with no blocker line.
- A track is **BLOCKED** if its status contains `Blocked` or if a `Blocked until` / `Depends on` field is present and unresolved.
- Tab letter suffix (`a`, `b`, `c`…) is assigned by track order in tracks.md.
- Sprint number is inferred from the track IDs (e.g., `T22a` → sprint 22). If tracks have mixed sprint numbers, use the majority; flag the outlier.

---

## Protocol

### Step 1 — Read context
Read `docs/context/tracks.md`.

If the file has no tracks or is empty, output:
> No tracks found in `docs/context/tracks.md`. Run `/open-sprint` to define tracks first.

### Step 2 — Classify tracks
Separate tracks into:
- **OPEN** — ready to start now, no unresolved blockers
- **BLOCKED** — has a blocker or dependency that is not yet resolved

### Step 3 — Resolve plan file
The plan file follows the pattern `docs/context/t##-plan.md` where `##` is the sprint number (e.g., sprint 22 → `docs/context/t22-plan.md`). Use this path in every prompt.

### Step 3b — Triage open feedback (non-blocking)

Invoke `/triage-feedback` to surface any open feedback issues from `designgrappler/agent-os` before proposing tracks.

- If `/triage-feedback` succeeds: include the cluster summary in the sprint scoping context. Reference any relevant clusters when building the track list.
- If `/triage-feedback` errors (e.g. `gh` auth failure, network issue): continue sprint kickoff with a one-line note:
  ```
  feedback triage skipped — <error>
  ```
  Do not halt sprint kickoff.

---

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

```
Sprint T[##] — Parallel Kickoff

OPEN (start now):
  Tab [N] — @[agent] T[##x] [theme]
  Prompt: "[ready-to-paste prompt]"

  Tab [N] — @[agent] T[##x] [theme]
  Prompt: "[ready-to-paste prompt]"

BLOCKED:
  Tab [N] — @[agent] T[##x] [theme]  ← blocked until [condition]

Open one tab per OPEN track via Cmd+Shift+Esc, paste the prompt, name the tab.
```

If there are no BLOCKED tracks, omit the BLOCKED section entirely.
If all tracks are blocked, output the BLOCKED list and note: `No tracks are ready to start. Resolve blockers first.`
