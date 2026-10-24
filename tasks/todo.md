# Task List: GSD-Inspired Quality & Orchestration Upgrades

## Phase 1: Broken-Windows & Defect Ledger (s-ship & shipping-and-launch)

- [x] **Task 1.1: Enhance skills/shipping-and-launch/SKILL.md with Broken-Windows Audit**
  - **Description**: Add Broken-Windows Audit Pass section into `skills/shipping-and-launch/SKILL.md` (scanning for `TODO`, `FIXME`, stubs, skipped tests, mock fallbacks, requiring explicit waiver in acknowledged risks).
  - **Acceptance Criteria**:
    - [x] Broken-Windows Audit Pass clearly documented with grep patterns and waiver requirements.
    - [x] Red Flags and Verification sections updated accordingly.
    - [x] Conforms 100% to `docs/skill-anatomy.md`.
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/shipping-and-launch/SKILL.md`

- [x] **Task 1.2: Synchronize Broken-Windows Gate in /s-ship Command Files**
  - **Description**: Add Broken-Windows & Stub Audit into Phase B in `commands/s-ship.toml`, `.claude/commands/s-ship.md`, `.gemini/commands/s-ship.toml`. Keep description synchronized across all files.
  - **Acceptance Criteria**:
    - [x] All three command files include Broken-Windows checking in Phase B.
    - [x] `description` string matches exactly across `.claude/commands/s-ship.md`, `commands/s-ship.toml`, `.gemini/commands/s-ship.toml`.
  - **Verification**: `node scripts/validate-commands.js`
  - **Files**: `commands/s-ship.toml`, `.claude/commands/s-ship.md`, `.gemini/commands/s-ship.toml`

### Checkpoint 1: Broken-Windows
- [x] `npm test` passes for shipping-and-launch and s-ship.

---

## Phase 2: Anti-Thrashing Forensics & Session State Handoff

- [x] **Task 2.1: Enhance skills/autonomous-agent-workflow/SKILL.md and s-agent Commands**
  - **Description**: In `skills/autonomous-agent-workflow/SKILL.md`, add Thrashing Detection to Phase 4 (if file churn > 3 iterations without green tests, pause and run forensics) and add Session Checkpointing (`tasks/handoff.md`). Update `commands/s-agent.toml`, `.claude/commands/s-agent.md`, `.gemini/commands/s-agent.toml` with thrashing detection and checkpoint instructions.
  - **Acceptance Criteria**:
    - [x] Thrashing threshold (>3 edits without green) explicitly defined with recovery steps.
    - [x] Standard `tasks/handoff.md` structure documented.
    - [x] `description` string matches exactly across Claude, toml, and Gemini s-agent command files.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-commands.js`
  - **Files**: `skills/autonomous-agent-workflow/SKILL.md`, `commands/s-agent.toml`, `.claude/commands/s-agent.md`, `.gemini/commands/s-agent.toml`

- [x] **Task 2.2: Add --forensics Mode to skills/debugging-and-error-recovery/SKILL.md and s-debug Commands**
  - **Description**: Add git history forensics pass (`--forensics`) to `skills/debugging-and-error-recovery/SKILL.md` (analyzing commit churn, diff variance, repeated file edits) and update debug command files (`commands/s-debug.toml`, `.claude/commands/s-debug.md`, `.gemini/commands/s-debug.toml`).
  - **Acceptance Criteria**:
    - [x] `--forensics` documented for diagnosing stuck loops, regression gaps, and file churn.
    - [x] Command parity and description match across Claude, toml, and Gemini debug command files.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-commands.js`
  - **Files**: `skills/debugging-and-error-recovery/SKILL.md`, `commands/s-debug.toml`, `.claude/commands/s-debug.md`, `.gemini/commands/s-debug.toml`

### Checkpoint 2: Anti-Thrashing & Forensics
- [x] `npm test` passes for autonomous-agent-workflow, debugging, and commands.

---

## Phase 3: Wave-Based Execution Planning & Drift Pre-checks

- [x] **Task 3.1: Enhance skills/planning-and-task-breakdown/SKILL.md and s-plan Commands**
  - **Description**: Add Execution Wave decomposition (Wave 1: Foundation/Contracts → Wave 2: Parallel Components → Wave 3: Integration) and Plan Convergence self-critique pass into `skills/planning-and-task-breakdown/SKILL.md` and sync with `commands/s-planning.toml`, `.claude/commands/s-plan.md`, `.gemini/commands/s-planning.toml`.
  - **Acceptance Criteria**:
    - [x] Wave-based breakdown guidelines added for safe sub-agent parallelism.
    - [x] Plan critique check added to verify against acceptance criteria before human approval.
    - [x] Command parity and description match across all plan command files.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-commands.js`
  - **Files**: `skills/planning-and-task-breakdown/SKILL.md`, `commands/s-planning.toml`, `.claude/commands/s-plan.md`, `.gemini/commands/s-planning.toml`

- [x] **Task 3.2: Enhance skills/spec-driven-development/SKILL.md and s-spec Commands**
  - **Description**: Add Schema Drift & Context Drift pre-checks into `skills/spec-driven-development/SKILL.md` and update `commands/s-spec.toml`, `.claude/commands/s-spec.md`, `.gemini/commands/s-spec.toml`.
  - **Acceptance Criteria**:
    - [x] Schema drift check (schema vs migrations vs models) documented.
    - [x] Context drift check (verifying upstream requirements have not diverged) documented.
    - [x] Description match across all spec command files.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-commands.js`
  - **Files**: `skills/spec-driven-development/SKILL.md`, `commands/s-spec.toml`, `.claude/commands/s-spec.md`, `.gemini/commands/s-spec.toml`

### Checkpoint 3: Waves & Drift
- [x] `npm test` passes 100% across all 31 skills, 4 personas, 12 commands, and reference links.

---

## Phase 4: Final Verification & Git Commit

- [x] **Task 4.1: Run Full Test Suite & Sanity Audit**
  - **Description**: Execute `npm test` and verify clean exit with 0 errors and 0 warnings.
  - **Acceptance Criteria**:
    - [x] `npm test` passes cleanly.
  - **Verification**: `npm test`

- [x] **Task 4.2: Create Clean Git Commit**
  - **Description**: Stage all updated skill and command files and create an atomic git commit.
  - **Acceptance Criteria**:
    - [x] Clean git working tree with meaningful commit message.
  - **Verification**: `git status && git log -1`
