---
description: "Audit and track deliberate shortcuts and technical debt — scan ceilings, upgrade triggers, and rot risks"
---

Invoke the agent-skills:technical-debt-and-shortcuts skill.

Audit technical shortcuts and deferred complexity across the codebase:

1. Scan the repository for `shortcut:` (and legacy `ponytail:`) comment markers
2. For each marker, extract the declared ceiling and upgrade trigger
3. Flag any markers lacking an upgrade trigger with `[no-trigger]` as silent rot risks
4. Check whether expected system load crosses any active ceiling
5. Output the structured Debt Ledger, or write to `DEBT.md` if requested
