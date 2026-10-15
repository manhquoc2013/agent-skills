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
/** Where a denylist was read from, for message text. */
export interface DenylistSource {
    patterns: string[];
    /** Entries the parser saw but could not use, e.g. non-string YAML nodes. */
    malformed: string[];
}
export interface PolicyDrift {
    /** In docs/safety.md but absent from gate.yaml -- enforcement is weaker than the doc. */
    missingInGate: string[];
    /** In gate.yaml but absent from docs/safety.md -- enforcement is undocumented. */
    missingInDoc: string[];
    /** gate.yaml limits that the prose policy never states. */
    undocumentedLimits: string[];
}
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
export declare function extractSafetyDenylist(markdown: string): DenylistSource | null;
/**
 * Pull denylist + limits out of gate.yaml. Returns null when the file is not
 * valid YAML or has no denylist -- loop-gate reports those itself, and we do
 * not want to double-report a broken gate file as a drift error.
 */
export declare function extractGateDenylist(yamlText: string): DenylistSource | null;
/** gate.yaml numeric limits that should also appear in the prose policy. */
export declare function findUndocumentedLimits(yamlText: string, markdown: string): string[];
/**
 * Compare the two policies. Comparison is exact string equality on the trimmed
 * glob: two globs can be semantically equivalent while differing textually
 * (`**\/auth/**` vs `**\/auth/*`), and for a safety policy we want the doc and
 * the enforced file to read identically, not merely overlap.
 */
export declare function comparePolicies(safety: DenylistSource, gate: DenylistSource, undocumentedLimits?: string[]): PolicyDrift;
export declare function hasDrift(drift: PolicyDrift): boolean;
