#!/usr/bin/env node
/**
 * scan-debt.js
 *
 * Scans repository files for deliberate technical shortcuts marked with:
 *   // shortcut: <ceiling>, <upgrade-trigger>
 *   # shortcut: <ceiling>, <upgrade-trigger>
 *   /* shortcut: <ceiling>, <upgrade-trigger> * /
 *
 * Also supports legacy 'ponytail:' markers.
 * Flags any marker lacking an upgrade trigger as a 'no-trigger' rot risk.
 */

'use strict';

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');

function scanMarkers(customPattern) {
  const pattern = customPattern || '(#|//|/[*])\\s*(shortcut|ponytail):';
  let stdout = '';

  try {
    stdout = execSync(
      `git grep --no-index --exclude-standard -nE '${pattern}'`,
      { cwd: ROOT, encoding: 'utf8', maxBuffer: 10 * 1024 * 1024 }
    );
  } catch (err) {
    // git grep exits with 1 when no matches are found
    if (err.status === 1) return [];
    // If git is unavailable or errors, return empty
    return [];
  }

  const lines = stdout.trim().split('\n').filter(Boolean);
  const results = [];

  const markerRegex = /(?:#|\/\/|\/\*)\s*(?:shortcut|ponytail):\s*(.+)/i;

  for (const line of lines) {
    const firstColon = line.indexOf(':');
    const secondColon = line.indexOf(':', firstColon + 1);
    if (firstColon === -1 || secondColon === -1) continue;

    const file = line.substring(0, firstColon);
    const lineNum = parseInt(line.substring(firstColon + 1, secondColon), 10);
    const rawContent = line.substring(secondColon + 1).trim();

    // Skip comments that merely mention the word shortcut or ponytail without being a marker
    if (file.includes('skills/technical-debt-and-shortcuts') || file.includes('scan-debt') || file.startsWith('docs/references/')) {
      // Exclude the scanner itself, skill documentation, and reference docs
      continue;
    }

    const match = rawContent.match(markerRegex);
    if (!match) continue;

    const body = match[1].replace(/\*\/$/, '').trim();
    // Convention: ceiling, upgrade trigger
    const commaIndex = body.indexOf(',');
    let ceiling = '';
    let upgrade = '';
    let hasTrigger = false;

    if (commaIndex !== -1) {
      ceiling = body.substring(0, commaIndex).trim();
      upgrade = body.substring(commaIndex + 1).trim();
      if (upgrade.length > 0) {
        hasTrigger = true;
      }
    } else {
      ceiling = body;
    }

    results.push({
      file,
      line: lineNum,
      raw: rawContent,
      ceiling,
      upgrade: hasTrigger ? upgrade : null,
      hasTrigger
    });
  }

  return results;
}

function formatMarkdown(results) {
  if (results.length === 0) {
    return '# Technical Debt Ledger\n\nNo shortcut debt found. Clean ledger.\n';
  }

  const byFile = {};
  let rotRisks = 0;

  for (const item of results) {
    if (!byFile[item.file]) byFile[item.file] = [];
    byFile[item.file].push(item);
    if (!item.hasTrigger) rotRisks++;
  }

  let md = '# Technical Debt Ledger\n\n';
  md += `Found **${results.length}** shortcut marker(s) across **${Object.keys(byFile).length}** file(s).\n`;
  if (rotRisks > 0) {
    md += `⚠️ **${rotRisks}** marker(s) flagged with \`[no-trigger]\` rot risk.\n\n`;
  } else {
    md += `All markers have defined upgrade triggers.\n\n`;
  }

  md += '## Active Shortcuts\n\n';

  for (const [file, items] of Object.entries(byFile)) {
    md += `### \`${file}\`\n\n`;
    for (const item of items) {
      md += `- **Line ${item.line}**: ${item.ceiling}\n`;
      if (item.hasTrigger) {
        md += `  - *Upgrade trigger*: ${item.upgrade}\n`;
      } else {
        md += `  - ⚠️ *Upgrade trigger*: \`[no-trigger]\` *(rot risk — please specify when to upgrade)*\n`;
      }
    }
    md += '\n';
  }

  return md;
}

// ─── CLI Entrypoint ─────────────────────────────────────────────────────────

if (require.main === module) {
  const args = process.argv.slice(2);
  let jsonOutput = false;
  let savePath = null;
  let customQuery = null;

  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--json') {
      jsonOutput = true;
    } else if (args[i] === '--save') {
      savePath = args[i + 1] || 'DEBT.md';
      i++;
    } else if (!args[i].startsWith('--')) {
      customQuery = args[i];
    }
  }

  const results = scanMarkers(customQuery);

  if (jsonOutput) {
    console.log(JSON.stringify(results, null, 2));
  } else {
    const report = formatMarkdown(results);
    console.log(report);

    if (savePath) {
      const fullPath = path.resolve(ROOT, savePath);
      fs.writeFileSync(fullPath, report, 'utf8');
      console.log(`Ledger saved to: ${fullPath}`);
    }
  }
}

module.exports = { scanMarkers, formatMarkdown };
