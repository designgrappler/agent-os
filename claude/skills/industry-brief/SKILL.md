---
name: industry-brief
description: Surveys recent AI industry developments across two focus areas (agent orchestration, frontend/design workflows) and writes a structured, tagged brief to docs/context/industry-brief.md. On-demand slash command; do not invoke on an already-current brief without need.
whenToUse: When you need an up-to-date snapshot of AI industry developments relevant to agent-os. Invoke on demand with /industry-brief. Output is written to docs/context/industry-brief.md (overwrite, single living file) — never dumped to chat. Do not modify an existing brief unless you are re-running the full skill; do not append partial findings to the brief file outside a skill run.
---

# Industry Brief

Surveys recent AI industry developments across two focus areas and writes a structured five-section brief. All findings carry live source URLs. No finding is asserted without a located source.

---

## Sources

### Focus Area A — Agent Orchestration

| Source | Fetch URL | Notes |
|---|---|---|
| GitHub Trending (agent/MCP/LLM topics) | `https://github.com/trending?since=weekly&spoken_language_code=en` | Filter by keyword in results |
| arXiv cs.AI recent submissions | `https://arxiv.org/list/cs.AI/recent` | Scan titles/abstracts for agent, orchestration, tool-use |
| Hacker News front page | `https://news.ycombinator.com/` | Keyword scan: agent, orchestration, MCP, tool-use |
| Anthropic Claude Code CHANGELOG | `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` | Canonical release notes |
| Simon Willison's blog — agents tag | `https://simonwillison.net/tags/agents/` | High-signal commentary on agent tooling |

Signal/noise filter: prefer repos with ≥500 stars or papers with institutional affiliation; exclude pure demos with no production usage.

### Focus Area B — Frontend/Design Workflows

| Source | Fetch URL | Notes |
|---|---|---|
| GitHub Trending (design-system/ui-generation topics) | `https://github.com/trending?since=weekly&spoken_language_code=en` | Filter for design-system, ai-ui, figma topics |
| Figma release notes | `https://www.figma.com/release-notes/` | Official Figma feature releases |
| news.smol.ai | `https://news.smol.ai/` | Aggregates Discord/Reddit/X AI news in daily digest |
| arXiv cs.HC / cs.AI (UI/design topics) | `https://arxiv.org/list/cs.HC/recent` | Human-computer interaction, AI-assisted design |

Signal/noise filter: prefer tools with active production use; exclude one-off demos; flag design-system AI tooling even without star counts if from known publishers (Figma, Vercel, Adobe).

---

## Phase 0 — Staleness Check

Before fetching any sources, check whether the existing brief is current.

1. Read `docs/context/industry-brief.md`. Extract the run timestamp from the Summary section (format: `Run timestamp: <ISO-8601>`).
2. If the file does not exist or the timestamp cannot be parsed, treat as "never run" → proceed to Phase 1.
3. Compute age in days from the timestamp to today.
4. If age < 14 days: skip Phases 1–4 entirely. Emit: `Brief is current (last run <date>, <N> days ago) — skipping survey.` Then proceed directly to Phase 5 (cron renewal).
5. If age ≥ 14 days: proceed to Phase 1 normally.

---

## Phase 1 — Survey

For each focus area, execute the batch-query strategy. **Hard limit: ≤4 WebFetch calls per focus area.** Prioritize sources with highest expected signal density.

### Phase 1A — Agent Orchestration Survey

Execute in this order (skip with noted reason if unreachable/auth-blocked):

1. Fetch `https://github.com/trending?since=weekly&spoken_language_code=en` — scan for repos tagged or named with: `agent`, `mcp`, `llm`, `orchestration`, `tool-use`. Record repo name, star count, and description for repos matching ≥1 keyword.
2. Fetch `https://news.ycombinator.com/` — scan story titles for: `agent`, `MCP`, `orchestration`, `tool use`, `Claude`, `Anthropic`, `OpenAI agents`. Record title, URL, and point count for matching stories.
3. Fetch `https://simonwillison.net/tags/agents/` — scan for posts published within last 14 days. Record post title, date, and URL for each.
4. Fetch `https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` — scan for entries added within last 14 days. Record feature name and description for each.

For each fetched source: record the source URL alongside every candidate finding. If a source returns 403/auth block or is unreachable, note: `[SKIP — unreachable: <URL>]` and do not fabricate a finding.

### Phase 1B — Frontend/Design Workflows Survey

Execute in this order:

1. Fetch `https://news.smol.ai/` — scan for entries mentioning: `design`, `UI generation`, `Figma`, `design system`, `component`, `frontend AI`. Record headline, date, and URL.
2. Fetch `https://www.figma.com/release-notes/` — scan for release notes published within last 14 days. Record feature name, date, and URL.
3. Fetch `https://github.com/trending?since=weekly&spoken_language_code=en` — scan for repos tagged or named with: `design-system`, `ui-generation`, `figma`, `component-ai`, `v0`. Record repo name, star count, and description.
4. Fetch `https://arxiv.org/list/cs.HC/recent` — scan titles/abstracts for: `UI generation`, `design automation`, `AI design`, `layout generation`. Record paper title, authors, and abstract URL.

Same skip-and-note rule applies for unreachable sources.

---

## Phase 2 — Synthesize

Assemble the five required sections from Phase 1 findings. Apply relevance tags from the vocabulary below. Every bullet must carry: (1) a source URL from Phase 1, (2) exactly one tag.

### Tag Vocabulary

| Tag | When to use |
|---|---|
| `[new-capability]` | A net-new tool, API, or model capability not previously available |
| `[pattern-shift]` | A change in how the community approaches a problem (not just a new tool) |
| `[tooling-update]` | A release, version bump, or configuration change to an existing tool |
| `[deprecation]` | A tool, API, or pattern being retired or superseded |
| `[backlog-candidate]` | Finding directly relevant to agent-os — would benefit from a backlog item |

A finding may not carry more than one tag. Choose the most specific match.

### Example Entry Format

```
- Model context window extended to 256k tokens. `[tooling-update]` — [Anthropic CHANGELOG](https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md)
```

### Five Required Sections (fixed order)

Assemble the brief in this exact section order:

1. **Summary** — one paragraph: date range surveyed, sources count (total fetched, total returning signal), run timestamp (ISO-8601).
2. **Agent Orchestration Findings** — one bullet per finding, format per example entry above.
3. **Frontend/Design Findings** — one bullet per finding, same format.
4. **Agent-OS Implications** — prose + bullets: what do these findings mean specifically for agent-os? Flag new patterns, deprecated approaches, capability gaps. Do not repeat findings — interpret them.
5. **Watch Items** — emerging signals noted but not yet actionable; no tag required; source URL still required.

If a section has no findings (all sources returned empty signal), write: `No findings this run — all sources returned no matching signal.`

---

## Phase 3 — Write

Overwrite `docs/context/industry-brief.md` with the assembled five-section brief.

- Create the file and any missing parent directories on first run.
- Do NOT print the brief body to chat.
- Do NOT modify any other file in this phase.

After writing, emit exactly one confirmation line:

```
Brief written to docs/context/industry-brief.md — <N> findings across <M> sources.
```

---

## Phase 4 — Backlog Candidate Extraction

Scan the assembled brief for all findings tagged `[backlog-candidate]`.

For each `[backlog-candidate]` finding:

1. Format a candidate item:
   ```
   - [backlog-candidate] <finding text> — source: <URL> — from industry-brief run <ISO date>
   ```
2. Append it under the `## AI Industry Signals` section in `docs/backlog.md`.
   - If the `## AI Industry Signals` section does not exist, create it at the end of the file.
   - Append-only — never rewrite or delete existing backlog content.

If no `[backlog-candidate]` findings exist in this run, skip this phase silently.

**Note:** Human triage and promotion of these candidates (assigning `B<n>` IDs, moving to domain sections) is defined in T87.3 and is never automated here.

**Sprint-time constraint:** The `docs/backlog.md` file is protected by a hook that blocks all writes during an active sprint. If Phase 4 is blocked by this hook, emit: `[Phase 4 deferred — backlog is locked during active sprint. Re-run /industry-brief outside sprint, or promote candidates manually.]` and list the deferred candidates in chat only (not written to any file). This is the expected behavior during sprint-open periods.

---

## Confirm

After completing all phases, emit the Phase 3 confirmation line and a brief Phase 4 status note. No other output to chat.

---

## Phase 5 — Cron Renewal

This phase always runs regardless of whether the survey ran (i.e., runs after a staleness-skip and after a full survey).

1. Re-create the weekly cron using `CronCreate`:
   - `cron: "57 8 * * 1"`
   - `durable: true`
   - `recurring: true`
   - `prompt: "/industry-brief"`
2. Do not attempt to delete any prior cron job — it may already be expired.
3. Emit: `Cron renewed — next run Monday 8:57am local.`

---

## Hard Constraints

- **No fabricated citations.** Every finding must carry a live source URL from a fetch actually performed in Phase 1. If a source could not be fetched, skip it with a noted reason. Do not assert claims without a located source. If you would write a finding without a URL: STOP and flag it as a gap.
- **Flag-don't-assert on undocumented behavior.** If a finding relies on undocumented behavior — an API guarantee, format convention, or tool parameter not confirmed in the fetched source — flag it: `[Unverified — source did not confirm this. Treating as a gap.]`
- **Write-only to two targets.** This skill writes only to `docs/context/industry-brief.md` (Phase 3) and `docs/backlog.md` (Phase 4, if not blocked). Do not modify any other file — no lifecycle skills, no agents, no other context files.
- **Overwrite-only on brief.** `docs/context/industry-brief.md` is always fully overwritten each run. Never append partial findings to it mid-run.
- **Append-only on backlog.** `docs/backlog.md` is append-only under `## AI Industry Signals`. Never rewrite existing backlog content.
- **Sprint-open trigger and backlog promotion workflow are owned by T87.3.** Do not implement scheduling, sprint-open checks, or `B<n>` auto-promotion here.
- **No brief body in chat.** Phase 3 content goes to the file only. Confirm line only in chat.

---

## Downstream — Weekly Automation & Promotion

### Invocation

- **On demand:** run `/industry-brief` at any time. Output overwrites `docs/context/industry-brief.md`.
- **Bi-weekly survey:** the skill surveys only when the existing brief is ≥14 days old (Phase 0 staleness check). If the brief is current, Phases 1–4 are skipped and only Phase 5 runs.
- **Weekly cron:** a durable cron fires every Monday ~8:57am local. Because the staleness gate allows a full survey only every other week, the cron fires weekly but triggers a full survey roughly every other run.
- **Self-renewing:** Phase 5 re-creates the cron at the end of every run — no manual renewal needed.
- To view the active cron: `CronList`. To cancel the current job: `CronDelete` with the job ID shown in `CronList`.

### Backlog Candidate Promotion

`[backlog-candidate]` findings are staged by Phase 4 under `## AI Industry Signals` in `docs/backlog.md` (append-only; write is deferred during active sprints). Promotion to real backlog items requires explicit Tim confirmation:

1. Open `docs/backlog.md` and review items under `## AI Industry Signals`.
2. For each item to promote: assign the next sequential `B<n>` ID (scan existing B-IDs, take max+1).
3. Move the item into the correct domain section (e.g. `## Agent OS / Workflow`).
4. Strip the `[backlog-candidate]` tag; retain the source URL.
5. Unconfirmed candidates persist in `## AI Industry Signals` until the next review, or are dropped only on Tim's explicit word.

No candidate is ever auto-promoted — promotion always requires an explicit confirmation step.
