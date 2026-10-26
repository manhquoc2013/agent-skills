# Spec: Upgrading agent-skills with Ponytail Engineering Patterns

## Objective

Elevate `agent-skills` from a Claude-centric skill catalog into an industry-leading, multi-agent engineering operating system by incorporating the proven, high-impact mechanisms of **Ponytail** (`docs/references/ponytail-main`). 

Ponytail demonstrates empirical benchmark advantages (-53% code bloat, -45% token consumption, 98% risky-logic test retention) through:
1. **The 6-Rung Ladder & Anti-Bloat Modes** (YAGNI, maximum reuse of platform & existing codebase, pushback on speculative complexity).
2. **Deliberate Technical Debt Tracking** (`shortcut: <ceiling>, <upgrade-trigger>` convention with automated ledger scanning).
3. **High-Signal, Concrete Review & Audit Standards** (4-part finding structure, mandatory caller-impact analysis outside the diff, load-assumed triage).
4. **Universal 20+ Agent Multi-Platform Support** (Cursor, Codex, OpenCode, Copilot, Gemini CLI, Windsurf, Cline, Antigravity, etc.).
5. **Session Lifecycle Hooks & Telemetry Statusline** (Visual feedback of active mode and lifecycle phase).

Target users: Senior engineers and AI agents working across multiple AI coding harnesses (Claude Code, Cursor, OpenCode, Codex, Antigravity, Copilot, Windsurf) who demand lean, battle-tested, zero-slop software engineering.

---

## Assumptions

1. **Single Source of Truth**: The core markdown files in `skills/`, `agents/`, and `references/` remain the authoritative source. Multi-agent configurations (Cursor, Windsurf, Copilot, OpenCode, etc.) should be generated or synced from these sources rather than maintained as diverged copies.
2. **Non-Destructive Integration**: Ponytail principles will complement and strengthen existing workflows (`spec-driven-development`, `code-review-and-quality`, `code-simplification`, `incremental-implementation`) rather than replacing `agent-skills`' structured lifecycle (DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP).
3. **Compatibility**: Multi-agent hooks and scripts must run with standard Node.js (or cross-platform shell scripts `bash`/`pwsh`) without requiring external proprietary binaries.

---

## Capability Map (Phase 0)

| Module ID | Responsibility | Depends On |
|---|---|---|
| `core-ladder-and-anti-bloat` | Integrate Ponytail's 6-Rung Ladder & 3 execution levels (`lite`, `full`, `ultra`) into `code-simplification` and implementation skills. | — |
| `technical-debt-and-shortcuts` | Introduce `technical-debt-and-shortcuts` skill & `/s-debt` command with grep-driven ledger generation and rot detection. | — |
| `review-and-audit-overhaul` | Upgrade `code-review-and-quality` and `agents/code-reviewer.md` with 4-part findings, out-of-diff ripple analysis, and triaged severity. | `core-ladder-and-anti-bloat` |
| `multi-agent-ecosystem-packaging` | Establish export & manifest infrastructure for 15+ agents (Cursor, OpenCode, Copilot, Gemini, Codex, Windsurf, Cline, etc.). | `core-ladder-and-anti-bloat`, `technical-debt-and-shortcuts` |
| `lifecycle-hooks-and-statusline` | Dynamic statusline script and lifecycle hook integration showing active stage (`SPEC`, `BUILD`, `REVIEW`, etc.) and mode. | `core-ladder-and-anti-bloat` |

**Build Order:** `core-ladder-and-anti-bloat` + `technical-debt-and-shortcuts` → `review-and-audit-overhaul` → `multi-agent-ecosystem-packaging` → `lifecycle-hooks-and-statusline`

---

## Tech Stack & Tooling

- **Core**: Markdown (GitHub Flavored Markdown with YAML frontmatter) conforming to `docs/skill-anatomy.md`.
- **Validation & Generators**: Node.js (`scripts/*.js`) for parsing frontmatter, cross-referencing links, generating agent manifests, and running eval suites.
- **Cross-Platform Scripts**: POSIX Shell (`.sh`) and PowerShell (`.ps1`) for local installation and terminal statuslines.

---

## Commands

```bash
# Validate skill frontmatter and formatting integrity
node scripts/validate-skills.js

# Validate internal cross-references and markdown links
node scripts/validate-reference-links.js

# Run trigger and routing evaluations
node scripts/run-evals.js

# Build/Sync multi-agent distributions (.cursor, .opencode, .windsurf, etc.)
node scripts/build-agent-dist.js

# Scan project for shortcut debt ledger
bash scripts/scan-debt.sh
```

---

## Detailed Specifications by Module

### 1. `core-ladder-and-anti-bloat`
- **The 6-Rung Ladder** incorporated into `skills/code-simplification/SKILL.md` and referenced in `skills/incremental-implementation/SKILL.md`:
  1. *Does it need to exist?* Skip unrequested features, options, and speculative abstractions.
  2. *Already in this codebase?* Reuse existing helpers, components, services, and patterns.
  3. *Standard library or platform native?* Browser native or runtime stdlib beats third-party widgets.
  4. *Installed dependency?* Reuse existing dependencies; never add a dependency for a few lines.
  5. *Can it be one line?* Write the clear, direct one-liner.
  6. *Minimum code that works*, leaving behind exactly one targeted test for risky logic.
- **Operating Levels**:
  - `lite`: Build what was requested, but state the smaller alternative in one line for the user to pick.
  - `full` (default): Strictly enforce the 6-rung ladder and minimum diff.
  - `ultra`: Proactively challenge requirements and push back against unnecessary complexity before writing code.
- **Invariants**: Never cut security, input validation at trust boundaries, data loss safeguards, or accessibility.

### 2. `technical-debt-and-shortcuts`
- **Standardized Marker Convention**:
  ```text
  // shortcut: <ceiling/limit>, <upgrade trigger>
  # Example:
  // shortcut: in-memory Map only holds up to 10k items, switch to Redis when multi-replica deployed
  ```
- **New Skill**: `skills/technical-debt-and-shortcuts/SKILL.md`
- **New Command**: `.claude/commands/s-debt.md` (and alias in other agents)
- **Engine**: Grep-driven scanner (`scripts/scan-debt.sh` / `scripts/scan-debt.js`) that produces a Markdown ledger grouped by file, flagging markers without an upgrade trigger as `no-trigger` rot risks.

### 3. `review-and-audit-overhaul`
- **4-Part Finding Schema**: Every review finding in `skills/code-review-and-quality/SKILL.md` and `agents/code-reviewer.md` must be concrete and actionable:
  1. **What this is**: 1-2 sentence description of the affected component.
  2. **Problem**: Concrete failure scenario (`input X causes crash/data corruption Y`). No hypothetical style nits.
  3. **Fix**: Smallest complete solution (preferring code deletion or native features).
  4. **If we skip it**: Exact operational consequence if deferred.
- **Out-of-Diff Ripple Tracing**: Reviewers MUST grep for all callers and consumers of touched symbols across untouched files.
- **Expected Load Profiling**: Review specifies assumed workload (e.g., CLI single-user vs. high-concurrency multi-tenant).
- **Three-Tier Numbered Triage**:
  - `Must fix`: Bugs, security vulnerabilities, data loss, scale breakages.
  - `Should fix`: Risky logic missing tests, high complexity, dead code, code duplication.
  - `Nice to have`: Micro-simplifications, phrasing improvements.

### 4. `multi-agent-ecosystem-packaging`
- **Directory Layout Extensions**:
  - `.cursor/rules/`: Native `.mdc` rules linking to agent-skills.
  - `.opencode/`: `opencode.json` package configuration and plugin loader.
  - `.codex-plugin/`: Manifest for OpenAI Codex CLI / Desktop.
  - `.gemini-extension.json`: Extension descriptor for Gemini CLI.
  - `.github/copilot-instructions.md`: Unified Copilot instructions.
  - `.windsurf/rules/`: Cascade rules for Windsurf.
  - `.clinerules/`: Rules for Cline / Roo Code.
  - `agents/`: Verified Antigravity, OpenClaw, and Devin compatibility.
- **Sync Tool**: `scripts/build-agent-dist.js` to ensure zero drift between `skills/`, `AGENTS.md`, and external IDE rules.

### 5. `lifecycle-hooks-and-statusline`
- **Statusline Utility**: `scripts/statusline.sh` and `scripts/statusline.ps1` providing prompt/status bar integration:
  - Displays current lifecycle phase: `[SPEC]`, `[PLAN]`, `[BUILD]`, `[REVIEW]`, `[SHIP]`
  - Displays active mode: `[lite]`, `[full]`, `[ultra]`
  - Displays shortcut debt count in the workspace.

---

## Code Style & Skill Anatomy

All new skills and updates strictly adhere to `docs/skill-anatomy.md`:
- YAML Frontmatter with `name` and `description` (3rd person summary + "Use when...").
- Standard Sections:
  1. `## Overview`
  2. `## When to Use` (and `When NOT to use`)
  3. `## Process` (step-by-step actionable workflow)
  4. `## Common Rationalizations` (table of excuses vs reality)
  5. `## Red Flags` (observable anti-patterns)
  6. `## Verification` (checklist with checkboxes)

---

## Testing & Validation Strategy

1. **Frontmatter & Reference Integrity**:
   - `node scripts/validate-skills.js` passes 100%.
   - `node scripts/validate-reference-links.js` passes with 0 broken links.
2. **Eval Suites**:
   - Add trigger and behavioral test cases for `technical-debt-and-shortcuts` and updated `code-simplification` in `evals/`.
   - `node scripts/run-evals.js` must pass.
3. **Multi-Agent Packaging Smoke Test**:
   - Automated tests verifying that generated rules for Cursor, Copilot, Windsurf, and OpenCode contain valid schemas and no broken relative paths.

---

## Boundaries

- **Always**:
  - Maintain backward compatibility for existing Claude Code commands (`/s-spec`, `/s-plan`, `/s-build`, `/s-review`, etc.).
  - Preserve the 6-part skill anatomy structure.
  - Run `validate-skills.js` and `validate-reference-links.js` before any commit.
- **Ask First**:
  - Introducing any new external npm runtime dependency (keep scripts dependency-free using standard Node.js APIs).
  - Removing or deprecating existing core skills.
- **Never**:
  - Sacrifice security, input validation, or error handling in the name of "shorter code".
  - Allow duplicated rule definitions to diverge across multi-agent configuration folders.

---

## Success Criteria

1. `SPEC.md` approved by user.
2. Module `core-ladder-and-anti-bloat` implemented with the 6-rung ladder and 3 modes in `code-simplification`.
3. Module `technical-debt-and-shortcuts` delivered with `skills/technical-debt-and-shortcuts/SKILL.md`, `.claude/commands/s-debt.md`, and debt scanner.
4. Module `review-and-audit-overhaul` implemented with 4-part findings and out-of-diff impact tracing in `code-review-and-quality`.
5. Module `multi-agent-ecosystem-packaging` delivered with automated sync script and adapters for Cursor, OpenCode, Codex, Copilot, Gemini, Windsurf.
6. All evals and validation scripts pass cleanly.

---

## Approved Design Decisions (User Aligned)

1. **Dedicated Command `/s-debt`**: Implemented as a standalone first-class command (`.claude/commands/s-debt.md` and equivalent in other agents), complementing `/s-review` and `/s-simplify`.
2. **Automatic Mode Switching**: The system supports automatic mode detection based on user prompts and task context (e.g., detecting keywords like "be lazy", "simplest", "quick fix" -> `lite`/`full`, or high-risk requirements -> `ultra`), backed by persistent config `~/.config/agent-skills/config.json` and lifecycle hooks.
3. **Simultaneous Multi-Agent Deployment**: Generate and package configs for all 20+ supported agents (Claude Code, Cursor, OpenCode, Codex, Antigravity, Copilot, Gemini CLI, Windsurf, Cline, Devin, Grok, Kimi, Kiro, OpenClaw, Qoder, Pi agent, Hermes, Amp, Junie, Zed) simultaneously via a unified generator script `scripts/build-agent-dist.js`.

