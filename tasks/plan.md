# Implementation Plan: Upgrading agent-skills with UI/UX Pro Max Design Intelligence

## Overview

This implementation plan decomposes the upgrade of `agent-skills` into vertical, verifiable tasks across 5 phases. The goal is to integrate UI UX Pro Max's design intelligence into `skills/frontend-ui-engineering/`, provide zero-dependency Python BM25/regex search capabilities, bind design system creation into `/s-spec` and `/s-build`, add pre-delivery UI validation into `/s-review` and `/s-ship`, implement asset-sync to resolve Issue #361, and provide multi-platform installer support.

## Architecture Decisions

1. **Direct Embedding in `skills/frontend-ui-engineering/`**: Rather than creating a detached skill, `frontend-ui-engineering` is transformed into an all-in-one production skill containing `data/` (79 styles, 192 reasoning profiles, 192 palettes, 74 typography pairings, 119 UX guidelines, 22 stacks, 25 charts, 105 icons, 17 motion presets) and `scripts/` (search engine, design system generator, reasoning contract).
2. **Zero-Dependency Python Search Engine**: Standard library Python 3 only (`csv`, `json`, `math`, `re`, `argparse`, `sys`, `pathlib`). Executes in <100ms on any machine without `pip install`.
3. **Workspace Standard Persistence**: Generated design systems persist to `.agents/design-system/MASTER.md` and `.agents/design-system/pages/<page-slug>.md` to maintain consistency across agent sessions.
4. **Root CLI Shortcut**: Create `scripts/ui-search.sh` (and `scripts/ui-search.ps1`) for instant user and agent querying.
5. **No Symlinks (Windows & Single-Skill Safe)**: Implement `scripts/sync-assets.js` to mirror necessary assets cleanly without symlinks, guaranteeing single-skill distribution portability (resolving Issue #361).
6. **Unified Multi-Agent Distribution**: Update `scripts/install-local.sh` and `scripts/build-agent-dist.js` to distribute data-backed skills and execution permissions to all 20+ supported AI tools.

---

## Dependency Graph & Build Order

```
[Phase 1: Data & Intelligence Engine]
  ├── Canonical CSVs & JSONs -> skills/frontend-ui-engineering/data/
  └── Python Search & Design System Generator -> skills/frontend-ui-engineering/scripts/
           │
           ▼
[Phase 2: Skill Overhaul & CLI Shortcut]
  ├── Update skills/frontend-ui-engineering/SKILL.md & references/
  └── Implement scripts/ui-search.sh
           │
           ▼
[Phase 3: Lifecycle Hooks & Command Integration]
  ├── Bind to /s-spec (generate MASTER.md in .agents/design-system/)
  ├── Bind to /s-build (query stack recipes and tokens)
  └── Bind to /s-review and /s-ship (Pre-Delivery UI Checklist)
           │
           ▼
[Phase 4: Asset Sync & Multi-Platform Installer]
  ├── Implement scripts/sync-assets.js (No-symlink asset mirror, solves #361)
  ├── Update scripts/install-local.sh (file permissions & data copying)
  └── Update scripts/build-agent-dist.js (20+ agents)
           │
           ▼
[Phase 5: Validation, Tests & Documentation]
  ├── Implement scripts/validate-ui-data.py & Python unit tests
  ├── Run node scripts/validate-skills.js & link checker
  └── Update README.md, INSTALL.md, and docs/
```

---

## Task List

### Phase 1: Data & Intelligence Engine (Foundation)
- [ ] **Task 1.1**: Migrate and curate canonical datasets into `skills/frontend-ui-engineering/data/` (styles, products, colors, typography, ux-guidelines, ui-reasoning, charts, icons, motion, stacks).
- [ ] **Task 1.2**: Implement Python BM25/Regex search engine and Design System generator in `skills/frontend-ui-engineering/scripts/` (`core.py`, `design_system.py`, `reasoning_contract.py`, `search.py`), configured to save to `.agents/design-system/`.

### Checkpoint 1: Engine Verified
- [ ] `python skills/frontend-ui-engineering/scripts/search.py "fintech dashboard" --domain color` returns valid palette.
- [ ] `python skills/frontend-ui-engineering/scripts/search.py "saas modern" --design-system` generates complete design system in <200ms.

### Phase 2: Skill Overhaul & CLI Shortcut
- [ ] **Task 2.1**: Rewrite `skills/frontend-ui-engineering/SKILL.md` to incorporate the Query Contract, 10-tier rule priority, pre-delivery checklist, anti-patterns, and stack guides. Add `references/quick-reference.md` and `references/pro-rules.md`.
- [ ] **Task 2.2**: Implement root-level executable wrapper `scripts/ui-search.sh` and make it executable.

### Checkpoint 2: Skill Content Verified
- [ ] `node scripts/validate-skills.js` passes with 0 errors.
- [ ] `./scripts/ui-search.sh "minimal blog" --design-system` runs successfully from repo root.

### Phase 3: Lifecycle Integration
- [ ] **Task 3.1**: Update `/s-spec` (`skills/spec-driven-development/SKILL.md`) to automatically invoke design system generation when UI/frontend requirements are detected, saving to `.agents/design-system/MASTER.md`.
- [ ] **Task 3.2**: Update `/s-review` (`skills/code-review-and-quality/SKILL.md` & `agents/code-reviewer.md`) and `/s-ship` to enforce the Pre-Delivery UI Checklist on frontend PRs.

### Checkpoint 3: Lifecycle Verified
- [ ] Spec generation test produces `.agents/design-system/MASTER.md`.
- [ ] Code reviewer recognizes UI anti-patterns (contrast, emoji icons, missing reduced-motion).

### Phase 4: Asset Sync & Multi-Platform Distribution
- [ ] **Task 4.1**: Implement `scripts/sync-assets.js` to mirror data and scripts without symlinks.
- [ ] **Task 4.2**: Update `scripts/install-local.sh` and `scripts/build-agent-dist.js` to distribute data-backed skills and permissions across 20+ agents.

### Checkpoint 4: Distribution Verified
- [ ] `./scripts/install-local.sh --list` recognizes new executable skill assets.
- [ ] `node scripts/sync-assets.js` verifies 100% asset synchronization.

### Phase 5: Validation, Tests & Documentation
- [ ] **Task 5.1**: Implement `scripts/validate-ui-data.py` and run Python test suite (`python -m unittest discover -s skills/frontend-ui-engineering/scripts/tests`).
- [ ] **Task 5.2**: Update `README.md`, `docs/skill-anatomy.md`, and multi-agent documentation. Run complete validation suite (`validate-skills.js`, `validate-reference-links.js`).

### Final Checkpoint: Full System Operational
- [ ] All validation scripts pass with 0 warnings/errors.
- [ ] Git working tree clean and ready for deployment.
