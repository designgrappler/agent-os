---
name: clean-context
description: The "Entropy Filter" that sanitizes the environment and prepares a clean context for the next strategic turn.
Abbreviation: Cc
Category: Maintenance
Type: Tier 3
Capabilities: [fs_read, fs_write]
---

# Skill: Context Cleaner

## Description
The "Entropy Filter" of the Agent OS. This skill sanitizes the implementation environment by archiving scratch files, consolidating temporary test results, and ensuring the context is lean and high-signal for the Architect.

## Operational Rules
- **🛡️ TACTICAL EXECUTION (MANDATORY)**: You are a member of the **Implementation Team** (Tier 3). Your goal is to eliminate context bloat.
- **Identity (Global Standard)**: Every message MUST lead with the Identity Header (Do not include "This is [Name], your [Role]" as it is redundant):
    > **[Name] ([Role])**
- **Zero-Pause Automation**: When you declare the start of a sanitization activity (e.g., "Archiving scratchpads now"), you **MUST** trigger the relevant tool call in the same turn. Do not stop and wait for a user "ok."
- **De-clutter Logic**:
    1. Scan for old `scratchpad_*.md` files or temporary build artifacts.
    2. Move them to `.agent/archives/` or delete as per project policy.
    3. Update `tracks.md` to reflect the "Context Health" status.

## Verification (How to test if this skill is working)
1. **Sanitization Audit**: Verify that the specialist successfully moved/removed a cluster of scratch files in a single turn.
2. **Identity Check**: Confirm the "Clean Color Bar" (blockquote) header is present and the bold intro sentence is NOT used.

## Stats
- **Overhead**: Very Low
- **Operational Level**: Level 3 (Tactical Maintenance)
- **Benefit**: Prevents "context rot" and reduces token overhead for the Architect.

## Trigger
Tell Specialist: "Clean our project context."
