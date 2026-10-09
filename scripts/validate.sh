#!/usr/bin/env bash
# validate.sh — check every skills/<name>/SKILL.md has valid frontmatter.
#
# Checks per skill:
#   - SKILL.md exists
#   - file starts with a --- frontmatter block that is closed
#   - has a name: that matches its folder name
#   - has a non-empty description:
#   - (warning) description contains "use when" trigger phrases
#
# Usage:
#   bash scripts/validate.sh            # validate ./skills
#   bash scripts/validate.sh path/to/skills
#
# Exits non-zero if any error is found (good for CI / pre-commit).

set -u

if [ "$#" -ge 1 ]; then
  SKILLS_DIR="$1"
else
  ROOT="$(cd "$(dirname "$0")/.." && pwd)"
  SKILLS_DIR="$ROOT/skills"
fi

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: no skills directory at: $SKILLS_DIR"
  exit 1
fi

errors=0
warnings=0
count=0

for dir in "$SKILLS_DIR"/*/; do
  [ -d "$dir" ] || continue
  name="${dir%/}"; name="${name##*/}"
  file="${dir}SKILL.md"
  count=$((count + 1))
  file_err=0

  if [ ! -f "$file" ]; then
    echo "✗ $name — missing SKILL.md"
    errors=$((errors + 1))
    continue
  fi

  result="$(awk -v folder="$name" '
    BEGIN { fm = 0; namev = ""; descv = "" }
    NR == 1 {
      if ($0 == "---") { fm = 1; next }
      else { print "ERR no-frontmatter"; done = 1; exit }
    }
    fm == 1 && $0 == "---" { fm = 2; next }
    fm == 1 {
      if ($0 ~ /^name:/) {
        v = $0; sub(/^name:[ \t]*/, "", v); gsub(/^"|"$/, "", v); namev = v
      }
      if ($0 ~ /^description:/) {
        v = $0; sub(/^description:[ \t]*/, "", v); gsub(/^"|"$/, "", v); descv = v
      }
    }
    END {
      if (done == 1) { exit }
      if (fm == 1) { print "ERR unclosed-frontmatter"; exit }
      if (namev == "") { print "ERR no-name" }
      else if (namev != folder) { print "ERR name-mismatch:" namev }
      if (descv == "") { print "ERR no-description" }
      else if (tolower(descv) !~ /use when|when the user|when you/) { print "WARN no-use-when" }
    }
  ' "$file")"

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in
      "ERR no-frontmatter")      echo "✗ $name — no frontmatter (file must start with ---)"; file_err=1 ;;
      "ERR unclosed-frontmatter") echo "✗ $name — frontmatter not closed with ---"; file_err=1 ;;
      "ERR no-name")             echo "✗ $name — missing 'name:' in frontmatter"; file_err=1 ;;
      "ERR name-mismatch:"*)     echo "✗ $name — 'name:' is '${line#ERR name-mismatch:}', must match folder '$name'"; file_err=1 ;;
      "ERR no-description")      echo "✗ $name — missing 'description:'"; file_err=1 ;;
      "WARN no-use-when")        echo "⚠ $name — description has no 'use when …' trigger phrases (recommended)"; warnings=$((warnings + 1)) ;;
    esac
  done <<EOF
$result
EOF

  if [ "$file_err" -eq 1 ]; then
    errors=$((errors + 1))
  else
    echo "✓ $name"
  fi
done

echo "----"
echo "$count skill(s) checked, $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ] || exit 1
