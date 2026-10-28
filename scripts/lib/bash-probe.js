'use strict';
/**
 * bash-probe.js — one place that decides WHICH bash to run and whether it works.
 *
 * Two callers depend on this: scripts/run-hook-tests.js and
 * scripts/uninstall-test.js. They carried their own copies and had already
 * drifted: the hook runner probed bare `bash`, which on Windows resolves to
 * C:\Windows\System32\bash.exe — the WSL relay — and fails when no distro is
 * installed, while the uninstaller resolved Git Bash first and ran fine. The
 * visible result was `npm run test:hooks` skipping three suites that would have
 * passed on the same machine. Resolution order lives here, once, so a future
 * caller cannot re-introduce that split.
 *
 * Resolution order matters: an explicit GIT_BASH wins, then the usual Git for
 * Windows install locations, then whatever `git --exec-path` points at, and
 * only then the bare name on PATH. The bare name is last precisely because on
 * Windows it is the one most likely to be the broken relay.
 */

const fs = require('fs');
const path = require('path');
const { execSync, spawnSync } = require('child_process');

function resolveBash() {
  if (process.platform !== 'win32') return 'bash';

  const candidates = [
    process.env.GIT_BASH,
    path.join(process.env.LOCALAPPDATA || '', 'Programs', 'Git', 'bin', 'bash.exe'),
    path.join(process.env.ProgramFiles || 'C:\\Program Files', 'Git', 'bin', 'bash.exe'),
    path.join(process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)', 'Git', 'bin', 'bash.exe'),
  ];
  for (const candidate of candidates) {
    if (candidate && fs.existsSync(candidate)) return candidate;
  }

  try {
    const gitExec = execSync('git --exec-path', { encoding: 'utf8' }).trim();
    const gitBash = path.resolve(gitExec, '..', '..', 'bin', 'bash.exe');
    if (fs.existsSync(gitBash)) return gitBash;
  } catch {
    // git not installed — fall through to the bare name and let the probe decide.
  }

  return 'bash';
}

const BASH_CMD = resolveBash();

/**
 * True only if the resolved bash can actually exec something. A binary that
 * exists but cannot be run (status === null from a spawn error, or a non-zero
 * exit from the relay) counts as absent: "installed" is not "working".
 */
function hasWorkingBash(cmd = BASH_CMD) {
  const probe = spawnSync(cmd, ['-c', 'exit 0'], { stdio: 'ignore' });
  return !probe.error && probe.status === 0;
}

/**
 * The loud local-only notice. Both callers print the same shape so a
 * contributor meets one explanation, not two dialects of the same one.
 */
function skipBanner({ title, items, runCommand }) {
  const lines = [
    '==============================================================',
    `  SKIPPED — ${title} were NOT run`,
    '==============================================================',
    '',
    '  Reason: no WORKING bash was detected on this machine.',
    '          A bash that exists but cannot exec (a broken WSL relay)',
    '          counts as none, because running zero suites and',
    '          reporting success is the failure this guards against.',
    '',
    `  Resolved bash: ${BASH_CMD}`,
    '',
    '  Suites skipped (NOT run):',
  ];
  for (const item of items) lines.push(`    - ${item}`);
  lines.push(
    '',
    '  How to run them:',
    '    - Install Git Bash (https://gitforwindows.org), set GIT_BASH, or',
    '      enable a WSL distro, then re-run:',
    `      ${runCommand}`,
    '',
    '  NOTE: this skip is a LOCAL convenience only. Pass --require-bash (CI',
    '        does) to turn it into a hard error instead.',
    '==============================================================',
  );
  return lines.join('\n');
}

module.exports = { BASH_CMD, resolveBash, hasWorkingBash, skipBanner };
