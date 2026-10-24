# Specification: GSD-Inspired Quality & Orchestration Upgrades for agent-skills

## Objective

Incorporate battle-tested architectural mechanisms from `gsd-core-next` into the `agent-skills` catalog and slash commands without compromising markdown-first simplicity:
1. **Broken-Windows Ledger & No-Defer Ship Gate**: Eliminate silent defect accumulation by detecting stubs (`TODO`, `FIXME`, skipped tests, mock fallbacks) during pre-launch review in `s-ship` / `shipping-and-launch`.
2. **Anti-Thrashing Forensics & Session Handoff**: Prevent infinite trial-and-error loops in `s-agent` / `s-debug` by detecting file churn/thrashing and formalizing session state checkpoints (`tasks/handoff.md`).
3. **Wave-Based Planning & Drift Pre-checks**: Equip `s-plan` / `s-spec` with execution wave boundaries for safe sub-agent parallelism and upstream drift detection (schema drift, context drift).
4. **Command & Skill Parity**: Ensure full synchronization across `.claude/commands/*.md`, `commands/*.toml`, `.gemini/commands/*.toml`, and `skills/*/SKILL.md`.

---

## Architectural Changes & Feature Set

### 1. Broken-Windows Ledger & No-Defer Gate (`shipping-and-launch`, `/s-ship`)
- **Problem**: Agents often declare tasks "done" while leaving behind `// TODO: implement later`, commented-out assertions, `@ts-ignore`, mock fallbacks, or disabled test cases (`it.skip`).
- **Solution**:
  - In `skills/shipping-and-launch/SKILL.md`, introduce the **Broken-Windows Audit Pass**:
    - Scan staged changes and recent commits for defect markers (`TODO`, `FIXME`, `HACK`, `STUB`, skipped tests, disabled lints).
    - If any open defect exists without an explicit waiver in `acknowledged risks`, the launch decision is blocked (**NO-GO**).
  - In `commands/s-ship.toml`, `.claude/commands/s-ship.md`, `.gemini/commands/s-ship.toml`: Add Phase B.1 (Broken-Windows & Stub Audit) as a mandatory gate before synthesizing final GO/NO-GO.

### 2. Anti-Thrashing Forensics & Session State Handoff (`autonomous-agent-workflow`, `s-agent`, `debugging-and-error-recovery`, `s-debug`)
- **Problem**: Autonomous agents can enter self-destructive loops modifying the same 2-3 files repeatedly without making actual progress ("file thrashing"), and context limits force resets that lose state.
- **Solution**:
  - In `skills/autonomous-agent-workflow/SKILL.md` & `s-agent` commands:
    - Add **Thrashing Detection**: Track file churn in Phase 4. If the same file is modified >3 times across failed self-healing attempts, pause immediately, trigger **Forensics Mode** (analyze git commit history and hypothesis validity rather than re-patching).
    - Add **Session Checkpointing (`tasks/handoff.md`)**: Provide a standard handoff format documenting active phase, completed tasks with commit hashes, in-progress state, blockers, and external background tasks to survive `/clear` or session boundary.
  - In `skills/debugging-and-error-recovery/SKILL.md` & `s-debug` commands:
    - Add explicit **Forensics & History Analysis** (`--forensics`): Inspect recent git commit churn (`git log --name-only -10`) and diff variance before formulating a bug hypothesis.

### 3. Wave-Based Planning & Drift Pre-checks (`planning-and-task-breakdown`, `s-plan`, `spec-driven-development`, `s-spec`)
- **Problem**: Parallel sub-agents collide if tasks with overlapping dependencies run simultaneously; furthermore, planning against stale assumptions causes architectural drift.
- **Solution**:
  - In `skills/planning-and-task-breakdown/SKILL.md` & `s-plan` / `s-planning` commands:
    - Structure vertical slices into **Execution Waves** (Wave 1: Foundation/Types/Contracts → Wave 2: Parallel Services/Components → Wave 3: Integration/E2E). Tasks within the same wave are safe for parallel sub-agents.
    - Add **Plan Convergence Critique**: Self-check plan against SPEC criteria before requesting human approval.
  - In `skills/spec-driven-development/SKILL.md` & `s-spec` commands:
    - Add **Drift Pre-check**: Verify schema synchronization (DB schema vs migrations vs models) and ensure upstream decisions are reconciled before writing specs.

---

## Validation & Testing Strategy

- `node scripts/validate-skills.js`: All 31 skills must strictly follow anatomy guidelines (Overview, When to Use, Process, Common Rationalizations, Red Flags, Verification).
- `node scripts/validate-commands.js`: Command parity, frontmatter, and descriptions must match 100% across Claude, toml, and Gemini directories.
- `node scripts/validate-reference-links.js`: Zero dead links in `references/`.
- `npm test`: Full test suite exits cleanly with code 0.

---

## Boundaries & Constraints

- No runtime binary dependencies added to the repository.
- Markdown-first instructions and portable shell commands only.
- Preserve backward compatibility for existing command invocations and skill references.
