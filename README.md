# agent-skills

A growing personal collection of engineering skills for AI coding agents. The first workflow — R&D to ship — is orchestrated by `product-flow`; add more skills over time. Works with Claude Code (as a plugin or loose skills) and any agent the `skills` CLI supports.

## What's inside

```
.
├── .claude-plugin/
│   ├── plugin.json              # plugin manifest (name, version, description)
│   └── marketplace.json         # makes this repo installable as a marketplace
├── skills/                      # one folder per skill — this is what agents discover
│   ├── product-flow/SKILL.md         # orchestrator / router
│   ├── bootstrap-context/SKILL.md    # → AGENTS.md + GLOSSARY.md
│   ├── roadmap/SKILL.md              # → ROADMAP.md
│   ├── rnd-product-plan/SKILL.md     # → plans/<slug>.md + PLAN.md overview
│   ├── design-doc/SKILL.md           # → DESIGN.md
│   ├── write-adr/SKILL.md            # → docs/adr/NNNN-*.md
│   ├── run-the-plan/SKILL.md         # builds the plan in test-first slices
│   ├── release-plan/SKILL.md         # → RELEASE.md
│   ├── setup-release-please/SKILL.md # wires up release automation
│   ├── setup-vite-plus/SKILL.md      # Vite+ (vp) toolchain setup
│   ├── setup-rstack/SKILL.md         # Rstack (rs) toolchain setup
│   ├── setup-module-federation/SKILL.md # micro-frontends / remotes
│   ├── setup-commit-lint/SKILL.md    # Conventional Commits + staged checks
│   ├── clean-global-skills/SKILL.md  # audit global vs project skills, clean up with a backup
│   ├── project-structure/SKILL.md    # folder layout for app / monorepo / library
│   ├── react/SKILL.md                # React house conventions + router
│   ├── base-ui/SKILL.md              # Base UI (@base-ui/react) component conventions
│   ├── stylex/SKILL.md               # StyleX styling conventions
│   ├── tanstack/SKILL.md             # official TanStack skills via Intent
│   └── zustand/SKILL.md              # Zustand client-state conventions
├── references/                  # SOURCE OF TRUTH for files shared by several skills
│   ├── definition-of-done.md    # shared checklist skills pull in
│   ├── workspace-detection.md   # detect app vs monorepo vs library; adapt paths
│   ├── supply-chain.md          # install rules: no pipe-to-shell, pinned versions, consent
│   └── external-skills.md       # every third-party skill we point at, pinned to a commit
├── templates/
│   └── SKILL.template.md        # copy this to start a new skill
├── docs/
│   ├── skill-anatomy.md         # the rules for writing a good skill
│   └── library-skills.md        # how library skills (Base UI, StyleX, ...) are added and kept current
├── scripts/
│   ├── validate.sh              # checks frontmatter, supply-chain lint, self-contained skills
│   ├── sync-references.sh       # copies shared references/ files into the skills that use them
│   └── shared-references.txt    # which skill gets which shared file
├── .githooks/
│   └── pre-commit               # runs the validator before each commit
├── .github/workflows/
│   ├── validate.yml             # CI: validate skills on push/PR
│   └── release-please.yml       # CI: automated releases from Conventional Commits
├── release-please-config.json   # release-please settings (type: simple)
├── .release-please-manifest.json# tracks the current version
├── README.md
├── AGENTS.md                    # guidance for any agent editing THIS repo
├── CLAUDE.md                    # one line: @AGENTS.md (Claude Code reads this file)
└── GEMINI.md                    # one line: @AGENTS.md (Gemini CLI reads this file)
```

The only hard convention: **every skill lives at `skills/<name>/SKILL.md`** with YAML frontmatter. Everything else is optional structure.

## Install

**A. As a Claude Code plugin (this repo as its own marketplace)**
```
/plugin marketplace add barathrajd/agent-skills
/plugin install agent-skills@agent-skills-marketplace
```
Skills then run as `/agent-skills:product-flow`, `/agent-skills:rnd-product-plan`, etc.

**B. With the skills CLI (any agent)**
```bash
npx skills add barathrajd/agent-skills            # all skills
npx skills add barathrajd/agent-skills --skill product-flow
```

**C. Loose, no packaging** — copy skill folders straight in. Pick the folder your agent reads (table below):
```bash
cp -R skills/* /path/to/project/.agents/skills/     # Codex, OpenCode, Gemini CLI
cp -R skills/* /path/to/project/.claude/skills/     # Claude Code (OpenCode also reads this)
```

### Which agent reads which folder
| Agent | Project folder | Global folder |
| --- | --- | --- |
| Claude Code | `.claude/skills/` | `~/.claude/skills/` |
| Codex | `.agents/skills/` (from the working directory up to the repo root) | `~/.agents/skills/` |
| OpenCode | `.opencode/skills/`, `.claude/skills/`, `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` |
| Gemini CLI | `.gemini/skills/` or `.agents/skills/` (the latter wins) | `~/.gemini/skills/` or `~/.agents/skills/` |

Every skill is a plain `SKILL.md` with `name` and `description`, which all four accept, so nothing needs converting. A project install with the skills CLI (B) writes to `.agents/skills/` and links `.claude/skills/` to it, so one install serves all four. Codex and OpenCode also read `AGENTS.md`; Claude Code reads `CLAUDE.md` and Gemini CLI reads `GEMINI.md`, and here both are one-line pointers to `AGENTS.md`. Gemini CLI can also install a skill from a Git URL (`gemini skills install <url> --path skills/<name> --scope workspace`) and shows each skill's directory for approval before it activates. The plugin route (A) is Claude Code only.

> The manifest `name` (`agent-skills`) becomes the slash-command prefix. Want shorter commands? Change only `"name"` in `plugin.json` to something like `ash` → `/ash:product-flow`, while keeping the repo named `agent-skills`.

## Skill index

| Skill | Role | Use when |
| --- | --- | --- |
| `product-flow` | Orchestrator — installs the curated set and routes the lifecycle | "set up the flow", "start a feature", "what's next" |
| `bootstrap-context` | Standing setup — writes AGENTS.md + GLOSSARY.md for the repo | "set up AGENTS.md", "bootstrap context" (once per repo) |
| `setup-vite-plus` | Build toolchain — set up / migrate to the Vite+ (vp) toolchain | "set up vite plus", "migrate to vite+" |
| `setup-rstack` | Build toolchain — set up / migrate to the Rstack (rs) toolchain | "set up rstack", "migrate to rstack" |
| `setup-module-federation` | Micro-frontends — share/consume remote modules across apps | "module federation", "micro-frontend", "expose a remote" |
| `setup-commit-lint` | Commit workflow — Conventional Commits + staged checks (toolchain-aware) | "set up commitlint", "commit hooks" |
| `project-structure` | Folder layout — web app, monorepo (reusable UI in `packages/ui`, core logic in `packages/core`), or library; tests in `tests/`; works with Rstack or Vite+ | "project structure", "folder structure", "monorepo layout", "where should this live" |
| `clean-global-skills` | Housekeeping — audits global skills, resolves clashes with project skills, moves extras out with a backup | "clean up global skills", "skills clashing", "skills burning tokens" |
| `roadmap` | Strategic sequencing — maintains ROADMAP.md (Now/Next/Later) | "roadmap", "prioritize", "what's next" |
| `rnd-product-plan` | R&D + planning — grills the idea, resolves unknowns, writes plans/<slug>.md and a short PLAN.md overview | "plan this", "spec this", "grill me" |
| `design-doc` | Technical design — writes DESIGN.md before non-trivial builds | "design this", "how should we build X" |
| `write-adr` | Knowledge sharing — records decisions as docs/adr/NNNN-*.md | "record this decision", "write an ADR" |
| `run-the-plan` | Execution — builds a plan from plans/ in test-first slices | "build it", "run the plan", "implement this" |
| `release-plan` | Release planning — maintains RELEASE.md (feature-based versioned cuts) | "plan a release", "what's in the next release" |
| `setup-release-please` | Release automation — wires up GitHub-side releases from Conventional Commits | "set up releases", "add release-please" |
| `react` | React umbrella — house conventions + routes to tanstack/zustand/base-ui/stylex | "react", "react best practices", "structure this component" |
| `base-ui` | Base UI (`@base-ui/react`) — unstyled primitives, `render` composition, docs matched to the installed version | "base ui", "build a dialog/menu/select", "add a component to packages/ui" |
| `stylex` | StyleX styling — `create`/`props`, typed style props, tokens, bundler setup, use with Base UI | "stylex", "design tokens", "style this component" |
| `tanstack` | Official TanStack skills via Intent (version-synced) | "tanstack", "intent install", "query/router best practices" |
| `zustand` | Zustand client-state conventions (no official skill exists) | "zustand", "set up a store", "selectors", "persist" |

_Keep this table current — it's the fastest way for anyone (including an agent) to see what's here._

## Add a new skill in the future

1. `cp -R templates/SKILL.template.md skills/<new-name>/SKILL.md`
2. Fill in the frontmatter (`name` must match the folder) and the sections. Read `docs/skill-anatomy.md` first.
3. Add a row to the Skill index above.
4. If `product-flow` should route to it, add it to that skill's phase table.
5. If it wraps a third-party library, follow `docs/library-skills.md`.
6. If it links a shared file, add it to `scripts/shared-references.txt` and run `bash scripts/sync-references.sh`.
7. Commit. Re-install or reload plugins to pick it up.

## Golden rules

- One active router only. `product-flow` is it — don't also enable another pack's meta-router.
- Keep skills lean. Description earns its place in context on every turn; the body loads only when used.
- Every skill ends in verifiable evidence, never "seems right".
- Install nothing unpinned or unconfirmed. External skills come only from `references/external-skills.md`, at their pinned commit, after the user says yes; no `curl | bash`, no `@latest`. See `references/supply-chain.md`. `scripts/validate.sh` enforces it in CI.
