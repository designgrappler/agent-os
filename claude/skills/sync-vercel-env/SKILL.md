---
name: sync-vercel-env
description: Reads the local `.env` file, presents all keys found, lets you confirm an exclude list, then pushes the remaining keys to Vercel (Production + Preview) using the Vercel CLI.
---
# Sync Vercel Env
Reads the local `.env` file, presents all keys found, lets you confirm an exclude list, then pushes the remaining keys to Vercel (Production + Preview) using the Vercel CLI. Safe by default — never pushes access tokens, local-only vars, or anything you exclude.

## Trigger
Run `/sync-vercel-env` any time you want to sync local env vars to Vercel.

---

## Rules
- **Never push secrets that are local-only**: access tokens, personal API keys, and CLI credentials stay out of Vercel.
- **Always confirm before pushing**: show the final push list and wait for approval.
- **Overwrite-safe**: `vercel env add` with `--force` updates existing vars without error.
- **Zero assumptions**: if `.env` is missing or the Vercel CLI is not installed, stop and explain what's needed.

---

## Step 1 — Preflight Checks

Run both checks silently before asking anything.

```bash
# Check Vercel CLI is installed
vercel --version

# Check project is linked
cat .vercel/project.json 2>/dev/null || echo "NOT_LINKED"
```

If `vercel` is not installed: "Install the Vercel CLI first: `npm i -g vercel`, then run `vercel login` and `vercel link`."

If `NOT_LINKED`: "This project isn't linked to Vercel yet. Run `vercel link` in the project root first."

---

## Step 2 — Read `.env`

Read `.env` from the project root. Extract every non-comment, non-empty key.

Show the user:

```
Found X keys in .env:

  DATABASE_URL
  SUPABASE_URL
  SUPABASE_SERVICE_ROLE_KEY
  SUPABASE_ACCESS_TOKEN
  NODE_ENV
  PORT
  FRONTEND_URL
  ...

Default exclude list (local-only / CLI tokens / auto-set by Vercel):
  NODE_ENV, PORT, SUPABASE_ACCESS_TOKEN, [any key ending in _ACCESS_TOKEN or _CLI_TOKEN]

Anything else to exclude? (Enter key names separated by commas, or press Enter to accept defaults)
```

Wait for the user's response before continuing.

---

## Step 3 — Confirm Push List

Build the final push list by removing the exclude list from all keys found.

Show:

```
Will push these keys to Vercel (Production + Preview):

  ✓ DATABASE_URL
  ✓ SUPABASE_URL
  ✓ SUPABASE_SERVICE_ROLE_KEY

Excluded:
  ✗ NODE_ENV  (local-only)
  ✗ PORT  (local-only)
  ✗ SUPABASE_ACCESS_TOKEN  (CLI token — excluded)

Proceed? (yes / no)
```

Wait for confirmation. If the user says no, stop.

---

## Step 4 — Push to Vercel

For each key in the push list, run:

```bash
vercel env rm KEY_NAME production --yes 2>/dev/null; echo "VALUE" | vercel env add KEY_NAME production
vercel env rm KEY_NAME preview --yes 2>/dev/null; echo "VALUE" | vercel env add KEY_NAME preview
```

Read each value from `.env` at push time — never log or echo the values in output.

Report progress as each key is pushed:
```
Pushing DATABASE_URL ... done
Pushing SUPABASE_URL ... done
Pushing SUPABASE_SERVICE_ROLE_KEY ... done
```

---

## Step 5 — Summary

```
## Vercel Env Sync Complete

Pushed to Production + Preview:
  ✓ DATABASE_URL
  ✓ SUPABASE_URL
  ✓ SUPABASE_SERVICE_ROLE_KEY

Excluded (not pushed):
  ✗ NODE_ENV, PORT, SUPABASE_ACCESS_TOKEN

Next: trigger a Vercel redeploy for the new values to take effect.
Run: git commit --allow-empty -m "chore: trigger redeploy" && git push
```
