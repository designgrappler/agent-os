---
name: triage-feedback
description: Read-only triage of open Agent OS feedback issues on designgrappler/agent-os. Groups issues by subject cluster and outputs a sprint-planning summary. Invoked by /start-sprint or explicit user command.
disable-model-invocation: true
---
# Triage Feedback

Read-only triage of open `feedback`-labeled issues on `designgrappler/agent-os`. Groups by subject cluster and outputs a markdown summary for sprint planning.

## Trigger

Invoked in two ways only:
1. **Explicit user command:** `/triage-feedback`, "triage feedback", "review feedback issues", "what feedback is open"
2. **Programmatic invocation by `/start-sprint`** as part of its information-gathering phase.

**Auto-loading on free-text planning phrases is explicitly disabled** (`disable-model-invocation: true` in frontmatter). This skill never auto-loads from general chat.

---

## Phase 1 — Fetch

Run:
```
gh issue list --repo designgrappler/agent-os --label feedback --state open --json number,title,body,createdAt,author --limit 100
```

Capture the result as `FEEDBACK_ISSUES`.

If the command errors (auth failure, network issue), surface the `gh` stderr verbatim and stop. If `/start-sprint` is the caller, return the error string for its non-blocking handler.

---

## Phase 2 — Group by theme

For each issue, extract the `SUBJECT` field from the issue body. The `/submit-agent-os-feedback` template embeds it as:
```
**Subject:** <value>
```

Parse the `**Subject:**` line. If absent or not parseable, classify as `uncategorized`.

Group issues by subject value. For each cluster:
- Count of issues
- List of issue numbers
- One-line synthesis of the common pattern (inferred from titles and bodies)

---

## Phase 3 — Triage summary output

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

---

## Phase 4 — Wait for Conductor decision

This skill is read-only. It produces a triage report only. The Conductor decides which clusters become tracks for the next sprint and instructs the Architect from there.

---

## Hard Constraints

- **Read-only.** Never invoke `gh issue close`, `gh issue edit`, or `gh issue comment`.
- **Never write to `docs/context/`.** Output is chat-displayed text only — not a written artifact.
- Never modify any file in response to this skill's invocation.
