# CLAUDE.md

Guidance for an agent working **on this repository** (editing or adding skills), not for the skills themselves.

## What this repo is
A personal skill pack for AI coding agents. Each skill is a workflow at `skills/<name>/SKILL.md`. The repo is also a Claude Code plugin (`.claude-plugin/plugin.json`) and its own marketplace (`.claude-plugin/marketplace.json`).

## Adding or editing a skill
1. Read `docs/skill-anatomy.md` first — it's the format spec.
2. Start from `templates/SKILL.template.md`. Copy it to `skills/<new-name>/SKILL.md`.
3. The frontmatter `name` must equal the folder name.
4. Write a *workflow* (steps with exit criteria), not reference prose.
5. Keep it lean — cut anything that doesn't change a step or decision.

## Always do after a change
- Update the Skill index table in `README.md`.
- If the new skill belongs in the lifecycle, add it to `product-flow`'s phase table.
- Validate frontmatter: every `SKILL.md` has `name` (matching its folder) and a `description` containing trigger phrases.

## Guardrails
- One active router only: `product-flow`. Don't add a second meta-router.
- Don't duplicate a skill that already exists in a pack you depend on — reference it instead.
- Shared checklists go in `references/` and are linked, not copy-pasted into each skill.
- Never commit secrets.

## Conventions
- Skill names: lowercase-hyphen.
- One skill = one job. If it grows a second job, split it.
- Prefer deleting a skill over keeping a stale one.
