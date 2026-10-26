# Institutional Learnings: Slash Command & Installation Parity

## 1. Antigravity Skill Discovery & Naming
- **Workspace Root**: Antigravity uses `.agents/` (plural) at the workspace root for local rules, skills, and customizations. Using `.agent/` breaks discovery.
- **Native Slash Commands vs Alias Skills**: Antigravity automatically registers `commands/*.toml` as slash commands when a plugin is installed. Generating parallel `s-*` skill directories inside `~/.gemini/config/skills` leads to redundant skills and clutter in the IDE prompt suggestions.

## 2. Command Naming Parity
- Rather than mapping divergent stems in tooling (`s-plan` vs `s-planning`), standardizing filenames (`s-plan.toml`) across `.claude/commands/`, `.gemini/commands/`, and `commands/` eliminates cognitive load and removes special-case translation logic in CI validators.

## 3. Cursor Alias Invocation Safety
- In Cursor, custom slash commands installed as skills must always include `disable-model-invocation: true` in their frontmatter. Without this flag, Cursor's background agent will proactively trigger them during routine turns rather than waiting for the user to explicitly invoke `/<command>`.

## 4. Windows Shell Execution in Node Tests
- Never invoke `.sh` scripts directly using raw path strings in `execSync` on Windows. Windows does not associate `.sh` with an interpreter.
- Using Git's bash (`Git/bin/bash.exe` or `git --exec-path`) is more reliable than invoking generic `bash` on Windows, because `System32\bash.exe` can route to a broken or unconfigured WSL relay.
