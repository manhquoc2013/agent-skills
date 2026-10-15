#!/usr/bin/env node
/**
 * Append one JSON run entry to loop-run-log.md and prune entries older than 30 days.
 * Usage: node scripts/append-run-log.mjs '<json-object>' [path-to-log]
 */
import { readFile, writeFile } from 'node:fs/promises';

const MARKER = '<!-- Loop appends below this line -->';
const MAX_AGE_MS = 30 * 24 * 60 * 60 * 1000;
// Only strings shaped like an ISO date are treated as timestamps for pruning.
// `new Date(...)` is a lenient parser: a non-ISO run_id (a numeric GitHub run
// id, a custom slug like "run-1") doesn't reliably yield NaN, it can parse
// into a spurious in-range-looking date instead (e.g. "run-1" -> 2001-01-01),
// which would then read as "older than 30 days" and get silently pruned even
// though the entry was just written. Gate the parse on this pattern first so
// non-ISO run_ids are always kept, matching loop-metrics' handling of the
// same run_id shapes.
const ISO_DATE_RE = /^\d{4}-\d{2}-\d{2}/;

const entryJson = process.argv[2];
const logPath = process.argv[3] || 'loop-run-log.md';

if (!entryJson) {
  console.error('Usage: node scripts/append-run-log.mjs \'<json>\' [loop-run-log.md]');
  process.exit(1);
}

let entry;
try {
  entry = JSON.parse(entryJson);
} catch {
  console.error('Usage: second argument must be a valid JSON object');
  process.exit(1);
}
const content = await readFile(logPath, 'utf8');
const markerAt = content.indexOf(MARKER);
if (markerAt === -1) {
  console.error(`Marker not found in ${logPath}`);
  process.exit(1);
}

const before = content.slice(0, markerAt + MARKER.length);
const after = content.slice(markerAt + MARKER.length);
const now = Date.now();

const kept = [];
for (const line of after.split('\n')) {
  const trimmed = line.trim();
  if (!trimmed.startsWith('{')) continue;
  try {
    const obj = JSON.parse(trimmed);
    const t = ISO_DATE_RE.test(obj.run_id) ? new Date(obj.run_id).getTime() : NaN;
    if (Number.isNaN(t) || now - t <= MAX_AGE_MS) {
      kept.push(trimmed);
    }
  } catch {
    // skip malformed lines
  }
}

kept.push(JSON.stringify(entry));
await writeFile(logPath, `${before}\n\n${kept.join('\n')}\n`);
console.log(`Appended run ${entry.run_id} (${kept.length} entries within 30d window)`);