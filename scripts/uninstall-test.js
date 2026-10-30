/**
 * Automated test suite for multi-agent skill uninstallation.
 * Verifies full uninstallation, selective skill removal, alias cleanup, and delegation.
 *
 * Bash handling comes from scripts/lib/bash-probe.js, shared with
 * scripts/run-hook-tests.js so the two cannot disagree about which bash to use.
 * Without a working bash the default is to SKIP with a loud banner;
 * --require-bash turns that skip into a hard error (as CI calls it).
 */
'use strict';
const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');
const assert = require('assert');

const REPO_ROOT = path.resolve(__dirname, '..');
const INSTALL_SCRIPT = path.join(REPO_ROOT, 'scripts', 'install-local.sh');
const UNINSTALL_SCRIPT = path.join(REPO_ROOT, 'scripts', 'uninstall-local.sh');
const ALIASES_SCRIPT = path.join(REPO_ROOT, 'scripts', 'install-aliases.sh');

const { BASH_CMD, hasWorkingBash, skipBanner } = require('./lib/bash-probe');

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

    console.log('Test 5b: Antigravity /s-* aliases land in slash-command skill dirs');
    const fakeHome = path.join(tempDir, 'home');
    fs.mkdirSync(fakeHome, { recursive: true });
    const aliasEnv = { ...process.env, HOME: fakeHome };
    execSync(`"${BASH_CMD}" "${toPosixPath(ALIASES_SCRIPT)}" --only antigravity`, {
      env: aliasEnv,
      stdio: 'pipe',
    });
    const ideAlias = path.join(fakeHome, '.gemini', 'config', 'skills', 's-spec', 'SKILL.md');
    const cliAlias = path.join(fakeHome, '.gemini', 'antigravity-cli', 'skills', 's-spec', 'SKILL.md');
    const pluginAlias = path.join(fakeHome, '.gemini', 'config', 'plugins', 'agent-skills', 'skills', 's-spec');
    assert(fs.existsSync(ideAlias), 'IDE global /s-spec skill should exist');
    assert(fs.existsSync(cliAlias), 'CLI global /s-spec skill should exist');
    assert(!fs.existsSync(pluginAlias), 'Plugin catalog must not receive /s-* wrappers');
    assert(fs.readFileSync(ideAlias, 'utf8').includes('name: s-spec'), 'Wrapper name must be the slash command');
    execSync(`"${BASH_CMD}" "${toPosixPath(ALIASES_SCRIPT)}" --uninstall --only antigravity`, {
      env: aliasEnv,
      stdio: 'pipe',
    });
    assert(!fs.existsSync(ideAlias), 'IDE /s-spec wrapper should be removed');
    assert(!fs.existsSync(cliAlias), 'CLI /s-spec wrapper should be removed');
    console.log('  ✓ Test 5b passed.');

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

  console.log(skipBanner({
    title: 'uninstaller test suite',
    items: SUITES,
    runCommand: 'node scripts/uninstall-test.js',
  }));
  process.exit(0);
}

if (require.main === module) {
  main();
}

module.exports = { hasWorkingBash, skipBanner, runTests };
