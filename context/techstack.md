# Technical Specification: Agent OS v1.0

This document defines the structural requirements for any host environment implementing the **Conductor Structural Enforcement** model.

## 1. Structural Enforcement (The Policy Engine)
The host MUST implement **System-Level Tool Denial**. Relying on persona instructions is considered a critical security failure in v1.0.
- **Mechanism**: The environment (e.g., Gemini CLI) must use a **Policy Hub** (e.g., `policy.toml`) to intercept tool manifests.
- **Action**: Any tool category unauthorized for the persona's Tier (e.g., `write_file` for an Architect) must be **physically removed** from the available toolset before the agent initializes.

## 2. Atomic Context Heartbeats
To prevent strategic drift and context bloat, the host must support **Task-Isolated Sessions**.
- **The Protocol**: When transitioning from Strategic (Tier 2) to Tactical (Tier 3), the system must launch a **Fresh Process** with an empty context window.
- **State Re-Injection**: The specific task-metadata is re-primed from the `ledger.json` on wake, ensuring the agent has the "Freshest Context Signal."

## 3. Standard Global Ledger
The framework uses a **Global Task Ledger** to manage project state across local sessions.
- **Storage**: `~/.gemini/conductor/ledgers/<project_id>.json`
- **Ownership**: Every task must be "Checked Out" by a Specialist ID before write-access is granted to production directories.

## 4. Capability Bundles (Structural Locks)

| Bundle | Structural Lock | Mandatory Exclusion |
| :--- | :--- | :--- |
| **ARCHITECT** | Policy-Blocked | `write_file`, `replace`, `cmd_exec` (unfiltered) |
| **SPECIALIST** | State-Locked | `net_fetch`, `meta_planning` |
| **SENTINEL** | Audit-Locked | `fs_write`, `edit_file` |

## 5. Visual & Operational Signaling
- **Command Banners**: Introduction banners must clearly state the **Mode (Enforced)** and the **Persona**.
- **Handoff Automation**: Architects must generate self-executing `gemini` commands to facilitate the Atomic Wake protocol.

---
**Enforcement Authority: Gemini CLI Policy Engine.**
