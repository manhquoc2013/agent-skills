/**
 * gate.yaml <-> docs/safety.md policy drift detection.
 *
 * docs/safety.md's "Path Denylist" fenced block is the prose policy; gate.yaml
 * is its machine-readable twin that loop-gate actually enforces. gate.yaml says
 * "Keep in sync with docs/safety.md when either changes" -- but nothing checked
 * it, so the two could silently diverge and leave loop-gate approving paths the
 * documented policy forbids. This module makes that invariant mechanical.
 *
 * Deliberately read-only: a divergence is a human decision (which side is
 * right?), so we never auto-fix a safety policy.
 */
import { parse } from 'yaml';
const DENYLIST_HEADING = /^#{1,6}\s+Path Denylist\s*$/im;
const FENCE = /^\s*```/;
/**
 * Pull the denylist globs out of docs/safety.md.
 *
 * Takes the first fenced block after the "Path Denylist" heading. Strips inline
 * `#` comments (safety.md annotates entries, e.g.
 * `**\/migrations/**  # unless explicit migration loop`).
 *
 * Returns null when the heading or its code block is absent, so callers can
 * tell "no policy documented" apart from "policy documented as empty".
 */
export function extractSafetyDenylist(markdown) {
    const heading = DENYLIST_HEADING.exec(markdown);
    if (!heading)
        return null;
    const after = markdown.slice(heading.index + heading[0].length);
    const lines = after.split(/\r?\n/);
    let start = -1;
    for (let i = 0; i < lines.length; i++) {
        if (FENCE.test(lines[i])) {
            start = i + 1;
            break;
        }
        // A following heading before any fence means the section has no code block.
        if (/^#{1,6}\s/.test(lines[i]))
            return null;
    }
    if (start === -1)
        return null;
    const patterns = [];
    for (let i = start; i < lines.length; i++) {
        if (FENCE.test(lines[i])) {
            return { patterns, malformed: [] };
        }
        const entry = stripComment(lines[i]);
        if (entry)
            patterns.push(entry);
    }
    // Unterminated fence -- treat as unparseable rather than guessing.
    return null;
}
function stripComment(line) {
    const hash = line.indexOf('#');
    // A leading '#' is a whole-line comment; '**/#foo' is not a glob we expect.
    const withoutComment = hash === -1 ? line : line.slice(0, hash);
    return withoutComment.trim();
}
/**
 * Pull denylist + limits out of gate.yaml. Returns null when the file is not
 * valid YAML or has no denylist -- loop-gate reports those itself, and we do
 * not want to double-report a broken gate file as a drift error.
 */
export function extractGateDenylist(yamlText) {
    let parsed;
    try {
        parsed = parse(yamlText);
    }
    catch {
        return null;
    }
    if (!parsed || typeof parsed !== 'object')
        return null;
    const denylist = parsed.denylist;
    if (!Array.isArray(denylist))
        return null;
    const patterns = [];
    const malformed = [];
    for (const entry of denylist) {
        if (typeof entry === 'string' && entry.trim()) {
            patterns.push(entry.trim());
        }
        else {
            malformed.push(String(entry));
        }
    }
    return { patterns, malformed };
}
/** gate.yaml numeric limits that should also appear in the prose policy. */
export function findUndocumentedLimits(yamlText, markdown) {
    let parsed;
    try {
        parsed = parse(yamlText);
    }
    catch {
        return [];
    }
    if (!parsed || typeof parsed !== 'object')
        return [];
    const limits = [];
    const maxFiles = parsed.maxFiles;
    if (typeof maxFiles === 'number' && !mentionsMaxFiles(markdown, maxFiles)) {
        limits.push(`maxFiles: ${maxFiles}`);
    }
    return limits;
}
function mentionsMaxFiles(markdown, value) {
    if (/maxFiles/i.test(markdown))
        return true;
    // Accept prose phrasings like "more than 10 files" / "10 changed files".
    // String.raw so the escapes reach RegExp intact -- a plain template literal
    // would turn \b into a backspace character.
    const prose = String.raw `\b${value}\b[^.\n]{0,24}\bfiles?\b`;
    return new RegExp(prose, 'i').test(markdown);
}
/**
 * Compare the two policies. Comparison is exact string equality on the trimmed
 * glob: two globs can be semantically equivalent while differing textually
 * (`**\/auth/**` vs `**\/auth/*`), and for a safety policy we want the doc and
 * the enforced file to read identically, not merely overlap.
 */
export function comparePolicies(safety, gate, undocumentedLimits = []) {
    const gateSet = new Set(gate.patterns);
    const safetySet = new Set(safety.patterns);
    return {
        missingInGate: safety.patterns.filter((p) => !gateSet.has(p)),
        missingInDoc: gate.patterns.filter((p) => !safetySet.has(p)),
        undocumentedLimits,
    };
}
export function hasDrift(drift) {
    return (drift.missingInGate.length > 0 ||
        drift.missingInDoc.length > 0 ||
        drift.undocumentedLimits.length > 0);
}
