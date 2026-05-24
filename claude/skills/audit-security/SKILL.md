---
name: audit-security
description: Scans a project for security vulnerabilities, hardcoded secrets, insecure patterns, and dependency risks.
---
# Audit Security
Scans a project for security vulnerabilities, hardcoded secrets, insecure patterns, and dependency risks. Works on any project — no Agent OS installation required. If Agent OS is present, findings are written to `tracks.md` and block further handoffs until critical issues are resolved.

## When to Run
- Before any production deployment or PR merge
- After a specialist completes a track involving auth, data handling, or external APIs
- On-demand for any project, with or without Agent OS installed

---

## Rules
- **Read-only by default**: Do not modify source files. Report findings only — remediation is the developer's job.
- **Zero-pause**: When you announce a scan step (e.g., "Running secrets sweep now"), trigger the tool call in the same turn.
- **Severity discipline**: Every finding must carry a severity level. Do not pad with Low findings to appear thorough.
- **Agent OS aware**: If `AGENTIC.md` exists, cross-reference findings against the project's declared security constraints. If it does not exist, skip that step.

---

## Scan Protocol

Run the following checks in order. Do not skip a step because a prior step found issues — complete all steps, then report.

### Step 1 — Secrets Sweep
Search for hardcoded credentials, API keys, tokens, and passwords.

```bash
# Patterns to grep for across all source files:
grep -rn --include="*.{ts,tsx,js,jsx,py,go,rb,env,yaml,yml,json,toml}" \
  -E "(api_key|apikey|secret|password|token|private_key|access_key)\s*=\s*['\"][^'\"]{8,}" .
```

Also check:
- `.env` files committed to the repo (should be in `.gitignore`)
- Any hardcoded URLs containing credentials (e.g., `postgres://user:pass@host`)

### Step 2 — Dependency Audit
Run the appropriate package audit command for the detected stack.

| Stack | Command |
|---|---|
| Node.js / Bun | `npm audit --audit-level=moderate` or `bun audit` |
| Python | `pip-audit` or `safety check` |
| Ruby | `bundle audit` |
| Go | `govulncheck ./...` |

Record the count of Critical, High, and Moderate vulnerabilities. Skip Low unless total count is zero.

### Step 3 — Configuration Review
Check for insecure configuration patterns:
- CORS set to `*` in production config
- Missing auth middleware on routes that handle sensitive data
- Debug mode or verbose error output enabled outside of development
- `.env.example` containing real credentials instead of placeholders
- `console.log` statements that output sensitive data

### Step 4 — Code Pattern Scan
Scan for common vulnerability patterns:

| Pattern | Risk |
|---|---|
| `eval(`, `exec(`, `Function(` on user input | Remote code execution |
| Unparameterized SQL strings | SQL injection |
| `innerHTML =` / `dangerouslySetInnerHTML` | XSS |
| `Math.random()` for tokens or IDs | Insecure randomness |
| Missing `await` on auth checks | Auth bypass |
| Unvalidated redirect URLs | Open redirect |

### Step 5 — Agent OS Gate (skip if Agent OS not installed)
If `AGENTIC.md` exists:
- Read the security constraints declared there
- Flag any findings that violate those constraints as **Critical** regardless of generic severity
- If any Critical findings exist, write a blocked status to `tracks.md` before reporting

---

## Findings Report

Always produce the full report, even if findings are empty.

```
## Security Audit Report
**Project:** [project name or current directory]
**Date:** [date]
**Agent OS:** [Installed / Not installed]

---

### Summary
| Severity | Count |
|---|---|
| 🔴 Critical | [N] |
| 🟠 High | [N] |
| 🟡 Moderate | [N] |
| 🔵 Low | [N] |

**Overall verdict:** CLEAR / REVIEW REQUIRED / BLOCKED

---

### Findings

#### 🔴 Critical
[Finding 1]
- **Location:** [file:line or package name]
- **Issue:** [what it is]
- **Remediation:** [specific fix]

[Repeat for each critical finding]

#### 🟠 High
[Same format]

#### 🟡 Moderate
[Same format — omit section if empty]

---

### Agent OS Status
[If installed: "1 Critical finding written to tracks.md — handoffs blocked until resolved." ]
[If not installed: "Agent OS not detected — findings not written to project state."]
```

**Verdict rules:**
- **BLOCKED** — any Critical finding
- **REVIEW REQUIRED** — any High finding, no Critical
- **CLEAR** — no Critical or High findings

## Trigger
Run `/audit-security` at any time. Works with or without Agent OS installed.
