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

## Hard Constraints
- **Read-only by default**: Do not modify source files. Report findings only — remediation is the developer's job.
- **Zero-pause**: When you announce a scan step (e.g., "Running secrets sweep now"), trigger the tool call in the same turn.
- **Severity discipline**: Every finding must carry a severity level. Do not pad with Low findings to appear thorough.
- **Agent OS aware**: If `CLAUDE.md` exists, cross-reference findings against the project's declared security constraints. If it does not exist, skip that step.
- **Never silently return CLEAR**: If a required scanner is absent, the step is SKIPPED — not passed. CLEAR verdicts require all steps to complete successfully.

---

## Scan Protocol

Run the following checks in order. Do not skip a step because a prior step found issues — complete all steps, then report.

### Step 1 — Secrets Sweep

**Scanner detection (run first):**
```bash
command -v gitleaks >/dev/null 2>&1 && echo "GITLEAKS_PRESENT" || echo "GITLEAKS_ABSENT"
```

**If `GITLEAKS_PRESENT`:** run the sweep:
```bash
gitleaks detect --source . --no-banner
```
Capture all findings. Any detected secret is a Critical finding regardless of file type.

**If `GITLEAKS_ABSENT`:** do NOT proceed with this step. Surface the following and mark Step 1 as SKIPPED in the report:
```
Step 1 SKIPPED — gitleaks not installed.
Install: brew install gitleaks  (macOS)  |  https://github.com/gitleaks/gitleaks#installing
Re-run /audit-security after installing to get a complete secrets scan.
```

Also check (regardless of gitleaks availability):
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

**Scanner detection (run first):**
```bash
command -v semgrep >/dev/null 2>&1 && echo "SEMGREP_PRESENT" || echo "SEMGREP_ABSENT"
```

**If `SEMGREP_PRESENT`:** run the scan:
```bash
semgrep scan --config auto
```
Capture all findings. Map semgrep severity levels to the report tiers: ERROR → High or Critical (based on rule metadata); WARNING → Moderate; INFO → Low.

**If `SEMGREP_ABSENT`:** do NOT proceed with this step. Surface the following and mark Step 4 as SKIPPED in the report:
```
Step 4 SKIPPED — semgrep not installed.
Install: pip install semgrep  |  brew install semgrep  |  https://semgrep.dev/docs/getting-started/
Re-run /audit-security after installing to get a complete code pattern scan.
```

### Step 5 — Agent OS Gate (skip if Agent OS not installed)
If `CLAUDE.md` exists:
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
