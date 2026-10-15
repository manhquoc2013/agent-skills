---
name: dispatching-parallel-agents
description: Dispatches one agent per independent problem domain so work runs concurrently. Use when facing two or more independent tasks, failures, or investigations that share no state and no sequential dependency, and when the coordinator's context should stay free for integration.
---

# Dispatching Parallel Agents

## Overview

Sequential investigation wastes time that could run in parallel: two independent failures need not wait for each other. The pattern is one agent per independent problem domain, each with an isolated, hand-built brief — never a copy of the coordinator's session history. Dispatching also preserves the coordinator's context for the integration work.

**Core principle:** one agent per independent domain; independent dispatches issued together run together.

## When to Use

- Multiple test failures with different root causes
- Several subsystems broken independently
- Two or more investigations that share no files and no state
- Work that can be understood without the other tasks' context

**When NOT to use:**

- Failures are related — fixing one may fix others. Investigate together first.
- The work shares state or files — agents would interfere with each other.
- You don't yet know what is broken — that is exploratory debugging, one focused investigation.
- One agent could finish the whole job faster than you can write two briefs.

## Process

### 1. Identify Independent Domains

Group the work by *what is broken*, not by file count. "File A tests: tool approval flow; File B tests: batch completion; File C tests: abort behavior" are three domains if fixing one cannot affect the others.

### 2. Write Focused Briefs

Each agent gets exactly what it needs and nothing inherited:

- **Scope:** one file or one subsystem, named.
- **Goal:** what "done" means, in checkable terms.
- **Constraints:** what it must NOT touch.
- **Expected output:** the summary it must return.

Paste the relevant error messages and test names into the brief — the agent has no other context.

### 3. Dispatch Together

Issue all dispatches in one batch, not one per message: dispatches issued together run concurrently; dispatches issued one at a time serialize.

### 4. Review and Integrate

When the agents return: read each summary, check that the changes do not conflict, run the full suite yourself, and integrate. **The agents' success reports are claims — verify them** (see `verification-before-completion`).

## Brief Quality

| Bad | Good |
|---|---|
| "Fix all the tests" | "Fix agent-tool-abort.test.ts" |
| "Fix the race condition" | The failing log lines and test names pasted in |
| No constraints | "Do NOT change production code" |
| "Fix it" | "Return the root cause and the changes you made" |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll just do them one by one, it's simpler" | Independent work serialized costs the full sum of the durations. |
| "Give the agent my context so it can figure things out" | Inherited context drags in assumptions and burns tokens. Hand-build the brief. |
| "Parallel agents will conflict" | Only if the domains weren't actually independent — that is a scoping failure, not a flaw of parallelism. |
| "I'll trust their reports" | A report is a claim. Re-run the suite before integrating. |

## Red Flags

- Two dispatches whose briefs overlap the same files
- A dispatch that restates another agent's whole context instead of one focused domain
- Issuing dispatches one per message and calling it parallel
- Integrating changes without running the full suite
- No expected-output line in a brief

## Verification

Before declaring the fan-out complete:

- [ ] Each agent's domain is disjoint from the others (files and state)
- [ ] Every brief names scope, goal, constraints, and expected output
- [ ] All dispatches were issued together
- [ ] Each returned summary was read, and conflicting changes were checked
- [ ] The full suite passes after integration — run by the coordinator, not reported by the agents
- [ ] If any agent returned without evidence: re-check its work before integrating — never assume

## See Also

- `verification-before-completion` — the gate that governs trusting agent reports
- `../../references/orchestration-patterns.md` — the broader fan-out and merge patterns this skill instantiates
