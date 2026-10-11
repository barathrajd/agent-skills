# Skill Anatomy

How to write a skill for this repo. A skill is a **workflow an agent follows**, not reference prose it reads. If you're writing an essay, you're writing the wrong thing.

## File format

Every skill is `skills/<name>/SKILL.md` with YAML frontmatter:

```markdown
---
name: lowercase-hyphen-name
description: One sentence on what it does, then "Use when…" with the exact words a user would say to trigger it.
---
```

- **`name`** must match the folder name, lowercase with hyphens.
- **`description`** is the only part always in the agent's context, so it's how the agent decides whether to reach for the skill. Pack it with real trigger phrases ("use when the user says 'ship it', 'deploy', 'release'"). A vague description means the skill never fires.

## Required sections (in order)

1. **Overview** — what the skill produces and its one job. 2–4 sentences.
2. **When to Use** — concrete triggering conditions.
3. **Process** — numbered steps. Each meaningful step ends in an **exit criterion** ("done when X"). This is the heart of the skill.
4. **Rationalizations** — a table of excuses an agent/engineer uses to skip a step, each with a one-line rebuttal. This is what keeps the agent honest.
5. **Red Flags** — observable signs the skill is going wrong; "stop and fix".
6. **Verification** — the evidence that proves the work is actually done.

## The six design principles

1. **Process over prose.** Steps with checkpoints, not advice. Advice gets skimmed and skipped.
2. **Anti-rationalization.** Pre-write the rebuttals to the shortcuts the agent will be tempted to take.
3. **Verification is non-negotiable.** End in evidence — a passing test, a build result, a runtime check. "Seems right" never closes a step.
4. **Portable across agents.** The frontmatter is `name` and `description` only, and the body names no agent-specific tool. Claude Code, Codex, OpenCode and Gemini CLI all load the same file. Keep each description short: agents list every description on each run and Codex shortens or drops them past its budget.
5. **Progressive disclosure.** Keep the body short; it only loads when the skill runs. Push long material into the skill's own `references/` folder and link it. A skill must be self-contained, because installs copy only the skill's folder. Material shared by several skills lives once in the repo-root `references/`, is listed in `scripts/shared-references.txt`, and is copied in by `bash scripts/sync-references.sh`; never edit the copies. `validate.sh` fails on dangling or stale links.
6. **Scope discipline.** The skill touches only what it's for. If it starts doing a neighbouring skill's job, split it.

## Keep it lean

The community's #1 complaint about skill packs is token bloat. A skill that's three tight pages beats one that's ten. Cut anything that doesn't change a decision or a step. If two skills overlap, merge or delete — don't ship both.

## Checklist before you commit

- [ ] `name` matches the folder.
- [ ] `description` contains the literal words a user would type to trigger it.
- [ ] Every process step that matters has an exit criterion.
- [ ] There's a rationalizations table and a verification section.
- [ ] Nothing in the body could be cut without losing a step.
- [ ] Added to the Skill index in `README.md` (and `product-flow`'s phase table if it routes there).
