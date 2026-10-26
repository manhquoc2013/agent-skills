# Implementation Plan: Upgrading agent-skills with Ponytail Patterns

## Overview

This plan decomposes the upgrade of `agent-skills` into vertical, verifiable tasks across 5 phases. The goal is to integrate Ponytail's 6-rung ladder anti-bloat philosophy, technical debt ledger system (`/s-debt`), high-signal 4-part review schema, universal 20+ agent packaging, and cross-platform statusline/hooks.

## Architecture Decisions

1. **Markdown-First Single Source of Truth**: All core engineering principles originate in `skills/`, `agents/`, and `references/`. Multi-agent directories (`.cursor/`, `.windsurf/`, `.clinerules/`, `.opencode/`, etc.) will be maintained and synchronized via `scripts/build-agent-dist.js` to prevent drift.
2. **First-Class `/s-debt` Command**: Technical debt tracking is decoupled into its own skill and slash command (`skills/technical-debt-and-shortcuts/SKILL.md` + `.claude/commands/s-debt.md`) with a fast Node/shell scanner (`scripts/scan-debt.js` / `scripts/scan-debt.sh`).
3. **Structured Review Finding Contract**: Every review finding strictly conforms to the 4-part schema (*What this is / Problem / Fix / If we skip it*) with concrete reproduction cases and out-of-diff ripple tracing.
4. **Zero External Runtime Dependencies**: All validation, scanning, and distribution scripts run natively on Node.js using built-in modules (`fs`, `path`, `child_process`).

---

## Task List

### Phase 1: Core Ladder & Debt Skill (Foundation)
- [ ] **Task 1**: Update `skills/code-simplification/SKILL.md` to incorporate the 6-Rung Ladder, 3 operating modes (`lite`, `full`, `ultra`), and automatic mode switching.
- [ ] **Task 2**: Create new skill `skills/technical-debt-and-shortcuts/SKILL.md` defining the `shortcut: <ceiling>, <upgrade-trigger>` syntax, rot detection, and ledger generation.
- [ ] **Task 3**: Create `.claude/commands/s-debt.md` and implement the debt scanner script `scripts/scan-debt.js` / `scripts/scan-debt.sh`.

### Checkpoint 1: Foundation Verified
- [ ] `node scripts/validate-skills.js` passes cleanly.
- [ ] Debt scanner runs on current repo and correctly detects/reports shortcut markers.

### Phase 2: Review & Audit Overhaul
- [ ] **Task 4**: Upgrade `skills/code-review-and-quality/SKILL.md` and `agents/code-reviewer.md` with the 4-part finding schema (*What this is / Problem / Fix / If we skip it*), out-of-diff ripple analysis, and triaged severity (*Must fix / Should fix / Nice to have*).

### Checkpoint 2: Review Engine Verified
- [ ] `node scripts/validate-skills.js` and `node scripts/validate-reference-links.js` pass.
- [ ] Review template conforms to skill anatomy.

### Phase 3: Universal Multi-Agent Packaging & Distribution
- [ ] **Task 5**: Build the generator script `scripts/build-agent-dist.js` to compile and synchronize rules, manifests, and plugins for 20+ agents.
- [ ] **Task 6**: Generate and populate distribution packages:
  - Cursor (`.cursor/rules/`, `.cursor/hooks.json`, `scripts/cursor-hooks.js`)
  - OpenCode (`.opencode/`, `opencode.json`, `package.json`)
  - OpenAI Codex (`.codex-plugin/`)
  - Gemini CLI (`gemini-extension.json`)
  - GitHub Copilot (`.github/copilot-instructions.md`, `hooks/copilot-hooks.json`)
  - Windsurf (`.windsurf/rules/`)
  - Cline / Roo (`.clinerules/`)
  - Antigravity, Devin, Grok, Kimi, Kiro, OpenClaw, Qoder, Pi agent, Hermes descriptors.
- [ ] **Task 7**: Update `INSTALL.md` and `README.md` with multi-agent installation guides and compatibility matrix.

### Checkpoint 3: Multi-Agent Packaging Verified
- [ ] `node scripts/build-agent-dist.js` executes without errors.
- [ ] All generated configs validate against their platform schemas.
- [ ] `node scripts/validate-reference-links.js` passes.

### Phase 4: Statusline & Lifecycle Hooks
- [ ] **Task 8**: Implement cross-platform statusline `scripts/statusline.sh` and `scripts/statusline.ps1` displaying active lifecycle phase (`[SPEC]`, `[PLAN]`, `[BUILD]`, `[REVIEW]`, `[SHIP]`), mode (`lite`/`full`/`ultra`), and debt count.
- [ ] **Task 9**: Add lifecycle hooks for Claude Code, Codex, and Cursor.

### Checkpoint 4: Hooks & Statusline Verified
- [ ] Statusline executes in terminal and renders expected badges.
- [ ] Lifecycle hooks register properly without hanging.

### Phase 5: Verification & Evals
- [ ] **Task 10**: Add eval cases in `evals/` for `technical-debt-and-shortcuts` and updated `code-simplification`. Run complete eval suite (`node scripts/run-evals.js`).

### Final Checkpoint: Complete Upgrade
- [ ] All validation scripts pass (skills, commands, reference links, artifact paths).
- [ ] All evals pass.
- [ ] Full repository health verified.

---

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Rule drift across 20+ agent directories | High | Enforce `scripts/build-agent-dist.js` as single build step; add CI check to prevent manual edits in generated folders. |
| Incompatible hook format across agents | Medium | Use standalone scripts with fallbacks; if an agent lacks hook support, fall back gracefully to instruction-based execution. |
| Over-aggressive code cutting by agents in `ultra` mode | Medium | Strictly document invariants: never cut validation at trust boundaries, security, data-loss protection, or accessibility. |
