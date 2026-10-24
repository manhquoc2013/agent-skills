---
description: Conduct a five-axis code review — correctness, readability, architecture, security, performance
---

Invoke the agent-skills:code-review-and-quality skill.

### Token-Optimized Review Workflow

1. **Scope the Diff Efficiently (Avoid Context Bloat):**
   - Run `git status` and `git diff --stat` (or `git diff --cached --stat`) first to assess changed files and lines.
   - Filter noisy lockfiles (`*lock*`), compiled bundles (`dist/`, `build/`), and minified assets from raw diff dumps (`git diff -- . ':(exclude)*lock*' ':(exclude)dist/*'`).
   - Read targeted line slices (`view_file` slices or `git diff -U3`) around changed symbols instead of ingesting entire files.

2. **Five-Axis Evaluation:**
   - **Correctness**: Spec alignment, edge cases handled, error paths covered, tests adequate (run focused tests quietly via `-q` or `--reporter=dot`).
   - **Readability**: Clear naming, straightforward logic, no unnecessary abstractions.
   - **Architecture**: Follows existing patterns, clean boundaries, ripple impact verified (`git grep -n "<symbol>"`).
   - **Security**: Boundary validation, no secrets or injections, safe auth checks.
   - **Performance**: No N+1 queries, no unbounded ops, scale matched to assumed load.
   - *(If frontend/UI)*: WCAG contrast (≥4.5:1), touch targets (≥44px), mobile layout (375px), SVG icons.

3. **Structured Finding Triage (3 Tiers, Numbered 1..N):**
   Group all findings across axes into three continuously numbered tiers so the author can say "Fix 1 and 3":
   - **Must fix**: Bugs, security vulnerabilities, data loss, breaks at expected load.
   - **Should fix**: Risky code lacking tests, real slowness, duplication, functions mixing jobs, dead code.
   - **Nice to have**: Small speedups, shorter syntactic forms.

4. **Concise 4-Part Finding Contract:**
   For each finding, output 1-2 tight sentences without echoing large diffs or code blocks:
   - **[Finding Title]** (`path/to/file:L10-20`)
     - **What this is:** What the affected code does.
     - **Problem:** Concrete input/condition causing failure.
     - **Fix:** Minimal working remedy.
     - **If we skip it:** Operational impact.

5. **Verdict:** Conclude with `Verdict: Ship.` or `Verdict: Fix [N] and [M] first.`, followed by `Lean: -<N> lines` (if simplifications exist) and `Not checked:`.
