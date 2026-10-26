# Tasks: Slash Command & Installation Deduplication and Parity

- [x] **Task 1.1: Fix Antigravity project skills path typo (`.agent` -> `.agents`)**
  - **Files**: `scripts/install-local.sh`, `scripts/uninstall-local.sh`, `scripts/install-local.ps1`
  - **Verify**: Inspect lines and verify `.agents/skills` is used consistently.

- [x] **Task 1.2: Standardize `s-planning.toml` to `s-plan.toml` & Update Validator**
  - **Files**: `commands/s-planning.toml`, `.gemini/commands/s-planning.toml`, `scripts/validate-commands.js`
  - **Verify**: Run `node scripts/validate-commands.js` without `NAME_MAP`.

- [x] **Task 2.1: Fix Cursor Alias Frontmatter in `scripts/install-aliases.sh`**
  - **Files**: `scripts/install-aliases.sh`
  - **Verify**: Check that Cursor alias skills receive `disable-model-invocation: true`.

- [x] **Task 2.2: Prevent Duplicate Antigravity Skills in `scripts/install-aliases.sh`**
  - **Files**: `scripts/install-aliases.sh`
  - **Verify**: Check `user_destinations_for antigravity` or skip generating duplicate skills for Antigravity.

- [x] **Task 3.1: Add Alias Cleanup to `scripts/uninstall-local.ps1`**
  - **Files**: `scripts/uninstall-local.ps1`
  - **Verify**: Test uninstallation logic to ensure `/s-*` aliases are removed when `-KeepAliases` is not passed.

- [x] **Task 4.1: Fix Windows Shell Execution in `scripts/uninstall-test.js`**
  - **Files**: `scripts/uninstall-test.js`
  - **Verify**: Run `node scripts/uninstall-test.js` on Windows directly.

- [x] **Task 4.2: Full Regression & Verification Run**
  - **Verify**: `npm test` passes completely (0 errors).
