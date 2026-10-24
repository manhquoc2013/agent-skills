/**
 * Automated test suite for multi-agent skill uninstallation.
 * Verifies full uninstallation, selective skill removal, alias cleanup, and delegation.
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

console.log('Running Multi-Agent Skill Uninstaller Test Suite...');

// Create a sandbox project directory
const tempDir = fs.mkdtempSync(path.join(os.tmpdir(), 'agent-skills-test-'));
try {
  console.log(`Sandbox directory: ${tempDir}`);

  // Test 1: Help and flag checks
  console.log('Test 1: CLI Help output validation');
  const uninstallHelp = execSync(`${UNINSTALL_SCRIPT} --help`, { encoding: 'utf8' });
  assert(uninstallHelp.includes('uninstall-local.sh'), 'Expected usage info in uninstall-local.sh');
  assert(uninstallHelp.includes('--skills'), 'Expected --skills in uninstall-local.sh help');

  const installHelp = execSync(`${INSTALL_SCRIPT} --help`, { encoding: 'utf8' });
  assert(installHelp.includes('--uninstall'), 'Expected --uninstall in install-local.sh help');

  const aliasesHelp = execSync(`${ALIASES_SCRIPT} --help`, { encoding: 'utf8' });
  assert(aliasesHelp.includes('--uninstall'), 'Expected --uninstall in install-aliases.sh help');
  console.log('  ✓ Test 1 passed.');

  // Test 2: Project installation to sandbox
  console.log('Test 2: Install skills to sandbox');
  execSync(`${INSTALL_SCRIPT} --only cursor --scope project --project "${tempDir}" --no-aliases`, { stdio: 'pipe' });
  const cursorSkillsDir = path.join(tempDir, '.cursor', 'skills');
  assert(fs.existsSync(cursorSkillsDir), 'Cursor skills directory should exist in sandbox');
  assert(fs.existsSync(path.join(cursorSkillsDir, 'using-agent-skills', 'SKILL.md')), 'Marker skill should exist');
  assert(fs.existsSync(path.join(cursorSkillsDir, '.agent-skills-install.json')), 'Install stamp should exist');
  console.log('  ✓ Test 2 passed.');

  // Test 3: Selective skill uninstallation
  console.log('Test 3: Selective skill uninstallation (--skills)');
  assert(fs.existsSync(path.join(cursorSkillsDir, 'autonomous-agent-workflow')), 'autonomous-agent-workflow should exist before removal');
  execSync(`${UNINSTALL_SCRIPT} --only cursor --scope project --project "${tempDir}" --skills autonomous-agent-workflow --keep-aliases`, { stdio: 'pipe' });
  assert(!fs.existsSync(path.join(cursorSkillsDir, 'autonomous-agent-workflow')), 'autonomous-agent-workflow should be removed');
  assert(fs.existsSync(path.join(cursorSkillsDir, 'using-agent-skills')), 'using-agent-skills should remain intact');
  console.log('  ✓ Test 3 passed.');

  // Test 4: Full uninstallation of all skills
  console.log('Test 4: Full uninstallation (--all)');
  execSync(`${UNINSTALL_SCRIPT} --only cursor --scope project --project "${tempDir}" --keep-aliases`, { stdio: 'pipe' });
  assert(!fs.existsSync(path.join(cursorSkillsDir, 'using-agent-skills')), 'Marker skill should be removed');
  assert(!fs.existsSync(path.join(cursorSkillsDir, '.agent-skills-install.json')), 'Install stamp should be removed');
  console.log('  ✓ Test 4 passed.');

  // Test 5: Alias installation and uninstallation
  console.log('Test 5: Slash command aliases uninstallation');
  execSync(`${ALIASES_SCRIPT} --only cursor --scope project --project "${tempDir}"`, { stdio: 'pipe' });
  const aliasDir = path.join(cursorSkillsDir, 's-agent');
  assert(fs.existsSync(aliasDir), 'Alias s-agent should exist after install');
  execSync(`${ALIASES_SCRIPT} --uninstall --only cursor --scope project --project "${tempDir}"`, { stdio: 'pipe' });
  assert(!fs.existsSync(aliasDir), 'Alias s-agent should be removed after uninstall');
  console.log('  ✓ Test 5 passed.');

  // Test 6: Delegation via install-local.sh --uninstall
  console.log('Test 6: Delegation from install-local.sh --uninstall');
  const delegatedList = execSync(`${INSTALL_SCRIPT} --uninstall --list --scope project --project "${tempDir}"`, { encoding: 'utf8' });
  assert(delegatedList.includes('Destination'), 'Delegated list should contain Destination header');
  console.log('  ✓ Test 6 passed.');

  console.log('\nAll 6 uninstaller test suites passed successfully!');
} finally {
  fs.rmSync(tempDir, { recursive: true, force: true });
}
