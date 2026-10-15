---
type: Fixed
pr: 5269
---
**Claude Code installs no longer pre-authorize `npx gsd-core`** — the installer wrote a `Bash(npx gsd-core *)` allow rule, but GSD ships as `@opengsd/gsd-core` and the unscoped npm name belongs to a different owner, so Claude Code would run whatever was published under it without asking. Fresh installs no longer write the rule, the next install or upgrade removes it from an existing settings file (exact match only), and `GEMINI.md` now gives the scoped install command. (#5054)
