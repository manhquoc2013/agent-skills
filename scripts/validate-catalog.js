#!/usr/bin/env node
/**
 * validate-catalog.js
 *
 * Validates that the README.md skill catalog table and every stated skill
 * count in the first-party docs agree with the skills/ directory, which is the
 * single source of truth.
 *
 * Exit codes: 0 = agreement, 1 = one or more discrepancies (one line each).
 */

'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const SKILLS_DIR = path.join(ROOT, 'skills');

// `[<name>](skills/<name>/SKILL.md)` — group 2 is the skill name.
const README_LINK_RE = /\[([^\]]+)\]\(skills\/([^/)]+)\/SKILL\.md\)/g;
// `\b(\d+)\s+skills?\b` case-insensitive.
// Not an exhaustive count: matches only digit counts written "N skills"/"N skill", and the docs walk is deliberately non-recursive because docs/comparison.md and docs/cursor-setup.md (excluded below) carry counts that are not this repo's catalog size.
const COUNT_RE = /\b(\d+)\s+skills?\b/gi;

// Documents whose `N skills` text is NOT a claim about this repo's catalog.
// Scanning is opt-out rather than an allowlist so a newly written setup guide is
// covered the day it lands, but these two must stay excluded or the check cries
// wolf and gets switched off:
//   docs/comparison.md  — the catalog-size row counts THREE projects side by side
//                         ("26 skills | ~14 skills | ~30 skills"); only the first
//                         is ours and it is maintained by hand.
//   docs/cursor-setup.md — quotes the advice "Load 10 skills as always-on rules"
//                         as an anti-pattern to reject, not as a repo total.
const COUNT_SCAN_EXCLUDE = new Set(['docs/comparison.md', 'docs/cursor-setup.md']);

// Docs that state repo-wide facts. docs/references/** is vendored third-party
// material and is never scanned: it is full of other projects' skill counts.
const COUNT_SCAN_ROOT_FILES = ['AGENTS.md', 'CLAUDE.md'];

function collectCountDocs() {
  const docs = {};
  for (const name of COUNT_SCAN_ROOT_FILES) {
    const abs = path.join(ROOT, name);
    if (fs.existsSync(abs)) docs[name] = fs.readFileSync(abs, 'utf8');
  }

  const docsDir = path.join(ROOT, 'docs');
  if (!fs.existsSync(docsDir)) return docs;

  // Non-recursive on purpose: the only markdown under docs/references/ belongs
  // to other projects, and a directory walk is how that boundary gets crossed
  // by accident later.
  for (const entry of fs.readdirSync(docsDir)) {
    if (!entry.endsWith('.md')) continue;
    const rel = `docs/${entry}`;
    if (COUNT_SCAN_EXCLUDE.has(rel)) continue;
    docs[rel] = fs.readFileSync(path.join(docsDir, entry), 'utf8');
  }
  return docs;
}

/**
 * Pure catalog check: returns an array of discrepancy strings (empty = agreement).
 *
 * @param {string[]} skillDirs directory names under skills/ that contain SKILL.md
 * @param {string} readmeText contents of README.md
 * @param {{[path: string]: string}} otherDocs additional docs scanned for counts
 * @returns {string[]} discrepancy messages
 */
function checkCatalog({ skillDirs, readmeText, otherDocs }) {
  const discrepancies = [];
  const dirSet = new Set(skillDirs);

  const readmeSkills = new Set();
  for (const match of readmeText.matchAll(README_LINK_RE)) {
    readmeSkills.add(match[2]);
  }

  for (const dir of skillDirs) {
    if (!readmeSkills.has(dir)) {
      discrepancies.push(`skill ${dir} is missing from the README catalog table`);
    }
  }

  for (const name of readmeSkills) {
    if (!dirSet.has(name)) {
      discrepancies.push(`README catalog row points at missing skill ${name}`);
    }
  }

  const real = skillDirs.length;
  const docs = Object.assign({ 'README.md': readmeText }, otherDocs);
  for (const [docPath, text] of Object.entries(docs)) {
    for (const match of text.matchAll(COUNT_RE)) {
      const stated = parseInt(match[1], 10);
      if (stated !== real) {
        discrepancies.push(`${docPath} states ${stated} skills; expected ${real}`);
      }
    }
  }

  return discrepancies;
}

function main() {
  const skillDirs = fs
    .readdirSync(SKILLS_DIR)
    .filter(
      (d) =>
        fs.statSync(path.join(SKILLS_DIR, d)).isDirectory() &&
        fs.existsSync(path.join(SKILLS_DIR, d, 'SKILL.md')),
    )
    .sort();

  const readmeText = fs.readFileSync(path.join(ROOT, 'README.md'), 'utf8');
  const installText = fs.readFileSync(path.join(ROOT, 'INSTALL.md'), 'utf8');

  const discrepancies = checkCatalog({
    skillDirs,
    readmeText,
    // INSTALL.md is passed explicitly because it is a root-level install guide,
    // not part of the docs/ sweep below.
    otherDocs: Object.assign(collectCountDocs(), { 'INSTALL.md': installText }),
  });

  if (discrepancies.length > 0) {
    for (const message of discrepancies) {
      console.error(message);
    }
    process.exit(1);
  }

  console.log(
    `Catalog valid: ${skillDirs.length} skills agree with the README table and count claims.`,
  );
}

if (require.main === module) {
  try {
    main();
  } catch (err) {
    console.error(`\nERROR: validate-catalog failed unexpectedly: ${err.message}`);
    process.exit(1);
  }
}

module.exports = { checkCatalog };
