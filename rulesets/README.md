# Repository rulesets

`main.json` is the ruleset every Kanagawa repository uses for its default
branch. `apply.sh` applies it. The organization is on the free plan, which has
no organization-wide rulesets, so each repository gets its own copy.

## What it enforces

- Changes reach the default branch only through a pull request. There are no
  bypass actors, so maintainers follow the same path.
- A merge commit is the only merge method. The commits in a pull request land
  on `main` unchanged, so their signatures are kept, and GitHub signs the merge
  commit it creates.
- Commits must be signed. Branch deletion and force pushes are blocked.
- Three status checks must pass before a pull request can be merged. Only GitHub
  Actions can report them, so another app cannot post a status with the same
  name.
  - `conventional-commits / check` runs
    [`check-commits.yml`](../.github/workflows/check-commits.yml), which verifies
    every commit the pull request adds with [cocogitto](https://docs.cocogitto.io/).
  - `files / format` and `files / lint` run
    [`check-files.yml`](../.github/workflows/check-files.yml), which checks
    formatting and lints Markdown, JSON, TOML, YAML, and workflows.

## Why merge commits

Squash and rebase merges create new commits on GitHub, and GitHub does not sign
rebased commits. Rebasing the commits of a signed pull request left every one of
them unsigned on `main`, so rebase merging cannot be combined with required
signatures. A merge commit keeps the original commits, so it can. The ruleset
leaves out linear history, because that rule forbids merge commits.

Cocogitto ignores merge commits (`ignore_merge_commits = true` in `cog.toml`),
so their default messages do not need to be conventional. Releases and
changelogs come from the commits inside each pull request.

## History before conventional commits

The check reads only the commits a pull request introduces. Older history,
such as the Neovim port's commits from before this rule, is never read, so it
needs no bypass and no rewrite.

## Applying it

```sh
rulesets/apply.sh neovim .github           # dry run
rulesets/apply.sh --apply neovim .github   # make the changes
```

The script also sets the repository to allow merge commits only, to use the pull
request title as the merge commit title, and to delete merged branches. If a repository still has a ruleset named `master`, it is replaced in
place.

Rulesets are not copied with a template repository. Organization maintainers
apply them when a port is adopted, and
[`scripts/adopt-port.sh`](../scripts/adopt-port.sh) runs this script as one of
its steps.

## Tests added by a port

A port that adds its own tests can require them without touching this ruleset.
Rulesets add up, so a second ruleset on that repository that requires the new
check applies alongside the shared one.

## After the first pull request

Each required check name is the caller job id followed by the job name in the
reusable workflow. `conventional-commits / check` is confirmed. Confirm that
`files / format` and `files / lint` match the names GitHub shows on a pull
request before applying the ruleset. A mismatch leaves pull
requests waiting for a check that never reports.

Also confirm that the first merge commit made on the web shows as Verified.
The ruleset needs GitHub to sign it.
