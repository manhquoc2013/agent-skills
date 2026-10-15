# Condition-Based Waiting

Supporting technique for `debugging-and-error-recovery`. Flaky tests often guess at timing with arbitrary delays. That creates race conditions: the test passes on a fast machine and fails under load or in CI.

**Core principle:** wait for the actual condition you care about, not a guess about how long it takes.

## When to Use

- Tests carry arbitrary delays (`setTimeout`, `sleep`, `time.sleep()`)
- Tests are flaky — pass sometimes, fail under load or in parallel runs
- You are waiting for an async operation to complete

**Don't use when** the test is genuinely about timing behavior (debounce intervals, throttle windows). If an arbitrary timeout must stay, document WHY it exists.

## Core Pattern

```typescript
// BEFORE: guessing at timing
await new Promise((r) => setTimeout(r, 50));
const result = getResult();
expect(result).toBeDefined();

// AFTER: waiting for the condition
await waitFor(() => getResult() !== undefined);
const result = getResult();
expect(result).toBeDefined();
```

| Scenario | Pattern |
|----------|---------|
| Wait for an event | `waitFor(() => events.find((e) => e.type === 'DONE'))` |
| Wait for state | `waitFor(() => machine.state === 'ready')` |
| Wait for a count | `waitFor(() => items.length >= 5)` |
| Wait for a file | `waitFor(() => fs.existsSync(path))` |
| Complex condition | `waitFor(() => obj.ready && obj.value > 10)` |

## Implementation

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000,
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise((r) => setTimeout(r, 10)); // Poll every 10ms
  }
}
```

## Common Mistakes

- **Polling too fast** (`setTimeout(check, 1)`) wastes CPU — poll every 10ms.
- **No timeout** loops forever when the condition never arrives — always bound it, with an error naming what you waited for.
- **Stale data**: call the getter *inside* the loop, or you cache the first value and wait forever on it.

## When an Arbitrary Timeout IS Correct

```typescript
await waitForEvent(manager, 'TOOL_STARTED'); // First: wait for the condition
await new Promise((r) => setTimeout(r, 200)); // Then: wait for timed behavior
// 200ms = 2 ticks at the tool's known 100ms interval — documented and justified
```

Requirements for the exception: (1) wait for the triggering condition first, (2) base the duration on known timing, not a guess, (3) comment WHY.
