---
name: autonomous-agent-workflow
description: Orchestrates autonomous end-to-end engineering, from a high-level idea through requirements interview, spec generation, task breakdown, parallel sub-agent dispatch, self-healing TDD, and multi-axis review until 100% complete. Use when you want the agent to ask clarifying questions, close every gap, and build a whole feature end to end without stopping, or when starting a feature or project that requires interactive clarification and autonomous execution to final verification.
---

# Autonomous Agent Workflow

## Overview

Execute end-to-end engineering autonomously with zero guesswork. This workflow acts as the master orchestrator uniting interactive requirements interrogation, formal specification, atomic task planning, parallel sub-agent delegation, self-healing test-driven development, and multi-specialist review.

The agent never makes speculative assumptions: it clarifies every open question via interactive dialog until all gaps are closed, then drives implementation to 100% completion with persistent self-healing execution.

## When to Use

- Starting a new feature, module, or initiative from a high-level prompt
- Ambiguous or complex requirements that require interactive clarification
- End-to-end implementations that benefit from parallel sub-agents (e.g. backend, frontend, tests)
- Autonomous overnight or long-running development goals where the agent must solve problems and self-heal test failures rather than stopping on minor hurdles

**When NOT to use:** Trivial single-line fixes, simple typo corrections, or tasks where requirements and implementation steps are already 100% concrete and self-contained.

---

## The 5-Phase Autopilot Loop

```
1. INTERROGATE ──▶ 2. SPEC & PLAN ──▶ 3. DISPATCH SUB-AGENTS ──▶ 4. SELF-HEALING TDD ──▶ 5. VERIFY & SHIP
  ask_question       SPEC.md             Parallel sub-agents         RED → GREEN loop          Code Reviewer
  Popup modal        tasks/plan.md       for independent             Self-debug errors         Security Auditor
  Zero gaps left     tasks/todo.md       workstreams                 Until 100% passing        Test Engineer
```

### Phase 1: Interactive Requirements Interrogation (Popup Modal)

Never assume requirements or guess architecture. Surface all unknowns and interrogate the user:

1. **Activate Interactive Clarification**:
   - In environments supporting interactive modals (e.g. Antigravity IDE `ask_question`), render a focused multiple-choice modal with explicit options and custom write-in capabilities.
   - In CLI environments, present numbered questions and wait for user answers.
2. **Key Clarification Dimensions**:
   - Target audience, operational scale, and expected workload.
   - Core functional requirements and strict out-of-scope boundaries.
   - Tech stack, database, and UI design archetype (triggering local design intelligence if visual).
   - Invariants: security, compliance, data-loss protections, and accessibility.
3. **Exit Gate**: Continue questioning until **zero ambiguities or unverified assumptions remain**.

### Phase 2: Specification & Atomic Task Breakdown

1. **Synthesize `SPEC.md`**:
   - Invoke `spec-driven-development` to author a binding specification covering Objective, Commands, Project Structure, Code Style, Testing Strategy, and Boundaries.
   - If UI is involved, automatically run `./scripts/ui-search.sh "<product> <keywords>" --design-system --persist -p "<project>"` to establish `.agents/design-system/<project>/MASTER.md`.
2. **Decompose into Vertical Slices**:
   - Invoke `planning-and-task-breakdown` to produce `tasks/plan.md` and dependency-ordered atomic tasks in `tasks/todo.md`.
   - Each task must have clear Acceptance Criteria, Verification Commands, and Files likely touched.
3. **Continuous Autonomous Execution & In-Flight Gap Interruption**:
   - Once requirements are clarified and the spec/plan are written, proceed **directly into implementation** without pausing for redundant confirmation.
   - **In-Flight Gap Interruption**: If at any point during planning, sub-agent dispatch, or implementation an unexpected ambiguity, unknown constraint, or architectural decision gap is encountered, immediately invoke `ask_question` (interactive popup modal) to clarify with the user rather than guessing or continuing with unverified assumptions.

### Phase 3: Parallel Sub-Agent Dispatch

When tasks cluster into independent problem domains (e.g., API backend vs frontend components vs independent test fixtures):

1. **Apply `dispatching-parallel-agents`**:
   - The coordinator agent constructs self-contained briefs for each independent task.
   - Spawn sub-agents concurrently, passing only necessary file contexts.
   - Sub-agents execute within their bounded domain and report back structured results.
2. **Merge & Coordinate**:
   - The coordinator validates integration points and merges outputs sequentially without git race conditions.

### Phase 4: Autonomous Self-Healing TDD Loop & Anti-Thrashing Guard

Execute every task in dependency order using the strict Red-Green-Refactor loop:

1. **RED**: Write a focused, failing test proving the new behavior.
2. **GREEN**: Implement minimal code satisfying the test.
3. **REGRESSION**: Run full test suite and compilation check.
4. **SELF-HEALING & ANTI-THRASHING GUARD**:
   - If a test fails or build breaks, **do not stop or ask the user immediately**.
   - Invoke `debugging-and-error-recovery`:
     - Inspect stack trace and localize the failure.
     - Formulate a root-cause hypothesis and apply minimal fix.
     - Re-run test suite. Retry the self-healing loop up to 3 times.
   - **Anti-Thrashing Detection**: Track file churn during self-healing. If the same file is modified >3 times without reaching green tests:
     - **Halt patch churn immediately.** Do not keep applying speculative syntax edits.
     - Trigger **Forensics Analysis**: Inspect recent git diffs (`git diff HEAD~3`) and verify whether the test assumptions or interface contracts contradict the underlying architecture.
     - Only escalate to the user if a fundamental architectural contradiction is proven.
5. **COMMIT & ADVANCE**:
   - Create one atomic git commit per completed task.
   - Mark task `[x]` in `tasks/todo.md` and advance to the next pending task.

### Session Checkpointing & Handoff (`tasks/handoff.md`)

When long-running work must pause, when context token limits near exhaustion, or when external credentials are required, author a durable state checkpoint in `tasks/handoff.md`:

```markdown
# Session Handoff Checkpoint

- **Timestamp**: YYYY-MM-DD HH:MM:SS
- **Current Task**: [Task ID & Name]
- **Status**: [Paused | Blocked | Awaiting Human Action]
- **Completed Tasks**:
  - [x] Task 1: [Name] (Commit: `hash`)
- **Remaining Tasks**:
  - [ ] Task 2: [Name]
- **Uncommitted Changes**: [List of modified files]
- **Blockers / Human Actions Needed**: [e.g. Set API key, approve migration]
- **Resume Command**: `/s-agent continue` or `/s-build`
```

### Phase 5: Multi-Specialist Verification, Learnings & Ship Gate

Before declaring the initiative finished, execute the parallel review fan-out:

1. **Specialist Evaluation**:
   - **Code Reviewer**: Evaluates against the 5-axis review and 4-part finding contract.
   - **Security Auditor**: Verifies input sanitization, authentication, and dependency audits.
   - **Test Engineer**: Confirms edge-case coverage and mutation resistance.
2. **UI Polish Gate** (if user-facing):
   - Contrast ≥ 4.5:1, touch targets ≥ 44×44px, visible focus, zero horizontal overflow at 375px.
3. **Institutional Learnings Extraction**:
   - Summarize key technical decisions, architectural patterns established, and unexpected gotchas in `tasks/learnings.md` to preserve memory across future agent sessions.
4. **Deliverable Summary**:
   - Present completed tasks, added tests, git commits, and verified success criteria.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I can guess what the user meant without asking" | Guessing requirements causes 80% of project rewrites. Interrogate upfront via popup modal. |
| "A sub-agent can make architectural decisions" | Sub-agents execute focused workstreams; the coordinator owns architecture and spec boundaries. |
| "A test failed, I should stop and ask the user" | Senior engineers debug and self-heal test failures before bothering stakeholders. |
| "It's faster to skip writing a formal spec" | Without `SPEC.md`, autonomous loops drift and hallucinate off-track requirements. |
| "I'll try one more small patch on this file" | If you've modified the same file 3+ times without passing tests, you are thrashing. Run forensics instead of guessing. |

## Red Flags

- Writing code before clarifying open ambiguities with the user
- Stopping after writing one task when autonomous mode was invoked
- Spawning nested sub-agents (sub-agents spawning other sub-agents is forbidden)
- Silently ignoring failed tests or deleting assertions to make tests "pass"
- Making git commits with `git add -A` instead of staging only task-specific files
- Repeatedly patching the same file (>3 times) without checking test premises or git diff history (thrashing)

## Verification

Before marking the autonomous workflow complete, verify:

- [ ] All user requirements were clarified without remaining ambiguity
- [ ] `SPEC.md` exists and covers all core sections
- [ ] Every task in `tasks/todo.md` is marked complete `[x]`
- [ ] Full test suite and lint/build pass with zero errors
- [ ] Git history contains atomic, descriptive commits for each vertical task
- [ ] Multi-specialist verification passes without blocking issues
- [ ] `tasks/handoff.md` written if work is paused or handed over across session boundaries
