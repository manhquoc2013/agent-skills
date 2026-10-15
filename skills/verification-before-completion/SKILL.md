---
name: verification-before-completion
description: Enforces evidence before completion claims — proof from freshly run checks and their output, not assertion. Use when about to report work as done, passing, or fixed; when asked to verify or prove a status or run the checks again; before committing, opening a PR, or handing off to the next task.
---

# Verification Before Completion

## Overview

Evidence before claims, always. The moment you report work as complete, passing, or fixed, you are making a factual claim — and a claim without a fresh verification run is an assertion wearing a status.

## When to Use

- Before ANY success or completion claim
- Before committing, opening a PR, or marking a task done
- Before moving to the next task or delegating work
- When a delegate reports success and you are about to relay it

**When NOT to use:** When you are mid-work and stating a plan or asking a question — a plan is not a claim about the state of the code.

## Critical Rules

- Never claim a check passed without running it yourself this session and reading its output — the command output is the evidence, not your memory of it.
- Never treat a previous run, a delegate's report, or "it should pass" as evidence.
- Never express satisfaction or completion ("done", "fixed", "passes") before the verification step has run.
- The implementer's own verification is a working check, never the closing one — see `../../references/definition-of-done.md`.

## Process

Before claiming any status:

1. **Identify** the command that proves the claim.
2. **Run** the full command — fresh, complete, in this session.
3. **Read** the output: exit code, failure counts, the lines that matter.
4. **Verify** the output confirms the claim.
   - If NO: state the actual status with the evidence you have.
   - If YES: state the claim with the evidence.
5. Only then make the claim.

## What Counts as Evidence

| Claim | Requires | Not Sufficient |
|---|---|---|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, "logs look good" |
| Bug fixed | The original symptom reproduced, then gone | "Code changed, assumed fixed" |
| Regression test works | Red-green cycle: fails without the fix, passes with it | The test passing once |
| Delegate completed the work | The diff, read by you | The delegate's report |
| Requirements met | Each requirement checked against the artifact | "Tests pass" alone |

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It should work now" | Run the verification. "Should" is a hypothesis. |
| "I'm confident" | Confidence is not evidence. |
| "Just this once" | The exception is the rule you keep. |
| "The linter passed" | A linter does not run your tests or build. |
| "The agent said it was done" | Verify independently — read the diff and re-run the checks. |
| "A partial check is enough" | Partial verification proves a partial claim, nothing more. |
| "I'm out of time" | Then report unverified work as unverified — that is the honest status. |

## Red Flags

- "Should", "probably", "seems to" in a status report
- Satisfaction expressed before verification ("all green!" with no run in the transcript)
- About to commit, push, or open a PR with no verification in the transcript
- Relaying a delegate's success report without reading its diff
- Relying on the previous session's run for today's claim

## Verification

Before declaring this skill satisfied:

- [ ] The claim is stated only after the fresh command run, with its output cited
- [ ] The evidence matches the claim (a test run for a test claim, not a lint run)
- [ ] Unverified work, if any, is reported as unverified
- [ ] If any check cannot be evidenced: stop and state the actual status — never smooth it over

## See Also

- `../../references/definition-of-done.md` — the standing checklist and the independent-verification rule
- `test-driven-development` — the red-green loop the regression claim above refers to
