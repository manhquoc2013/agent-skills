---
description: Run autonomous end-to-end engineering — interactive interview popup, spec & plan generation, sub-agent dispatch, self-healing TDD, and full verification.
---

Invoke the agent-skills:autonomous-agent-workflow skill.

## Autonomous End-to-End Execution Flow

When invoked, execute the complete 5-phase engineering lifecycle without stopping:

1. **Clarify via Interactive Modal / Questions:**
   - Detect all open ambiguities, architectural decisions, and unknown constraints in `$ARGUMENTS`.
   - In environments supporting interactive modal prompts (e.g. Antigravity IDE `ask_question`), launch interactive question dialogs with selectable options and write-in fields.
   - Continue questioning until zero gaps or unverified assumptions remain.

2. **Generate Spec & Decompose Tasks:**
   - Synthesize `SPEC.md` covering Objective, Commands, Architecture, Code Style, Testing Strategy, and Boundaries.
   - If user-facing screens or UI are required, automatically generate `.agents/design-system/<project>/MASTER.md` via `./scripts/ui-search.sh "<product> <keywords>" --design-system --persist -p "<project>"`.
   - Produce vertical slices in `tasks/plan.md` and dependency-ordered tasks in `tasks/todo.md`.
   - Proceed directly into implementation without pausing for redundant confirmation. If any gap, unexpected ambiguity, or architectural decision emerges at any point in the workflow, immediately invoke interactive questions to clarify with the user.

3. **Dispatch Parallel Sub-Agents (When applicable):**
   - For independent problem domains (e.g. API backend vs UI components vs test harnesses), invoke agent-skills:dispatching-parallel-agents to spawn specialized sub-agents concurrently.
   - The coordinator agent oversees integration and serializes git commits.

4. **Self-Healing Test-Driven Implementation & Anti-Thrashing Guard:**
   - Execute each task following RED → GREEN → Refactor.
   - If tests fail or builds break, invoke agent-skills:debugging-and-error-recovery to inspect stack traces, localize the root cause, and self-heal automatically rather than stopping prematurely.
   - Guard against file thrashing: if the same file is modified >3 times without reaching green tests, halt speculative patching and run forensics on git diff history and test premises.
   - If execution must pause or context nears exhaustion, write a durable checkpoint to `tasks/handoff.md`.
   - Create one atomic git commit per completed task.

5. **Multi-Specialist Verification & Final Review:**
   - Fan-out evaluation across Code Reviewer, Security Auditor, and Test Engineer personas.
   - Verify Pre-Delivery UI Polish checklist (4.5:1 contrast, 44px touch targets, prefers-reduced-motion) for frontend changes.
   - Extract institutional learnings into `tasks/learnings.md` to preserve architectural decisions across sessions.
   - Summarize completed tasks, tests added, and commits made.
