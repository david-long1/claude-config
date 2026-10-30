#!/usr/bin/env bash
# PostToolUse hook: format the file Claude just edited with the formatter the
# project already uses. Missing formatters are skipped; never fails the edit.
# Format only — lint fixes like removing unused imports would undo an
# edit that adds an import before its first use.
f=$(jq -r '.tool_input.file_path // empty') || exit 0
[ -f "$f" ] || exit 0
cd "$(dirname "$f")" || exit 0

# Nearest ancestor directory containing $1.
up() {
  local d=$PWD
  while [ "$d" != / ]; do
    [ -e "$d/$1" ] && { echo "$d"; return 0; }
    d=$(dirname "$d")
  done
  return 1
}

case "$f" in
  *.go)
    command -v gofumpt >/dev/null && gofumpt -w "$f"
    ;;
  *.rs)
    # rustfmt alone defaults to edition 2015; take it from Cargo.toml,
    # walking up past workspace members that inherit it.
    ed= d=$PWD
    while [ -z "$ed" ] && [ "$d" != / ]; do
      [ -f "$d/Cargo.toml" ] && ed=$(sed -n 's/^edition *= *"\([0-9]*\)".*/\1/p' "$d/Cargo.toml" | head -1)
      d=$(dirname "$d")
    done
    command -v rustfmt >/dev/null && rustfmt --edition "${ed:-2021}" "$f"
    ;;
  *.py)
    if v=$(up .venv) && [ -x "$v/.venv/bin/ruff" ]; then
      "$v/.venv/bin/ruff" format -q "$f"
    elif command -v ruff >/dev/null; then
      ruff format -q "$f"
    fi
    ;;
  *.ts | *.tsx | *.js | *.jsx | *.mjs | *.cjs | *.css | *.scss)
    # npm links transitive deps' binaries too, so require prettier to be a
    # declared dependency before trusting node_modules/.bin/prettier.
    if r=$(up package.json) && grep -q '"prettier"' "$r/package.json" &&
      [ -x "$r/node_modules/.bin/prettier" ]; then
      "$r/node_modules/.bin/prettier" --write --log-level warn "$f"
    fi
    ;;
esac
exit 0
