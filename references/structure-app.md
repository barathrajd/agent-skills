# Structure: standalone web app

Applies to a single-package React app (Rsbuild/Rstack or Vite+). Feature-first, with one-way dependencies.

## Layout
```
.
├── package.json
├── rstack.config.ts        # define.app / define.test / define.lint / define.fmt / define.staged
├── tsconfig.json
├── .rstack/hooks/
├── public/
└── src/
    ├── main.tsx            # entry (with Module Federation: tiny file that does import('./bootstrap'))
    ├── app/                # providers, router, root layout, global styles, error boundary
    ├── routes/             # thin route components that compose features
    ├── features/
    │   └── <feature>/
    │       ├── components/ # UI owned by this feature
    │       ├── hooks/      # data + behaviour hooks
    │       ├── api/        # TanStack Query hooks + request functions
    │       ├── store/      # Zustand store, only if client state is shared
    │       ├── types.ts
    │       └── index.ts    # the feature's public API
    ├── components/         # shared presentational UI (no feature imports)
    ├── hooks/              # shared hooks
    ├── lib/                # api client, query client, formatting, small pure utilities
    └── assets/
```

## Dependency rule
`app → routes → features → shared (components, hooks, lib)` — imports only point right/down.
- A feature may import shared code, never `routes/` or `app/`.
- A feature imports another feature only through that feature's `index.ts`; prefer lifting the shared piece to `components/`, `hooks/` or `lib/` over cross-feature imports.
- Shared code never imports from `features/`.

## Rules of placement
- Co-locate the test next to the file (`Button.tsx`, `Button.test.tsx`); one public component per file.
- Server state lives in `features/<x>/api` (TanStack Query); shared client state in `features/<x>/store` (Zustand); local state stays in the component. See the `react` skill.
- Promote code to shared only when a second feature needs it.
- Avoid `utils/` catch-alls: name `lib/` modules by what they do (`lib/format-date.ts`).

## Variations
- **Small app (a few screens):** drop `features/`, keep `routes/`, `components/`, `hooks/`, `lib/`; introduce `features/` when a screen grows its own hooks/api/store.
- **Module Federation host or remote:** add `src/bootstrap.tsx` (real app start) behind the async boundary in `main.tsx`; remotes put exposed modules under `src/exposed/` (or as configured in `module-federation.config.ts`) and expose only public entries.
