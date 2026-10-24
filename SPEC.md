# Specification: Skill Catalog Reconciliation, Meta-Skill Discovery Completeness & Plugin Synchronization

## Objective

Remediate the documentation drift and meta-skill discovery gaps identified during the multi-axis review:
1. **Catalog Inventory Reconciliation in `README.md`**: Update total skill count from 29 to 31 (30 lifecycle skills + 1 `using-agent-skills` meta-skill), and integrate `technical-debt-and-shortcuts` into the catalog table.
2. **Meta-Skill Discovery Completeness in `skills/using-agent-skills/SKILL.md`**: Expand the ASCII Skill Discovery decision tree and Quick Reference table to encompass all 31 skills (adding `technical-debt-and-shortcuts`, `autonomous-agent-workflow`, `dispatching-parallel-agents`, `receiving-code-review`, and `verification-before-completion`).
3. **Multi-Agent Distribution Build & Local Plugin Sync**: Rebuild all multi-agent manifests via `scripts/build-agent-dist.js` and synchronize the local Antigravity plugin and slash commands via `scripts/install-local.sh` and `scripts/install-aliases.sh`.

---

## Architectural Changes & Feature Set

### 1. Catalog Reconciliation (`README.md` & `AGENTS.md`)
- Update `README.md` heading `## All 29 Skills` to `## All 31 Skills`.
- In `README.md`, add `technical-debt-and-shortcuts` to the Review / Quality table with proper anchor, description, and "Use When" guidance.
- Align `AGENTS.md` intent-to-skill and lifecycle mapping to reflect full orchestration capabilities (`autonomous-agent-workflow` for end-to-end features, `dispatching-parallel-agents` for parallel sub-agents).

### 2. Meta-Skill Routing Completeness (`skills/using-agent-skills/SKILL.md`)
- In the **Skill Discovery** decision tree:
  - Add `Autonomous end-to-end development? ──→ autonomous-agent-workflow`
  - Add `Multiple independent sub-problems? ──→ dispatching-parallel-agents`
  - Add `Receiving / addressing review feedback? ──→ receiving-code-review`
  - Add `Pre-commit / marking work done? ──→ verification-before-completion`
  - Add `Deliberate shortcuts / technical debt? ──→ technical-debt-and-shortcuts`
- In the **Quick Reference** table:
  - Add missing skills mapped to their canonical lifecycle phases (Meta, Build, Verify, Review).
- Maintain skill line budget strictly under the 500-line ceiling.

### 3. Distribution Rebuild & Local Sync
- Run `node scripts/build-agent-dist.js` to regenerate manifests.
- Re-sync local Antigravity plugin directory and aliases.
- Execute full test suite: `npm test` and node test suites.

---

## Validation Strategy
- `node scripts/validate-skills.js`: 31 skills conform to anatomy rules and line budget.
- `node scripts/validate-commands.js`: 12 commands conform to parity.
- `node scripts/validate-reference-links.js`: 0 broken links.
- `npm test`: Clean pass with 0 errors.
