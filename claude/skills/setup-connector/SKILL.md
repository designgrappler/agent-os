---
name: setup-connector
description: Reads a connector config file from docs/context/connectors/<name>.md, validates it is filled in, writes MCP server entries to ~/.claude/settings.json, and updates connectors.md status.
whenToUse: When the user runs /setup-connector <name> to apply a connector config.
---

# Setup Connector

Reads a filled-in connector config file and wires it up in `~/.claude/settings.json`.

## Trigger

`/setup-connector <name>` — where `<name>` matches a file in `docs/context/connectors/<name>.md`.

---

## Step 1 — Locate config file

Read `docs/context/connectors/<name>.md`.

If the file does not exist:
> No config file found at `docs/context/connectors/<name>.md`.
> Check `docs/context/connectors/` for available connectors.

Stop.

---

## Step 2 — Validate credentials are filled in

Parse the **Credentials** section. For each `KEY=` line:
- If the value after `=` is empty → the file is not filled in.

If any credential is missing:
> **`<name>` is not configured yet.**
>
> Open `docs/context/connectors/<name>.md` and fill in:
> [list the empty KEY= lines]
>
> Not sure what goes there? Ask: "What is [KEY] for the [name] connector?"

Stop.

---

## Step 3 — Parse config

Extract from the config file:

- **Credentials** — every `KEY=value` pair in the Credentials section
- **Services** — every `- service-name` line in the Services section (skip commented-out or deleted lines)

---

## Step 4 — Show plan and confirm

Display what will be written:

```
Ready to configure <name>:

Services:
  [list each service]

This will add [N] MCP server entries to ~/.claude/settings.json.
Existing entries for these servers will be replaced.

Proceed? (yes / no)
```

Wait for confirmation. If no, stop.

---

## Step 5 — Write settings.json entries

Read `~/.claude/settings.json`. For each service in the parsed list, add or replace the entry in `mcpServers`.

### Google Workspace service map

| Service line | Server name | URL |
|---|---|---|
| gmail | gmail | https://gmailmcp.googleapis.com/mcp/v1 |
| google-drive | google-drive | https://drivemcp.googleapis.com/mcp/v1 |
| google-docs | google-docs | https://docsmcp.googleapis.com/mcp/v1 |
| google-sheets | google-sheets | https://sheetsmcp.googleapis.com/mcp/v1 |
| google-slides | google-slides | https://slidesmcp.googleapis.com/mcp/v1 |
| google-calendar | google-calendar | https://calendarmcp.googleapis.com/mcp/v1 |
| google-chat | google-chat | https://chatmcp.googleapis.com/mcp/v1 |
| google-people | google-people | https://people.googleapis.com/mcp/v1 |

Each entry format:

```json
"<server-name>": {
  "type": "http",
  "url": "<url>",
  "oauth": {
    "clientId": "<CLIENT_ID value>",
    "callbackPort": 8080
  }
}
```

The `CLIENT_SECRET` is not stored in `settings.json`. It is passed via the CLI in Step 6.

Write the updated `settings.json` — preserve all existing keys outside `mcpServers`.

---

## Step 5b — Add SessionStart cache-clear hook (Google Workspace only)

If any Google Workspace service was added in Step 5, ensure the following hook is present in `~/.claude/settings.json` under `hooks.SessionStart`.

Check whether a hook command containing `mcp-needs-auth-cache.json` already exists in the `SessionStart` array. If it does, skip silently.

If it does not exist, append this hook object to the `SessionStart` hooks array (create the `SessionStart` key if absent):

```json
{
  "hooks": [
    {
      "type": "command",
      "command": "python3 -c \"\nimport json, os\npath = os.path.expanduser('~/.claude/mcp-needs-auth-cache.json')\ntry:\n    with open(path) as f: cache = json.load(f)\nexcept: cache = {}\ngoogle_keys = [k for k in cache if k.startswith('google-')]\nfor k in google_keys: del cache[k]\nwith open(path, 'w') as f: json.dump(cache, f)\nif google_keys: print(f'[session-start] Cleared Google MCP auth cache: {google_keys}')\n\""
    }
  ],
  "matcher": ""
}
```

**Why this exists:** Claude Code writes `~/.claude/mcp-needs-auth-cache.json` when a Google MCP OAuth connection fails during troubleshooting. This cache entry persists across sessions and silently blocks reconnection even after a valid token exists. Clearing `google-*` entries at session start ensures the OAuth flow is always attempted fresh, matching user expectation that connections work after authentication.

SAP and other non-Google entries in the cache are preserved.

---

## Step 6 — Register client secret

The `--client-secret` flag requires an interactive TTY and will fail inside Claude Code. Use the `MCP_CLIENT_SECRET` env var instead.

For each service added, run:

```bash
MCP_CLIENT_SECRET="<CLIENT_SECRET>" claude mcp add-json "<server-name>" \
  '{"type":"http","url":"<url>","oauth":{"clientId":"<CLIENT_ID>","callbackPort":8080}}' \
  --scope user
```

Report each registration as it completes:
```
Registered gmail ... done
Registered google-drive ... done
...
```

If any registration fails, show the error and stop. Do not mark the connector active if any service failed.

---

## Step 7 — Update connectors.md

Read `docs/context/connectors.md`. Find the `## <name>` section.

Update:
- `**Status:**` → `active`
- `**Notes:**` → `[N] services configured — authenticate with /mcp`

Write the updated file.

---

## Step 8 — Summary

```
## <name> connector configured

Services added:
  ✓ [list each service]

Next step: authenticate with Google.

**Claude Code CLI:** Run `/mcp` and complete the OAuth flow for each service.

**VS Code extension:** Open an external terminal and run:
  claude mcp login <server-name>
for each service (e.g. `claude mcp login gmail`, `claude mcp login google-drive`).

You'll be redirected to Google sign-in once per service.
Re-authentication is required each session (the session-start hook clears auth cache on startup).
Verify with: `claude mcp list`

Config file: docs/context/connectors/<name>.md
Settings:    ~/.claude/settings.json
```
