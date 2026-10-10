# Structure: library

Applies to a reusable package — standalone repo or a package inside a monorepo. Built with Rslib (`define.lib()`) or another library-mode build.

## Layout
```
<lib>/
├── package.json         # name, version, exports, files, peerDependencies, scripts
├── rstack.config.ts     # define.lib (+ define.test; define.doc only if it has a docs site)
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts         # the ONLY public entry
│   ├── <module>/
│   │   ├── index.ts     # module's public surface (re-exported from src/index.ts if public)
│   │   ├── <module>.ts
│   │   └── <module>.test.ts
│   └── internal/        # shared by modules, never exported
├── docs/                # optional Rspress site
└── dist/                # build output, git-ignored
```

## Public API rule
- `package.json` `exports` is the contract. Export `src/index.ts` (and deliberate subpaths); everything else is private.
- No deep imports into `src/` from consumers; consumers use the package name.
- Adding an export is a decision; removing one is a breaking change.
- Types are shipped (`dts: true` in `define.lib()`), and `exports` points at them.

## Dependencies
- Framework packages (`react`, `react-dom`, router, state libs) are `peerDependencies`, never bundled and never pinned in `dependencies`.
- Mirror them in `devDependencies` so tests and the dev build resolve.
- A leaf library (e.g. `utils`) imports no internal packages; a UI library may import the leaf library and nothing app-level.

## Rules of placement
- One module per folder, with its test beside it; shared private code in `src/internal/`.
- Component libraries: one public component per file, styles co-located, no app-specific state or routing.
- Keep `scripts` minimal and uniform: `build` (`rs lib`), `dev` (`rs lib -w`), `test` (`rs test`), `doc` (`rs doc`, only if configured).

## Variations
- **Multiple entry points:** declare each subpath in `exports` and the matching Rslib entries; keep one `index.ts` per entry.
- **Module Federation producer library:** add `module-federation.config.ts` with `exposes` pointing at public modules only. See `setup-module-federation`.
