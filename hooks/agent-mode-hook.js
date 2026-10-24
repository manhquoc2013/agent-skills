#!/usr/bin/env node
/**
 * agent-mode-hook.js
 *
 * Session lifecycle hook for Claude Code, Codex, and Cursor.
 * Detects and injects active mode (lite, full, ultra) and lifecycle state.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const CONFIG_DIR = process.env.AGENT_SKILLS_MODE_DIR || path.join(os.homedir(), '.config', 'agent-skills');
const MODE_FILE = path.join(CONFIG_DIR, 'mode');

function getActiveMode() {
  try {
    if (fs.existsSync(MODE_FILE)) {
      const mode = fs.readFileSync(MODE_FILE, 'utf8').trim().toLowerCase();
      if (['lite', 'full', 'ultra'].includes(mode)) return mode;
    }
  } catch (e) {
    // fallback
  }
  return 'full';
}

function run() {
  const mode = getActiveMode();
  let instructions = `[agent-skills: active mode is ${mode.toUpperCase()}]\\n`;

  if (mode === 'ultra') {
    instructions += 'Enforce ULTRA mode: aggressively challenge unneeded features, push back on bloat, and write the absolute minimum code that satisfies core requirements.\\n';
  } else if (mode === 'lite') {
    instructions += 'Enforce LITE mode: present the smallest alternative in one line and let the user confirm before building.\\n';
  } else {
    instructions += 'Enforce FULL mode: follow the 6-rung ladder, minimum diff, and zero deliberate shortcuts without an upgrade trigger.\\n';
  }

  const envelope = {
    hookSpecificOutput: {
      hookEventName: 'SessionStart',
      additionalContext: instructions
    }
  };

  process.stdout.write(JSON.stringify(envelope) + '\n');
}

if (require.main === module) {
  run();
}

module.exports = { getActiveMode };
