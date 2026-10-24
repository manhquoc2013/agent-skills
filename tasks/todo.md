# Task List: Upgrading agent-skills with UI/UX Pro Max Design Intelligence

## Phase 1: Data & Intelligence Engine (Foundation)

- [x] **Task 1.1: Populate Canonical Datasets into frontend-ui-engineering**
  - **Description**: Copy and organize canonical CSV and JSON datasets from `docs/references/ui-ux-pro-max-skill-main/src/ui-ux-pro-max/data/` into `skills/frontend-ui-engineering/data/` (styles, products, colors, typography, ux-guidelines, ui-reasoning, charts, icons, motion, and 22 stacks).
  - **Acceptance Criteria**:
    - [x] `skills/frontend-ui-engineering/data/` contains all 17 canonical data files + `stacks/` directory with 22 stack files.
    - [x] All CSV files are intact, properly encoded in UTF-8 without corruption.
  - **Verification**: `python scripts/validate-ui-data.py` (or directory file count check)
  - **Files**: `skills/frontend-ui-engineering/data/*`

- [x] **Task 1.2: Implement Python BM25/Regex Search Engine & Design System Generator**
  - **Description**: Implement zero-dependency search engine in `skills/frontend-ui-engineering/scripts/` (`core.py`, `design_system.py`, `reasoning_contract.py`, `search.py`, `validate_data.py`, and unit tests). Update default persistence directory in `design_system.py` to `.agents/design-system/` per user approval.
  - **Acceptance Criteria**:
    - [x] Zero external dependencies (runs with python3 standard library).
    - [x] Domain search (`--domain <domain>`) returns accurate BM25-ranked results.
    - [x] `--design-system` produces complete design system (layout, style, color, typography, anti-patterns).
    - [x] `--variance`, `--motion`, `--density` dials adjust output deterministically.
    - [x] `--persist` writes to `.agents/design-system/MASTER.md` without overwriting unless `--force`.
  - **Verification**: `python skills/frontend-ui-engineering/scripts/search.py "fintech" --domain color && python -m unittest discover -s skills/frontend-ui-engineering/scripts/tests`
  - **Files**: `skills/frontend-ui-engineering/scripts/*`

### Checkpoint 1: Engine Foundation
- [x] Datasets present and valid
- [x] Search engine unit tests pass 100%

---

## Phase 2: Skill Overhaul & CLI Shortcut

- [x] **Task 2.1: Overhaul skills/frontend-ui-engineering/SKILL.md & References**
  - **Description**: Update `skills/frontend-ui-engineering/SKILL.md` to integrate the Query Contract, 10-tier rule priority matrix, stack search guidelines, anti-patterns, and the Pre-Delivery UI Checklist. Add `references/quick-reference.md` and `references/pro-rules.md`.
  - **Acceptance Criteria**:
    - [x] Frontmatter conforms to `docs/skill-anatomy.md`.
    - [x] Detailed workflow covering when to use domain search vs design-system generator.
    - [x] Standard sections included: Overview, When to Use, Process, Common Rationalizations, Red Flags, Verification.
    - [x] References `references/quick-reference.md` and `references/pro-rules.md` exist and are linked.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-reference-links.js`
  - **Files**: `skills/frontend-ui-engineering/SKILL.md`, `skills/frontend-ui-engineering/references/quick-reference.md`, `skills/frontend-ui-engineering/references/pro-rules.md`

- [x] **Task 2.2: Implement Root CLI Shortcut scripts/ui-search.sh**
  - **Description**: Create root-level executable wrapper `scripts/ui-search.sh` that delegates to `skills/frontend-ui-engineering/scripts/search.py` with automatic python3 detection and friendly error reporting.
  - **Acceptance Criteria**:
    - [x] `scripts/ui-search.sh` is executable (`chmod +x`).
    - [x] Supports all arguments passed to `search.py`.
    - [x] Handles python/python3 path resolution gracefully.
  - **Verification**: `./scripts/ui-search.sh --help && ./scripts/ui-search.sh "saas" --domain style`
  - **Files**: `scripts/ui-search.sh`, `scripts/ui-search.ps1`

### Checkpoint 2: Skill & CLI Shortcut
- [x] `node scripts/validate-skills.js` passes with 0 errors
- [x] `./scripts/ui-search.sh` runs cleanly from workspace root

---

## Phase 3: Lifecycle Hooks & Command Integration

- [x] **Task 3.1: Integrate Design System Generation into /s-spec & spec-driven-development**
  - **Description**: Update `skills/spec-driven-development/SKILL.md` to trigger `--design-system` generation during Phase 1 (Specify) whenever requirements involve user interfaces, web applications, or mobile screens, persisting to `.agents/design-system/MASTER.md`.
  - **Acceptance Criteria**:
    - [x] Workflow explicitly instructs agent to run design system generation for UI features.
    - [x] `MASTER.md` created in `.agents/design-system/` before writing frontend code.
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/spec-driven-development/SKILL.md`

- [x] **Task 3.2: Integrate Pre-Delivery UI Checklist into /s-review and /s-ship**
  - **Description**: Update `skills/code-review-and-quality/SKILL.md` and `agents/code-reviewer.md` to evaluate UI diffs against the Pre-Delivery Checklist (contrast 4.5:1, touch target 44px, no emoji icons, prefers-reduced-motion).
  - **Acceptance Criteria**:
    - [x] UI review criteria included in 4-part finding structure.
    - [x] Pre-delivery checklist verified during `/s-ship` pre-launch gate.
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/code-review-and-quality/SKILL.md`, `agents/code-reviewer.md`, `skills/shipping-and-launch/SKILL.md`

### Checkpoint 3: Lifecycle Integration
- [x] Lifecycle skills validate cleanly
- [x] Spec and review steps explicitly enforce design intelligence standards

---

## Phase 4: Asset Sync & Multi-Platform Distribution

- [x] **Task 4.1: Implement scripts/sync-assets.js**
  - **Description**: Create `scripts/sync-assets.js` to mirror datasets and scripts cleanly without symlinks, guaranteeing standalone skill portability for Issue #361.
  - **Acceptance Criteria**:
    - [x] Validates that all mirrored copies match source files byte-for-byte.
    - [x] Flags any drift or missing assets.
    - [x] Never generates symlinks.
  - **Verification**: `node scripts/sync-assets.js`
  - **Files**: `scripts/sync-assets.js`

- [ ] **Task 4.2: Update scripts/install-local.sh and scripts/build-agent-dist.js**
  - **Description**: Update local installation script to ensure Python search scripts and data directories are properly copied and marked executable across all 20+ supported tools (Claude Code, Cursor, Codex, Gemini CLI, Antigravity CLI, Windsurf, OpenCode, Copilot, etc.).
  - **Acceptance Criteria**:
    - [ ] `./scripts/install-local.sh --list` detects and lists updated frontend skill assets.
    - [ ] `scripts/build-agent-dist.js` generates correct multi-agent distribution artifacts.
  - **Verification**: `./scripts/install-local.sh --list && node scripts/build-agent-dist.js`
  - **Files**: `scripts/install-local.sh`, `scripts/build-agent-dist.js`

### Checkpoint 4: Multi-Agent Distribution
- [ ] Installer functions properly on test directories
- [ ] Assets sync cleanly with zero drift

---

## Phase 5: Validation, Tests & Documentation

- [ ] **Task 5.1: Implement scripts/validate-ui-data.py & Run Evals**
  - **Description**: Provide `scripts/validate-ui-data.py` to continuously validate dataset schemas, column headers, and Google Fonts references. Run full Python and Node test suites.
  - **Acceptance Criteria**:
    - [ ] Validates all CSV/JSON datasets.
    - [ ] Python unit tests pass 100%.
  - **Verification**: `python scripts/validate-ui-data.py && python -m unittest discover -s skills/frontend-ui-engineering/scripts/tests`
  - **Files**: `scripts/validate-ui-data.py`

- [ ] **Task 5.2: Update Documentation & Run Final Verification**
  - **Description**: Update `README.md`, `docs/skill-anatomy.md`, and references. Run full repository verification suite (`validate-skills.js`, `validate-reference-links.js`, `validate-commands.js`).
  - **Acceptance Criteria**:
    - [ ] `README.md` documents UI design intelligence capabilities and `./scripts/ui-search.sh`.
    - [ ] Zero broken links or validation errors.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-reference-links.js && node scripts/validate-commands.js`
  - **Files**: `README.md`, `docs/skill-anatomy.md`

### Final Checkpoint: Complete Upgrade Ready
- [ ] All tasks checked
- [ ] All validation commands pass
- [ ] Git commit ready
