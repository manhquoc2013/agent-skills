# Task List: Multi-Agent Skill Uninstaller & Selective Removal

## Wave 1: Alias & Slash Command Wrapper Uninstallation
- [x] **Task 1.1: Add `--uninstall` flag to `scripts/install-aliases.sh`** ([S])
  - **Scope**: Support removing generated alias skill folders and copilot prompt files from target IDE destinations.
  - **Verify**: Run `./scripts/install-aliases.sh --help` and verify `--uninstall` option; test removing an alias target.
  - **Files**: `scripts/install-aliases.sh`

## Wave 2: Core Shell Uninstaller & `install-local.sh` Integration
- [x] **Task 2.1: Implement `scripts/uninstall-local.sh`** ([M])
  - **Scope**: Build full-featured uninstaller with target detection, selective `--skills`, `--all`, `--only`, `--scope user|project`, interactive menu, and alias cleanup.
  - **Verify**: `chmod +x scripts/uninstall-local.sh && ./scripts/uninstall-local.sh --help`
  - **Files**: `scripts/uninstall-local.sh`

- [x] **Task 2.2: Add `--uninstall` / `-u` delegation to `scripts/install-local.sh`** ([XS])
  - **Scope**: Allow `./scripts/install-local.sh --uninstall [args]` to invoke `uninstall-local.sh`.
  - **Verify**: `./scripts/install-local.sh --help` shows `--uninstall` flag.
  - **Files**: `scripts/install-local.sh`

## Wave 3: PowerShell Parity (`scripts/uninstall-local.ps1`)
- [x] **Task 3.1: Implement `scripts/uninstall-local.ps1` and update `scripts/install-local.ps1`** ([M])
  - **Scope**: Mirror all features of `uninstall-local.sh` in PowerShell with parameter validation and `-Uninstall` support.
  - **Verify**: Validate PowerShell script syntax.
  - **Files**: `scripts/uninstall-local.ps1`, `scripts/install-local.ps1`

## Wave 4: Automated Testing, Documentation & Package Integration
- [x] **Task 4.1: Create automated unit test suite `scripts/uninstall-test.js`** ([S])
  - **Scope**: Test isolated full install -> test uninstaller -> test selective removal -> test alias cleanup.
  - **Verify**: `node scripts/uninstall-test.js` passes 100%.
  - **Files**: `scripts/uninstall-test.js`

- [x] **Task 4.2: Update `package.json`, `INSTALL.md`, and `README.md`** ([S])
  - **Scope**: Add `"uninstall"` script to `package.json`, document uninstallation and selective removal commands in `INSTALL.md` and `README.md`.
  - **Verify**: `node scripts/validate-reference-links.js`
  - **Files**: `package.json`, `INSTALL.md`, `README.md`

- [x] **Task 4.3: Final Validation and Verification** ([XS])
  - **Scope**: Run full repo test suite `npm test` and verify zero lint or validation regressions.
  - **Verify**: `npm test`
  - **Files**: All modified files
