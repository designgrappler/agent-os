---
name: streamline-approvals
description: Scans recent Claude Code transcripts, identifies common read-only tool calls, and writes an optimized allowlist to `~/.claude/settings.json` (global) to reduce permission prompts across all projects.
---
# Streamline Approvals
Scans recent Claude Code transcripts, identifies common read-only tool calls, and writes an optimized allowlist to `~/.claude/settings.json` (global) to reduce permission prompts across all projects. Focuses exclusively on read-only operations — nothing that writes, deletes, pushes, or installs.

## Profile Argument-Detection (runs before everything else)

If the skill is invoked with an argument, process it here and **exit** — do NOT continue to the transcript scanner.

### `auto` argument
1. Read `~/.claude/settings.json`. If the file does not exist, create it with `{"permissions":{"allow":[]}}`. If `permissions.allow` is missing, create it as an empty array.
2. Use `jq` to append `"Agent"` and `"Task"` to `permissions.allow` if not already present. De-duplicate. Write back atomically (write to a temp file in the same directory, then `mv` — never use `>` redirect).
3. Verify: `jq '.permissions.allow | index("Agent")' ~/.claude/settings.json` must return a non-null index. Same for `"Task"`. Verify all other top-level keys are unchanged.
4. Report: `Applied 'auto' profile. Agent and Task allowlisted in ~/.claude/settings.json. Sprint Coordinator Agent spawns will proceed without per-call prompts.`
5. Exit. Do not run the transcript scanner.

### `manual` argument
1. Read `~/.claude/settings.json`. If the file does not exist or `permissions.allow` is missing or empty, report `Already in 'manual' posture — no Agent allowlist entry present.` and exit zero (idempotent).
2. Use `jq` to remove any element of `permissions.allow` equal to `"Agent"` or `"Task"`. Preserve all other entries. De-duplicate. Write back atomically.
3. Verify: `jq '.permissions.allow | index("Agent")' ~/.claude/settings.json` must return `null`. Same for `"Task"`. Verify other entries are preserved.
4. Report: `Applied 'manual' profile. Agent allowlist entry removed from ~/.claude/settings.json. Sprint Coordinator Agent spawns will now require a per-call permission prompt.`
5. Exit. Do not run the transcript scanner.

### Unknown argument
If the argument is any other non-empty string, surface this error and exit — do NOT run the transcript scanner:
```
Unknown profile: <arg>. Valid profiles: auto, manual. Run /streamline-approvals (no argument) for the transcript scanner.
```

### No argument
Fall through to the transcript scanner (Steps 1–10 below).

---

## Auto-Trigger
Invoke when the user says:
- "reduce permission prompts", "fewer prompts", "stop asking me about permissions"
- "add to allowlist", "update settings allowlist"
- "scan transcripts for permissions"

---

## Rules
- **Read-only only.** Never allowlist a command that writes, deletes, renames, pushes, merges, installs, or runs a build/test with side effects. When in doubt, leave it out.
- **No arbitrary code execution.** Never allowlist a wildcard pattern for interpreters (`python3`, `node`, `bun`, `deno`, `ruby`, etc.), shells (`bash`, `sh`, `zsh`, `eval`, `exec`, `ssh`), package runners (`npx`, `bunx`, `uvx`), or task-runner wildcards (`bun run *`, `npm run *`, `make *`). An exact form like `Bash(bun run typecheck)` is fine; `Bash(bun run *)` is not.
- **Merge, never overwrite.** Preserve all existing keys and existing `permissions.allow` entries. De-duplicate. Never reorder unrelated fields.
- **Global settings.** Write to `~/.claude/settings.json` — not `.claude/settings.json`, not `.claude/settings.local.json`. Patterns found across multiple projects belong globally; writing per-project leaves prompts unresolved everywhere else.
- **Scripts directory scope.** When Step 9a extracts a compound command into a script, write the script to `scripts/<name>.sh` inside the current project's working directory (the per-project repo). Do not write extracted scripts to global paths (`~/.claude/`, `/usr/local/bin/`, etc.). The `scripts/` directory and its contents belong to the project repo, not the global Agent OS install.

---

## Protocol

### Step 1 — Locate transcripts
Session transcripts live at `~/.claude/projects/<sanitized-cwd>/*.jsonl`. Each line is a JSON object. Tool calls appear as `assistant` messages with `message.content[]` entries of `type: "tool_use"`. The `name` field identifies the tool (e.g. `"Bash"`, `"mcp__slack__slack_read_thread"`); for Bash, `input.command` is the shell string.

Scan recent transcripts across the user's full projects dir — not just the current project — so the allowlist reflects actual usage. Cap at the 50 most-recently-modified JSONL files.

### Step 2 — Extract tool-call frequencies
- **Bash calls:** parse `input.command` with the following normalizations before recording:

  1. **Env-var prefixes** — if the command starts with `KEY=value` assignments (e.g. `GH_HOST=github.com gh run list`), strip the prefix to identify the base command, but record the original prefix separately. The base command is used for read-only classification; the prefix is preserved in the generated pattern (e.g. `Bash(GH_HOST=github.com gh *)`).

  2. **`git -C <path> <subcommand>`** — if the command matches `git -C <path> <subcommand> ...`, extract `<subcommand>` as the operative token. Record as `git -C * <subcommand>` for classification. These are NOT auto-allowed by Claude Code even when the subcommand is read-only — they need explicit allowlist entries.

  3. **Compound commands** (`&&`, `||`, `|`, `;`, `for`/`while` loops, subshells) — flag these separately as "compound — cannot allowlist as-is." Do not attempt to parse constituent commands. Normalize whitespace (collapse all runs of whitespace to a single space, trim leading/trailing whitespace) to produce a canonical form for each compound, then count occurrences of each canonical form across all scanned transcripts. Collect the resulting canonical-form → count map in a separate list for Step 9a and the Step 10 gap report.

  4. **Everything else** — take the leading command token (handling `sudo`, `timeout`). Record the command + first subcommand pair (e.g. `git status`, `gh pr view`, `ls`).

- **MCP calls:** record the full tool name (e.g. `mcp__slack__slack_read_thread`).
- **Built-in tool calls:** record other tool names that aren't Bash or MCP — specifically `WebFetch`.

Count occurrences across all scanned transcripts.

### Step 3 — Filter to read-only (plus workspace management)
Keep commands that don't mutate state, **plus** workspace management operations that are safe to allowlist even though they touch the filesystem. Examples of safe read-only commands: `git status/log/diff/show/branch`, `gh pr view/list/diff`, `gh issue view/list`, `gh run view/list`, `rg`, `grep`, `find`, `bun run typecheck`, `bun run lint`, `docker ps/logs`, `kubectl get/describe`, `ps`, `env`, `printenv`, `WebFetch`, any MCP tool with `read`/`get`/`list`/`search`/`view`/`retrieval` in its name.

Workspace management operations to include: `git worktree add/remove/list/prune/move/lock/unlock` — these manage local working trees and are safe to allowlist as `Bash(git worktree *)`.

### Step 4 — Drop auto-allowed commands
These never prompt in Claude Code — skip them:

- **Always auto-allowed (any args):** `cat`, `head`, `tail`, `wc`, `stat`, `ls`, `cd`, `find`, `diff`, `echo`, `printf`, `date`, `which`, `file`, `grep`, `egrep`, `fgrep`, `rg`, `jq`, `sort`, `uniq`, `tree`, `ps`, `du`, `df`, and most other standard read-only Unix utilities.
- **Auto-allowed with zero args only:** `pwd`, `whoami`, `alias`.
- **All git read-only subcommands:** `git status`, `git log`, `git diff`, `git show`, `git blame`, `git branch`, `git tag`, `git remote`, `git ls-files`, `git stash list`, `git reflog`, `git worktree list`, etc.
- **`git worktree add/remove/prune/move/lock/unlock` — NOT auto-allowed.** Even though worktree management is safe to allowlist, only `git worktree list` is auto-allowed. All other `git worktree` subcommands prompt and should be suggested as `Bash(git worktree *)`.
- **`git -C <path> <subcommand>` — NOT auto-allowed.** Even when the subcommand is read-only, Claude Code does not auto-allow `git -C` variants (the `-C` flag shifts the subcommand to the third token position). Do not drop these — let them flow through as allowlist candidates with pattern `Bash(git -C * <subcommand> *)`.
- **All gh read-only subcommands:** `gh pr view/list/diff/checks/status`, `gh issue view/list`, `gh run view/list`, `gh repo view`, `gh release view/list`, `gh auth status`, etc.
- **Docker read-only:** `docker ps`, `docker images`, `docker logs`, `docker inspect`.

**Source of truth:** If you're unsure whether a command is already covered, grep `src/tools/BashTool/readOnlyValidation.ts` (`READONLY_COMMANDS`, `READONLY_NOARGS`, `READONLY_EXACT`, `COMMAND_ALLOWLIST`) and `src/utils/shell/readOnlyCommandValidation.ts` (`GIT_READ_ONLY_COMMANDS`, `GH_READ_ONLY_COMMANDS`, `DOCKER_READ_ONLY_COMMANDS`) in the Claude Code repo. Never guess — check the source.

### Step 5 — Pick the pattern form
Use the narrowest pattern that covers observed usage:
- Many variants of the same Bash command (`git log`, `git log --oneline`, `git log main..HEAD`) → `Bash(git log *)` (space before `*` is required for prefix matching)
- Single exact Bash invocation → `Bash(foo)` with no wildcard
- **Env-var prefixed commands** — preserve the prefix in the pattern. `GH_HOST=github.com gh run list` → `Bash(GH_HOST=github.com gh *)`. Use a wildcard after the base command if multiple variants appear; use an exact form if only one invocation was observed.
- **`git -C` variants** — use `Bash(git -C * <subcommand> *)`. One entry per distinct read-only subcommand observed (e.g. `Bash(git -C * status *)`, `Bash(git -C * log *)`).
- **MCP tools — prefer server-level entries.** If multiple tools from the same server appear (e.g. `mcp__figma__get_file` and `mcp__figma__get_component`), use the server prefix `mcp__figma` — it covers all tools from that server and avoids a growing list of individual entries. Use a specific full tool name only if you want to allow one tool from a server while leaving others unapproved.
- **`WebFetch`** — use the bare tool name verbatim.

### Step 6 — Cross-reference current allowlist
Read `~/.claude/settings.json` and extract the current `permissions.allow` entries. For each candidate pattern from Steps 3–5, mark it as one of:
- **Already covered** — an existing allowlist entry already matches it (exact or prefix). Skip entirely — don't re-add or surface.
- **Approved manually** — the pattern appears in transcripts, is not auto-allowed, and is not in the current allowlist. This means the user has been approving it via prompt every time. These are the highest-priority entries to add.
- **New suggestion** — a read-only pattern that appears frequently but hasn't been explicitly encountered as a prompt yet.

### Step 7 — Prioritize
1. **Approved manually** entries first (sorted by count descending) — these directly eliminate recurring prompts.
2. **New suggestions** second (sorted by count descending). Drop anything with fewer than ~3 occurrences. Cap the combined list at ~20 entries.

### Step 8 — Present to user
Show the prioritized list as a markdown table before writing anything, with a tier label:

| # | Pattern | Count | Tier | Notes |
|---|---------|-------|------|-------|
| 1 | `Bash(npx tsc --noEmit)` | 34 | Approved manually | TS type-check |
| 2 | `mcp__figma` | 18 | Approved manually | Figma reads |
| 3 | `Bash(curl -s *)` | 12 | New suggestion | API reads |

### Step 9 — Merge into `~/.claude/settings.json`
Create the file if it doesn't exist. Preserve existing keys and `permissions.allow` entries; de-duplicate; don't remove anything; don't touch `permissions.deny` or `permissions.ask` or any other field.

### Step 9a — Compound Script Extraction
Using the canonical-form → count map built in Step 2, split the compound commands into two tiers:

**Tier A — extraction candidates (3 or more occurrences):**

For each canonical form that appears 3+ times across the scanned transcripts:
1. Propose a descriptive script name under `scripts/` that captures the command's purpose (e.g. `scripts/check-status.sh`, `scripts/verify-build.sh`).
2. Show the proposed script contents — a minimal shell script wrapping the compound exactly as observed (canonical form). Example:
   ```
   Proposed: scripts/check-status.sh
   #!/usr/bin/env bash
   set -euo pipefail
   git remote -v && GH_HOST=github.com gh auth status 2>&1 | head -10
   ```
3. Ask the user to **approve**, **decline**, or **rename** each proposed script individually. Wait for the user's response before proceeding to any writes.
4. For each approved script:
   - If the `scripts/` directory does not exist in the current project repo, create it silently (`mkdir -p scripts`).
   - Write the script file to `scripts/<name>.sh`.
   - Make it executable (`chmod +x scripts/<name>.sh`).
   - Add `Bash(bash scripts/<name>.sh)` to the allowlist candidates for Step 9 (merge into `~/.claude/settings.json`).
5. Declined scripts are skipped entirely — move them to the "CANNOT ALLOWLIST" bucket in the Step 10 gap report.
6. Renamed scripts use the user-supplied name in place of the proposed name; otherwise the process is identical.

**Tier B — low-frequency compounds (fewer than 3 occurrences):**

Do not propose script extraction for these. Continue to report them as un-allowlistable in the Step 10 gap report under the "CANNOT ALLOWLIST" bucket (existing behavior preserved exactly).

### Step 10 — Report back
Tell the user: what was added (count + examples), what was already in the allowlist, and what was skipped and why (e.g. "dropped `rm` and `git push` — not read-only; dropped `cat`/`ls`/`git status` — already auto-allowed").

**Known gaps — commands that cannot be allowlisted:**

If compound commands were detected in Step 2, report them here:

```
EXTRACTED TO SCRIPTS (compound commands, 3+ occurrences — extracted in Step 9a):
  - `git remote -v && GH_HOST=github.com gh auth status 2>&1 | head -10`
    → scripts/check-status.sh  (Bash(bash scripts/check-status.sh) added to allowlist)

CANNOT ALLOWLIST (compound commands, fewer than 3 occurrences or declined in Step 9a):
  These commands triggered prompts but cannot be safely pattern-matched:
  - `ls ~/.claude/skills/ && cat CLAUDE.md | grep skill`

  Fix: extract into a named script and allowlist the script instead.
  Example:
    scripts/check-skills.sh  →  Bash(bash scripts/check-skills.sh)

  Compound constructs (&&, ||, |, ;, for/while loops) always prompt
  regardless of whether the constituent commands are safe.
```

---

## Named Profiles

Two predefined presets map the old `operatingMode` labels to approval-frequency configurations. Run `/streamline-approvals` and invoke a profile name to batch-apply the preset.

### `auto` profile

Adds Agent-tool spawn to the approval allowlist — equivalent to the old AUTONOMOUS mode posture. With this profile active, the Sprint Coordinator's Agent tool calls proceed without a per-spawn permission prompt.

**To apply:** Run `/streamline-approvals auto`

Effect: adds `Agent` (or the equivalent Agent-tool pattern) to `~/.claude/settings.json` `permissions.allow`. The Sprint Coordinator can spawn Specialists inline without per-call prompts.

### `manual` profile

The default posture — no pre-approved Agent spawns. The Claude Code permission prompt fires on each Agent tool call. Equivalent to the post-T23.A.1 MANUAL mode behavior.

**To apply:** Run `/streamline-approvals manual`

Effect: removes any Agent-tool spawn entry from `~/.claude/settings.json` `permissions.allow` (if present). Every Sprint Coordinator Agent spawn requires an inline approve/deny decision from the Conductor.

### When to use which

| Profile | Use when |
|---------|----------|
| `auto` | You've established trust in the pipeline; want hands-off sprint execution |
| `manual` | You want per-spawn approval; high-stakes sprints; onboarding a new Specialist |

The profile names are intentionally identical to the old mode labels so existing mental models carry over cleanly.
