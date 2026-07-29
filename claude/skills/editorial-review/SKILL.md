---
name: editorial-review
description: Checks written output against a provided brief and returns a numbered gap list. Invoked by the writer specialist before sign-off. Gap identification only — no rewrites, no suggestions.
whenToUse: When the writer specialist has completed a content track and needs to verify the output meets the brief before signing off.
---

# Editorial Review

Checks written output against a provided brief. Returns a numbered gap list of what is missing or misaligned. Does not rewrite. Does not suggest fixes.

## Inputs

**Required:**
- `output` — path to the written output file
- `brief` — path to the brief file, OR the brief content inline in the invocation

## How to run

1. Read the output file in full.
2. Read the brief in full.
3. For each element of the brief (audience, purpose, structure, tone, content requirements), check whether the output satisfies it.
4. Produce a numbered gap list. Each item must state:
   - The specific issue (what is wrong or missing)
   - Which brief criterion it violates (quote the relevant brief language)

## Output format

**If gaps found:**
```
Editorial Review — [output file name]

Gaps:
1. [Specific issue] — violates brief criterion: "[quoted brief language]"
2. [Specific issue] — violates brief criterion: "[quoted brief language]"
...
```

**If no gaps:**
```
Editorial Review — [output file name]

No gaps found — output meets brief.
```

## Hard constraints

- Do NOT rewrite any content
- Do NOT suggest how to fix gaps — state what is wrong, not how to correct it
- Do NOT pass output that has gaps — the gap list is a blocking finding, not a suggestion
- If the brief is absent or incomplete, report: "Brief incomplete — cannot run editorial review. Required: audience, purpose, output format, subject matter."
