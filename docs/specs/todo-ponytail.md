# Task List: Upgrading agent-skills with Ponytail Engineering Patterns

## Phase 1: Core Ladder & Debt Skill (Foundation)

- [x] **Task 1: Update code-simplification with 6-Rung Ladder & Modes**
  - **Description**: Enhance `skills/code-simplification/SKILL.md` to introduce Ponytail's 6-Rung Ladder, 3 operating modes (`lite`, `full`, `ultra`), automatic mode switching, and invariant protections.
  - **Acceptance Criteria**:
    - [x] 6-Rung Ladder documented clearly with code examples.
    - [x] `lite`, `full`, and `ultra` modes defined with trigger keywords and automatic detection guidelines.
    - [x] Invariants (security, validation, accessibility, data-loss safeguards) marked as non-negotiable.
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/code-simplification/SKILL.md`

- [x] **Task 2: Create technical-debt-and-shortcuts Skill**
  - **Description**: Add `skills/technical-debt-and-shortcuts/SKILL.md` defining the `shortcut: <ceiling>, <upgrade-trigger>` comment convention, debt ledger format, and rot prevention (`no-trigger` warnings).
  - **Acceptance Criteria**:
    - [x] Follows all sections of `docs/skill-anatomy.md`.
    - [x] Explains comment format, scanning mechanics, and ledger output structure.
    - [x] Defines boundaries (read-only scan vs. generating `DEBT.md`).
  - **Verification**: `node scripts/validate-skills.js`
  - **Files**: `skills/technical-debt-and-shortcuts/SKILL.md`

- [x] **Task 3: Implement /s-debt Command and Scanner Script**
  - **Description**: Create `.claude/commands/s-debt.md` and implement fast debt scanner utility in Node.js and Bash.
  - **Acceptance Criteria**:
    - [x] `.claude/commands/s-debt.md` created and conforms to command standards.
    - [x] `scripts/scan-debt.js` and `scripts/scan-debt.sh` created, correctly scanning git-tracked files (respecting `.gitignore`) for `shortcut:` markers.
    - [x] Reports ceiling, upgrade trigger, and flags `no-trigger` risks.
  - **Verification**: `node scripts/validate-commands.js && bash scripts/scan-debt.sh`
  - **Files**: `.claude/commands/s-debt.md`, `scripts/scan-debt.js`, `scripts/scan-debt.sh`

### Checkpoint 1: Foundation
- [x] `node scripts/validate-skills.js` passes with 0 errors
- [x] `node scripts/validate-commands.js` passes with 0 errors
- [x] Debt scanner successfully detects test markers

---

## Phase 2: Review & Audit Overhaul

- [x] **Task 4: Upgrade code-review-and-quality & code-reviewer Persona**
  - **Description**: Upgrade `skills/code-review-and-quality/SKILL.md` and `agents/code-reviewer.md` with Ponytail's 4-part finding structure, out-of-diff caller tracing, assumed load profiling, and 3-tier numbered triage.
  - **Acceptance Criteria**:
    - [x] Enforces 4-part finding structure: *What this is*, *Problem* (with concrete reproduction case), *Fix* (minimal diff), *If we skip it*.
    - [x] Mandates out-of-diff caller impact analysis across untouched files.
    - [x] Categorizes findings into *Must fix*, *Should fix*, and *Nice to have* with contiguous global numbering.
  - **Verification**: `node scripts/validate-skills.js && node scripts/validate-reference-links.js`
  - **Files**: `skills/code-review-and-quality/SKILL.md`, `agents/code-reviewer.md`

### Checkpoint 2: Review Engine
- [x] `node scripts/validate-skills.js` passes
- [x] `node scripts/validate-reference-links.js` passes

---

## Phase 3: Universal Multi-Agent Packaging & Distribution

- [x] **Task 5: Implement build-agent-dist.js Generator**
  - **Description**: Create `scripts/build-agent-dist.js` to parse `skills/`, `agents/`, and `references/` and generate native configurations and rule files for 20+ agents.
  - **Acceptance Criteria**:
    - [x] Script runs without external dependencies.
    - [x] Generates valid markdown and json descriptors for each target IDE/agent.
  - **Verification**: `node scripts/build-agent-dist.js`
  - **Files**: `scripts/build-agent-dist.js`

- [x] **Task 6: Populate Multi-Agent Configurations**
  - **Description**: Generate and check in configurations for Cursor, OpenCode, Codex, Gemini CLI, Copilot, Windsurf, Cline, Antigravity, Devin, Grok, Kimi, Kiro, OpenClaw, Qoder, Pi agent, Hermes.
  - **Acceptance Criteria**:
    - [x] `.cursor/rules/`, `.cursor/hooks.json`, `scripts/cursor-hooks.js` present.
    - [x] `.opencode/`, `opencode.json`, `package.json` configured.
    - [x] `.codex-plugin/`, `gemini-extension.json`, `.github/copilot-instructions.md`, `.windsurf/rules/`, `.clinerules/` present.
    - [x] Unified `AGENTS.md` updated and synchronized across all environments.
  - **Verification**: `node scripts/validate-artifact-paths.js`
  - **Files**: Multiple directories under root (`.cursor/`, `.opencode/`, `.codex-plugin/`, etc.)

- [x] **Task 7: Update Documentation (INSTALL.md & README.md)**
  - **Description**: Provide comprehensive installation, configuration, and uninstallation guides for all 20+ supported agents.
  - **Acceptance Criteria**:
    - [x] `INSTALL.md` has dedicated sections for each agent.
    - [x] `README.md` updated with multi-agent compatibility badges and table.
  - **Verification**: `node scripts/validate-reference-links.js`
  - **Files**: `INSTALL.md`, `README.md`

### Checkpoint 3: Multi-Agent Packaging
- [x] All 20+ agent configurations present and synchronized
- [x] `node scripts/validate-reference-links.js` passes with 0 broken links

---

## Phase 4: Statusline & Lifecycle Hooks

- [x] **Task 8: Implement Dynamic Statusline Utility**
  - **Description**: Create `scripts/statusline.sh` and `scripts/statusline.ps1` providing prompt/status bar integration that reflects current lifecycle stage (`[SPEC]`, `[BUILD]`, `[REVIEW]`, etc.), active mode (`lite`/`full`/`ultra`), and active shortcut debt.
  - **Acceptance Criteria**:
    - [x] `scripts/statusline.sh` runs in POSIX bash/zsh.
    - [x] `scripts/statusline.ps1` runs in PowerShell.
    - [x] Fast execution (<20ms) suitable for shell prompt or agent statusline.
  - **Verification**: `bash scripts/statusline.sh`
  - **Files**: `scripts/statusline.sh`, `scripts/statusline.ps1`

- [x] **Task 9: Add Lifecycle Hook Adapters**
  - **Description**: Configure session lifecycle hooks for Claude Code, Codex, and Cursor to automatically inject active mode and lifecycle phase context.
  - **Acceptance Criteria**:
    - [x] Hooks cleanly set and track active mode without blocking.
    - [x] Mode persists across turns or sessions as configured.
  - **Verification**: Inspect hook definitions in `hooks/`
  - **Files**: `hooks/agent-mode-hook.js`, `hooks/claude-hooks.json`, `hooks/cursor-hooks.json`

### Checkpoint 4: Hooks & Statusline
- [x] Statusline renders cleanly in terminal
- [x] Hooks register and pass validation

---

## Phase 5: Verification & Evals

- [x] **Task 10: Add Evals and Execute Complete Test Suite**
  - **Description**: Add test eval scenarios for debt tracking and anti-bloat in `evals/`, and run the complete validation suite.
  - **Acceptance Criteria**:
    - [x] `evals/` includes trigger evals for `technical-debt-and-shortcuts`.
    - [x] `node scripts/run-evals.js` passes 100%.
    - [x] `node scripts/validate-skills.js` passes 100%.
    - [x] `node scripts/validate-commands.js` passes 100%.
    - [x] `node scripts/validate-reference-links.js` passes 100%.
  - **Verification**: Run all scripts sequentially.
  - **Files**: `evals/cases/technical-debt.json`, test scripts

### Final Checkpoint: Complete Upgrade
- [x] All tasks checked off
- [x] Repository in healthy, production-ready state
