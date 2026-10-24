# Implementation Plan: Multi-Agent Skill Uninstaller & Selective Removal

## Overview
Implement complete uninstallation capabilities for `agent-skills`, including `scripts/uninstall-local.sh`, `scripts/uninstall-local.ps1`, flag integration in `scripts/install-local.sh` and `scripts/install-aliases.sh`, package script integration, test suite, and documentation.

---

## Phase Breakdown

### Wave 1: Alias & Slash Command Wrapper Uninstallation
- Extend `scripts/install-aliases.sh`:
  - Add `--uninstall` / `-u` flag.
  - When `--uninstall` is set, iterate through all detected or specified targets and remove created alias skill folders (`<dest>/<cmd>`) and prompt files (`<dest>/<cmd>.prompt.md`).
  - Clean up parent directories if empty.

### Wave 2: Core Shell Uninstallation Script (`scripts/uninstall-local.sh`) & Flag in `install-local.sh`
- Create `scripts/uninstall-local.sh`:
  - Full detection parity with `install-local.sh` (cursor, claude, codex, gemini, antigravity, windsurf, opencode, copilot, copilot-cli, kiro, commandcode).
  - Scope support: `--scope user` and `--scope project` (with `--project <path>`).
  - Filtering: `--only <ids>` and selective skill removal `--skills <skill1,skill2...>`.
  - Cleanup of skills, metadata `.agent-skills-install.json`, and `references/`.
  - Automatic invocation of `install-aliases.sh --uninstall` unless `--keep-aliases` is passed.
  - Interactive selection menu when run without flags.
- Update `scripts/install-local.sh`:
  - Add `--uninstall` / `-u` flag that forwards arguments to `scripts/uninstall-local.sh`.

### Wave 3: PowerShell Cross-Platform Parity (`scripts/uninstall-local.ps1`)
- Create `scripts/uninstall-local.ps1`:
  - Implement matching logic for Windows environments with `-Only`, `-All`, `-Skills`, `-Scope`, `-Project`, `-KeepAliases`, `-List`.
- Update `scripts/install-local.ps1`:
  - Support `-Uninstall` flag.

### Wave 4: Testing, Documentation, and Package Integration
- Add `uninstall-test.js` to verify:
  - Full uninstallation cleans all copied skills and metadata.
  - Selective uninstallation removes only targeted skills while retaining others.
  - Alias uninstallation cleans all `/s-*` command folders.
- Update `package.json`:
  - Add `"uninstall": "bash scripts/uninstall-local.sh"`.
- Update `INSTALL.md` and `README.md` with uninstallation guides.
- Execute full validation suite: `npm test` and custom test suites.
