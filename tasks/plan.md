# Implementation Plan: S-Review Token Optimization

## Overview
Optimize token consumption for the `/s-review` slash command, `code-review-and-quality` skill, and `code-reviewer` persona by enforcing scoped diff inspection, lockfile filtering, quiet test verification, bounded caller greps, and concise 4-part findings.

---

## Phase Breakdown

### Phase 1: Core Skill & Persona Directives
- Equip `skills/code-review-and-quality/SKILL.md` with:
  - Scoped diff ingestion (`git diff --stat` first).
  - Noise/lockfile filtering (`':!*lock*'`, `':!dist/*'`).
  - Targeted line slices instead of whole-file reads.
  - Quiet test runner execution during review verification.
  - Rationalization, red flags, and verification checklist updates.
- Equip `agents/code-reviewer.md` with scoped diff inspection and bounded caller tracing.

### Phase 2: Command Synchronization
- Update `.claude/commands/s-review.md`, `commands/s-review.toml`, and `.gemini/commands/s-review.toml` with the token-optimized review workflow.
- Ensure strict parity across command descriptions and schema definitions.

### Phase 3: Alias Re-sync & Test Suite Verification
- Re-sync installed IDE alias wrappers (`./scripts/install-aliases.sh --all`).
- Run `npm test` to verify 100% compliance across all 31 skills, 4 personas, and 12 commands.
