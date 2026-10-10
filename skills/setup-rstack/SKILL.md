---
name: setup-rstack
description: Sets up or migrates a project onto the Rstack toolchain via the rs CLI (Rspack, Rsbuild, Rstest, Rslib, Rspress, and linting/formatting) with one rstack.config.ts. Covers install, config, the core rs commands, and repository git hooks. Use when the user says "set up rstack", "use rs", "migrate to rstack", or wants the Rust-based build/test/lint toolchain configured.
---

# Setup Rstack

## Overview
Get a project onto Rstack so build, dev, test, lint, format, and git hooks run through one `rs` CLI and one `rstack.config.ts`. Rstack is the Rust-powered web toolchain (Rspack/Rsbuild bundling, Rstest tests, Rslib libraries, Rspress docs). Treat rstack.rs as the source of truth — this skill is the workflow; confirm exact flags against the docs rather than guessing.

## When to Use
- Standing up a new project, or migrating an existing one onto Rstack.
- The user says "set up rstack / rs", "migrate to rstack", "configure the Rstack toolchain".

## Process

### 1. Install / add the Rstack CLI
Create a new project or add the CLI to an existing one per rstack.rs/guide/quick-start. Confirm the `rs` command resolves (globally or via the package manager).
- **Exit criterion:** `rs --help` (or `pnpm exec rs --help`) works.

### 2. Create or migrate
- New: scaffold via the quick-start flow.
- Existing: follow rstack.rs/guide/migration — it has a recommended migration Skill. Preserve unrelated changes.

### 3. Configure in rstack.config.ts
Rstack uses `define` APIs in `rstack.config.ts` for app builds, tests, linting, and formatting (e.g. `define.app()`, `define.lint()`). Add only what the project needs; see rstack.rs/guide/configuration.

### 4. Learn the core commands
`rs dev` (Rsbuild dev server + HMR), `rs build` (production), `rs preview`, `rs lib` (libraries), `rs doc` (Rspress docs), `rs test` (Rstest), `rs check` (lint + format, optional typecheck), `rs lint`, `rs fmt`.

### 5. Git hooks (optional but recommended)
`rs hooks` installs/configures repository git hooks; `rs staged` runs lint-staged tasks on staged files. See rstack.rs/guide/git-hooks. Wire the commit-message layer via the `setup-commit-lint` skill. Do not add husky — Rstack owns the hook path.

### 6. Monorepo
See rstack.rs/guide/monorepo for shared checks, formatting, staged tasks, and per-project workflows.

## Rationalizations — and the rebuttals
| Excuse | Rebuttal |
| --- | --- |
| "Guess the rs flags from memory." | Rstack is young and moving. Check `rs <cmd> --help` or rstack.rs before asserting. |
| "Add husky for hooks." | Rstack manages hooks via `rs hooks`; husky collides on `core.hooksPath`. |
| "Skip rstack.config.ts, pass flags each time." | Config in `rstack.config.ts` keeps checks consistent across dev, CI, and hooks. |

## Red Flags — stop and fix
- A second hook manager (husky) installed alongside `rs hooks`.
- Config scattered across ad-hoc flags instead of `rstack.config.ts`.
- Asserting a command/flag not confirmed against rstack.rs.

## Verification — done when
- `rs check` and `rs build` run successfully.
- Config lives in `rstack.config.ts` via the `define` APIs.
- Hooks (if enabled) are installed via `rs hooks`, with no husky present.
