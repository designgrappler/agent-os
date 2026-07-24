---
name: track-close
description: Closes a single track — sets the exit record in tracks.md and reconciles the matching backlog item in backlog.md. Idempotent.
whenToUse: When a track is complete and you want to record its outcome, mark it DONE in tracks.md, and remove the corresponding backlog item if one exists.
---

## Instructions

### Inputs

| Input | Required | Description |
|---|---|---|
| `track-id` | required | The track identifier, e.g. `T49.1`. |
| `close-notes` | required | Outcome summary that becomes the `What happened` field in the exit record. |
| `next-steps` | optional | What the next actor should do. Defaults to `None` if omitted. |
| `backlog-title` | optional | Exact title of the backlog item to reconcile when no `(T<N>)` tag is present on the item. |

**Invocation examples:**
```
/track-close T49.1 "Canonical close skill authored and manifest registered."
/track-close T49.1 "Canonical close skill authored." next-steps="QA to run Bandit review."
/track-close T49.1 "Canonical close skill authored." backlog-title="Canonical close operation"
```

---

### Step 1 — Write the exit record to tracks.md (D1 — set, not append)

Read `docs/context/tracks.md`.

Locate the block whose heading matches `## Track <track-id>:` (case-insensitive on the ID portion).

**If the block is absent:** report "track not found; no action" and exit with code 0. Do not modify any file. Skip to Step 3.

**If the block exists:** set the following fields to exact values — do not append, do not add duplicate fields:

```
- **Status:** DONE
```
(The top-level `- **Status:**` line in the track block.)

Within the `- **Exit Record**` section of that block:
```
  - **Status:** DONE
  - **What happened:** <close-notes>
  - **Next steps:** <next-steps, or "None" if omitted>
```

Write the updated file back. The write is a set-not-append: locate the exact field line and replace its value. Never add a second instance of any field.

**Idempotency:**
- If all three exit-record fields already contain identical content to the incoming inputs, and the top-level `Status:` is already `DONE` → no write occurs. Report: "already closed — no change."
- If the block is already `DONE` but the incoming notes differ → overwrite the fields (explicit re-close). Report: "exit record updated."

---

### Step 2 — Reconcile backlog.md (D2/D3 — exact/tagged match, removal)

Read `docs/backlog.md`. If the file is absent, skip silently.

Find a bullet line that satisfies **either** of these exact-match conditions (in priority order):

1. **Tagged match:** the line contains the literal text `(T<track-id>)` — e.g. `(T49.1)`. Match is case-insensitive on the ID.
2. **Title match:** the line's leading bold text (the text between the first `**` pair) is a case-insensitive exact match to `backlog-title` (only checked if `backlog-title` was supplied).

**Match found:** remove the matched line from the file. If the matched item is already absent → no-op (idempotent, already removed).

**No confident match:** do not modify `backlog.md`. Report: "no matching backlog item — backlog unchanged."

**Constraint: never fuzzy-match.** If neither exact condition is met, treat as no match. No substring guessing.

---

### Step 3 — Report outcome

Output a short confirmation:

```
Track <track-id> closed.

tracks.md:   <"exit record set" | "already closed — no change" | "exit record updated" | "track not found; no action">
backlog.md:  <"item removed" | "no matching backlog item — backlog unchanged" | "item already absent — no change" | "skipped (file absent)">
```

---

## Trigger Contract

This section is a language-agnostic specification. Callers that cannot invoke this skill directly (e.g. a GitHub Actions YAML/bash workflow) must replicate these exact semantics.

### Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `track-id` | string | yes | Track identifier, e.g. `T49.1`. |
| `close-notes` | string | yes | Outcome summary for the `What happened` field. |
| `next-steps` | string | no | Next-actor instruction. Default: `"None"`. |
| `backlog-title` | string | no | Exact title for backlog lookup when no `(T<N>)` tag is present. |

### What is written

**`docs/context/tracks.md`** — the following fields are set to exact values within the matching `## Track <track-id>:` block:

```
- **Status:** DONE
```
(top-level Status field in the block)

```
- **Exit Record**
  - **Status:** DONE
  - **What happened:** <close-notes>
  - **Next steps:** <next-steps>
```

The write operation is **set, not append.** Running twice with identical inputs produces byte-identical file state.

**`docs/backlog.md`** (conditional) — the matched bullet line is removed. No other lines are modified.

### What is NOT touched

- `skills-manifest.json` — no version bump.
- `bun run build` — not invoked.
- `docs/archive/` — no archiving.
- `git` — no commit, no stage, no push.
- `docs/context/plan.md` — not modified.
- Any file not listed above.

### Canonical exit-record shape

```markdown
- **Exit Record**
  - **Status:** DONE
  - **What happened:** <close-notes verbatim>
  - **Next steps:** <next-steps, or "None">
```

Field order is fixed. No additional fields are inserted. No trailing whitespace after the value.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | Closed, already-closed (no-op), or not-found degrade — all non-error outcomes. |
| non-zero | Malformed input (missing required field, unreadable file). Reserved; not currently used by in-session invocation. |

---

## Idempotency

This skill uses **set-not-append** semantics throughout:

- **Already closed, same content:** `tracks.md` is not written; `backlog.md` lookup still runs (idempotent if item already removed).
- **Already closed, different content:** the exit record fields are overwritten. This is an explicit re-close, not a duplicate write.
- **Backlog item already absent:** no write to `backlog.md`; operation is a no-op.
- **Track block absent (e.g. sprint archived):** no write to `tracks.md`; graceful degrade — reports "track not found; no action" and exits 0.

Running `/track-close` N times with identical inputs produces the same file state as running it once.
