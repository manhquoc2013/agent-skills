# Specification: Token Efficiency & Context Footprint Optimizations

## Objective

Implement the token-optimization recommendations identified during the Staff Review to minimize context consumption, prevent log bloat, and ensure cross-platform PowerShell installer resilience:
1. **Test Runner Log Pruning**: Equip `test-driven-development` and `debugging-and-error-recovery` with instructions to use quiet/focused test reporters (`-q`, `--reporter=dot`, `--tb=short`) to avoid dumping massive stdout logs into context.
2. **Compact Task Formatting for Small Slices**: Introduce a 3-line compact format for XS/S tasks in `planning-and-task-breakdown` to keep `tasks/todo.md` concise (<100 lines) and reduce turn-by-turn re-reading token overhead.
3. **Cross-Platform Host Resolution in PowerShell Installer**: Fix `$env:USERPROFILE` and `$env:LOCALAPPDATA` null-binding crash in `scripts/install-local.ps1` by adding fallback to `$env:HOME`.

---

## Architectural Changes & Feature Set

### 1. Test Output Log Pruning (`test-driven-development` & `debugging-and-error-recovery`)
- Add guidance in both skills for running focused, quiet test commands that output only failure stack traces, suppressing noisy coverage summaries and verbose progress dots.
- Preserve full verbose logs only when explicitly required for non-reproducible or concurrency bugs.

### 2. Compact Task Format for XS/S Slices (`planning-and-task-breakdown`)
- Provide a streamlined checklist format for XS/S tasks:
  `- [ ] Task X.Y: Title — Description. Verify: command. Files: path`
- Keep detailed block format for complex M/L tasks and major architectural waves.

### 3. Cross-Platform Environment Fallback (`scripts/install-local.ps1`)
- Update `Get-HostCatalog`:
  ```powershell
  $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
  $local = if ($env:LOCALAPPDATA) { $env:LOCALAPPDATA } else { $homeDir }
  ```
- Prevents null parameter binding when running with PowerShell Core (`pwsh`) on macOS/Linux.

---

## Validation Strategy

- `pwsh ./scripts/install-local.ps1 -List` or bash equivalent to confirm installer resolution.
- `node scripts/validate-skills.js`: All skills conform to anatomy rules.
- `node scripts/validate-commands.js`: Parity across all command files.
- `npm test`: Clean pass with 0 errors.
