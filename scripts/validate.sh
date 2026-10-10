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
# Also fails if a skill links to a references/ file it does not ship, or if a
# vendored shared reference is stale (see scripts/sync-references.sh).
#
# Then a supply-chain lint over fenced code blocks in skills/, references/,
# docs/ and templates/: fails on pipe-to-shell installers, @latest, npx -y,
# global installs, unpinned `skills add`, and dlx/npx without an exact version.
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

# --- Supply-chain lint -------------------------------------------------------
# Scans fenced code blocks in skills/, references/, docs/ and templates/ for
# install commands that break references/supply-chain.md. Prose that merely
# *mentions* a banned pattern is ignored; only commands in code blocks count.
ROOT_DIR="$(cd "$SKILLS_DIR/.." && pwd)"

lint_file() {
  awk -v f="$1" '
    function report(m) { if (!((NR, m) in seen)) { seen[NR, m] = 1; printf "%s:%d: %s\n", f, NR, m; bad = 1 } }
    # Always-on (code block or inline): the two highest-risk patterns, written
    # so that prose which merely names them (no URL, no package) does not match.
    /(curl|wget)[^|]*https?:\/\/[^|]*\|[ \t]*(sudo[ \t]+)?(ba|z|da)?sh/ { report("pipe-to-shell installer") }
    /[A-Za-z0-9]@latest/ { report("floating @latest tag") }
    /^[ \t]*```/ { infence = !infence; next }
    !infence { next }
    /^[ \t]*#/ { next }
    {
      line = $0
      if (line ~ /(curl|wget)[^|]*\|[ \t]*(sudo[ \t]+)?(ba|z|da)?sh/ ||
          line ~ /(ba)?sh[ \t]+<\([ \t]*(curl|wget)/ ||
          line ~ /eval[ \t]+"?\$\([ \t]*(curl|wget)/) report("pipe-to-shell installer")
      if (line ~ /@latest/) report("floating @latest tag")
      if (line ~ /npx[ \t]+(-y|--yes)/) report("npx auto-confirm flag")
      if (line ~ /(^|[ \t])(-g|--global)([ \t]|$)/) report("global install flag")
      if (line ~ /skills add/) report("unpinned skills add (use references/external-skills.md)")
      n = split(line, t, /[ \t]+/)
      for (i = 1; i <= n; i++) {
        if ((t[i] == "dlx" && (t[i-1] == "pnpm" || t[i-1] == "yarn")) || t[i] == "npx" || t[i] == "bunx") {
          j = i + 1
          while (j <= n && t[j] ~ /^-/ && t[j] !~ /^--package=/) j++
          tok = t[j]; sub(/^--package=/, "", tok)
          if (tok != "" && tok !~ /[A-Za-z0-9]@[0-9]/) report("dlx/npx package without an exact version: " tok)
        }
      }
    }
    END { exit bad }
  ' "$1"
}

lint_errors=0
lint_files=0
while IFS= read -r md; do
  lint_files=$((lint_files + 1))
  if ! out="$(lint_file "$md")"; then
    while IFS= read -r l; do
      [ -z "$l" ] && continue
      echo "✗ lint ${l#"$ROOT_DIR"/}"
    done <<EOF
$out
EOF
    lint_errors=$((lint_errors + 1))
  fi
done < <(find "$ROOT_DIR/skills" "$ROOT_DIR/references" "$ROOT_DIR/docs" "$ROOT_DIR/templates" -name '*.md' -type f 2>/dev/null | sort)

if [ "$lint_errors" -eq 0 ]; then
  echo "✓ supply-chain lint ($lint_files file(s))"
else
  errors=$((errors + lint_errors))
fi

# --- Self-contained skills ---------------------------------------------------
# The skills CLI installs only a skill's own folder, so every references/<file>.md
# a skill links to must exist inside that skill's folder.
dangling=0
for dir in "$SKILLS_DIR"/*/; do
  [ -d "$dir" ] || continue
  sname="${dir%/}"; sname="${sname##*/}"
  while IFS= read -r md; do
    while IFS=: read -r ln ref; do
      [ -z "$ref" ] && continue
      if [ ! -f "${dir}${ref}" ]; then
        echo "✗ dangling ${md#"$ROOT_DIR"/}:$ln links to $ref, which this skill does not ship (vendor it via scripts/shared-references.txt or move it into the skill)"
        dangling=$((dangling + 1))
      fi
    done < <(grep -noE 'references/[A-Za-z0-9._/-]+\.md' "$md" 2>/dev/null)
  done < <(find "$dir" -name '*.md' -type f | sort)
done
if [ "$dangling" -eq 0 ]; then
  echo "✓ every skill is self-contained (no dangling references/ links)"
else
  errors=$((errors + dangling))
fi

# Vendored shared references must match their source of truth.
if [ -f "$ROOT_DIR/scripts/sync-references.sh" ] && [ -f "$ROOT_DIR/scripts/shared-references.txt" ]; then
  if ! bash "$ROOT_DIR/scripts/sync-references.sh" --check; then
    errors=$((errors + 1))
  fi
fi

echo "----"
echo "$count skill(s) checked, $errors error(s), $warnings warning(s)."
[ "$errors" -eq 0 ] || exit 1
