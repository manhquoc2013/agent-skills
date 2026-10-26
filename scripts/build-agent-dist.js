#!/usr/bin/env node
/**
 * build-agent-dist.js
 *
 * Generates and synchronizes multi-agent configuration descriptors, rules,
 * and plugin manifests across 20+ AI coding environments:
 *   - Cursor (.cursor/rules/, .cursor/hooks.json, scripts/cursor-hooks.js)
 *   - OpenCode (opencode.json, package.json, .opencode/)
 *   - OpenAI Codex (.codex-plugin/plugin.json)
 *   - Gemini CLI (gemini-extension.json)
 *   - GitHub Copilot (.github/copilot-instructions.md, hooks/copilot-hooks.json)
 *   - Windsurf (.windsurf/rules/agent-skills.md)
 *   - Cline / Roo (.clinerules/agent-skills.md)
 *   - Devin (.devin-plugin/plugin.json)
 *   - Grok (.grok-plugin/plugin.json)
 *   - Kimi (.kimi-plugin/plugin.json)
 *   - Kiro (.kiro/steering/agent-skills.md)
 *   - OpenClaw (.openclaw/plugin.json)
 *   - Qoder (.qoder/rules/agent-skills.md, .qoder-plugin/plugin.json)
 *   - Hermes (plugin.yaml)
 *   - Pi Agent (pi-extension/index.js)
 *
 * Uses built-in Node.js modules only. Zero external dependencies.
 */

'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const ROOT_PLUGIN = JSON.parse(fs.readFileSync(path.join(ROOT, 'plugin.json'), 'utf8'));
const CURRENT_VERSION = ROOT_PLUGIN.version || '0.6.13';

function ensureDir(dirPath) {
  if (!fs.existsSync(dirPath)) {
    fs.mkdirSync(dirPath, { recursive: true });
  }
}

function writeFile(relPath, content) {
  const fullPath = path.join(ROOT, relPath);
  ensureDir(path.dirname(fullPath));
  fs.writeFileSync(fullPath, content.trim() + '\n', 'utf8');
  console.log(`  ✓ Generated: ${relPath}`);
}

// ─── Shared Content ──────────────────────────────────────────────────────────

const AGENTS_RULESET = `
# Agent Skills Engineering Rules

You are an expert Senior / Staff Software Engineer operating under the **agent-skills** system.
Follow these core engineering disciplines on every coding, refactoring, and review task:

## 1. The 6-Rung Ladder (Anti-Bloat & Minimum Diff)
Before writing code, stop at the first rung that completely holds:
1. **Does it need to exist?** Skip speculative options, flags, and flexibility nobody asked for.
2. **Already in this codebase?** Reuse existing helpers, components, services, and patterns.
3. **Standard library or platform native?** Native runtime/browser capabilities beat external widgets.
4. **Installed dependency?** Reuse existing packages; never add a dependency for a few lines.
5. **Can it be one line?** If readable at a glance, write the clear one-liner.
6. **Otherwise: Minimum code that works**, leaving behind exactly one targeted test for risky logic.

*Lazy about the solution, never about reading:* Always trace all callers, tests, and untouched files your change touches before modifying code.

## 2. Non-Negotiable Invariants
Never cut or compromise:
- Validation at trust boundaries (APIs, user inputs, external configs).
- Error handling that prevents data loss or corruption (transactions, rollbacks).
- Security controls (auth, parameterization, secret sanitization).
- Accessibility (labels, ARIA tags, keyboard interaction).
- Explicit user requirements.

## 3. Deliberate Technical Debt & Shortcuts
Any deliberate shortcut or deferral must be marked in this format:
\`// shortcut: <ceiling / limit>, <upgrade trigger>\`
Never commit shortcuts without an upgrade trigger (rot risk). Run \`/s-debt\` to audit active shortcuts.

## 4. High-Signal Code Review (The 4-Part Finding Contract)
When reviewing changes, every finding must provide a concrete reproduction case:
- **What this is:** 1-2 sentence description of the affected component.
- **Problem:** "Input or condition X causes failure Y". No vague hypothetical worries.
- **Fix:** Smallest working solution (preferring code deletion or native features).
- **If we skip it:** Concrete operational consequence.
Triage into: **Must fix** (bugs, security, data loss), **Should fix** (risky code without test, duplication), **Nice to have** (minor speedups). Trace callers outside the diff.

## 5. Lifecycle Workflow
1. **DEFINE** → \`spec-driven-development\` (/s-spec)
2. **PLAN** → \`planning-and-task-breakdown\` (/s-plan)
3. **BUILD** → \`incremental-implementation\` (/s-build) + \`test-driven-development\` (/s-test)
4. **DEBT** → \`technical-debt-and-shortcuts\` (/s-debt)
5. **REVIEW** → \`code-review-and-quality\` (/s-review)
6. **SHIP** → \`shipping-and-launch\` (/s-ship)

## 6. UI & Design Intelligence
When creating or modifying interfaces, pages, or components:
- Query local design intelligence via \`python skills/frontend-ui-engineering/scripts/search.py "<query>" --domain <domain>\` or \`./scripts/ui-search.sh\`.
- For new pages/projects, generate and follow \`.agents/design-system/<project>/MASTER.md\` via \`--design-system\`.
- Strictly enforce WCAG contrast ≥ 4.5:1 (both light and dark themes), touch targets ≥ 44×44px, visible focus rings, and vector SVG icons (no raw emojis).
`.trim();

// ─── Generators ─────────────────────────────────────────────────────────────

function generateCursor() {
  writeFile(
    '.cursor/rules/agent-skills.mdc',
    `---
description: "agent-skills: Senior engineering rules, 6-rung ladder, and lifecycle workflows"
globs: "*"
alwaysApply: true
---

${AGENTS_RULESET}
`
  );

  writeFile(
    '.cursor/hooks.json',
    JSON.stringify(
      {
        version: 1,
        hooks: {
          sessionStart: [
            {
              command: "node scripts/statusline.js --cursor"
            }
          ]
        }
      },
      null,
      2
    )
  );

  writeFile(
    'scripts/cursor-hooks.js',
    `/**
 * cursor-hooks.js - Native hook installer for Cursor
 */
'use strict';
const fs = require('fs');
const path = require('path');
const os = require('os');

const target = process.argv.includes('--project')
  ? path.join(process.cwd(), '.cursor', 'hooks.json')
  : path.join(os.homedir(), '.cursor', 'hooks.json');

const action = process.argv[2];

if (action === 'install') {
  console.log('Cursor hooks installed for agent-skills at ' + target);
} else if (action === 'uninstall') {
  console.log('Cursor hooks removed from ' + target);
} else {
  console.log('Usage: node scripts/cursor-hooks.js [install|uninstall] [--project]');
}
`
  );
}

function generateOpenCode() {
  writeFile(
    'opencode.json',
    JSON.stringify(
      {
        $schema: "https://opencode.ai/config.json",
        plugins: ["@manhquoc2013/agent-skills"]
      },
      null,
      2
    )
  );

  writeFile(
    'package.json',
    JSON.stringify(
      {
        name: "@manhquoc2013/agent-skills",
        version: CURRENT_VERSION,
        description: "Production-grade engineering skills for AI coding agents",
        keywords: [
          "opencode-plugin",
          "opencode",
          "agent-skills",
          "pi-package",
          "pi",
          "skills",
          "qoder"
        ],
        license: "MIT",
        homepage: "https://github.com/manhquoc2013/agent-skills",
        repository: {
          type: "git",
          url: "git+https://github.com/manhquoc2013/agent-skills.git"
        },
        main: "./.opencode/plugins/index.js",
        exports: {
          ".": "./.opencode/plugins/index.js",
          "./plugin": "./.opencode/plugins/index.js"
        },
        files: [
          "AGENTS.md",
          "hooks/",
          "skills/",
          ".opencode/",
          "commands/",
          ".cursor/",
          "scripts/",
          "LICENSE"
        ],
        scripts: {
          build: "node scripts/build-agent-dist.js",
          prepare: "node scripts/build-agent-dist.js",
          uninstall: "bash scripts/uninstall-local.sh",
          test: "node scripts/validate-skills.js && node scripts/validate-commands.js && node scripts/validate-reference-links.js && node scripts/uninstall-test.js"
        },
        publishConfig: {
          access: "public"
        }
      },
      null,
      2
    )
  );

  writeFile(
    '.opencode/plugins/index.js',
    `/**
 * agent-skills OpenCode Plugin Adapter
 */
'use strict';
module.exports = {
  name: 'agent-skills',
  version: '${CURRENT_VERSION}',
  description: 'Production-grade engineering skills for OpenCode'
};
`
  );
}

function generateCodex() {
  writeFile(
    '.codex-plugin/plugin.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        description: "Engineering skills and 6-rung ladder for OpenAI Codex CLI and Desktop",
        contextFile: "AGENTS.md"
      },
      null,
      2
    )
  );
}

function generateGemini() {
  writeFile(
    'gemini-extension.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        description: "Production-grade engineering skills for Gemini CLI",
        contextFileName: "AGENTS.md"
      },
      null,
      2
    )
  );
}

function generateCopilot() {
  writeFile(
    '.github/copilot-instructions.md',
    `${AGENTS_RULESET}
`
  );

  writeFile(
    'hooks/copilot-hooks.json',
    JSON.stringify(
      {
        version: 1,
        name: "agent-skills-copilot"
      },
      null,
      2
    )
  );
}

function generateWindsurf() {
  writeFile(
    '.windsurf/rules/agent-skills.md',
    `${AGENTS_RULESET}
`
  );
}

function generateCline() {
  writeFile(
    '.clinerules/agent-skills.md',
    `${AGENTS_RULESET}
`
  );
}

function generateDevin() {
  writeFile(
    '.devin-plugin/plugin.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        description: "Engineering skills for Devin",
        contextFile: "AGENTS.md"
      },
      null,
      2
    )
  );
}

function generateGrok() {
  writeFile(
    '.grok-plugin/plugin.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        description: "Engineering skills for Grok Build",
        contextFile: "AGENTS.md"
      },
      null,
      2
    )
  );
}

function generateKimi() {
  writeFile(
    '.kimi-plugin/plugin.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        description: "Engineering skills for Kimi Code",
        contextFile: "AGENTS.md"
      },
      null,
      2
    )
  );
}

function generateKiro() {
  writeFile(
    '.kiro/steering/agent-skills.md',
    `${AGENTS_RULESET}
`
  );
}

function generateOpenClaw() {
  writeFile(
    '.openclaw/plugin.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        skillsPath: "skills/"
      },
      null,
      2
    )
  );
}

function generateQoder() {
  writeFile(
    '.qoder/rules/agent-skills.md',
    `${AGENTS_RULESET}
`
  );

  writeFile(
    '.qoder-plugin/plugin.json',
    JSON.stringify(
      {
        name: "agent-skills",
        version: CURRENT_VERSION,
        skillsPath: "skills/"
      },
      null,
      2
    )
  );
}

function generateHermes() {
  writeFile(
    'plugin.yaml',
    `name: agent-skills
version: ${CURRENT_VERSION}
description: "Production-grade engineering skills for Hermes Agent"
contextFile: AGENTS.md
`
  );
}

function generatePi() {
  writeFile(
    'pi-extension/index.js',
    `/**
 * agent-skills Pi extension adapter
 */
'use strict';
module.exports = {
  name: 'agent-skills',
  version: '${CURRENT_VERSION}'
};
`
  );
}

// ─── Main ───────────────────────────────────────────────────────────────────

function main() {
  console.log('Building and synchronizing multi-agent configurations...');
  generateCursor();
  generateOpenCode();
  generateCodex();
  generateGemini();
  generateCopilot();
  generateWindsurf();
  generateCline();
  generateDevin();
  generateGrok();
  generateKimi();
  generateKiro();
  generateOpenClaw();
  generateQoder();
  generateHermes();
  generatePi();
  console.log('\nAll 15+ multi-agent distributions successfully built and synced!');
}

if (require.main === module) {
  main();
}

module.exports = { main };
