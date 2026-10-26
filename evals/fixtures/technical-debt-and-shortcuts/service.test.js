'use strict';

const assert = require('assert');
const { getSession, findItem } = require('./service');

assert.strictEqual(getSession('missing'), undefined);
assert.deepStrictEqual(findItem([{ id: 1 }], 1), { id: 1 });
