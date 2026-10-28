#!/usr/bin/env node
/**
 * run-hook-tests.js
 *
 * Runs the bash hook test suites (session-start, sdd-cache, simplify-ignore)
 * in order. Probes for a working `bash` first, because a machine can have a
 * `bash` on PATH that is a broken WSL relay and cannot exec anything: running
 * zero suites and reporting success is the failure mode this exists to prevent.
 *
 * Without a usable bash the default is to SKIP with a loud banner, so a
 * contributor on a bash-less Windows box is not blocked by a suite that has
 * nothing to do with their change. CI calls
 * `node scripts/run-hook-tests.js --require-bash`, which turns that skip into a
 * hard error so a gate is never silently skipped.
 *
 * The flag, not an ambient `CI` environment variable, decides this. `CI` is set
 * on plenty of developer machines and inside agent harnesses, so keying the
 * behaviour off it turns every local run into a false alarm.
 *
 * Uses built-in Node.js modules only. Zero external dependencies.
 */

'use strict';

const { spawnSync } = require('child_process');
const path = require('path');

const HOOK_SUITES = [
  'session-start-test.sh',
  'sdd-cache-test.sh',
  'simplify-ignore-test.sh',
];

const HOOKS_DIR = path.resolve(__dirname, '..', 'hooks');

function hasWorkingBash() {
  // A broken WSL relay fails the probe with a spawn error (status === null),
  // so treat "bash exists but cannot exec" as "no bash".
  const probe = spawnSync('bash', ['-c', 'exit 0'], { stdio: 'ignore' });
  return !probe.error && probe.status === 0;
}

function skipBanner() {
  const lines = [
    '==============================================================',
    '  SKIPPED — hook test suites were NOT run',
    '==============================================================',
    '',
    '  Reason: no working bash was detected on this machine',
    '          (probe `bash -c "exit 0"` failed, e.g. a broken WSL relay).',
    '',
    '  Suites skipped (NOT run):',
  ];
  for (const suite of HOOK_SUITES) {
    lines.push(`    - hooks/${suite}`);
  }
  lines.push(
    '',
    '  How to run them:',
    '    - Install Git Bash (https://gitforwindows.org), or enable WSL,',
    '      then re-run:  npm run test:hooks',
    '',
    '  NOTE: this skip is a LOCAL convenience only. CI calls',
    '        `node scripts/run-hook-tests.js --require-bash` to turn it into a',
    '        hard error.',
    '=============================================================='
  );
  return lines.join('\n');
}

function main() {
  if (hasWorkingBash()) {
    for (const suite of HOOK_SUITES) {
      console.log(`\nRunning hook suite: ${suite}`);
      const result = spawnSync('bash', [path.join(HOOKS_DIR, suite)], {
        stdio: 'inherit',
      });
      if (result.error) {
        console.error(`\nFailed to execute ${suite}: ${result.error.message}`);
        process.exit(1);
      }
      if (result.status !== 0) {
        process.exit(result.status == null ? 1 : result.status);
      }
    }
    process.exit(0);
  }

  if (process.argv.includes('--require-bash')) {
    console.error('Error: hook test suites could not run because no working bash is available.');
    console.error('--require-bash was passed, so this is a hard error rather than a skip.');
    console.error('Suites that could not run:');
    for (const suite of HOOK_SUITES) {
      console.error(`  - hooks/${suite}`);
    }
    process.exit(1);
  }

  console.log(skipBanner());
  process.exit(0);
}

if (require.main === module) {
  main();
}

module.exports = { HOOK_SUITES, hasWorkingBash, skipBanner };
