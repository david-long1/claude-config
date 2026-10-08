# Claude Code / Codex launchers. Import from a repo's justfile with:
#   import? '.claude/claude.just'
# A profile is .claude/profiles/<name>/system-prompt.md, appended to the
# agent's built-in system prompt. Omit the profile for a plain session.

set positional-arguments

# list available profiles
[group('agents')]
profiles:
    @ls .claude/profiles

# launch Claude Code, optionally with a profile (e.g. `just claude go-backend`)
[group('agents')]
claude profile="" *args:
    #!/usr/bin/env bash
    set -euo pipefail
    profile="$1"; shift
    [ -z "$profile" ] && exec claude "$@"
    f=".claude/profiles/$profile/system-prompt.md"
    [ -f "$f" ] || { echo "unknown profile '$profile'; have: $(ls .claude/profiles | tr '\n' ' ')" >&2; exit 1; }
    exec claude --append-system-prompt-file "$f" "$@"

# resume the last Claude Code session, optionally with a profile
[group('agents')]
claude-resume profile="" *args:
    @just claude "$1" --continue "${@:2}"

# launch Codex CLI, optionally with a profile as developer_instructions
[group('agents')]
codex profile="" *args:
    #!/usr/bin/env bash
    set -euo pipefail
    profile="$1"; shift
    root="$(git rev-parse --show-toplevel)"
    [ -z "$profile" ] && exec codex --cd "$root" "$@"
    f="$root/.claude/profiles/$profile/system-prompt.md"
    [ -f "$f" ] || { echo "unknown profile '$profile'; have: $(ls "$root/.claude/profiles" | tr '\n' ' ')" >&2; exit 1; }
    exec codex --cd "$root" -c developer_instructions="$(cat "$f")" "$@"
