#!/usr/bin/env node
/**
 * sync-assets.js — Verifies and mirrors skill assets without symlinks (Issue #361)
 * Ensures all skills with data/scripts are self-contained and free of broken symlinks.
 */

'use strict';

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const repoRoot = path.resolve(__dirname, '..');
const checkOnly = process.argv.includes('--check');

const toLF = (text) => text.replace(/\r\n/g, '\n');

function exists(p) {
  try {
    fs.accessSync(p);
    return true;
  } catch {
    return false;
  }
}

function verifyNoSymlinks(root) {
  const violations = [];
  function walk(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isSymbolicLink()) {
        violations.push(path.relative(repoRoot, fullPath));
      } else if (entry.isDirectory()) {
        walk(fullPath);
      }
    }
  }
  if (exists(root)) {
    walk(root);
  }
  return violations;
}

function listFiles(root) {
  const files = [];
  function walk(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        if (entry.name !== '__pycache__' && entry.name !== '.pytest_cache') {
          walk(fullPath);
        }
      } else if (entry.isFile()) {
        if (!entry.name.endsWith('.pyc')) {
          files.push(path.relative(root, fullPath).replace(/\\/g, '/'));
        }
      }
    }
  }
  if (exists(root)) {
    walk(root);
  }
  return files.sort();
}

function main() {
  console.log('🔍 Checking skill asset integrity and portability...');

  // 1. Check for forbidden symlinks across skills/
  const symlinks = verifyNoSymlinks(path.join(repoRoot, 'skills'));
  if (symlinks.length > 0) {
    console.error('❌ Found forbidden symlinks (violates Windows & portability contract):');
    for (const s of symlinks) console.error(`  - ${s}`);
    process.exit(1);
  }

  // 2. Validate frontend-ui-engineering self-contained assets
  const frontendDir = path.join(repoRoot, 'skills', 'frontend-ui-engineering');
  const dataDir = path.join(frontendDir, 'data');
  const scriptsDir = path.join(frontendDir, 'scripts');
  const refsDir = path.join(frontendDir, 'references');

  const checks = [
    { name: 'data/', path: dataDir, minFiles: 30 },
    { name: 'scripts/search.py', path: path.join(scriptsDir, 'search.py'), isFile: true },
    { name: 'scripts/core.py', path: path.join(scriptsDir, 'core.py'), isFile: true },
    { name: 'scripts/design_system.py', path: path.join(scriptsDir, 'design_system.py'), isFile: true },
    { name: 'references/quick-reference.md', path: path.join(refsDir, 'quick-reference.md'), isFile: true },
    { name: 'references/pro-rules.md', path: path.join(refsDir, 'pro-rules.md'), isFile: true },
  ];

  let errors = 0;
  for (const check of checks) {
    if (check.isFile) {
      if (!exists(check.path)) {
        console.error(`❌ Missing required file: ${path.relative(repoRoot, check.path)}`);
        errors++;
      } else {
        console.log(`  ✓ ${check.name} present`);
      }
    } else {
      if (!exists(check.path)) {
        console.error(`❌ Missing required directory: ${path.relative(repoRoot, check.path)}`);
        errors++;
      } else {
        const files = listFiles(check.path);
        if (files.length < check.minFiles) {
          console.error(`❌ Incomplete directory ${check.name}: expected ≥${check.minFiles} files, found ${files.length}`);
          errors++;
        } else {
          console.log(`  ✓ ${check.name} present (${files.length} files)`);
        }
      }
    }
  }

  if (errors > 0) {
    console.error(`\n❌ Asset sync verification failed with ${errors} error(s).`);
    process.exit(1);
  }

  console.log('\n✅ All assets are self-contained, valid, and symlink-free (Portability contract satisfied).');
}

main();
