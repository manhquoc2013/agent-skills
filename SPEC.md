# Spec: Upgrading agent-skills with UI/UX Pro Max Design Intelligence

## Capability Map: UI/UX Intelligence & Engineering Upgrade

| Module ID | Responsibility | Depends On |
|---|---|---|
| `data-intelligence-engine` | Zero-dependency local search engine (BM25 + regex) and canonical curated design datasets (styles, palettes, typography, stacks, UX rules, charts, icons, motion) | — |
| `frontend-ui-upgrade` | Upgrade `skills/frontend-ui-engineering` to integrate local design querying, reasoning rules, design dials, and stack-specific recipes | `data-intelligence-engine` |
| `lifecycle-ui-binding` | Bind design system generation and pre-delivery verification into lifecycle commands (`/s-spec`, `/s-build`, `/s-review`, `/s-ship`) and master/overrides persistence | `frontend-ui-upgrade` |
| `asset-sync-and-portability` | Self-contained skill bundling and sync utility (`sync-assets`) eliminating symlinks and solving Issue #361 for single-skill distribution | `data-intelligence-engine` |
| `multi-platform-installer` | Update `scripts/install-local.sh` and multi-agent distribution adapters to deploy executable skills, data, and hooks across 20+ AI coding environments | `asset-sync-and-portability`, `lifecycle-ui-binding` |
| `testing-and-validation` | Automated test suite verifying BM25 search precision, dataset schema integrity, cross-platform installer syntax, and eval scenarios | `multi-platform-installer` |

Build order: `data-intelligence-engine` → `frontend-ui-upgrade`, `asset-sync-and-portability` → `lifecycle-ui-binding` → `multi-platform-installer` → `testing-and-validation`.

---

## 1. Objective

Upgrade `agent-skills` from high-level markdown-only frontend guidelines into an industry-grade, deterministic **Design Intelligence & UI Engineering System**, drawing directly from the architectural innovations of **UI UX Pro Max** (`docs/references/ui-ux-pro-max-skill-main`).

### Problems Solved:
1. **Generic "AI Aesthetic" & Guesswork**: Agents currently generate plain, repetitive, or mismatched UI styles, inaccurate color contrast, and arbitrary typography because `frontend-ui-engineering` only provides high-level text instructions without concrete, searchable design datasets.
2. **Missing Tech Stack Precision**: Real-world apps use diverse frameworks (Tailwind, Shadcn UI, Next.js, SwiftUI, Flutter, Jetpack Compose, Vue, Svelte). Currently, `agent-skills` lacks specialized guidelines and component tokens for these stacks.
3. **Session Inconsistency**: Complex apps lose visual cohesion across multiple agent turns without an explicit, persistent design contract (`MASTER.md` + page overrides).
4. **Skill Portability Gap (Issue #361)**: Installing single skills via `npx skills add` or package managers strips external `references/` folders. Packaging self-contained assets with automated mirroring ensures all skills remain 100% portable.

### Target Users:
Senior engineers and AI coding agents (Claude Code, Cursor, OpenCode, Codex, Antigravity, Copilot, Windsurf) building production web and mobile user interfaces who demand pixel-perfect visual polish, rigorous WCAG accessibility, and cohesive design systems.

---

## 2. Assumptions

```
ASSUMPTIONS I'M MAKING:
1. Zero External Dependencies: The search engine will use standard Python 3 (standard library only: json, csv, math, re, argparse, sys, os) so it executes instantaneously in any environment without `pip install`.
2. Clean Modular Organization: The design datasets and search engine will live natively within `skills/frontend-ui-engineering/` (with a mirror or shared CLI helper in `scripts/`), keeping skills self-contained.
3. Master + Overrides Convention: Persisted design systems will live in `design-system/<project-slug>/MASTER.md` with optional page overrides in `design-system/<project-slug>/pages/<page-slug>.md`.
4. Backward Compatibility: All existing markdown skills and commands (`/s-spec`, `/s-plan`, `/s-build`, `/s-review`, `/s-debt`, `/s-ship`) remain fully functional; UI design intelligence activates conditionally when tasks touch user-facing screens or design decisions.
```

---

## 3. Core Modules & Architecture

### Module 1: `data-intelligence-engine`
- **Location**: `skills/frontend-ui-engineering/data/` and `skills/frontend-ui-engineering/scripts/`
- **Canonical Datasets** (curated CSVs and JSONs):
  - `styles.csv`: 79 UI styles (glassmorphism, bento grid, neo-brutalism, minimal flat, dark modern, claymorphism, etc.) with CSS keywords, visual traits, complexity, performance cost, and accessibility ratings.
  - `products.csv` & `ui-reasoning.csv`: 192 product reasoning profiles (SaaS, FinTech, E-commerce, Healthcare, Developer Tools, Media) mapping industry intent to layout structures, emotional tone, and anti-patterns.
  - `colors.csv`: 192 curated 5-token color palettes (primary, secondary, CTA/accent, background, text/neutral) with WCAG contrast notes.
  - `typography.csv`: 74 harmonious font pairings with Google Fonts import URLs and mood descriptors.
  - `ux-guidelines.csv`: 119 concrete UX/UI rules covering accessibility (4.5:1 contrast, visible focus rings, keyboard traps), touch targets (44×44px min), CLS prevention, layout responsiveness, and form feedback.
  - `stacks/*.csv`: 22 framework-specific implementation guides (React, Next.js, Shadcn UI, HTML-Tailwind, Astro, Vue, Nuxt, Svelte, SwiftUI, Flutter, React Native, Jetpack Compose, Three.js, etc.).
  - `charts.csv`: 25 chart types with library recommendations and accessibility advice.
  - `icons.csv`: Curated icon search for Lucide, Heroicons, and Phosphor.
  - `motion.csv`: 17 GSAP and CSS motion presets organized by intensity tiers (hover, scroll-reveal, stagger, transitions, reduced-motion fallbacks).
- **Embedded Search Script (`scripts/search.py`)**:
  - BM25 ranking algorithm combined with tokenized regex matching.
  - Domain queries: `python skills/frontend-ui-engineering/scripts/search.py "<query>" --domain <domain>` where domain is `product|style|typography|color|landing|chart|ux|icons|stacks|motion`.
  - Design system synthesis: `python skills/frontend-ui-engineering/scripts/search.py "<query>" --design-system [-p "Project Name"]`
  - Design dials: `--variance <1-10>`, `--motion <1-10>`, `--density <1-10>`.
  - Persistence flag: `--persist --output-dir <path>` producing `MASTER.md`.

### Module 2: `frontend-ui-upgrade`
- Overhaul `skills/frontend-ui-engineering/SKILL.md`:
  - Integrate Query Contract: small targeted searches vs full `--design-system` generation.
  - 10-tier rule priority matrix (Accessibility → Touch & Interaction → Performance → Style → Responsive → Typography & Color → Animation → Forms & Feedback → Navigation → Data Viz).
  - Component architecture rules combined with stack-specific token application.
  - Industry anti-pattern avoidance (no emoji as icons, no purple/pink generic AI gradients, no gray-on-gray unreadable text, no 0ms jarring transitions).
  - Canonical Pre-Delivery UI Checklist.

### Module 3: `lifecycle-ui-binding`
- **DEFINE (`/s-spec`)**:
  - When a requirement specifies a UI, web app, or mobile screen, `/s-spec` automatically runs `--design-system` to establish typography, color tokens, layout strategy, and accessibility constraints directly into the generated `SPEC.md` and `design-system/<project>/MASTER.md`.
- **PLAN (`/s-plan`)**:
  - Generates atomic tasks for design token setup, component scaffolding with verified styles, and responsive verification breakpoints (375px, 768px, 1024px, 1440px).
- **BUILD (`/s-build`)**:
  - Automatically queries framework-specific recipes (`--stack <stack>`) and icons/motion snippets during component implementation.
- **REVIEW (`/s-review`) & SHIP (`/s-ship`)**:
  - Incorporates the Pre-Delivery UI Checklist: WCAG 4.5:1 contrast verification, 44px touch targets, prefers-reduced-motion compliance, zero horizontal overflow, and accessible icon labels.

### Module 4: `asset-sync-and-portability`
- Standalone sync script: `scripts/sync-assets.mjs` (or `.js`).
- Eliminates symlinks to guarantee full compatibility on Windows, macOS, and Linux without git checkout corruption.
- Single Source of Truth architecture: updates made to data or scripts in `skills/frontend-ui-engineering/` are mirrored automatically to installer bundle targets and multi-agent distribution directories.
- Resolves Issue #361 by ensuring any single-skill installation includes its own localized `data/`, `scripts/`, and `references/`.

### Module 5: `multi-platform-installer`
- Update `scripts/install-local.sh`:
  - Detects Python 3 runtime and sets execution permissions on `scripts/search.py`.
  - Copies complete, self-contained skills with their respective datasets to user/project skill directories for all 20+ supported tools (Claude Code, Cursor, Codex, Gemini CLI, Antigravity CLI, Windsurf, OpenCode, GitHub Copilot, Copilot CLI, Kiro, Command Code).
- Multi-agent configuration sync (`scripts/build-agent-dist.js`):
  - Emits platform-specific instructions guiding agents on how to execute local Python search commands in their respective environments.

### Module 6: `testing-and-validation`
- `scripts/validate-ui-data.py`: Validates CSV syntax, column schemas, Google Fonts URLs, and JSON data integrity.
- Automated BM25 search test suite: Verifies precision across product types, design system generation, and dial adjustments.
- Frontmatter and link linting: Extends `validate-skills.js` and `validate-reference-links.js`.

---

## 4. Commands

```bash
# Search design intelligence across domains
python skills/frontend-ui-engineering/scripts/search.py "<query>" --domain <domain>

# Generate full Design System with customizable dials
python skills/frontend-ui-engineering/scripts/search.py "<query>" --design-system --variance 6 --motion 5 --density 7 -p "<ProjectName>"

# Generate and persist to design-system/<project-slug>/MASTER.md
python skills/frontend-ui-engineering/scripts/search.py "<query>" --design-system --persist -p "<ProjectName>" --output-dir .

# Search stack-specific guidance
python skills/frontend-ui-engineering/scripts/search.py "<query>" --stack <stack-name>

# Validate dataset integrity & schemas
python scripts/validate-ui-data.py

# Test BM25 search and design system synthesis
python -m unittest discover -s skills/frontend-ui-engineering/scripts/tests

# Sync assets across skills and distribution packages (no symlinks)
node scripts/sync-assets.js

# Install to detected IDEs/agents locally
./scripts/install-local.sh --all
```

---

## 5. Project Structure

```
agent-skills/
├── skills/
│   └── frontend-ui-engineering/
│       ├── SKILL.md                 # Overhauled UI/UX skill with query contract & checklist
│       ├── data/                    # Curated design datasets (CSVs & JSONs)
│       │   ├── styles.csv           # 79 UI styles with traits & ratings
│       │   ├── products.csv         # 192 product archetypes & layout recommendations
│       │   ├── colors.csv           # 192 color palettes with hex tokens
│       │   ├── typography.csv       # 74 typography pairings with Google Fonts links
│       │   ├── ux-guidelines.csv    # 119 UX/accessibility rules
│       │   ├── ui-reasoning.csv     # Industry vertical reasoning matrices
│       │   ├── charts.csv           # Chart choices & visualization guidelines
│       │   ├── icons.csv            # Curated Lucide/Heroicons/Phosphor directory
│       │   ├── motion.csv           # Motion tiers and GSAP presets
│       │   └── stacks/              # 22 stack guides (tailwind, react, swiftui, etc.)
│       ├── scripts/
│       │   ├── search.py            # CLI entry point
│       │   ├── core.py              # BM25 + regex search engine
│       │   ├── design_system.py     # Cohesive design system generator
│       │   ├── reasoning_contract.py# Anti-pattern and rules parser
│       │   └── tests/               # Search engine unit tests
│       └── references/
│           ├── quick-reference.md   # Complete rule list across all 10 priority categories
│           └── pro-rules.md         # Canonical pre-delivery polish checklist
├── scripts/
│   ├── sync-assets.js               # Synchronizer copying assets without symlinks
│   ├── validate-ui-data.py          # Data validation linter
│   ├── install-local.sh             # Multi-agent local installer (updated)
│   └── build-agent-dist.js          # Multi-agent dist generator (updated)
└── docs/
    └── specs/
        └── SPEC-ui-ux-intelligence.md # This specification
```

---

## 6. Code Style & Conventions

- **Python Search Engine**:
  - Python 3.8+ compatible, using standard library only (`csv`, `json`, `math`, `re`, `argparse`, `sys`, `pathlib`).
  - Fast execution (<100ms startup and query time).
  - Explicit error messages with helpful fallbacks when queries return no match.
- **Skill Markdown**:
  - Adheres strictly to `docs/skill-anatomy.md`.
  - Concise triggers in frontmatter `description` ("what" + "when").
  - Practical code/token examples rather than theoretical essays.
- **Data Standards**:
  - CSV format with UTF-8 encoding.
  - Normalized column names (`id, category, name, description, keywords, best_for, avoid`).
  - Google Fonts links verified against public Google Fonts directory.

---

## 7. Testing Strategy

1. **Data Validation (`validate-ui-data.py`)**:
   - Every CSV file has valid headers and non-empty IDs.
   - Hex color codes conform to `#RRGGBB` or `#RGB`.
   - Google Fonts URLs return valid HTTP 200 responses.
   - All 22 stack files exist in `data/stacks/`.
2. **Search Engine Unit Tests**:
   - Keyword query ranking tests (BM25 matches intended category).
   - Domain auto-detection accuracy tests.
   - `--design-system` synthesis test: verify all 5 aspects (layout, style, color, typography, anti-patterns) are generated.
   - Dial modifier test: `--variance`, `--motion`, `--density` modify output deterministically.
   - File output test: `--persist` generates valid `MASTER.md` and doesn't overwrite existing files without `--force`.
3. **Integration & Lifecycle Evals**:
   - Run `/s-spec` on a sample UI requirement (e.g. "Crypto Portfolio Tracker") and verify `MASTER.md` creation.
   - Run `/s-review` and verify detection of forbidden anti-patterns (e.g., emoji icons, low contrast text).

---

## 8. Boundaries

- **Always**:
  - Keep Python search scripts zero-dependency (no `pip install` required).
  - Maintain absolute backwards compatibility with existing slash commands and markdown workflows.
  - Require human approval before overwriting any existing `MASTER.md` or design tokens.
  - Enforce WCAG 2.1 AA (4.5:1 text contrast, visible focus, reduced-motion).
- **Ask First**:
  - Before introducing external NPM packages for UI parsing.
  - Before generating heavy assets (>1MB) into the repository.
- **Never**:
  - Use symlinks in git repositories (breaks Windows git clones).
  - Hardcode framework defaults when inspecting projects; auto-detect or ask.
  - Persist unverified or hallucinatory search output.

---

## 9. Success Criteria

1. Approved `SPEC.md` covering all 6 core areas.
2. `skills/frontend-ui-engineering/` successfully equipped with curated datasets and fast local Python search tool (`search.py`).
3. Running `python skills/frontend-ui-engineering/scripts/search.py "fintech dark dashboard" --design-system` outputs a complete, production-grade design system in <200ms.
4. Seamless integration with `/s-spec` and `/s-build` generating and reading `design-system/<project>/MASTER.md`.
5. Pre-delivery checklist integrated into `/s-review` and `/s-ship`.
6. `sync-assets.js` and `validate-ui-data.py` passing cleanly with zero errors.
7. Local installer `./scripts/install-local.sh` installs the enhanced skill across all 20+ supported AI tools.

---

## 10. Approved Design Decisions (User Aligned)

1. **Direct Skill Integration**: Directly upgrade `skills/frontend-ui-engineering/` by embedding the curated design datasets (`data/`), zero-dependency search engine (`scripts/`), and references into it, turning it into a complete, self-contained design intelligence skill.
2. **Root-Level CLI Shortcut**: Provide a convenient root-level wrapper script (`scripts/ui-search.sh`) allowing developers and agents to run design searches and generate systems quickly (e.g. `./scripts/ui-search.sh "saas dashboard" --design-system`).
3. **Agent-Skills Standard Persistence**: Persist generated design systems directly into `.agents/design-system/MASTER.md` and page overrides into `.agents/design-system/pages/<page-slug>.md` to align with `agent-skills` workspace conventions.

