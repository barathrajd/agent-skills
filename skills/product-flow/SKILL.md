---
name: product-flow
description: One orchestrator for the full R&D-to-ship workflow. On setup it installs a curated set of skills from Matt Pocock's and Addy Osmani's packs plus the local rnd-product-plan and run-the-plan skills, then routes the user through the lifecycle from a single entry point. Use when the user says "product-flow", "set up the flow", "run the flow", "start a feature", "what's next", or wants to manage the R&D and engineering skills from one place.
---

# Product Flow

## Overview
A single skill that manages the whole R&D-to-ship pipeline so the user never has to remember which skill to call. It does two jobs:
1. **Setup** — installs the curated skill set (idempotent; skips what's already present).
2. **Route** — figures out where the user is in the lifecycle and invokes the right skill, enforcing the guardrails that keep the packs from fighting each other.

**Division of labor:** Matt Pocock's skills own the fuzzy R&D front half; Addy Osmani's skills own the engineering lifecycle. This skill is the only active router — the pack skills are invoked by name, never as competing routers.

## When to Use
- First-time setup: "set up the flow", "install the skills".
- Starting work: "start a feature", "run the flow", "new project".
- Mid-stream: "what's next", "where am I", "move to the next step".

## Setup — install the curated set
Run this only when a skill in the flow is missing. Check first; skip anything already installed. These are per-skill installs so no full-pack meta-router is pulled in (that's what causes conflicts).

```bash
# R&D / shaping — Matt Pocock
npx skills add mattpocock/skills --skill grill-me
npx skills add mattpocock/skills --skill research
npx skills add mattpocock/skills --skill prototype
npx skills add mattpocock/skills --skill wayfinder
npx skills add mattpocock/skills --skill pr
npx skills add mattpocock/skills --skill retro

# Engineering lifecycle — Addy Osmani
npx skills add addyosmani/agent-skills --skill spec-driven-development
npx skills add addyosmani/agent-skills --skill constraint-driven-development
npx skills add addyosmani/agent-skills --skill planning-and-task-breakdown
npx skills add addyosmani/agent-skills --skill incremental-implementation
npx skills add addyosmani/agent-skills --skill test-driven-development
npx skills add addyosmani/agent-skills --skill debugging-and-error-recovery
npx skills add addyosmani/agent-skills --skill code-review-and-quality
npx skills add addyosmani/agent-skills --skill security-and-hardening
npx skills add addyosmani/agent-skills --skill shipping-and-launch
```

The local `rnd-product-plan` and `run-the-plan` skills should already be in `.claude/skills/`. If not, install them from the repo before routing.

**Note:** per-skill installs copy only that skill's folder, not the pack's shared `references/` checklists. `code-review-and-quality` and `security-and-hardening` reference those. If either reports a missing checklist, install the whole pack once with `npx skills add addyosmani/agent-skills` and keep this skill as the sole router.

After setup, confirm the install succeeded and tell the user the flow is ready.

## Route — the lifecycle, managed from here
Assess which phase the user is in from what they ask and what artifacts exist (`PLAN.md`, `CONSTRAINTS.md`, tests, commits), then invoke the matching skill. Default to the lean path unless the project needs the extra rigor.

| Phase | Invoke | Trigger / signal |
| --- | --- | --- |
| 0. Big effort? | `wayfinder` | Large/ambiguous initiative that spans many decisions |
| 1. Shape the idea | `grill-me`, then `research` / `prototype` as unknowns appear | New idea, vague ask, "what should we build" |
| 2. Spec | `spec-driven-development` (`/spec`) | Grilled understanding exists, needs a PRD |
| 3. Quality bar | `constraint-driven-development` (`/constraints`) | No `CONSTRAINTS.md` yet — do once, early |
| 4. Plan | `planning-and-task-breakdown` (`/plan`) | Spec exists, needs tasks |
| 5. Build | `incremental-implementation` (`/build`) + `test-driven-development` | Tasks exist, writing code |
| 6. Debug | `debugging-and-error-recovery` | Tests fail, build breaks, odd behavior |
| 7. Review | `code-review-and-quality` (`/review`) + `security-and-hardening` | Slice done, before merge |
| 8. Ship | `shipping-and-launch` (`/ship`) + `pr` | Reviewed, ready to deploy |
| 9. Learn | `retro` | After shipping — tune skills and CONSTRAINTS.md |

**Lean path (default):** the local `rnd-product-plan` covers phases 1–2 and `run-the-plan` covers phases 5–7. Use those two for everyday work; reach into the pack skills above only when a project needs the extra hardening, security, launch, or large-effort mapping.

## Guardrails — enforce every time
- **This is the only router.** Never activate Matt's or Addy's full-pack meta-routers alongside it. Invoke pack skills by name only.
- **Never use Matt's `code-review`.** It collides with the built-in `/code-review` and can fan out to dozens of sub-agents. Always use Addy's `code-review-and-quality` instead. Do not install it.
- **One TDD only.** Use Addy's `test-driven-development`. Do not also load Matt's `tdd` — the two philosophies conflict.
- **Stay lean.** Don't load a phase's skill until that phase is active. Loading everything at once is the token-bloat trap.

## Rationalizations — and the rebuttals
| Excuse | Rebuttal |
| --- | --- |
| "Just install both full packs, it's easier." | Two routers collide on command names and hooks. Curated per-skill installs are the whole point of this skill. |
| "Skip the setup check, reinstall everything." | Setup is idempotent — check first, install only what's missing, or you waste time and churn files. |
| "I'll route to a skill before the previous phase produced its artifact." | Each phase consumes the last one's output. No spec, no plan. Confirm the artifact exists first. |

## Red Flags — stop and fix
- Matt's or Addy's meta-router is active at the same time as this skill.
- Matt's `code-review` got installed or invoked.
- Both `test-driven-development` and `tdd` are present.
- You're invoking a build/review skill with no `PLAN.md` in the repo.

## Verification — working correctly when
- `claude plugins`/skills list shows the curated set installed and no duplicate routers.
- Matt's `code-review` and `tdd` are absent.
- Each invocation routes to exactly one phase skill and hands control back here when it finishes.
- The lean path (two local skills) runs end-to-end without needing the pack skills for simple features.
