"use strict";

const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const test = require("node:test");

const manifestPaths = [
  "plugin.json",
  ".codex-plugin/plugin.json",
  ".claude-plugin/plugin.json",
  ".claude-plugin/marketplace.json",
  ".agents/plugins/marketplace.json",
  "package.json",
  "gemini-extension.json",
  "plugin.yaml",
];

function readManifestVersion(manifestPath) {
  const text = readFileSync(manifestPath, "utf8");
  if (/\.ya?ml$/i.test(manifestPath)) {
    const m = /^version:\s*(.+)$/m.exec(text);
    return m ? m[1].trim() : undefined;
  }
  const manifest = JSON.parse(text);
  return manifest.version ?? manifest.plugins?.[0]?.version;
}

test("all plugin manifests use the root plugin.json version", () => {
  const expectedVersion = readManifestVersion("plugin.json");
  assert.ok(expectedVersion, "plugin.json must define a version");

  for (const manifestPath of manifestPaths) {
    assert.equal(
      readManifestVersion(manifestPath),
      expectedVersion,
      `${manifestPath} must use version ${expectedVersion}`,
    );
  }
});
