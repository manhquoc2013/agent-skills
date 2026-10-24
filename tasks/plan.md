# Implementation Plan: GSD-Inspired Quality & Orchestration Upgrades

## Overview

Upgrade `agent-skills` with architectural improvements from `gsd-core-next` (Broken-Windows defect ledger, Anti-thrashing forensics, Session handoff, Execution waves, Drift detection) while maintaining full parity across all command files and passing all validation suites.

---

## Phase Breakdown

### Phase 1: Broken-Windows & Defect Ledger (`shipping-and-launch` & `s-ship`)
- **Goal**: Prevent stealth debt and stub accumulation before shipping.
- **Components**:
  - Update `skills/shipping-and-launch/SKILL.md` with Broken-Windows audit protocol and stub scanner instructions.
  - Update `commands/s-ship.toml`, `.claude/commands/s-ship.md`, `.gemini/commands/s-ship.toml` with Broken-Windows gate in Phase B.
- **Verification**: `npm test` checks command parity and skill anatomy.

### Phase 2: Anti-Thrashing Forensics & Session State Handoff (`autonomous-agent-workflow`, `s-agent`, `debugging-and-error-recovery`, `s-debug`)
- **Goal**: Prevent infinite trial-and-error loops and enable clean session pausing/resuming.
- **Components**:
  - Update `skills/autonomous-agent-workflow/SKILL.md` with File Thrashing detection in Phase 4 and Session Checkpoint (`tasks/handoff.md`) format.
  - Update `commands/s-agent.toml`, `.claude/commands/s-agent.md`, `.gemini/commands/s-agent.toml` with thrashing guard and handoff capability.
  - Update `skills/debugging-and-error-recovery/SKILL.md` and debug command files (`commands/s-debug.toml`, `.claude/commands/s-debug.md`, `.gemini/commands/s-debug.toml`) with `--forensics` mode (commit churn and diff analysis).
- **Verification**: `npm test` checks command parity and skill anatomy.

### Phase 3: Wave-Based Execution Planning & Drift Pre-checks (`planning-and-task-breakdown`, `s-plan`/`s-planning`, `spec-driven-development`, `s-spec`)
- **Goal**: Support safe sub-agent parallelism without git conflicts, and prevent stale architectural drift.
- **Components**:
  - Update `skills/planning-and-task-breakdown/SKILL.md` with Wave-based breakdown (Wave 1: Foundation → Wave 2: Parallel Services/Components → Wave 3: Integration) and self-convergence plan critique.
  - Update `commands/s-planning.toml`, `.claude/commands/s-plan.md`, `.gemini/commands/s-planning.toml` with Wave-based execution instructions.
  - Update `skills/spec-driven-development/SKILL.md` and spec command files (`commands/s-spec.toml`, `.claude/commands/s-spec.md`, `.gemini/commands/s-spec.toml`) with Schema Drift & Context Drift pre-checks.
- **Verification**: `npm test` checks command parity and skill anatomy.

### Phase 4: Final Verification, Parity Audit & Commit
- **Goal**: Complete validation across repository, ensure 100% test passing, and commit changes cleanly.
- **Verification**: `npm test` (31 skills, 4 personas, 12 commands parity, references check).
