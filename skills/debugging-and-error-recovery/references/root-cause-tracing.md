# Root-Cause Tracing

Supporting technique for `debugging-and-error-recovery`. Bugs often manifest deep in the call stack (a file created in the wrong directory, a database opened with the wrong path). The instinct is to fix where the error appears — that is treating a symptom.

**Core principle:** trace backward through the call chain until you find the original trigger, then fix at the source.

## When to Use

- The error happens deep in execution, not at the entry point
- The stack trace shows a long call chain
- It is unclear where an invalid value originated
- You need to find which caller or test triggers the problem

## The Tracing Process

**1. Observe the symptom.**

```
Error: git init failed in ~/project/packages/core
```

**2. Find the immediate cause.** What code directly causes this?

```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

**3. Ask: what called this?**

```
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → Session.initializeWorkspace()
  → Session.create()
  → test at Project.create()
```

**4. Keep tracing up — what value was passed?** `projectDir = ''`. An empty string as `cwd` resolves to `process.cwd()` — the source code directory. That is a clue, not the answer.

**5. Find the original trigger.** Where did the empty string come from? The test accessed `context.tempDir` before its setup ran. The root cause is a top-level initialization ordering bug — fixing `git init` would have patched the symptom.

## Adding Stack Traces

When you cannot trace manually, add instrumentation before the problematic operation:

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;
  console.error('DEBUG git init:', {
    directory,
    cwd: process.cwd(),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}
```

- Use `console.error()` in tests — logging frameworks may be suppressed there.
- Log *before* the dangerous operation, not after it fails.
- Include context: directory, cwd, environment variables.
- `new Error().stack` captures the full call chain.

## Key Principles

- **Never fix just where the error appears.** Trace back to the original trigger.
- After fixing at the source, add validation at each layer the bad value passed through — the bug should become impossible, not just absent.
- Remove the debug instrumentation once the root cause is found and the regression test guards it.
