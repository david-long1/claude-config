# Working Agreements

Project instructions for Claude Code (and Codex, via the `AGENTS.md`
symlink). Copy into a repo with `just install <path>` and trim to taste.

## General

- Do what was asked: nothing more, nothing less. Prefer editing existing
  files over creating new ones; don't create docs unless asked.
- Run the repo's formatter, linter, and tests before declaring work done,
  and report real results — failures included.
- Use subagents for genuinely independent work (broad searches, parallel
  reviews), not by default.

## Code comments

- Short and human. Explain *why*, not *what*; never narrate what the code
  already says.
- No design-doc section numbers, requirement IDs, or ticket numbers in
  comments — state the behavior or constraint directly.
- No "what once was" comments. Document what *is*.
- Avoid the word "verbatim" — use "as-is", "unmodified", "unchanged".
- Match the surrounding file's comment density. When in doubt, cut it.

## Requirements — validate purpose, not just feasibility

Before working out *how* to satisfy a requirement, re-derive *why* it
exists: what concrete failure does it prevent, and when would that failure
actually occur? If no such scenario exists, propose removing the
requirement instead of approximating it. An unsatisfiable or surprisingly
expensive criterion is a signal to question its premise.

## Check for deprecation before recommending anything

Before code, an error message, docs, or a PR tells someone to use a flag,
CLI option, API, config key, or dependency, confirm it isn't deprecated:
read its definition and help text, and for external tools check upstream
docs or changelogs (cite them).

## Facts and versions

Verify version numbers, release dates, and support status online before
stating them. Cite sources.

## Git

- Run `git status` before staging; stage files by path, never `git add -A`.
- After a formatter or hook runs, re-check `git status` — hooks can stage
  files you didn't intend to commit.
- Commit subject ≤ 72 chars, conventional type (`feat:`, `fix:`, `chore:`,
  `docs:`, `refactor:`, `test:`, `perf:`). Most commits need no body; add
  1-2 sentences only when the *why* isn't obvious from the diff.
- Show the full commit message for review before any push.
- Never force-push or merge a PR without explicit approval.

## Posting to GitHub

- Draft comments, reviews, and PR bodies first; post only after explicit
  approval.
- If a post fails or times out, re-list existing comments before any
  retry, as a separate step — it may have gone through.
- Use `owner/repo#N` for cross-repo links.

## PR descriptions and comments for upstream/OSS repos

- Body ~150 words: one short paragraph on why, 2-4 bullets on what, merge
  order if stacked, a one-line test summary.
- Replies 1-3 sentences. Polished generic phrasing and volunteered extras
  (alternatives, side notes nobody asked for) read as AI-written and get
  flagged more than length does.
- Read the project's CONTRIBUTING and AI policy first; follow its commit
  trailer and disclosure rules.

## Reviewing PRs

1. **Section map first.** Split the diff into logical sections (not files)
   with a risk rating each; skip generated artifacts. Confirm the map
   before deep-diving.
2. **Per section:** correctness, failure modes, edge cases; research best
   practice only where a choice is contestable (and cite it); security where
   relevant; audit every comment for truth and clarity.
3. **Cross-section pass:** interactions, scope creep, test gaps.

Lens: trust boundaries first (who controls each input?), fail closed and
loudly, watch for logic duplicated in two places that can drift, and
misleading error messages.

Posted comment voice: plain prose, 2-4 sentences, lead with what breaks and
when, end with the fix as a short question. `nit:` prefix for low stakes;
one concern per comment. No bold titles or headers.

## Design docs

Use the `design-doc` skill. Lead with the decision, keep it scannable
(tables, diagrams, short paragraphs), back every estimate with reasoning,
gloss every internal term at first use.

## Explanations

When explaining a concept or tool, build from first principles: define
jargon at first use, one concrete analogy, cause → effect, then the short
expert version. Status updates and reviews stay tight.

## Python tooling (uv + direnv)

`.envrc` runs `uv sync` and `PATH_add .venv/bin`, so venv tools are on
`PATH` after `cd`. Call tools directly (`ruff check .`, `pytest`) in
justfiles, docs, and CI — no `uv run` prefix.
