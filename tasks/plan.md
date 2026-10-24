# Implementation Plan: Catalog Reconciliation & Meta-Skill Completeness

## Overview
Implement the three-part optimization resulting from the multi-axis review: reconcile `README.md` and `AGENTS.md` to reflect all 31 skills, complete discovery routing in `skills/using-agent-skills/SKILL.md`, and synchronize local plugin and IDE distributions.

---

## Phase Breakdown

### Wave 1: Catalog Inventory & Intent Alignment
- Reconcile `README.md`:
  - Change heading from `## All 29 Skills` to `## All 31 Skills`.
  - Add `technical-debt-and-shortcuts` entry to the Review/Quality table.
- Align `AGENTS.md`:
  - Add `autonomous-agent-workflow` and `dispatching-parallel-agents` to the Intent → Skill Mapping.

### Wave 2: Meta-Skill Discovery Tree & Reference Table Expansion
- In `skills/using-agent-skills/SKILL.md`:
  - Update the ASCII decision tree to branch to `autonomous-agent-workflow`, `dispatching-parallel-agents`, `receiving-code-review`, `verification-before-completion`, and `technical-debt-and-shortcuts`.
  - Expand the Quick Reference table with the 5 omitted skills mapped to their respective phases.
  - Verify line count remains well below 500 lines.

### Wave 3: Distribution Rebuild, Local Plugin Re-sync & Verification
- Execute `node scripts/build-agent-dist.js` to synchronize all 15+ multi-agent distributions.
- Run `./scripts/install-local.sh --all` and `./scripts/install-aliases.sh --all` to re-sync local IDE environments.
- Verify through `npm test`.
