/**
 * Automated test suite for multi-agent skill uninstallation.
 * Verifies full uninstallation, selective skill removal, alias cleanup, and delegation.
 *
 * Mirrors scripts/run-hook-tests.js bash handling: probes the SAME executable the
 * suites run. Without a working bash the default is to SKIP with a loud banner;
 * --require-bash turns that skip into a hard error (as CI calls it).
 */
'use strict';
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync, spawnSync } = require('child_process');
const assert = require('assert');

const REPO_ROOT = path.resolve(__dirname, '..');
const INSTALL_SCRIPT = path.join(REPO_ROOT, 'scripts', 'install-local.sh');
const UNINSTALL_SCRIPT = path.join(REPO_ROOT, 'scripts', 'uninstall-local.sh');
const ALIASES_SCRIPT = path.join(REPO_ROOT, 'scripts', 'install-aliases.sh');

// The unquoted resolved path: quote it only inside runScript's exec template so
// hasWorkingBash() probes the exact same executable the suites actually run.
const BASH_CMD = (() => {
  if (process.platform !== 'win32') return 'bash';
  const candidates = [
    process.env.GIT_BASH,
    path.join(process.env.LOCALAPPDATA || '', 'Programs', 'Git', 'bin', 'bash.exe'),
    path.join(process.env.ProgramFiles || 'C:\\Program Files', 'Git', 'bin', 'bash.exe'),
    path.join(process.env['ProgramFiles(x86)'] || 'C:\\Program Files (x86)', 'Git', 'bin', 'bash.exe'),
  ];
  for (const c of candidates) {
    if (c && fs.existsSync(c)) return c;
  }
  try {
    const gitExec = execSync('git --exec-path', { encoding: 'utf8' }).trim();
    const gitBash = path.resolve(gitExec, '..', '..', 'bin', 'bash.exe');
    if (fs.existsSync(gitBash)) return gitBash;
  } catch {}
  return 'bash';
})();

const SUITES = [
  'help/flags',
  'install',
  'selective uninstall',
  'full uninstall',
  'aliases',
  'delegation',
];

function toPosixPath(p) {
  return p.replace(/\\/g, '/');
}

function runScript(scriptPath, args, options = {}) {
  const normScript = `"${toPosixPath(scriptPath)}"`;
  return execSync(`"${BASH_CMD}" ${normScript} ${args}`, options);
}

function hasWorkingBash() {
  // A broken WSL relay fails the probe with a spawn error (status === null),
  // so treat "bash exists but cannot exec" as "no bash".
  const probe = spawnSync(BASH_CMD, ['-c', 'exit 0'], { stdio: 'ignore' });
  return !probe.error && probe.status === 0;
}

function skipBanner() {
  const lines = [
    '==============================================================',
    '  SKIPPED — uninstaller test suite was NOT run',
    '==============================================================',
    '',
    '  Reason: no working bash was detected on this machine',
    '          (probe `bash -c "exit 0"` failed, e.g. a broken WSL relay).',
    '',
    '  Suites skipped (NOT run):',
  ];
  for (const suite of SUITES) {
    lines.push(`    - ${suite}`);
  }
  lines.push(
    '',
    '  How to run them:',
    '    - Install Git Bash (https://gitforwindows.org), or enable WSL,',
    '      then re-run after installing Git Bash / enabling WSL:',
    '      node scripts/uninstall-test.js',
    '=============================================================='
  );
  return lines.join('\n');
}

function runTests() {
  console.log('Running Multi-Agent Skill Uninstaller Test Suite...');

  // Create a sandbox project directory
  const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'agent-skills-test-'));
  try {
    console.log(`Sandbox directory: ${tempDir}`);

    // Test 1: Help and flag checks
    console.log('Test 1: CLI Help output validation');
    const uninstallHelp = runScript(UNINSTALL_SCRIPT, '--help', { encoding: 'utf8' });
    assert(uninstallHelp.includes('uninstall-local.sh'), 'Expected usage info in uninstall-local.sh');
    assert(uninstallHelp.includes('--skills'), 'Expected --skills in uninstall-local.sh help');

    const installHelp = runScript(INSTALL_SCRIPT, '--help', { encoding: 'utf8' });
    assert(installHelp.includes('--uninstall'), 'Expected --uninstall in install-local.sh help');

    const aliasesHelp = runScript(ALIASES_SCRIPT, '--help', { encoding: 'utf8' });
    assert(aliasesHelp.includes('--uninstall'), 'Expected --uninstall in install-aliases.sh help');
    console.log('  ✓ Test 1 passed.');

    // Test 2: Project installation to sandbox
    console.log('Test 2: Install skills to sandbox');
    runScript(INSTALL_SCRIPT, `--only cursor --scope project --project "${toPosixPath(tempDir)}" --no-aliases`, { stdio: 'pipe' });
    const cursorSkillsDir = path.join(tempDir, '.cursor', 'skills');
    assert(fs.existsSync(cursorSkillsDir), 'Cursor skills directory should exist in sandbox');
    assert(fs.existsSync(path.join(cursorSkillsDir, 'using-agent-skills', 'SKILL.md')), 'Marker skill should exist');
    assert(fs.existsSync(path.join(cursorSkillsDir, '.agent-skills-install.json')), 'Install stamp should exist');
    console.log('  ✓ Test 2 passed.');

    // Test 3: Selective skill uninstallation
    console.log('Test 3: Selective skill uninstallation (--skills)');
    assert(fs.existsSync(path.join(cursorSkillsDir, 'autonomous-agent-workflow')), 'autonomous-agent-workflow should exist before removal');
    runScript(UNINSTALL_SCRIPT, `--only cursor --scope project --project "${toPosixPath(tempDir)}" --skills autonomous-agent-workflow --keep-aliases`, { stdio: 'pipe' });
    assert(!fs.existsSync(path.join(cursorSkillsDir, 'autonomous-agent-workflow')), 'autonomous-agent-workflow should be removed');
    assert(fs.existsSync(path.join(cursorSkillsDir, 'using-agent-skills')), 'using-agent-skills should remain intact');
    console.log('  ✓ Test 3 passed.');

    // Test 4: Full uninstallation of all skills
    console.log('Test 4: Full uninstallation (--all)');
    runScript(UNINSTALL_SCRIPT, `--only cursor --scope project --project "${toPosixPath(tempDir)}" --keep-aliases`, { stdio: 'pipe' });
    assert(!fs.existsSync(path.join(cursorSkillsDir, 'using-agent-skills')), 'Marker skill should be removed');
    assert(!fs.existsSync(path.join(cursorSkillsDir, '.agent-skills-install.json')), 'Install stamp should be removed');
    console.log('  ✓ Test 4 passed.');

    // Test 5: Alias installation and uninstallation
    console.log('Test 5: Slash command aliases uninstallation');
    runScript(ALIASES_SCRIPT, `--only cursor --scope project --project "${toPosixPath(tempDir)}"`, { stdio: 'pipe' });
    const aliasDir = path.join(cursorSkillsDir, 's-agent');
    assert(fs.existsSync(aliasDir), 'Alias s-agent should exist after install');
    runScript(ALIASES_SCRIPT, `--uninstall --only cursor --scope project --project "${toPosixPath(tempDir)}"`, { stdio: 'pipe' });
    assert(!fs.existsSync(aliasDir), 'Alias s-agent should be removed after uninstall');
    console.log('  ✓ Test 5 passed.');

    // Test 6: Delegation via install-local.sh --uninstall
    console.log('Test 6: Delegation from install-local.sh --uninstall');
    const delegatedList = runScript(INSTALL_SCRIPT, `--uninstall --list --scope project --project "${toPosixPath(tempDir)}"`, { encoding: 'utf8' });
    assert(delegatedList.includes('Destination'), 'Delegated list should contain Destination header');
    console.log('  ✓ Test 6 passed.');

    console.log('\nAll 6 uninstaller test suites passed successfully!');
  } finally {
    fs.rmSync(tempDir, { recursive: true, force: true });
  }
}

function main() {
  if (hasWorkingBash()) {
    runTests();
    return;
  }

  if (process.argv.includes('--require-bash')) {
    console.error('Error: uninstaller test suite could not run because no working bash is available.');
    console.error('--require-bash was passed, so this is a hard error rather than a skip.');
    console.error('Suites that could not run:');
    for (const suite of SUITES) {
      console.error(`  - ${suite}`);
    }
    process.exit(1);
  }

  console.log(skipBanner());
  process.exit(0);
}

if (require.main === module) {
  main();
}

module.exports = { hasWorkingBash, skipBanner, runTests };
