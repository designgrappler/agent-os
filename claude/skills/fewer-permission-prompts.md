# Fewer Permission Prompts
Scans recent Claude Code transcripts, identifies common read-only tool calls, and writes an optimized allowlist to `~/.claude/settings.json` (global) to reduce permission prompts across all projects. Focuses exclusively on read-only operations — nothing that writes, deletes, pushes, or installs.

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

---

## Protocol

### Step 1 — Locate transcripts
Session transcripts live at `~/.claude/projects/<sanitized-cwd>/*.jsonl`. Each line is a JSON object. Tool calls appear as `assistant` messages with `message.content[]` entries of `type: "tool_use"`. The `name` field identifies the tool (e.g. `"Bash"`, `"mcp__slack__slack_read_thread"`); for Bash, `input.command` is the shell string.

Scan recent transcripts across the user's full projects dir — not just the current project — so the allowlist reflects actual usage. Cap at the 50 most-recently-modified JSONL files.

### Step 2 — Extract tool-call frequencies
- **Bash calls:** parse `input.command` with the following normalizations before recording:

  1. **Env-var prefixes** — if the command starts with `KEY=value` assignments (e.g. `GH_HOST=github.com gh run list`), strip the prefix to identify the base command, but record the original prefix separately. The base command is used for read-only classification; the prefix is preserved in the generated pattern (e.g. `Bash(GH_HOST=github.com gh *)`).

  2. **`git -C <path> <subcommand>`** — if the command matches `git -C <path> <subcommand> ...`, extract `<subcommand>` as the operative token. Record as `git -C * <subcommand>` for classification. These are NOT auto-allowed by Claude Code even when the subcommand is read-only — they need explicit allowlist entries.

  3. **Compound commands** (`&&`, `||`, `|`, `;`, `for`/`while` loops, subshells) — flag these separately as "compound — cannot allowlist." Do not attempt to parse constituent commands. Collect them in a separate list for the Step 10 gap report.

  4. **Everything else** — take the leading command token (handling `sudo`, `timeout`). Record the command + first subcommand pair (e.g. `git status`, `gh pr view`, `ls`).

- **MCP calls:** record the full tool name (e.g. `mcp__slack__slack_read_thread`).
- **Built-in tool calls:** record other tool names that aren't Bash or MCP — specifically `WebFetch`.

Count occurrences across all scanned transcripts.

### Step 3 — Filter to read-only
Keep only commands that don't mutate state. Examples of safe read-only commands: `git status/log/diff/show/branch`, `gh pr view/list/diff`, `gh issue view/list`, `gh run view/list`, `rg`, `grep`, `find`, `bun run typecheck`, `bun run lint`, `docker ps/logs`, `kubectl get/describe`, `ps`, `env`, `printenv`, `WebFetch`, any MCP tool with `read`/`get`/`list`/`search`/`view`/`retrieval` in its name.

### Step 4 — Drop auto-allowed commands
These never prompt in Claude Code — skip them:

- **Always auto-allowed (any args):** `cat`, `head`, `tail`, `wc`, `stat`, `ls`, `cd`, `find`, `diff`, `echo`, `printf`, `date`, `which`, `file`, `grep`, `egrep`, `fgrep`, `rg`, `jq`, `sort`, `uniq`, `tree`, `ps`, `du`, `df`, and most other standard read-only Unix utilities.
- **Auto-allowed with zero args only:** `pwd`, `whoami`, `alias`.
- **All git read-only subcommands:** `git status`, `git log`, `git diff`, `git show`, `git blame`, `git branch`, `git tag`, `git remote`, `git ls-files`, `git stash list`, `git reflog`, etc.
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

### Step 10 — Report back
Tell the user: what was added (count + examples), what was already in the allowlist, and what was skipped and why (e.g. "dropped `rm` and `git push` — not read-only; dropped `cat`/`ls`/`git status` — already auto-allowed").

**Known gaps — commands that cannot be allowlisted:**

If compound commands were detected in Step 2, report them here:

```
CANNOT ALLOWLIST (compound commands):
  These commands triggered prompts but cannot be safely pattern-matched:
  - `ls ~/.claude/skills/ && cat CLAUDE.md | grep skill`
  - `git remote -v && GH_HOST=github.com gh auth status 2>&1 | head -10`

  Fix: extract into a named script and allowlist the script instead.
  Example:
    scripts/check-skills.sh  →  Bash(bash scripts/check-skills.sh)

  Compound constructs (&&, ||, |, ;, for/while loops) always prompt
  regardless of whether the constituent commands are safe.
```
