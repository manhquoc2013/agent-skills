---
description: Break work into small verifiable tasks with acceptance criteria and dependency ordering
---

Invoke the agent-skills:planning-and-task-breakdown skill.

Before planning, run pre-flight checks:
- If no spec exists (`SPEC.md` or equivalent), stop and invoke agent-skills:spec-driven-development first (via interactive interview popup).
- If existing spec and tasks are already 100% completed, archive them to `docs/specs/archive/YYYY-MM-DD-<initiative>/` and invoke `/s-spec` for the new feature.
- If existing plan is in-progress (`tasks/todo.md` has unchecked tasks), stop and confirm before overwriting.

Read the spec and relevant codebase sections. Then:

1. Enter plan mode — read only, no code changes
2. Identify the dependency graph between components
3. Slice work vertically (one complete path per task, not horizontal layers)
4. Write tasks with acceptance criteria and verification steps
5. Add checkpoints between phases
6. Present the plan for human review

Save the plan to `tasks/plan.md` and task list to `tasks/todo.md` (with progress header banner).
