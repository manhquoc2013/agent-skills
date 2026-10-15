---
name: receiving-code-review
description: Guides how to receive code review feedback — verify before implementing, ask before assuming. Use when responding to review comments or a reviewer's suggestions, and when feedback is unclear, seems wrong for the codebase, or conflicts with an earlier decision.
---

# Receiving Code Review

## Overview

Code review requires technical evaluation, not social performance. The goal of receiving feedback is a correct codebase — not agreement, speed, or comfort. Reviewers can be wrong, and blindly implementing a wrong suggestion imports the reviewer's mistake into your code.

**Core principle:** verify before implementing, ask before assuming. Technical correctness over social comfort.

## When to Use

- Responding to review comments on a PR or patch
- A reviewer suggests a change you are about to implement
- Feedback arrives in bulk (a numbered list) or is unclear
- A suggestion seems wrong for this codebase or conflicts with an earlier decision

**When NOT to use:** When you are the reviewer (`code-review-and-quality`) or when the feedback is a direct order with no technical ambiguity — orders still get implemented; this skill governs how you *evaluate* before you implement.

## Process

1. **Read** the complete feedback without reacting or fixing anything yet.
2. **Understand** — restate each requirement in your own words. If any item is unclear, stop and ask about those items before implementing anything: items may be related, and partial understanding produces the wrong fix.
3. **Verify against the codebase** — is the suggestion technically correct here? Does it break existing behavior? Is there a reason the current code looks the way it does? Does the reviewer have the full context?
4. **Evaluate** — correct feedback gets implemented; incorrect feedback gets a reasoned pushback; unverifiable feedback gets an honest "I can't verify this without X" and a proposed next step.
5. **Respond** — with an action or a technical argument, never with performative agreement.
6. **Implement** one item at a time, testing each, in this order: blocking issues (breaks, security), simple fixes, complex fixes.

## Responding Well

**Forbidden responses:**

- "You're absolutely right!", "Great point!", "Excellent feedback!" — agreement is not work.
- "Let me implement that now" before verifying against the code.
- Gratitude as a substitute for the fix. Actions show you heard the feedback; the code is the reply.

**When to push back** (with technical reasoning, not defensiveness):

- The suggestion breaks existing functionality
- The reviewer lacks full context (a platform constraint, a legacy contract)
- It violates YAGNI — grep the codebase: a "do it properly" request may target a feature nothing calls, and the honest answer may be to remove it instead
- It is technically incorrect for this stack
- It conflicts with an earlier architectural decision the user made — escalate that conflict to the user rather than resolving it silently

**When you pushed back and were wrong:** state the correction factually and move on — "Verified, you're right: [reason]. Implementing now." No apology ritual, no defense of the original pushback.

**Unclear feedback:** if items 1, 2, 3, 6 are clear and 4, 5 are not, say so and ask before implementing any of it — "I understand 1, 2, 3, 6; need clarification on 4 and 5 before proceeding." Fixing the clear half now and guessing the rest is the failure mode this rule exists for.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The reviewer said so" | Reviewers are fallible. Verify against the codebase before implementing. |
| "I'll fix the clear items and ask about the rest later" | Partial understanding = wrong implementation. Clarify first. |
| "Pushing back will look defensive" | Technical pushback with evidence is the job. Silent wrong fixes are the failure. |
| "A quick thank-you is polite" | The code is the reply. A fix with a description beats gratitude. |
| "Implement everything, it's their call" | Their call on *what* changes; your call on *whether it is technically sound*. A wrong suggestion implemented is your bug now. |

## Red Flags

- Performative agreement ("absolutely right") as the whole response
- Implementing before verifying against the codebase
- Batch-implementing a list without testing each item
- Treating every reviewer suggestion as correct by default
- Never pushing back on anything — a review with zero disagreement is a review not read

## Verification

Before declaring the feedback handled:

- [ ] Every feedback item is either implemented (with its test evidence) or answered with a technical argument
- [ ] Unclear items were clarified before implementation, not guessed
- [ ] Each fix is its own change and is tested individually
- [ ] Conflicts with an earlier user decision were surfaced to the user, not resolved silently
- [ ] If any item cannot be evidenced: state it and stop — do not declare the review handled

## See Also

- `code-review-and-quality` — the reviewer's side of the loop, including the re-review loop
- `git-workflow-and-versioning` — keeping each fix its own commit
