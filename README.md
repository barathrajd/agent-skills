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
│   ├── rnd-product-plan/SKILL.md     # → PLAN.md
│   ├── design-doc/SKILL.md           # → DESIGN.md
│   ├── write-adr/SKILL.md            # → docs/adr/NNNN-*.md
│   ├── run-the-plan/SKILL.md         # builds the plan in test-first slices
│   ├── release-plan/SKILL.md         # → RELEASE.md
│   └── setup-release-please/SKILL.md # wires up release automation
├── references/
│   └── definition-of-done.md    # shared checklist skills pull in
├── templates/
│   └── SKILL.template.md        # copy this to start a new skill
├── docs/
│   └── skill-anatomy.md         # the rules for writing a good skill
├── scripts/
│   └── validate.sh              # checks every SKILL.md's frontmatter
├── .githooks/
│   └── pre-commit               # runs the validator before each commit
├── .github/workflows/
│   ├── validate.yml             # CI: validate skills on push/PR
│   └── release-please.yml       # CI: automated releases from Conventional Commits
├── release-please-config.json   # release-please settings (type: simple)
├── .release-please-manifest.json# tracks the current version
├── README.md
└── CLAUDE.md                    # guidance for an agent editing THIS repo
```

The only hard convention: **every skill lives at `skills/<name>/SKILL.md`** with YAML frontmatter. Everything else is optional structure.

## Install (three ways)

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

**C. Loose, no packaging** — copy skill folders straight in:
```bash
cp -R skills/* ~/.claude/skills/            # global
# or into a project:
cp -R skills/* /path/to/project/.claude/skills/
```

> The manifest `name` (`agent-skills`) becomes the slash-command prefix. Want shorter commands? Change only `"name"` in `plugin.json` to something like `ash` → `/ash:product-flow`, while keeping the repo named `agent-skills`.

## Skill index

| Skill | Role | Use when |
| --- | --- | --- |
| `product-flow` | Orchestrator — installs the curated set and routes the lifecycle | "set up the flow", "start a feature", "what's next" |
| `bootstrap-context` | Standing setup — writes AGENTS.md + GLOSSARY.md for the repo | "set up AGENTS.md", "bootstrap context" (once per repo) |
| `roadmap` | Strategic sequencing — maintains ROADMAP.md (Now/Next/Later) | "roadmap", "prioritize", "what's next" |
| `rnd-product-plan` | R&D + planning — grills the idea, resolves unknowns, writes PLAN.md | "plan this", "spec this", "grill me" |
| `design-doc` | Technical design — writes DESIGN.md before non-trivial builds | "design this", "how should we build X" |
| `write-adr` | Knowledge sharing — records decisions as docs/adr/NNNN-*.md | "record this decision", "write an ADR" |
| `run-the-plan` | Execution — builds PLAN.md in test-first slices | "build it", "run the plan", "implement this" |
| `release-plan` | Release planning — maintains RELEASE.md (feature-based versioned cuts) | "plan a release", "what's in the next release" |
| `setup-release-please` | Release automation — wires up GitHub-side releases from Conventional Commits | "set up releases", "add release-please" |

_Keep this table current — it's the fastest way for anyone (including an agent) to see what's here._

## Add a new skill in the future

1. `cp -R templates/SKILL.template.md skills/<new-name>/SKILL.md`
2. Fill in the frontmatter (`name` must match the folder) and the sections. Read `docs/skill-anatomy.md` first.
3. Add a row to the Skill index above.
4. If `product-flow` should route to it, add it to that skill's phase table.
5. Commit. Re-install or reload plugins to pick it up.

## Golden rules

- One active router only. `product-flow` is it — don't also enable another pack's meta-router.
- Keep skills lean. Description earns its place in context on every turn; the body loads only when used.
- Every skill ends in verifiable evidence, never "seems right".
