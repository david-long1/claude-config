# claude-config

A portable Claude Code + Codex setup: per-domain profiles, `just`
launchers, shared skills, and safe default settings. One set of files
serves both tools.

## Install into a repo

```sh
just install ~/path/to/repo
```

This copies `.claude/` (skipping files that already exist), adds the
`AGENTS.md → CLAUDE.md` and `.agents → .claude` symlinks, and appends
`import? '.claude/claude.just'` to the repo's justfile. Copy `CLAUDE.md` in
yourself if you want these working agreements.

## Launchers

| Recipe | What it does |
|---|---|
| `just claude [profile] [args]` | Claude Code, with `.claude/profiles/<profile>/system-prompt.md` appended |
| `just claude-resume [profile]` | Same, continuing the last session |
| `just codex [profile] [args]` | Codex CLI, with the profile passed as `developer_instructions` |
| `just profiles` | List profiles |

Extra arguments pass through: `just claude go-backend -p "run the tests"`.

## How it works

- **Profiles** are plain markdown. Claude appends them with
  `--append-system-prompt-file`; Codex gets them through
  `-c developer_instructions=…`. Add one by creating
  `.claude/profiles/<name>/system-prompt.md`.
- **Codex sharing.** Claude reads `CLAUDE.md` and `.claude/`; Codex reads
  `AGENTS.md` and `.agents/`. The symlinks make each edit reach both.
- **Skills** in `.claude/skills/` load in every session regardless of
  profile. Codex discovers them through `.agents/skills/`, but
  `review-pr` uses Claude-only subagents.

## What's included

| Path | Purpose |
|---|---|
| `.claude/claude.just` | The launcher recipes |
| `.claude/profiles/go-backend/` | Example profile: Go service conventions |
| `.claude/settings.json` | Deny list (`rm -rf`, force-push, reading `.env`/secrets), read-only git/gh allow list, `gofumpt` on edited Go files, public plugins (`pr-review-toolkit`, `codex`, `superpowers`) |
| `.claude/skills/review-pr/` | Aspect-split PR review: a panel of `pr-review-toolkit` agents, a verification pass, one consolidated review |
| `.claude/skills/design-doc/` | Design doc generator |
| `.claude/skills/handoff/` | Session handoff prompt when context runs low |
| `.claude/skills/renovate/` | Triage and merge Renovate PRs |
| `.claude/output-styles/newbie.md` | Ground-up explanation style (`/output-style newbie`) |
| `CLAUDE.md` | Working agreements: comments, git, reviews, requirements |

## review-pr

```
/review-pr                 # current branch, auto panel
/review-pr 42              # PR #42 without checking it out
/review-pr 42 errors tests # only those aspects
/review-pr 42 --post       # post without asking
```

The auto panel scales with the diff: small changes get the code reviewer
alone; error-handling, test, type, and comment changes each bring in their
specialist; security-sensitive paths always get the full panel. Each
finding must quote the code it's about, and a verifier drops any finding
whose quote or premise doesn't hold. Add language checklists under
`checklists/` with an `applies-to` glob list in the frontmatter.
