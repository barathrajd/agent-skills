# Structure: monorepo

Applies to a pnpm workspace (with or without Turborepo/Nx) holding several apps and libraries. Two config levels, as Rstack recommends: the root owns shared tooling, each project owns its own build/test.

## Layout
```
.
├── package.json             # private; root scripts: check, format, lint, staged
├── pnpm-workspace.yaml      # packages: apps/*, packages/*; catalog: for shared versions
├── rstack.config.ts         # define.lint / define.fmt / define.staged ONLY
├── tsconfig.base.json       # shared compiler options; each project extends it
├── .rstack/hooks/           # git hooks (rs hooks) — one set for the whole repo
├── AGENTS.md  GLOSSARY.md   # repo-wide context
├── docs/adr/                # decisions
├── .claude/skills/          # skills installed once at the root
├── apps/
│   └── <app>/               # own package.json + rstack.config.ts (define.app, define.test)
│       └── src/             # laid out per references/structure-app.md
└── packages/
    ├── ui/                  # design-system library
    ├── utils/               # leaf library: pure helpers, no framework
    └── <domain>/            # shared business logic / api clients / types
```
Each package follows `references/structure-library.md`.

## Dependency rule
`apps → domain packages → ui, utils` — imports only point down.
- Nothing imports from `apps/*`.
- `utils` imports nothing internal. `ui` may import `utils`.
- Domain packages may import `ui`/`utils`, not each other unless the dependency is one-way and declared.
- Declare every internal dependency in `package.json` with `workspace:*`; never reach across packages by relative path.

## Config placement
- **Root:** shared Rstack CLI version, `define.lint()` (with `parserOptions.project` listing each project's `tsconfig.json`), `define.fmt()`, `define.staged()`, git hooks, release automation, CI.
- **Project:** `rstack.config.ts` with only what that project needs. The CLI loads config from the current working directory and does not merge it with the root config, so do not rely on root build settings reaching a project.
- **Project-specific lint rules:** use `files` patterns in the root lint config (paths resolve from the repo root).
- Project-only dependencies (Rsbuild plugins, test libs) go in the project, not the root.

## Rules of placement
- Naming: scope internal packages (`@org/ui`, `@org/utils`); folder name = package name without scope.
- Shared versions: pin framework singletons (`react`, `react-dom`, router, state libs) in the pnpm `catalog:` and reference them as `catalog:` in packages.
- Run package tasks in the owning package or via the task runner (`pnpm -F <pkg> <script>`, `turbo run <task> --filter=<pkg>`, `nx run <pkg>:<target>`).
- A new package needs a second consumer or a clear public API before it exists; otherwise keep the code inside the app's `features/` or `lib/`.

## Variations
- **Micro-frontends (Module Federation):** each producer/consumer is its own app with its own `module-federation.config.ts`; the host lives in `apps/<shell>`, remotes in `apps/<remote>`. Share singletons through MF `shared` and the catalog. See `setup-module-federation`.
- **Docs site:** `apps/docs` (or a package) using `define.doc()`.
- **Nx instead of plain pnpm tasks:** keep the same `apps/` + `packages/` shape; the task graph comes from Nx project config rather than `pnpm -F`.
