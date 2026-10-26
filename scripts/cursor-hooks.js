/**
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
