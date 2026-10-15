#!/usr/bin/env node
/**
 * Smoke test for scripts/append-run-log.mjs.
 * Run directly (node scripts/append-run-log.test.mjs) or via the validate gates.
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { mkdtemp, writeFile, rm, readFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const exec = promisify(execFile);
// `new URL(...).pathname` yields a leading-slash path (e.g. "/D:/...") that
// Windows' node CLI mis-resolves relative to the current drive instead of
// treating as absolute (same class of bug already fixed for
// tools/loop/test/files.test.mjs) -- fileURLToPath() gives the correct
// platform-native path on every OS.
const SCRIPT = fileURLToPath(new URL('./append-run-log.mjs', import.meta.url));

test('invalid JSON second arg exits 1 with a Usage / valid JSON message', async () => {
  await assert.rejects(
    exec('node', [SCRIPT, 'not-json', 'ignored.log']),
    (err) => {
      assert.equal(err.code, 1);
      const msg = `${err.stderr}${err.stdout}`;
      assert.match(msg, /Usage|valid JSON/i);
      return true;
    },
  );
});

test('valid minimal JSON entry does not throw on parse', async () => {
  const dir = await mkdtemp(path.join(tmpdir(), 'append-run-log-'));
  const logPath = path.join(dir, 'loop-run-log.md');
  await writeFile(logPath, '<!-- Loop appends below this line -->\n');
  try {
    const entry = JSON.stringify({ run_id: 'run-1', outcome: 'ok' });
    const { stdout } = await exec('node', [SCRIPT, entry, logPath]);
    assert.match(stdout, /Appended run run-1/);
    const written = await readFile(logPath, 'utf8');
    assert.ok(written.includes('"run_id":"run-1"'));
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});

test('a non-ISO run_id (e.g. a custom slug) survives the next append instead of being pruned', async () => {
  const dir = await mkdtemp(path.join(tmpdir(), 'append-run-log-'));
  const logPath = path.join(dir, 'loop-run-log.md');
  await writeFile(logPath, '<!-- Loop appends below this line -->\n');
  try {
    // "run-1" parses under JS's lenient Date constructor into 2001-01-01,
    // which looks 30+ days old -- it must not be pruned on the next append.
    await exec('node', [SCRIPT, JSON.stringify({ run_id: 'run-1', outcome: 'ok' }), logPath]);
    await exec('node', [SCRIPT, JSON.stringify({ run_id: 'run-2', outcome: 'ok' }), logPath]);
    const written = await readFile(logPath, 'utf8');
    assert.ok(written.includes('"run_id":"run-1"'), 'run-1 entry should still be present');
    assert.ok(written.includes('"run_id":"run-2"'), 'run-2 entry should still be present');
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
});
