---
name: project-structure
description: Decides and scaffolds the folder structure for a frontend codebase — a standalone web app, a monorepo (apps + packages), or a reusable library — with one-way dependency rules, public-API boundaries, and the right Rstack/Vite+ config placement. Use when the user says "project structure", "folder structure", "how should I organize this app", "monorepo layout", "library structure", "where should this code live", or "restructure this repo".
---

# Project Structure

## Overview
Picks one layout for the repo's shape and applies it, so every app, monorepo, and library here is organized the same way. It produces a folder tree, dependency rules, and public-API boundaries — not business code. It does NOT set up the toolchain (`setup-rstack`, `setup-vite-plus`) or Module Federation (`setup-module-federation`); it tells them where their config files go.

## When to Use
- Starting a new app, monorepo, or library and nothing defines its layout yet.
- A codebase has grown organically and "where does this go?" has no clear answer.
- Adding a new app/package/feature to an existing repo and needing to place it.
- The user says "project structure", "folder structure", "monorepo layout", "restructure this".

## Process

### 1. Detect the shape
Follow `references/workspace-detection.md`. Classify the repo as **standalone app**, **monorepo**, or **library**; classify each package inside a monorepo the same way. Check for an existing layout and for module-federation config (`module-federation.config.ts`) before proposing anything.
- **Exit criterion:** you can state the shape of the repo (and of each package) and what already exists.

### 2. Choose the layout
Open the matching reference and use it as the target; do not invent a variant:
- Standalone app → `references/structure-app.md`
- Monorepo → `references/structure-monorepo.md` (each app inside follows the app layout, each package the library layout)
- Library → `references/structure-library.md`

If the repo already has a layout, propose the smallest move toward the target, not a rewrite.
- **Exit criterion:** the target tree is written down, with each existing top-level folder mapped to where it ends up.

### 3. Scaffold or migrate in slices
Create folders and move code one feature/package at a time. Each slice keeps the build green. Put config where the reference says (root = shared lint/format/hooks; package = build/test). Add `index.ts` public entries as you go. Move any tests found inside `src/` into the package's top-level `tests/`, mirroring the source path, and fix imports to use the `@/` alias or public entry.
- **Exit criterion:** every moved slice passes `rs check` + `rs build` (or the repo's equivalents) before the next slice starts.

### 4. Enforce the boundaries
Write the dependency rules from the reference into the repo's `AGENTS.md` (via `bootstrap-context` if absent). Add an automated check if the toolchain supports one; if you cannot confirm a tool supports import-boundary rules, say so and use a dependency-graph check (e.g. `madge --circular`) or a small script instead of claiming enforcement.
- **Exit criterion:** a deliberate violation (e.g. a feature deep-importing another feature's internals) is caught by the check, or the gap is stated explicitly.

### 5. Record the decision
Any non-obvious choice (layer-first vs feature-first, package scope, where shared UI lives) goes through `write-adr`.
- **Exit criterion:** an ADR exists for each non-default choice, or none were made.

## Rationalizations — and the rebuttals
| Excuse | Rebuttal |
| --- | --- |
| "Put it in `utils` for now." | `utils` becomes the dumping ground. Place it in the owning feature; promote to shared only when a second consumer exists. |
| "Import the other feature's file directly, it's quicker." | Deep imports make features un-movable. Import only through that feature's `index.ts`. |
| "Move everything at once, then fix the build." | A broken build hides which move caused what. Migrate in green slices. |
| "Export everything from the library root." | The `exports` map is your public API; every extra export is a promise to maintain. |
| "Put the test next to the file, it's easier to find." | This repo keeps tests in a top-level `tests/` folder, outside `src/`, mirroring the source path. `src/` stays production code only. |
| "Add build config to the monorepo root so it's shared." | Rstack does not merge root and project config. Root holds lint/fmt/staged; each project holds its own build/test. |

## Red Flags — stop and fix
- A package imports from an app, or a shared package imports from a feature.
- Two features import each other (cycle).
- A folder named `utils`, `helpers`, `common`, or `misc` with unrelated contents.
- A library lists `react` / `react-dom` under `dependencies` instead of `peerDependencies`.
- Any `*.test.*` / `*.spec.*` file, or test helper, inside `src/`.
- Build/test config duplicated at both the repo root and a package.

## Verification — done when
- The tree matches the chosen reference (apps/packages/features/shared in the right places).
- `rs check` and `rs build` pass in every touched package.
- Every package has a `tests/` folder mirroring `src/`; `find src -name '*.test.*' -o -name '*.spec.*'` returns nothing; `rs test` discovers and runs the tests in `tests/`.
- The dependency rules are written in `AGENTS.md` and a violation is caught or the gap is stated.
- No cycles: the dependency-graph check reports none.
