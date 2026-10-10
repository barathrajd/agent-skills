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
- Skills are self-contained: installs copy only `skills/<name>/`, so every `references/*.md` a skill links must exist inside that folder. Material used by one skill lives there. Material shared by several lives once in root `references/`, is listed in `scripts/shared-references.txt`, and is copied in by `bash scripts/sync-references.sh`. Never edit a vendored copy; after changing root `references/`, re-run the sync. `validate.sh` fails on dangling or stale copies.
- Skills for third-party libraries follow `docs/library-skills.md` (docs source, `Reviewed against` line, maintenance routine).
- Never commit secrets.

## Conventions
- Skill names: lowercase-hyphen.
- One skill = one job. If it grows a second job, split it.
- Prefer deleting a skill over keeping a stale one.
