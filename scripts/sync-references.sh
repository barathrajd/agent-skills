#!/usr/bin/env bash
# sync-references.sh — vendor shared reference files into the skills that use them.
#
# Why: the skills CLI (and plugin-less installs) copy only a skill's own folder,
# so a skill that links to a repo-root references/ file ships with a dead link.
# Each skill must be self-contained. The source of truth stays at references/<file>;
# this script copies it into skills/<skill>/references/<file> per the mapping in
# scripts/shared-references.txt.
#
# Usage:
#   bash scripts/sync-references.sh           # write/refresh the vendored copies
#   bash scripts/sync-references.sh --check   # exit 1 if any copy is missing, stale, or unmapped
#
# Never edit a vendored copy; edit references/<file> and re-run this script.

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAP="$ROOT/scripts/shared-references.txt"
mode="sync"
[ "${1:-}" = "--check" ] && mode="check"

[ -f "$MAP" ] || { echo "ERROR: missing mapping file: $MAP"; exit 1; }

banner() {
  printf '<!-- Vendored copy. Source of truth: the repo-root references folder, file %s. Edit it there, then run scripts/sync-references.sh. -->\n\n' "$1"
}

bad=0
copies=0
mapped=" "

while read -r skill files; do
  case "$skill" in ''|\#*) continue ;; esac
  if [ ! -d "$ROOT/skills/$skill" ]; then
    echo "✗ mapping names an unknown skill: $skill"
    bad=1
    continue
  fi
  for f in $files; do
    src="$ROOT/references/$f"
    dst="$ROOT/skills/$skill/references/$f"
    mapped="$mapped$skill/$f "
    if [ ! -f "$src" ]; then
      echo "✗ $skill: shared file does not exist: references/$f"
      bad=1
      continue
    fi
    tmp="$(mktemp)"
    { banner "$f"; cat "$src"; } > "$tmp"
    copies=$((copies + 1))
    if [ "$mode" = "sync" ]; then
      mkdir -p "$(dirname "$dst")"
      cp "$tmp" "$dst"
    elif [ ! -f "$dst" ]; then
      echo "✗ $skill: missing vendored copy of $f (run scripts/sync-references.sh)"
      bad=1
    elif ! cmp -s "$tmp" "$dst"; then
      echo "✗ $skill: stale vendored copy of $f (run scripts/sync-references.sh)"
      bad=1
    fi
    rm -f "$tmp"
  done
done < "$MAP"

# A skill-local file that shadows a shared file but is not in the mapping is a
# stale or hand-made copy.
for dst in "$ROOT"/skills/*/references/*.md; do
  [ -f "$dst" ] || continue
  f="$(basename "$dst")"
  skill="$(basename "$(dirname "$(dirname "$dst")")")"
  if [ -f "$ROOT/references/$f" ]; then
    case "$mapped" in
      *" $skill/$f "*) ;;
      *) echo "✗ $skill: references/$f shadows a shared file but is not in scripts/shared-references.txt"; bad=1 ;;
    esac
  fi
done

if [ "$bad" -ne 0 ]; then
  exit 1
fi
if [ "$mode" = "sync" ]; then
  echo "✓ synced $copies vendored reference file(s)"
else
  echo "✓ vendored references in sync ($copies file(s))"
fi
