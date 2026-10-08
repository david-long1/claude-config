---
name: renovate
description: Triage, fix, and merge open Renovate dependency update PRs. Lists all open Renovate PRs, categorizes by risk (safe/major/workflow/failing), merges safe ones, fixes lockfile issues, flags majors and workflow PRs for manual action. Use when the user says /renovate or asks to handle Renovate PRs.
argument-hint: "[PR-number]"
allowed-tools: Bash(gh *), Bash(git *), Bash(pnpm *), Read, Grep
---

# Renovate PR Triage & Merge

Process open Renovate dependency update PRs — categorize, merge safe ones, fix failures, and flag the rest.

## Step 0: Preflight checks

Before doing anything, capture the current branch and verify the working tree is clean:

```bash
ORIGINAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
```

```bash
git diff --quiet && git diff --cached --quiet
```

If the working tree is dirty (either command exits non-zero), **stop immediately** and tell the user:
**"You have uncommitted changes. Please commit or stash them before running /renovate."**

Use `$ORIGINAL_BRANCH` for all "switch back" operations throughout this skill.

## Step 1: Discovery

If `$ARGUMENTS` contains a PR number, target only that PR. Otherwise, list all open Renovate PRs:

```bash
gh pr list --author "app/renovate" --state open --json number,title,labels,headRefName,mergeable,statusCheckRollup --limit 100
```

If no open Renovate PRs exist, tell the user and stop.

## Step 2: Categorize each PR

For each PR, assign exactly one category (check in this order):

1. **Workflow** — PR modifies files under `.github/workflows/` (check with `gh pr diff <number> --name-only | grep '^\.github/workflows/'`)
2. **Major** — title contains "major update" or version bump like `v1.x → v2.x` (check title for patterns like `major`, or semver major bump)
3. **Failing CI** — `statusCheckRollup` contains any check with `conclusion: "FAILURE"` or `state: "FAILURE"`
4. **Safe** — everything else (patch updates, minor updates, pin dependencies, lock file maintenance, digest updates)

Present a summary table to the user:
```
| # | PR | Category |
|---|-----|----------|
| 1 | #82 fix(deps): update dependency X to v1.2.3 | Safe |
| 2 | #83 chore(deps): major update Y to v3.0.0 | Major |
...
```

## Step 3: Process Safe PRs

Merge safe PRs one at a time, sequentially. **After each merge**, verify the next PR is still mergeable with passing CI before merging it — do not assume prior CI results are still valid.

For each safe PR:

1. **Check CI status** — verify all required checks have passed:
   ```bash
   gh pr checks <number>
   ```
   If checks are still pending, watch them:
   ```bash
   gh pr checks <number> --watch
   ```

2. **Check mergeability** — verify the PR hasn't been invalidated by a previous merge:
   ```bash
   gh pr view <number> --json mergeable,mergeStateStatus --jq '{mergeable, mergeStateStatus}'
   ```
   - If `CONFLICTING`: trigger a Renovate rebase (see Step 5) and wait for fresh CI before retrying.
   - If `UNKNOWN`: wait a few seconds and recheck — GitHub may be recalculating after a recent merge.

3. **Approve and merge**:
   ```bash
   gh pr review <number> --approve --body "LGTM - <brief reason, e.g. 'patch update for vite'>"
   gh pr merge <number> --admin --squash
   ```

4. If a merge fails due to conflicts or CI, move the PR to the **Failing CI** category and continue with the next safe PR.

## Step 4: Handle Failing CI PRs (lockfile issues)

For PRs failing CI (typically lockfile mismatches):

1. Checkout the branch:
   ```bash
   git fetch origin <branch>
   git checkout <branch>
   ```

2. Regenerate the lockfile — do NOT try to manually resolve, always regenerate:
   ```bash
   pnpm install
   ```

3. If `pnpm install` prompts about build approvals (pnpm 10+ security feature for native addons):
   ```bash
   pnpm approve-builds
   pnpm install
   ```

4. Commit and push:
   ```bash
   git add pnpm-lock.yaml
   git commit -m "chore: regenerate pnpm lockfile"
   git push
   ```

5. Switch back to the original branch:
   ```bash
   git checkout $ORIGINAL_BRANCH
   ```

6. **Poll CI** — wait for checks to pass, checking every 30 seconds (up to 10 minutes):
   ```bash
   gh pr checks <number> --watch
   ```

7. Once CI passes, approve and merge:
   ```bash
   gh pr review <number> --approve --body "LGTM - lockfile regenerated, CI passing"
   gh pr merge <number> --admin --squash
   ```

## Step 5: Handle conflict / stale PRs

If a PR has merge conflicts and Renovate hasn't auto-rebased:

- Use the GitHub API to trigger a Renovate rebase by updating the PR body to include the rebase checkbox. Fetch current body, prepend the rebase directive, and update:
  ```bash
  # Get current PR body
  BODY=$(gh pr view <number> --json body --jq '.body')
  # Update body with rebase checkbox at the top
  gh pr edit <number> --body $'\n- [x] <!-- rebase-check -->If you want to rebase/retry this PR, check this box\n\n'"$BODY"
  ```

- Tell the user that a rebase was triggered and the PR should be re-checked later.

- If the PR is very old (>30 days with no updates) and has conflicts, close it with a comment:
  ```bash
  gh pr close <number> --comment "Closing stale Renovate PR — will be recreated if dependency is still outdated."
  ```

## Step 6: Flag Workflow PRs

For PRs that modify `.github/workflows/` files:

Tell the user: **"PR #XX modifies workflow files. The `gh` CLI token lacks `workflow` scope, so this PR must be merged manually in the browser."**

Provide the direct URL: `gh pr view <number> --json url --jq '.url'`

## Step 7: Flag Major Bumps

For each major version bump PR, present details to the user:

- PR title and number
- What package and what versions (old → new)
- Link to the changelog if Renovate included one in the PR body
- CI status

Ask the user for each: **merge**, **close**, or **skip** (handle manually later).

If merge: approve and merge as in Step 3.
If close: `gh pr close <number> --comment "Closing — major bump not needed at this time."`
If skip: move on.

## Step 8: Summary

After processing all PRs, present a final summary:

```
## Renovate Triage Complete

- Merged: #82, #84, #85 (safe), #90 (lockfile fixed)
- Flagged for manual merge: #83 (workflow files)
- Awaiting user decision: #86 (major bump)
- Rebase triggered: #88
- Closed (stale): #91
```

## Important Notes

- **Always use `--admin` flag** when merging — branch protection rules require it.
- **Never manually edit lockfiles** — always regenerate with `pnpm install`.
- **Sequential merging** — merge one PR at a time to avoid conflicts cascading.
- **Workflow file limitation** — `gh` token lacks `workflow` scope; these PRs cannot be merged via CLI.
- If you encounter an unexpected error, report it to the user rather than retrying blindly.
