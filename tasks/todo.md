# Task List: Token Efficiency & Installer Resilience

## Wave 1: Core Skill Enhancements (Test Log Pruning & Compact Tasks)

- [x] **Task 1.1: Add Test Log Pruning to test-driven-development and debugging skills**
  - **Description**: Add guidance in `skills/test-driven-development/SKILL.md` and `skills/debugging-and-error-recovery/SKILL.md` for running focused, quiet test commands (`-q`, `--reporter=dot`, `--tb=short`) to suppress verbose logs and save context tokens.
  - **Acceptance Criteria**:
    - [x] `skills/test-driven-development/SKILL.md` updated with quiet reporter recommendations.
    - [x] `skills/debugging-and-error-recovery/SKILL.md` updated with log pruning instructions.
    - [x] `node scripts/validate-skills.js` passes.
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/test-driven-development/SKILL.md`, `skills/debugging-and-error-recovery/SKILL.md`

- [x] **Task 1.2: Add Compact Task Format for XS/S Slices to planning skill**
  - **Description**: In `skills/planning-and-task-breakdown/SKILL.md`, document the compact 3-line format for XS/S tasks to keep `tasks/todo.md` concise (<100 lines) and prevent turn-by-turn re-reading token overhead.
  - **Acceptance Criteria**:
    - [x] Compact format for small tasks documented with examples.
    - [x] `node scripts/validate-skills.js` passes.
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/planning-and-task-breakdown/SKILL.md`

## Wave 2: Cross-Platform Installer Fix

- [x] **Task 2.1: Fix Environment Variable Fallback in install-local.ps1**
  - **Description**: Update `scripts/install-local.ps1` so `$homeDir` resolves to `$env:USERPROFILE` if present, else `$env:HOME`, and `$local` resolves to `$env:LOCALAPPDATA` if present, else `$homeDir`.
  - **Acceptance Criteria**:
    - [x] `$homeDir` and `$local` handle non-Windows (macOS/Linux) environments cleanly without null-binding errors.
    - [x] Script executes without throwing parameter binding exceptions.
  - **Verification**: `pwsh -File ./scripts/install-local.ps1 -List` or bash test
  - **Files**: `scripts/install-local.ps1`

## Wave 3: Final Verification & Commit

- [x] **Task 3.1: Run Full Test Suite & Create Atomic Git Commit**
  - **Description**: Run `npm test` and verify 0 errors, then commit changes cleanly.
  - **Acceptance Criteria**:
    - [x] `npm test` passes cleanly.
    - [x] Clean git commit created.
  - **Verification**: `npm test && git status`
