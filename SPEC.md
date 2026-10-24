# Specification: Multi-Agent Skill Uninstallation & Selective Removal

## Objective

Deliver a comprehensive, safe, and cross-platform uninstallation capability for `agent-skills`, enabling users and agents to uninstall skills and slash command aliases when they are no longer needed.

Key Requirements:
1. **Dedicated Uninstaller Scripts**: Provide `scripts/uninstall-local.sh` and `scripts/uninstall-local.ps1`.
2. **Flag Integration**: Support `--uninstall` / `-u` in `scripts/install-local.sh` and `scripts/install-aliases.sh`.
3. **Selective & Clean-All Modes**:
   - Ability to remove all installed skills across all detected targets or specific IDE/CLI targets.
   - Ability to selectively remove specific skills (e.g. `--skills <name1,name2>`) without affecting others.
4. **Lifecycle Command & Alias Cleanup**: Automatically clean up corresponding `/s-*` command aliases and prompts unless `--keep-aliases` is passed.
5. **Dual Scoping**: Full support for both `--scope user` (global/home directories) and `--scope project` (repository-level).
6. **Documentation & npm Script**: Add npm script `npm run uninstall` and document uninstallation steps in `INSTALL.md` and `README.md`.

---

## Architectural Design

### 1. Targets and Destinations
The uninstaller tracks the exact same canonical targets as `install-local.sh`:
- `cursor`: `$HOME/.cursor/skills` (user) / `.cursor/skills` (project)
- `claude`: `$HOME/.claude/skills` (user) / `.claude/skills` (project)
- `codex`: `$HOME/.codex/skills` (user) / `.agents/skills` (project)
- `gemini`: `$HOME/.gemini/skills` (user) / `.gemini/skills` (project)
- `antigravity`: `$HOME/.gemini/config/plugins/agent-skills/skills` and `$HOME/.gemini/config/skills` (user) / `.agent/skills` (project)
- `windsurf`: `$HOME/.codeium/windsurf/skills` (user) / `.windsurf/skills` (project)
- `opencode`: `$HOME/.config/opencode/skills` (user) / `.opencode/skills` (project)
- `copilot`: `$HOME/.agents/skills` and `$HOME/.github/skills` (user) / `.github/skills` (project)
- `copilot-cli`: `$HOME/.copilot/skills` (user) / `.github/skills` (project)
- `kiro`: `$HOME/.kiro/skills` (user) / `.kiro/skills` (project)
- `commandcode`: `$HOME/.commandcode/skills` (user) / `.commandcode/skills` (project)

### 2. Selective vs All Uninstallation
- When `--skills <comma-separated-list>` is specified:
  - Validates skill names against the repo catalog or installed names.
  - Deletes only those specific skill subdirectories within the target destination.
  - Updates `.agent-skills-install.json` skill count if present.
- When no specific skills are passed (or `--all-skills`):
  - Enumerates all skills defined in `skills/` and removes each from the destination.
  - Removes `.agent-skills-install.json`.
  - Removes `references/` if installed alongside the skills.
  - If target directory is empty, cleans up the directory.

### 3. Alias / Slash Command Cleanup
- Integrates with `scripts/install-aliases.sh --uninstall`:
  - Iterates through discovered `/s-*` commands (`s-agent`, `s-build`, `s-debt`, `s-debug`, `s-guard`, `s-perf`, `s-plan`, `s-review`, `s-ship`, `s-simplify`, `s-spec`, `s-test`).
  - Removes wrapper directories (`<dest>/<cmd>`) and prompts (`<dest>/<cmd>.prompt.md`).

### 4. Interactive & Non-Interactive CLI Interface
- Flags:
  - `--list`: Display installed skills and status across detected targets.
  - `--all`: Uninstall from all detected targets without prompting.
  - `--only <id[,id...]>`: Uninstall only from specified IDE targets.
  - `--skills <skill[,skill...]>`: Selective uninstallation of specific skills.
  - `--scope user|project`: user config vs repo project config.
  - `--project <path>`: project directory root.
  - `--keep-aliases`: Skip removing `/s-*` slash command wrappers.
  - `--help`: Print usage instructions.

---

## Validation Strategy
1. Unit testing with temporary dummy install directory in `scripts/uninstall-test.js`.
2. Execution of `--list`, selective `--skills`, and full `--all` runs in dry/isolated modes.
3. Regression check with `npm test` ensuring existing validators pass.
