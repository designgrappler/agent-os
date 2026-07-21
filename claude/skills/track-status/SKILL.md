---
name: track-status
description: Shows a one-screen summary of all tracks — ID, description, status, and flags. Read-only.
whenToUse: When the user wants a quick overview of where things stand across all active tracks.
---

## Instructions

Read `docs/context/tracks.md`.

If the file does not exist or has no tracks, output:

> No tracks found. Run `/start-sprint` to open a sprint first.

Otherwise, produce this summary:

```
## Track Status

| Track | Description | Status | Flags |
|-------|-------------|--------|-------|
| <ID>  | <task name> | <status> | <exit record notes or —> |
```

- Read status directly from the `Status:` field in each track entry. Do not infer.
- Flags: if the Exit Record has a filled `What happened:` or `Next steps:` field, include a one-word summary (e.g. "blocked", "deferred"). Otherwise use `—`.
- No writes. No edits. Read only.
