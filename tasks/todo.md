# Task List: S-Review Empirical Grounding & Intent Handling

## Wave 1: Token Optimization for Code Review & Commands
- [x] **Task 1.1: Add Scoped Diff Ingestion & Quiet Verification to code-review-and-quality** ([S])
  - **Scope**: Add Token Efficiency directives (scoped stat first, lockfile exclusion, quiet test runners) and update rationalizations, red flags, and verification checklist.
  - **Verify**: `node scripts/validate-skills.js`
  - **Files**: `skills/code-review-and-quality/SKILL.md`

- [x] **Task 1.2: Upgrade code-reviewer persona with token-efficiency steps** ([XS])
  - **Scope**: Update `agents/code-reviewer.md` with scoped diff ingestion and bounded caller tracing.
  - **Verify**: `node scripts/validate-skills.js`
  - **Files**: `agents/code-reviewer.md`

- [x] **Task 1.3: Synchronize token-optimized workflow across all /s-review command files** ([S])
  - **Scope**: Update `.claude/commands/s-review.md`, `commands/s-review.toml`, `.gemini/commands/s-review.toml` with token-efficient workflow and 3-tier finding triage.
  - **Verify**: `node scripts/validate-commands.js`
  - **Files**: `.claude/commands/s-review.md`, `commands/s-review.toml`, `.gemini/commands/s-review.toml`

## Wave 2: Empirical Grounding & User Intent Fidelity (Anti-Hallucination)
- [x] **Task 2.1: Add empirical grounding and anti-hallucination rules to code-review-and-quality** ([S])
  - **Scope**: Anchor Step 1, Honesty in Review, Rationalizations, Red Flags, and Verification checklist in verifiable workspace code facts and user prompt instructions.
  - **Verify**: `node scripts/validate-skills.js`
  - **Files**: `skills/code-review-and-quality/SKILL.md`

- [x] **Task 2.2: Add Scope & Intent handling with empirical verification to /s-review command files** ([S])
  - **Scope**: Update `.claude/commands/s-review.md`, `commands/s-review.toml`, `.gemini/commands/s-review.toml`, and `agents/code-reviewer.md` to parse custom arguments, target files, and enforce zero-hallucination findings.
  - **Verify**: `node scripts/validate-commands.js`
  - **Files**: `.claude/commands/s-review.md`, `commands/s-review.toml`, `.gemini/commands/s-review.toml`, `agents/code-reviewer.md`

## Wave 3: Alias Re-sync & Verification
- [x] **Task 3.1: Re-sync installed IDE alias skills** ([XS])
  - **Scope**: Run `./scripts/install-aliases.sh --all` to update installed `/s-review` wrappers across IDE targets.
  - **Verify**: `./scripts/install-aliases.sh --list`
  - **Files**: `scripts/install-aliases.sh`

- [x] **Task 3.2: Full test suite verification** ([XS])
  - **Scope**: Run `npm test` and verify 0 errors, 0 warnings.
  - **Verify**: `npm test`
  - **Files**: All modified files
