# Specification: Slash Command & Installation Deduplication and Parity

## Objective

Resolve all duplicate definitions, conflicting installation pipelines, naming discrepancies, and platform-specific bugs identified in `/s-review`:
1. **Fix Antigravity Project Path**: Correct `.agent/skills` to `.agents/skills` across all install and uninstall scripts.
2. **Standardize Command Naming**: Unify `/s-planning` to `/s-plan` across Antigravity and Gemini CLI TOML commands, removing the artificial `NAME_MAP` translation in `validate-commands.js`.
3. **Resolve Cursor Slash Command Conflict & Overwrite**: Ensure Cursor alias installation is consistent, prevent `install-aliases.sh` from conflicting with or stripping `disable-model-invocation: true` on Cursor aliases, and maintain parity with `cursor-slash-commands.tsv`.
4. **Prevent Antigravity Skill Pollution**: Prevent `install-aliases.sh` from generating duplicate `s-*` skill directories inside Antigravity's global skills catalog, which already natively loads `commands/*.toml`.
5. **Implement Alias Cleanup in PowerShell Uninstaller**: Bring `uninstall-local.ps1` to feature parity with `uninstall-local.sh` by cleaning up `/s-*` aliases and Cursor slash commands when `-KeepAliases` is not specified.
6. **Cross-Platform Test Suite Execution**: Ensure `scripts/uninstall-test.js` reliably invokes `.sh` scripts via `bash` when executing on Windows platforms so that `npm test` passes cleanly.

---

## Architectural Changes

### 1. Antigravity Workspace Root Parity
- Change `.agent/skills` to `.agents/skills` in:
  - `scripts/install-local.sh`
  - `scripts/uninstall-local.sh`
  - `scripts/install-local.ps1`
  - `SPEC.md`

### 2. Slash Command Standardization (`s-plan`)
- Rename `commands/s-planning.toml` -> `commands/s-plan.toml`
- Rename `.gemini/commands/s-planning.toml` -> `.gemini/commands/s-plan.toml`
- Remove `NAME_MAP = { 's-plan': 's-planning' }` from `scripts/validate-commands.js`.
- All three environments (`.claude/commands/`, `.gemini/commands/`, `commands/`) will now share exact 1:1 filename stems (`s-plan`).

### 3. Cursor & Antigravity Alias De-duplication
- In `scripts/install-aliases.sh`:
  - When target is `cursor`, ensure generated `SKILL.md` preserves `disable-model-invocation: true`.
  - When target is `antigravity`, skip creating alias skills in `$HOME/.gemini/config/skills` and `$HOME/.gemini/config/plugins/agent-skills/skills` because `commands/*.toml` already provides native slash commands.
- In `scripts/install-local.sh`:
  - Align Cursor alias installation with `cursor-slash-commands.tsv`.

### 4. PowerShell Uninstaller Parity (`scripts/uninstall-local.ps1`)
- Add alias cleanup logic when `-KeepAliases` is false:
  - Remove all `/s-*` alias folders in destination skills directory (`cursor`, `copilot`, `gemini`, etc.).
  - Remove `.prompt.md` files in Copilot prompt directories.

### 5. Windows Shell Test Compatibility (`scripts/uninstall-test.js`)
- Helper function `runScript(scriptPath, args)` that prefixes `bash` when running on Windows (`process.platform === 'win32'`).

---

## Testing Strategy
1. `node scripts/validate-commands.js` (must pass with 0 errors without `NAME_MAP`).
2. `node scripts/validate-skills.js`.
3. `node scripts/validate-reference-links.js`.
4. `npm test` (must pass 100% on Windows and Unix).
