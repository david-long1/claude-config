#!/usr/bin/env bash
# Install or update this setup in another repo.
#
# .claude/.claude-config.lock in the target records each file's hash as
# installed. On a re-run, a file still matching its lock hash is updated to
# the new version; a file you edited is kept and reported; a file you deleted
# stays deleted; a file that was there before the first install is never
# touched.
set -euo pipefail

src="$(cd "$(dirname "$0")" && pwd)"
t="$(cd "${1:?usage: install.sh <target-repo>}" && pwd)"
lock="$t/.claude/.claude-config.lock"

if [ -n "$(git -C "$src" status --porcelain -- .claude)" ]; then
  echo "warning: $src/.claude has uncommitted changes; installing them anyway" >&2
fi

old=$(mktemp)
new=$(mktemp)
trap 'rm -f "$old" "$new"' EXIT
if [ -f "$lock" ]; then grep -v '^#' "$lock" > "$old" || true; fi

locked() { awk -v p="$1" '$2 == p { print $1 }' "$old"; }

# Hashes of every committed version of $1. Lets an install made before the
# lock existed count as unmodified when it matches one of them.
history() {
  git -C "$src" rev-list HEAD -- "$1" | while read -r c; do
    git -C "$src" rev-parse -q --verify "$c:$1" || true
  done
}

while IFS= read -r p; do
  s="$src/$p"
  d="$t/$p"
  sh=$(git hash-object "$s")
  lh=$(locked "$p")
  if [ ! -e "$d" ]; then
    if [ -n "$lh" ]; then
      echo "skip    $p (deleted locally)"
      echo "$lh $p" >> "$new"
    else
      mkdir -p "$(dirname "$d")"
      cp "$s" "$d"
      echo "add     $p"
      echo "$sh $p" >> "$new"
    fi
    continue
  fi
  dh=$(git hash-object "$d")
  if [ -z "$lh" ] && history "$p" | grep -qx "$dh"; then lh=$dh; fi
  if [ "$dh" = "$sh" ]; then
    echo "$sh $p" >> "$new"
  elif [ -n "$lh" ] && [ "$dh" = "$lh" ]; then
    cp "$s" "$d"
    echo "update  $p"
    echo "$sh $p" >> "$new"
  else
    # Edited locally, or present before the first install.
    if [ "$sh" != "$lh" ]; then echo "keep    $p (local changes; compare: diff $s $d)"; fi
    if [ -n "$lh" ]; then echo "$lh $p" >> "$new"; fi
  fi
done < <(git -C "$src" ls-files .claude)

{
  echo "# claude-config $(git -C "$src" rev-parse --short HEAD) from $src"
  cat "$new"
} > "$lock"

[ -e "$t/AGENTS.md" ] || [ ! -e "$t/CLAUDE.md" ] || ln -s CLAUDE.md "$t/AGENTS.md"
[ -e "$t/.agents" ] || ln -s .claude "$t/.agents"
if ! grep -qs "claude.just" "$t/justfile"; then
  printf "import? '.claude/claude.just'\n" >> "$t/justfile"
  echo "added import to $t/justfile"
fi
echo "done: $t — later, run \`just claude-sync\` there to pick up changes"
