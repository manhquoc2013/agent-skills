import { writeFileSync } from 'node:fs';

// Deliberately never reads stdin -- simulates an operator's notify script
// that ignores its input entirely. Writes a marker first so the test can
// confirm this process actually ran despite draining nothing.
writeFileSync(process.argv[2], 'ran');
