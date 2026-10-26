# Implementation Plan: Slash Command & Installation Deduplication and Parity

## Phase 1: Naming & Path Parity
- Task 1.1: Fix Antigravity project skills path typo (`.agent/skills` -> `.agents/skills`) across `install-local.sh`, `uninstall-local.sh`, and `install-local.ps1`.
- Task 1.2: Rename `commands/s-planning.toml` and `.gemini/commands/s-planning.toml` to `s-plan.toml`.
- Task 1.3: Update `scripts/validate-commands.js` to remove `NAME_MAP` and verify 1:1 filename parity.

## Phase 2: Deduplication & Alias Integrity
- Task 2.1: Update `scripts/install-aliases.sh` to include `disable-model-invocation: true` when writing alias skills for Cursor.
- Task 2.2: Prevent `scripts/install-aliases.sh` from polluting Antigravity with duplicate `s-*` skill directories since Antigravity uses native `commands/*.toml`.
- Task 2.3: In `scripts/install-local.sh`, ensure Cursor slash commands installation does not conflict or get overwritten with improper frontmatter.

## Phase 3: PowerShell Uninstaller Parity
- Task 3.1: Implement alias cleanup in `scripts/uninstall-local.ps1` when `-KeepAliases` is not specified.

## Phase 4: Test Suite & Windows Compatibility Verification
- Task 4.1: Update `scripts/uninstall-test.js` to execute `.sh` scripts via `bash` on Windows platforms.
- Task 4.2: Run full verification suite (`npm test`, `validate-commands`, `validate-skills`).
