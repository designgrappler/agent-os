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
- **Bash calls:** parse `input.command`, take the leading command token (handling `sudo`, `timeout`, pipes, `&&`, env-var prefixes). Record the command + first subcommand pair (e.g. `git status`, `gh pr view`, `ls`).
- **MCP calls:** record the full tool name (e.g. `mcp__slack__slack_read_thread`).

Count occurrences across all scanned transcripts.

### Step 3 — Filter to read-only
Keep only commands that don't mutate state. Examples of safe read-only commands: `git status/log/diff/show/branch`, `gh pr view/list/diff`, `gh issue view/list`, `gh run view/list`, `rg`, `grep`, `find`, `bun run typecheck`, `bun run lint`, `docker ps/logs`, `kubectl get/describe`, `ps`, `env`, `printenv`, any MCP tool with `read`/`get`/`list`/`search`/`view` in its name.

### Step 4 — Drop auto-allowed commands
These never prompt in Claude Code — skip them:

- **Always auto-allowed (any args):** `cat`, `head`, `tail`, `wc`, `stat`, `ls`, `cd`, `find`, `diff`, `echo`, `printf`, `date`, `which`, `file`, `grep`, `egrep`, `fgrep`, `rg`, `jq`, `sort`, `uniq`, `tree`, `ps`, `du`, `df`, and most other standard read-only Unix utilities.
- **Auto-allowed with zero args only:** `pwd`, `whoami`, `alias`.
- **All git read-only subcommands:** `git status`, `git log`, `git diff`, `git show`, `git blame`, `git branch`, `git tag`, `git remote`, `git ls-files`, `git stash list`, `git reflog`, etc.
- **All gh read-only subcommands:** `gh pr view/list/diff/checks/status`, `gh issue view/list`, `gh run view/list`, `gh repo view`, `gh release view/list`, `gh auth status`, etc.
- **Docker read-only:** `docker ps`, `docker images`, `docker logs`, `docker inspect`.

**Source of truth:** If you're unsure whether a command is already covered, grep `src/tools/BashTool/readOnlyValidation.ts` (`READONLY_COMMANDS`, `READONLY_NOARGS`, `READONLY_EXACT`, `COMMAND_ALLOWLIST`) and `src/utils/shell/readOnlyCommandValidation.ts` (`GIT_READ_ONLY_COMMANDS`, `GH_READ_ONLY_COMMANDS`, `DOCKER_READ_ONLY_COMMANDS`) in the Claude Code repo. Never guess — check the source.

### Step 5 — Pick the pattern form
Use the narrowest pattern that covers observed usage:
- Many variants of the same command (`git log`, `git log --oneline`, `git log main..HEAD`) → `Bash(git log *)` (space before `*` is required for prefix matching)
- Single exact invocation → `Bash(foo)` with no wildcard
- MCP tools → full tool name verbatim, no wildcard needed

### Step 6 — Prioritize
Rank by count descending. Drop anything that appeared fewer than ~3 times. Cap the list at the top ~20 entries.

### Step 7 — Present to user
Show the prioritized list as a markdown table before writing anything:

| # | Pattern | Count | Notes |
|---|---------|-------|-------|
| 1 | `Bash(git status *)` | 142 | repo status checks |
| 2 | `Bash(gh pr view *)` | 87 | PR inspection |
| 3 | `mcp__slack__slack_read_thread` | 54 | Slack thread reads |

### Step 8 — Merge into `~/.claude/settings.json`
Create the file if it doesn't exist. Preserve existing keys and `permissions.allow` entries; de-duplicate; don't remove anything; don't touch `permissions.deny` or `permissions.ask` or any other field.

### Step 9 — Report back
Tell the user: what was added (count + examples), what was already in the allowlist, and what was skipped and why (e.g. "dropped `rm` and `git push` — not read-only; dropped `cat`/`ls`/`git status` — already auto-allowed").
