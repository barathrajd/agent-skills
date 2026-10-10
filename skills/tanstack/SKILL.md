---
name: tanstack
description: Wires up the OFFICIAL TanStack agent skills via TanStack Intent — version-synced SKILL.md files that ship inside the installed @tanstack packages (Query, Router, Store, Table, etc.), so guidance matches the version in node_modules instead of drifting. Use when the user says "tanstack", "set up tanstack skills", "tanstack query/router best practices", or "intent install".
---

# TanStack (official skills via Intent)

## Overview
TanStack publishes agent skills *inside its npm packages* (`node_modules/<pkg>/skills/<skill>/SKILL.md`). The official tool **TanStack Intent** scans the `@tanstack/*` packages you actually have installed and writes an `intent-skills` guidance block into your agent config, pointing at those files. The guidance travels with `npm/pnpm update` — it always matches the installed version. This is the preferred path over any community TanStack pack.

Source of truth: tanstack.com (Intent docs + each library's "Agent Skills" page).

## When to Use
- Setting up TanStack guidance in a repo that already uses TanStack (e.g. `grand-line`).
- The agent is writing Query/Router/Store code and should follow version-correct patterns.
- Refreshing mappings after upgrading TanStack packages.

## Two things named "skills" — don't confuse them
- **Agent-authoring skills (this skill):** markdown that teaches your *coding assistant*. Set up with `intent install`.
- **Portable Agent Skills (runtime):** a different feature where *your app's* model loads skills at runtime. Not this. Ignore unless you're building that.

## Process

### 1. Confirm the packages are installed
Intent only wires skills for packages present in `node_modules`. Confirm what the repo uses (e.g. `@tanstack/react-query`, `@tanstack/react-router`). Keep `@tanstack/intent` in devDependencies and commit the lockfile for CI.

### 2. Run intent install (project-scoped)
From the repo root:
```bash
# in grand-line (uses pnpm)
pnpm dlx @tanstack/intent@latest install
```
First run is interactive (needs a TTY, Node ≥ 20.12): choose **Enable all**, specific packages, a whole scope (`@tanstack/*`), or individual skills. It confirms once, then writes the guidance block. Use `--dry-run` to preview without writing.

### 3. Review the generated mappings
Install appends an `intent-skills` block (into `AGENTS.md` / `CLAUDE.md` / `.cursorrules` / copilot-instructions) like:
```yaml
<!-- intent-skills:start -->
skills:
  - task: "Fetching, caching, and mutating server state with TanStack Query"
    load: "node_modules/@tanstack/react-query/skills/.../SKILL.md"
<!-- intent-skills:end -->
```
**Check the `task:` lines match what you actually build**, and confirm the packages you care about (Query, Router) actually shipped a skill — coverage depends on the installed package versions. Tighten wording so the agent loads the right skill at the right time.

### 4. Confirm it's wired up
Open a fresh agent session and ask it to build something with TanStack. It should follow version-correct APIs (e.g. current Query patterns) rather than training-data habits. If it falls back to old patterns, re-open the config and confirm the block is present and the `task:` descriptions cover the area.

### 5. Keep current
Re-run `intent install --review` after upgrading TanStack packages, or to change which skills/packages are enabled. The loaded content changes automatically with the installed version; the mappings don't need rewriting unless packages were added/removed.

## Discovery skills (optional, TanStack AI only)
There are user-level discovery skills — `/plugin install tanstack-ai` or `npx skills add TanStack/ai -g --skill tanstack-ai tanstack-ai-migration` — but these are specific to **TanStack AI** (the LLM/chat library), not Query/Router. Only install them if you use `@tanstack/ai`.

## If Intent doesn't cover a package you need
If `intent install` shows no skill for a package you rely on, that package hasn't shipped one yet. The best-known community fallback for Query/Router patterns is `DeckardGer/tanstack-agent-skills`:
```bash
pnpm dlx skills add DeckardGer/tanstack-agent-skills --skill tanstack-query
```
Prefer the official Intent skill whenever it exists — only reach for the community pack to fill a gap.

## Rationalizations — and the rebuttals
| Excuse | Rebuttal |
| --- | --- |
| "Just copy a community TanStack pack, it's simpler." | Community packs drift from your installed version. Intent ships the right version's guidance. Use it first. |
| "`npx skills add TanStack/ai` sets up Query." | No — that's the TanStack **AI** discovery skill. For Query/Router use `intent install`. |
| "Skip reviewing the mappings." | The `task:` lines decide when the agent loads each skill. Wrong wording = never loaded. Review them. |
| "Re-run install from scratch after every upgrade." | Content auto-syncs with the package version. Use `--review` only to change what's enabled. |

## Red Flags — stop and fix
- A community TanStack pack installed *instead of* running Intent on an installed package.
- The `intent-skills` block missing after install, or `task:` lines that don't match the work.
- `tanstack-ai` discovery skill installed in a repo that doesn't use `@tanstack/ai`.

## Verification — done when
- `intent install` ran and an `intent-skills` block exists in the agent config.
- The mappings cover the TanStack packages the repo actually uses, with accurate `task:` descriptions.
- A fresh agent session produces version-correct TanStack code.
- Any community fallback is only filling a genuine gap, not shadowing an official skill.
