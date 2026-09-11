---
name: triage
description: Surfaces open GitHub issues and backlog candidates for sprint planning — read-only, never edits backlog.md.
whenToUse: When starting a sprint or when you want a prioritized view of open backlog items and GitHub issues grouped by theme.
---

## Source / Scope Argument

Invoke with an optional argument to select the triage source:

- **No argument (default):** backlog + GitHub issues mode — Steps 1–6 below.
- **`feedback` argument:** Agent OS public feedback mode — Steps 7–10 below. Fetches open `feedback`-labeled issues from `designgrappler/agent-os`.

**Auto-loading on free-text planning phrases is disabled** for the `feedback` mode path — it is invoked explicitly via `/triage feedback` or programmatically by `/start-sprint`.

---

## Instructions

### Default Mode — Backlog + GitHub Issues

#### Step 1 — Resolve GitHub repo

Determine the target repo for the GitHub issues check:

1. Read `agent-setup.yml` from the project root. If a top-level `github_repo:` key is present, use its value as the repo (e.g. `owner/repo`).
2. If no `github_repo:` key is found (or the file does not exist), run:
   ```bash
   git remote get-url origin 2>/dev/null
   ```
   Parse the output to extract `owner/repo` — handle both HTTPS (`https://github.com/owner/repo`) and SSH (`git@github.com:owner/repo.git`) formats.
3. If neither source yields a repo, set repo to `(unresolved)` and continue — Step 2 will skip gracefully.

#### Step 2 — Fetch open GitHub issues (non-blocking)

If a repo was resolved and `gh` is available, run:
```bash
gh issue list --repo <resolved-repo> --state open 2>/dev/null
```

Collect all open issues (number, title, labels).

- If no repo was resolved, print `GitHub issues check skipped — no repo configured.` and continue.
- If `gh` is not installed, print `GitHub issues check skipped — gh not available.` and continue.
- If the command fails for any reason, print `GitHub issues check failed — continuing.` and continue.
- Never block or halt on this step.

#### Step 3 — Read backlog

Check whether `docs/backlog.md` exists. If it does, read the full file and note every item with its section heading. If the file does not exist, treat the backlog as empty and continue.

#### Step 4 — Cross-reference, deduplicate, group by theme

Compare the GitHub issues list from Step 2 against the backlog items from Step 3:

1. **Deduplicate** — if a backlog item and a GitHub issue clearly describe the same work (same domain + intent, even if worded differently), treat them as one candidate. Keep the GitHub issue number as the canonical reference; note the backlog item alongside it.
2. **Group by theme** — assign each candidate to a theme bucket based on its domain or subject area. Common themes: `observability`, `skill-sync`, `enforcement`, `sprint-workflow`, `agent-authoring`, `documentation`, `infrastructure`. Add new theme buckets as needed — do not force items into mismatched buckets.
3. **Prioritize within each theme** — lead with stop-and-fix items (active drift that gets worse every sprint), then missing-improvement items (value-add that does not degrade over time).

#### Step 5 — Emit triage report to chat

Output the triage report directly to chat. Do not write it to disk.

Format:

```
## Triage Report — <today's date>

### <Theme>
- [<source>] #<N> or B<N> — <title> — <one-sentence why it matters>
- ...

### <Theme>
- ...

---
Sources: GitHub issues (<resolved-repo> or skipped) + docs/backlog.md (<item count> items or absent)
```

Tag each item with its source: `[issue]` for GitHub issues, `[backlog]` for backlog-only items, `[both]` for deduplicated cross-references.

If both sources are empty or unavailable, emit: `Triage complete — no open issues and no backlog items found.`

#### Step 6 — Recommend sprint candidates (read-only)

After the report, emit a short recommendation block:

```
## Sprint Candidate Recommendations

Recommended for next sprint (stop-and-fix first):
1. ...
2. ...
3. ...

Queued (no active degradation):
- ...
```

This recommendation is advisory only. No changes are made to `docs/backlog.md` or any other file. Backlog promotion happens only when Tim explicitly confirms.

---

### Feedback Mode — Agent OS Public Feedback (`/triage feedback`)

#### Step 7 — Fetch open feedback issues

Run:
```bash
gh issue list --repo designgrappler/agent-os --label feedback --state open --json number,title,body,createdAt,author --limit 100
```

Capture the result as `FEEDBACK_ISSUES`.

If the command errors (auth failure, network issue), surface the `gh` stderr verbatim and stop. If `/start-sprint` is the caller, return the error string for its non-blocking handler.

#### Step 8 — Group by theme

For each issue, extract the `SUBJECT` field from the issue body. The `/submit-agent-os-feedback` template embeds it as:
```
**Subject:** <value>
```

Parse the `**Subject:**` line. If absent or not parseable, classify as `uncategorized`.

Group issues by subject value. For each cluster:
- Count of issues
- List of issue numbers
- One-line synthesis of the common pattern (inferred from titles and bodies)

#### Step 9 — Triage summary output

Display a markdown report:

```markdown
## Open Feedback (designgrappler/agent-os)

Total: <N> issues

### By subject

- **<subject>** (<count> issues) — #<num>, #<num> — common: <one-line pattern>
- **uncategorized** (<count> issues) — #<num>, #<num>

### Suggested track candidates

- <one-line proposal per cluster, framed as a Conductor-facing suggestion>

Conductor: which clusters become Sprint <N+1> tracks?
```

If `FEEDBACK_ISSUES` is empty, output:
```markdown
## Open Feedback (designgrappler/agent-os)

No open feedback issues.
```

#### Step 10 — Wait for Conductor decision

This step is read-only. It produces a triage report only. The Conductor decides which clusters become tracks for the next sprint and instructs the Architect from there.

---

## Hard Constraints

- **NEVER edit `docs/backlog.md`** — this skill is output-only. Any change to `docs/backlog.md` requires explicit Tim confirmation and must happen outside this skill.
- **Input sources (default mode): GitHub issues + `docs/backlog.md` only.** No Teams, Slack, or external connectors.
- **Input sources (feedback mode): `designgrappler/agent-os` GitHub issues with `feedback` label only.** Read-only — never invoke `gh issue close`, `gh issue edit`, or `gh issue comment`.
- **Report is emitted to chat, not written to disk.** Never write to `docs/context/` or any file in response to this skill's invocation.
- This skill never blocks or halts due to unavailable external sources — all external checks degrade gracefully.
