---
name: submit-agent-os-feedback
description: File a structured issue against the designgrappler/agent-os public mirror. Use when the user says "file feedback", "report an Agent OS issue", "this Agent OS skill is broken", or wants to report a bug or improvement in Agent OS.
---
# Submit Agent OS Feedback

Files a structured GitHub issue against `designgrappler/agent-os` using the user's existing `gh` auth session.

## Trigger
When the user runs `/submit-agent-os-feedback` or says:
- "file feedback"
- "report an Agent OS issue"
- "this Agent OS skill is broken"

---

## Phase 1 — Read version header

Read `release-version` from the canonical manifest:

1. **Primary (URL):** Fetch `https://raw.githubusercontent.com/designgrappler/agent-os/main/skills-manifest.json` and parse `.release-version`.
2. **Fallback (local clone):** If the fetch fails, read `~/Developer/agent-os-private/skills-manifest.json` and parse `.release-version`.
3. **If both fail:** Stop. Display: `Could not resolve Agent OS version — URL fetch failed and local clone not found at ~/Developer/agent-os-private/skills-manifest.json. Resolve access and re-run /submit-agent-os-feedback.`

Display to the user before any prompt:
```
Filing feedback against Agent OS <release-version>
```

**Hard constraint:** Always include the version header (`<release-version>`) at the top of the issue body — this is the single load-bearing requirement.

---

## Phase 2 — Wizard

Ask three sequential questions. Do not proceed to the next question until the current one is answered.

1. **"What happened? (one-paragraph description)"** → captured as `WHAT_HAPPENED`
2. **"Which skill or agent does this concern? (e.g. `update-agent-os`, `architect`, or `general`)"** → captured as `SUBJECT`
3. **"Optional context — recent commands, error messages, or transcript snippets (paste or skip)"** → captured as `CONTEXT` (may be empty; "skip" or empty reply = `CONTEXT` is `(none provided)`)

---

## Phase 3 — Secret detection + Preview

Before rendering any preview, scan `WHAT_HAPPENED` and `CONTEXT` for secret-shaped strings. Check each pattern:

| Pattern | Description |
|---|---|
| `[A-Z][A-Z0-9_]{3,}=\S+` | Env-var assignment (e.g. `SECRET_KEY=abc123`) |
| `Bearer\s+\S+` | Authorization header token |
| `sk-[A-Za-z0-9]{16,}` | OpenAI-style secret key |
| `ghp_[A-Za-z0-9]{16,}` | GitHub personal access token |
| `xox[baprs]-[A-Za-z0-9-]{10,}` | Slack token |
| `AKIA[0-9A-Z]{12,}` | AWS access key |
| `[A-Za-z0-9_\-]{40,}` adjacent to `key`, `token`, `secret`, or `password` | Generic long credential |

**On any match: HARD BLOCK.**
- Display the matched span(s) clearly.
- Instruct the user to remove the string and re-run `/submit-agent-os-feedback`.
- Do NOT render a preview.
- Do NOT offer "submit anyway."
- There is no override path. The user must remove the matching string before submission can proceed.

If no match, build the issue body using this fixed template:

```markdown
**Agent OS version:** <release-version>
**Subject:** <SUBJECT>
**What happened:**
<WHAT_HAPPENED>

**Context:**
<CONTEXT or "(none provided)">

---
*Filed via /submit-agent-os-feedback from <project-name>.*
```

Where `<project-name>` is the last path component of `$CLAUDE_PROJECT_DIR` (or the current working directory if unavailable).

**Title:** `[feedback] <first 60 chars of WHAT_HAPPENED>`

Display the full preview to the user with the title and body. Ask:
```
Submit, edit, or cancel?
```

- **Submit** → proceed to Phase 4.
- **Edit** → return to Phase 2; allow the user to revise any field.
- **Cancel** → stop. No issue is created.

---

## Phase 4 — Submit

**Never submit without explicit user "submit" confirmation in Phase 3.**

1. **Defensive label check:** Run:
   ```
   gh label list --repo designgrappler/agent-os
   ```
   Parse the output. If `feedback` is not in the list, stop:
   ```
   The "feedback" label does not exist on designgrappler/agent-os. Ask the repo owner to create it, then re-run /submit-agent-os-feedback.
   ```

2. **Submit:** Run:
   ```
   gh issue create --repo designgrappler/agent-os --title "<title>" --body "<body>" --label feedback
   ```
   Capture the resulting issue URL. Display it to the user:
   ```
   Issue filed: <URL>
   ```

3. **On error (label missing, auth failure, network):** Surface the `gh` stderr verbatim. Stop. Do not retry without explicit user confirmation.

---

## Hard Constraints

- Never submit without explicit user "submit" confirmation in Phase 3.
- **Hard block on secret-shaped strings — no override path.** User must remove the matching string before submission can proceed.
- Always include the version header (`<release-version>`) at the top of the issue body — this is the single load-bearing requirement.
- Always invoke `gh label list --repo designgrappler/agent-os` before submitting and surface a clear remediation if `feedback` is absent.
