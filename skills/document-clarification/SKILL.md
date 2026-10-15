---
name: document-clarification
description: Turns the ambiguities in a document into a structured clarification list for discussion. Use when reading or analyzing a spec, requirements document, PRD, ticket, or any document whose open points must be resolved before planning or implementation. Use when the user asks what a document still leaves unclear, or wants the gaps turned into questions.
---

# Document Clarification

## Overview

Documents — specs, requirements, PRDs, tickets — are written by people who know more than they wrote down. Every document carries unstated assumptions, undefined terms, and missing answers, and the cheapest time to find them is before planning starts. This skill reads a document end to end and turns every open point into a question the owner can answer quickly: each question shows what the document says (or does not say), why the answer matters, and a suggested default the user can accept with one word.

The output is a clarification list, not a rewrite and not a plan. The answers feed back into the document, and the clarified document is then ready for spec-driven-development or planning-and-task-breakdown. This skill turns an existing document into a question list and records the answers back; authoring the spec that follows is spec-driven-development's job.

## When to Use

- A spec, requirements document, PRD, ticket, or similar document needs review before planning or implementation
- Requirements exist but feel incomplete, contradictory, or untestable
- The user asks "what is unclear here", "what questions does this raise", or wants the gaps turned into questions
- Several readers of the same document disagree on what it means

**When NOT to use:** The user wants you to clarify by asking them directly, with no document as the subject — use the interview-me skill. The goal is to write a spec from vague requirements — use the spec-driven-development skill. The document has no ambiguity worth listing — say so in one line and stop.

## Process

### Step 1: Read the entire document

Read every section, table, list, and example before flagging anything. A question the document already answers on page 3 is a wasted question that erodes trust in the whole list.

### Step 2: Extract open points by category

Collect what the document leaves open. The standard categories:

| Category | What to look for |
|---|---|
| Business rules | Who, why now, what happens when the rule is violated |
| Scope | What is in, what is out, what is never mentioned |
| Actors & permissions | Who can do what; roles that are named but never granted anything |
| Data | Sources, formats, volumes, ownership, retention |
| Acceptance criteria | What done looks like — measurable and testable |
| Failure behavior | Errors, edge cases, retries, rollback |
| Non-functional | Performance, security, compliance, availability |
| Dependencies | Sequencing, external systems, blocking inputs |
| Terminology | Terms used with no definition, or defined twice with different meanings |

### Step 3: Write each question with evidence, severity, and a default

Every question carries four parts:

```markdown
### Q7 [Important] — Retry policy for payments
- What the document says: "The system charges the card" (section 4.2); retries and failure handling are not mentioned.
- Question: If the payment provider times out, should the system retry, and how many times?
- Suggested default: Retry once, then mark the order failed and notify the user (say "accept" to take the default).
- Without an answer: the implementation choice becomes a de facto business rule the author never approved.
```

```markdown
### Q2 [Blocker] — Data residency for EU customers
- What the document says: not addressed anywhere; section 6 covers retention only.
- Question: May EU customer data be processed outside the EU, and if not, which region hosts it?
- Suggested default: keep EU data in the EU region (say "accept" to take the default).
- Without an answer: the plan cannot pick a datastore, and the choice becomes a compliance decision nobody approved.
```

```markdown
### Q9 [Minor] — "workspace" vs "project"
- What the document says: "workspace" (section 2) and "project" (section 5) appear to name the same thing.
- Question: Which term is canonical, and should the other be removed?
- Suggested default: use "workspace" everywhere and replace the single use of "project" (say "accept" to take the default).
- Without an answer: two names for one concept invite two implementations.
```

- **Severity.** Mark every question Blocker (no correct implementation or plan is possible without an answer), Important (the answer changes design or scope), or Minor (wording, consistency, polish).
- **Evidence.** Cite the section, or state "not addressed anywhere", so every question is checkable against the document.
- **Suggested default.** Always propose the most likely answer so the user can accept with one word. The default is your hypothesis, clearly marked — never silently applied.

### Step 4: Separate real gaps from inferable answers

Before a question reaches the user, re-check the document. **Keep a question unless the document itself answers it.** Drop it if the document answers it elsewhere; downgrade it if the answer is genuinely inferable from stated constraints. Do not drop it merely because you are confident — your confidence is not the owner's approval.

### Step 5: Produce the clarification list

Output a single structured list, grouped by severity and ordered within each group. Number the questions (Q1, Q2, …) so the discussion can reference them:

```markdown
# Clarification List: [document name]

Read: [path], [N] sections. Open points: B blockers, I important, M minor.

## Blockers
...

## Important
...

## Minor
...
```

**Optional machine-readable output.** When a downstream tool consumes the list (a ticket importer, an issue tracker, a follow-up agent), emit the same questions as JSON alongside the markdown — same content, same ids, no new questions:

```json
{
  "document": "[path]",
  "summary": { "blockers": 0, "important": 0, "minor": 0 },
  "questions": [
    {
      "id": "Q1",
      "category": "Scope",
      "severity": "Blocker",
      "quote": "verbatim text from the document, or: not addressed anywhere",
      "question": "what the owner must decide",
      "suggested_default": "the most likely answer, clearly marked as a hypothesis"
    }
  ]
}
```

Emit the JSON only when it is asked for; the markdown list stays the default deliverable, and the two forms must agree question for question.

The markdown list is the deliverable. Do not start planning, spec-writing, or implementation.

### Step 6: Record the answers

When the user answers, record each answer into a durable clarification log (for example `docs/clarifications/<document>.md`) or annotate the document itself when the user owns it — never leave the answers only in the chat transcript, where the next session cannot find them. The log pairs each question id with its answer, the date, and who answered, so the record stays checkable. The clarified document is then ready for spec-driven-development.

## Common Rationalizations

- "The gaps are obvious from context" — obvious to you is still a guess; the owner may have meant the opposite. Unanswered is not the same as answerable by guessing.
- "I'll just pick a sensible default and note it" — proposing a default is part of the question; silently applying it turns your hypothesis into a requirement.
- "This document is too small to need clarification" — small documents carry the largest unstated assumptions, because there is less text to contradict them.
- "The user already reviewed this document" — review does not make a document ambiguity-free; it means the writer's blind spots passed their own review.
- "I'll list every minor gap to look thorough" — a long tail of wording nits buries the two blockers the reader must actually answer, and the list stops being read. Severity ordering is part of the deliverable: surface the blockers first, and keep the minors short or drop them.

## Red Flags

- A question appears that the document answers elsewhere — Step 1 was skipped
- "Assumed" or "assume" appears in the list without an explicit marker and without asking
- Questions with no severity, no evidence, or no suggested default
- The list was produced without reading the whole document
- The clarification list contains your own answers instead of questions
- Questions the user cannot act on — no decision to make, nothing they can change, or a sentence restated as a question

## Verification

- [ ] The document was read in full — every section, table, and example
- [ ] Every question cites where the document does or does not address it
- [ ] Every question has a severity and a suggested default
- [ ] Summary counts (blockers, important, minor) match the actual list
- [ ] No quoted text is invented — every "the document says X" is verbatim
- [ ] No planning, spec, or code was produced — the list is the deliverable
