"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");

const { checkCatalog } = require("./validate-catalog.js");

test("matching catalog passes", () => {
  const skillDirs = ["code-review-and-quality", "test-driven-development"];
  const readmeText = [
    "| [code-review-and-quality](skills/code-review-and-quality/SKILL.md) |",
    "| [test-driven-development](skills/test-driven-development/SKILL.md) |",
  ].join("\n");
  const otherDocs = {};
  assert.deepEqual(checkCatalog({ skillDirs, readmeText, otherDocs }), []);
});

test("a skill missing from README fails", () => {
  const skillDirs = ["code-review-and-quality", "test-driven-development"];
  const readmeText =
    "| [code-review-and-quality](skills/code-review-and-quality/SKILL.md) |";
  const otherDocs = {};
  assert.deepEqual(checkCatalog({ skillDirs, readmeText, otherDocs }), [
    "skill test-driven-development is missing from the README catalog table",
  ]);
});

test("a README row for a non-existent skill fails", () => {
  const skillDirs = ["code-review-and-quality"];
  const readmeText = [
    "| [code-review-and-quality](skills/code-review-and-quality/SKILL.md) |",
    "| [ghost-skill](skills/ghost-skill/SKILL.md) |",
  ].join("\n");
  const otherDocs = {};
  assert.deepEqual(checkCatalog({ skillDirs, readmeText, otherDocs }), [
    "README catalog row points at missing skill ghost-skill",
  ]);
});

test("a wrong stated count fails", () => {
  const skillDirs = ["a", "b", "c"];
  const readmeText = [
    "| [a](skills/a/SKILL.md) |",
    "| [b](skills/b/SKILL.md) |",
    "| [c](skills/c/SKILL.md) |",
  ].join("\n");
  const otherDocs = { "INSTALL.md": "The pack includes 26 skills total." };
  assert.deepEqual(checkCatalog({ skillDirs, readmeText, otherDocs }), [
    "INSTALL.md states 26 skills; expected 3",
  ]);
});
