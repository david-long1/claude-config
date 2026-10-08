import '.claude/claude.just'

default:
    @just --list

# copy this setup into another repo (never overwrites existing files)
install target:
    #!/usr/bin/env bash
    set -euo pipefail
    t="$(cd "{{ target }}" && pwd)"
    mkdir -p "$t/.claude"
    cp -Rn .claude/. "$t/.claude/"
    [ -e "$t/AGENTS.md" ] || [ ! -e "$t/CLAUDE.md" ] || ln -s CLAUDE.md "$t/AGENTS.md"
    [ -e "$t/.agents" ] || ln -s .claude "$t/.agents"
    if ! grep -qs "claude.just" "$t/justfile"; then
      printf "import? '.claude/claude.just'\n" >> "$t/justfile"
      echo "added import to $t/justfile"
    fi
    echo "installed into $t — add a profile under .claude/profiles/ and review .claude/settings.json"
