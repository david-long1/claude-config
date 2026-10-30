import '.claude/claude.just'

default:
    @just --list

# install into another repo, or update an earlier install (keeps your local edits)
install target:
    ./install.sh "{{ target }}"
