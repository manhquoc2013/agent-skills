# agent-skills

This is the agent-skills project — a collection of production-grade engineering skills for AI coding agents.

> **Scope:** This file configures agents working on the [`manhquoc2013/agent-skills`](https://github.com/manhquoc2013/agent-skills) repository itself, not other projects. Don't copy it into another project or a global agent configuration; the reusable assets are the skills in `skills/`.

## Project Structure

```
skills/       → Core skills (SKILL.md per directory)
agents/       → Reusable agent personas (code-reviewer, test-engineer, security-auditor, web-performance-auditor)
hooks/        → Session lifecycle hooks
.claude/commands/ → Slash commands (/s-spec, /s-plan, /s-guard, /s-build, /s-test, /s-debug, /s-review, /s-simplify, /s-ship; plus /s-perf specialist audit, /s-agent)
references/   → Supplementary checklists and shared contracts (testing, performance, security, accessibility, observability, definition-of-done, orchestration-patterns)
evals/        → Skill eval cases + framework (see evals/README.md)
docs/         → Setup guides for different tools
```

## Skills by Phase

**Define:** interview-me, idea-refine, document-clarification, spec-driven-development, constraint-driven-development
**Plan:** planning-and-task-breakdown
**Build:** incremental-implementation, test-driven-development, context-engineering, source-driven-development, doubt-driven-development, frontend-ui-engineering, api-and-interface-design
**Verify:** browser-testing-with-devtools, debugging-and-error-recovery
**Review:** code-review-and-quality, code-simplification, security-and-hardening, performance-optimization
**Ship:** git-workflow-and-versioning, ci-cd-and-automation, deprecation-and-migration, documentation-and-adrs, observability-and-instrumentation, shipping-and-launch

## Conventions

- Every skill lives in `skills/<name>/SKILL.md`
- YAML frontmatter with `name` and `description` fields
- Description starts with what the skill does (third person), followed by trigger conditions ("Use when...")
- Every skill has: Overview, When to Use, Process, Common Rationalizations, Red Flags, Verification
- Shared references are in the root `references/` directory; the emerging convention for self-contained, distributable skills keeps a skill's own references inside `skills/<name>/references/`
- Supporting files only created when content exceeds 100 lines

## Contributing

Before adding a new skill or significantly reworking an existing one, run the pre-flight checks in [CONTRIBUTING.md](CONTRIBUTING.md#before-proposing-a-new-skill): search the catalog, check open PRs, confirm the idea fits [docs/skill-anatomy.md](docs/skill-anatomy.md), and justify the gap. Prefer extending an existing skill over adding a near-duplicate. CONTRIBUTING.md is the single source of truth for this workflow; do not restate its checklist here or elsewhere, link to it.

## Commands

- `npm run build` — `scripts/build-agent-dist.js` regenerates package.json and the host descriptors; CI fails on drift.
- `npm test` — `test:gates` (validators + exact-file unit tests + eval floor), then `test:hooks`.
- Exact-file test command: `node --test scripts/lib/skill-lint-test.js scripts/validate-versions-test.js scripts/run-evals-test.js scripts/validate-reference-links-test.js scripts/validate-commands-test.js scripts/validate-artifact-paths-test.js scripts/floor-guard-reference-test.js scripts/validate-catalog-test.js`
- Validators: `node scripts/validate-skills.js` (frontmatter), `node scripts/validate-reference-links.js` (reference links), `node scripts/validate-versions.js` (manifest versions), `node scripts/validate-commands.js` (command parity), `node scripts/validate-artifact-paths.js` (artifact paths), `node scripts/validate-catalog.js` (README catalog + counts).
- Evals: `node scripts/run-evals.js` — trigger/routing evals for every skill (CI); `--behavioral <skill>` for graded runs

## Pull Requests

PRs target the upstream repository's default branch. In a typical fork setup the upstream remote is `upstream` and your fork is `origin`, but the exact remote names are not what matters here.

- Before opening a PR, search the upstream repository's open PRs and issues for work that touches the same files or rules. If any overlaps, coordinate (build on it, align your rules with it, or rebase after it merges) instead of opening a conflicting PR.
- Prefer small, focused PRs over large refactors of widely shared files (for example, files under `scripts/`), which are more likely to collide with in-flight work.

## Boundaries

- Always: Run the CONTRIBUTING.md pre-flight checks before creating a new skill directory
- Always: Follow the skill-anatomy.md format for new skills
- Always: Check the upstream repo's open PRs and issues for overlap before opening a new PR
- Never: Add skills that are vague advice instead of actionable processes
- Never: Duplicate content between skills — reference other skills instead
