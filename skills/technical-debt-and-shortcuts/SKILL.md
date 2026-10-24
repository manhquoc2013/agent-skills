---
name: technical-debt-and-shortcuts
description: Tracks deliberate shortcuts and technical debt across the codebase. Use when marking intentional deferrals or temporary shortcuts, scanning for technical debt, auditing shortcut ceilings, preventing forgotten shortcuts from rotting, or running /s-debt.
---

# Technical Debt and Shortcuts

## Overview

Manage deliberate technical shortcuts and deferrals with accountability. Deliberate shortcuts are a valid engineering tool to ship quickly and avoid over-engineering. However, an unrecorded shortcut silently becomes permanent rot. This skill establishes a standardized marker convention, automated grep-driven ledger scanning, and ceiling-trigger tracking so every intentional shortcut is visible, bounded, and actionable.

## When to Use

- When implementing a minimal or temporary solution to defer non-essential complexity
- When writing a simplified implementation with known limitations (rate limits, in-memory storage, un-sharded tables)
- When auditing a repository to discover deferred work or shortcuts before a release
- When running `/s-debt` or reviewing shortcut hygiene during code review
- When checking if expected user load crosses an existing shortcut's ceiling

**When NOT to use:**

- To justify sloppy, untested, or insecure code (shortcuts never compromise security or data integrity)
- For generic task management or unrefined roadmap ideas (use issue trackers or `spec-driven-development` instead)
- For temporary debug statements (use `debugging-and-error-recovery` and remove them before commit)

---

## The Shortcut Marker Convention

Every deliberate shortcut must be marked with a single-line comment specifying both its **ceiling** (the boundary where it breaks or becomes insufficient) and its **upgrade trigger** (the exact event or metric that demands replacing it).

### Syntax

```text
// shortcut: <ceiling / operational limit>, <upgrade trigger>
# shortcut: <ceiling / operational limit>, <upgrade trigger>
/* shortcut: <ceiling / operational limit>, <upgrade trigger> */
```

*(Legacy markers using `ponytail:` or `TODO(debt):` are recognized by scanners for compatibility).*

### Good vs. Bad Markers

| Style | Example | Verdict |
|---|---|---|
| **Actionable** | `// shortcut: in-memory Map holds up to 10k active sessions, switch to Redis when multi-replica deployed` | **Good**: Clear limit and unambiguous trigger. |
| **Actionable** | `# shortcut: sequential file sync fine for <50 files, switch to worker pool when batch import feature launches` | **Good**: Clear scale ceiling and product trigger. |
| **Rot Risk** | `// shortcut: temporary hack for now` | **Bad (`no-trigger`)**: No ceiling, no upgrade trigger. Will silently rot. |
| **Lazy TODO** | `// TODO: make this faster` | **Bad**: Vague complaint without boundary or criteria. |

---

## The Debt Audit Process

### Step 1: Scan the Codebase

Scan all tracked source files, respecting `.gitignore` and skipping vendor or build directories:

```bash
git grep --no-index --exclude-standard -nE '(#|//|/[*]) ?(shortcut|ponytail):'
```

Alternatively, run the dedicated project command:
```bash
/s-debt
# or via script:
bash scripts/scan-debt.sh
```

### Step 2: Categorize and Inspect Ceilings

For each discovered marker:
1. **Identify the ceiling**: What input size, user count, or architectural state causes this shortcut to fail?
2. **Identify the upgrade trigger**: Has this trigger been reached by recent changes or expected load?
   - If the expected load **now crosses the ceiling**, elevate this immediately to a **Must Fix** issue.
   - If the marker lacks an upgrade trigger, flag it with the `[no-trigger]` tag.
3. **Verify caller context**: Does neighboring code rely on this shortcut without realizing its ceiling?

### Step 3: Compile the Debt Ledger

Generate a structured debt ledger grouped by file:

```markdown
# Technical Debt Ledger: [Project Name]

## Active Shortcuts

### `src/auth/session.ts`
- **Line 42**: In-memory Map for active sessions.
  - **Ceiling**: Up to 10k concurrent sessions on a single instance.
  - **Upgrade Trigger**: Switch to Redis when horizontal scaling is enabled.
  - **Status**: Healthy (current load: ~200 sessions).

### `src/importer/csv.py`
- **Line 115**: Synchronous row-by-row insertion.
  - **Ceiling**: Batches under 1,000 rows.
  - **Upgrade Trigger**: `[no-trigger]` ⚠️ Rot Risk: Needs defined volume trigger.

## Summary
- **Total Markers**: 2
- **Rot Risks (no-trigger)**: 1
- **Ceilings Exceeded**: 0
```

### Step 4: Act on Debt

When resolving debt:
- Apply the smallest complete replacement conforming to the 6-Rung Ladder (`skills/code-simplification/SKILL.md`).
- Remove the `shortcut:` comment and add a targeted test asserting that the new boundary holds.

---

## Boundaries

- **Always**: Require both a ceiling and an upgrade trigger in every new shortcut comment.
- **Always**: Run the debt scan before major milestones or shipping releases.
- **Never**: Commit shortcuts that bypass authentication, user input sanitization, or transaction rollbacks.
- **Never**: Silently delete a shortcut comment without either implementing the full solution or formally transferring it to a tracked issue.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll remember to upgrade this next week" | You won't. Unrecorded shortcuts become invisible technical debt within 48 hours. |
| "A plain TODO is enough" | Plain TODOs have no ceiling or trigger, so they are routinely ignored for years. |
| "Writing the trigger takes too much time" | It takes 10 seconds to write what scale will break your shortcut. |
| "This is just an internal script, who cares?" | Internal scripts frequently get promoted to production pipelines without refactoring. |

---

## Red Flags

- Markers written as `// shortcut: fix later` without specific conditions
- Shortcuts that handle money, passwords, or personal data with known security gaps
- A codebase with more than 20% `no-trigger` rot-risk markers
- Disabling tests to make a shortcut pass without a documented ceiling

---

## Verification

Before completing a task that introduces or audits shortcuts, verify:

- [ ] Every shortcut added includes both a ceiling and an upgrade trigger
- [ ] No shortcut compromises security, data integrity, or accessibility
- [ ] `bash scripts/scan-debt.sh` runs cleanly and parses all markers
- [ ] Any markers whose ceiling has been crossed are resolved or escalated
- [ ] The debt ledger accurately reflects the current repository state
