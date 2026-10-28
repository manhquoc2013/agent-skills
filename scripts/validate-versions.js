#!/usr/bin/env node

"use strict";

const { readFileSync } = require("node:fs");

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
    const match = /^version:\s*(.+)$/m.exec(text);
    return match ? match[1].trim() : undefined;
  }
  const manifest = JSON.parse(text);
  return manifest.version ?? manifest.plugins?.[0]?.version;
}

const expectedVersion = readManifestVersion("plugin.json");
if (!expectedVersion) {
  throw new Error("plugin.json is missing a version field");
}

for (const manifestPath of manifestPaths) {
  const version = readManifestVersion(manifestPath);
  if (version !== expectedVersion) {
    throw new Error(
      `${manifestPath} has version ${version ?? "<missing>"}; expected ${expectedVersion}`,
    );
  }
}

console.log(`All plugin manifests use version ${expectedVersion}.`);
