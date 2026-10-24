# Implementation Plan: Token Efficiency & Installer Resilience

## Overview

Execute token-reduction enhancements across core skills and fix the PowerShell installer's cross-platform environment variable resolution.

---

## Phase Breakdown

### Phase 1: Test Log Pruning & Context Protection
- **Components**:
  - Update `skills/test-driven-development/SKILL.md` with log pruning directives (quiet/focused reporters, failure-only stack traces).
  - Update `skills/debugging-and-error-recovery/SKILL.md` with concise failure capture guidelines.
- **Verification**: `node scripts/validate-skills.js`.

### Phase 2: Lean Task Formatting in Planning
- **Components**:
  - Update `skills/planning-and-task-breakdown/SKILL.md` to document the 3-line compact format for XS/S tasks to keep `tasks/todo.md` token-efficient.
- **Verification**: `node scripts/validate-skills.js`.

### Phase 3: Cross-Platform Fix for install-local.ps1
- **Components**:
  - Update `scripts/install-local.ps1` to fall back to `$env:HOME` when `$env:USERPROFILE` is undefined.
- **Verification**: Run `pwsh ./scripts/install-local.ps1 -List` or syntax validation.

### Phase 4: Full Validation & Git Commit
- **Verification**: `npm test` passes cleanly.
