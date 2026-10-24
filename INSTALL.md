# Multi-Agent Installation Guide

**agent-skills** delivers production-grade engineering workflows and anti-bloat disciplines across 20+ AI coding harnesses.

Pick your environment below, or use [`AGENTS.md`](AGENTS.md) as the universal ruleset for any compatible agent.

---

## 1. Claude Code

Install via the Claude Code plugin marketplace:

```text
/plugin marketplace add manhquoc2013/agent-skills
/plugin install agent-skills@agent-skills
```

Once installed, all slash commands (`/s-spec`, `/s-plan`, `/s-build`, `/s-debt`, `/s-review`, `/s-simplify`, `/s-ship`) and skills are loaded automatically.

---

## 2. Cursor

### Option A: Native Workspace Rule (Zero Setup)
Clone or add `.cursor/rules/agent-skills.mdc` to your project root. Cursor will automatically apply the senior engineering rules and 6-rung ladder on every prompt.

### Option B: Lifecycle Hooks
```bash
node scripts/cursor-hooks.js install
# For project-level:
node scripts/cursor-hooks.js install --project
```

---

## 3. OpenCode

Add as a plugin via OpenCode CLI:

```bash
opencode plugin add @manhquoc2013/agent-skills
```

Or add to your project's `opencode.json`:

```json
{
  "plugins": ["@manhquoc2013/agent-skills"]
}
```

OpenCode automatically maps intent to skills and enforces the DEFINE → PLAN → BUILD → DEBT → REVIEW → SHIP lifecycle.

---

## 4. OpenAI Codex (CLI & Desktop)

Add the plugin to your Codex workspace:

```bash
codex plugin marketplace add manhquoc2013/agent-skills
codex plugin add agent-skills@agent-skills
```

Codex automatically reads `.codex-plugin/plugin.json` and loads `AGENTS.md` into the context thread.

---

## 5. Gemini CLI

Install the extension directly:

```bash
gemini extensions install https://github.com/manhquoc2013/agent-skills
```

Registers all 10 commands and loads `AGENTS.md` as continuous context.

---

## 6. GitHub Copilot (CLI & IDEs)

- **Copilot CLI**: Copy `.github/copilot-instructions.md` to `~/.copilot/copilot-instructions.md` (global) or keep it in your repository root.
- **VS Code / JetBrains Copilot Chat**: Reads `.github/copilot-instructions.md` automatically.

---

## 7. Antigravity CLI

```bash
agy plugin install https://github.com/manhquoc2013/agent-skills
```

Antigravity auto-converts all commands (`commands/*.toml`) into slash commands and loads workspace guidance from `AGENTS.md`.

---

## 8. Windsurf

Copy `.windsurf/rules/agent-skills.md` into your workspace `.windsurf/rules/` directory or global Cascade settings.

---

## 9. Cline / Roo Code

Copy `.clinerules/agent-skills.md` into your project root. Cline will enforce the 6-rung ladder and verification checklists.

---

## 10. Additional Agents

- **Devin CLI**: `devin plugins install manhquoc2013/agent-skills`
- **Grok Build**: `grok plugin install manhquoc2013/agent-skills --trust`
- **Kimi Code**: `/plugins install https://github.com/manhquoc2013/agent-skills`
- **Kiro**: `.kiro/steering/agent-skills.md`
- **OpenClaw**: `clawhub install agent-skills`
- **Qoder**: Loads `.qoder/rules/agent-skills.md` and `.qoder-plugin/plugin.json`
- **Hermes Agent**: Loads `plugin.yaml` via `hermes plugins enable agent-skills`
- **Pi / Oh My Pi**: `pi install git:github.com/manhquoc2013/agent-skills`

---

## Universal Install via Skills CLI

To install the skill files into any of 70+ supported tools with a single command:

```bash
npx skills add manhquoc2013/agent-skills
```

---

## Uninstallation & Selective Skill Removal

When you no longer need agent skills or want to remove specific ones:

### 1. Interactive Uninstallation
```bash
./scripts/uninstall-local.sh
# Or via npm
npm run uninstall
```

### 2. Full Uninstallation Across All Detected Tools
```bash
# macOS / Linux
./scripts/uninstall-local.sh --all

# Or via install-local.sh
./scripts/install-local.sh --uninstall --all

# Windows PowerShell
powershell -ExecutionPolicy Bypass -File .\scripts\uninstall-local.ps1 -All
```

### 3. Selective Skill Removal
Remove only specific skills (e.g. `s-perf`, `s-debug`) while keeping the rest:
```bash
./scripts/uninstall-local.sh --skills s-perf,s-debug
```

### 4. Project-Level Removal
Clean up skills installed inside a repository:
```bash
./scripts/uninstall-local.sh --scope project --project /path/to/repo
```

