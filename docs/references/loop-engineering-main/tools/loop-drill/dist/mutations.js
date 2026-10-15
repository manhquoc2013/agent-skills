/**
 * Mutation operators for the verifier canary.
 *
 * The canary needs a defect a competent verifier should reject. Rather than
 * asking a model to invent one (which makes the drill non-deterministic and
 * costs tokens), we borrow mutation testing: apply a small, mechanical,
 * behaviour-changing edit to real source and see whether the verifier notices.
 *
 * Operators are deliberately restricted to edits that change runtime behaviour
 * in every C-family language, and that a reviewer would call a bug rather than
 * a style choice. Anything ambiguous (`<` -> `>`, which breaks TS generics and
 * JSX; `+` -> `-`, which silently mangles string concatenation) is excluded:
 * a false mutant would report a verifier as broken when it was right to
 * approve.
 */
/**
 * Order matters: the first operator with a match in a file wins, so the
 * least ambiguous edits come first.
 */
export const OPERATORS = [
    {
        id: 'strict-equality-flip',
        description: 'flip === to !==',
        pattern: /===/g,
        replace: '!==',
    },
    {
        id: 'strict-inequality-flip',
        description: 'flip !== to ===',
        pattern: /!==/g,
        replace: '===',
    },
    {
        id: 'boundary-off-by-one',
        description: 'weaken <= to <',
        pattern: /<=/g,
        replace: '<',
    },
    {
        id: 'boundary-off-by-one-gte',
        description: 'weaken >= to >',
        pattern: />=/g,
        replace: '>',
    },
    {
        id: 'logical-and-to-or',
        description: 'flip && to ||',
        pattern: /&&/g,
        replace: '||',
    },
    {
        id: 'return-true-to-false',
        description: 'flip `return true` to `return false`',
        pattern: /\breturn true\b/g,
        replace: 'return false',
    },
    {
        id: 'return-false-to-true',
        description: 'flip `return false` to `return true`',
        pattern: /\breturn false\b/g,
        replace: 'return true',
    },
];
/**
 * Apply the first applicable operator to `content`, mutating only the first
 * occurrence. One edit per mutant keeps the signal clean: if the verifier
 * rejects, it rejected *this* defect.
 *
 * Skips occurrences inside line comments — a verifier is right not to care
 * about a flipped operator in a comment, and crediting it for catching one
 * would overstate the result.
 */
export function mutate(content, file, operators = OPERATORS) {
    for (const operator of operators) {
        const pattern = new RegExp(operator.pattern.source, 'g');
        let match;
        while ((match = pattern.exec(content)) !== null) {
            const index = match.index;
            if (isInLineComment(content, index))
                continue;
            const mutated = content.slice(0, index) + operator.replace + content.slice(index + match[0].length);
            const line = content.slice(0, index).split('\n').length;
            return {
                operator,
                file,
                mutated,
                line,
                before: lineAt(content, line).trim(),
                after: lineAt(mutated, line).trim(),
            };
        }
    }
    return null;
}
function lineAt(content, line) {
    return content.split('\n')[line - 1] ?? '';
}
/** True when `index` sits after a `//` or `#` on its own line. */
function isInLineComment(content, index) {
    const lineStart = content.lastIndexOf('\n', index - 1) + 1;
    const prefix = content.slice(lineStart, index);
    return prefix.includes('//') || /(^|\s)#/.test(prefix);
}
/**
 * Files worth mutating: real source, not build output, vendored code, tests,
 * or generated artifacts. Mutating a test file would make the canary trivially
 * easy (the suite fails loudly); mutating dist/ would make it meaningless
 * (nothing reads it).
 */
const SKIP_DIRECTORIES = /(^|\/)(node_modules|dist|build|out|coverage|vendor|\.git|__snapshots__)(\/|$)/;
const SOURCE_EXTENSIONS = /\.(ts|tsx|js|jsx|mjs|cjs|java|go|rs|c|cc|cpp|cs|kt|swift|php|rb)$/;
const TEST_FILE = /(^|\/)(test|tests|spec|__tests__)(\/|$)|\.(test|spec)\.[a-z]+$/;
export function isMutationCandidate(relativePath) {
    const normalized = relativePath.replace(/\\/g, '/');
    if (SKIP_DIRECTORIES.test(normalized))
        return false;
    if (TEST_FILE.test(normalized))
        return false;
    return SOURCE_EXTENSIONS.test(normalized);
}
