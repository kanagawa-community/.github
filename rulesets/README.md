# Repository rulesets

`main.json` is the ruleset every Kanagawa repository uses for its default
branch. `apply.sh` applies it. The organization is on the free plan, which has
no organization-wide rulesets, so each repository gets its own copy.

## What it enforces

- Changes reach the default branch only through a pull request. There are no
  bypass actors, so maintainers follow the same path.
- Rebase and merge is the only merge method, so history stays linear and each
  commit lands on `main` as written.
- Commits must be signed. Branch deletion, force pushes, and merge commits are
  blocked.
- The `conventional-commits / check` status check must pass. It runs
  [`check-commits.yml`](../.github/workflows/check-commits.yml), which verifies
  every commit the pull request adds with [cocogitto](https://docs.cocogitto.io/).

## Open question: signatures on rebase merges

A web rebase merge creates new commits, so the author's signatures do not carry
over. Whether GitHub signs the new commits, which `required_signatures` needs,
is not confirmed. Test it on a throwaway repository before applying this ruleset
anywhere. If GitHub does not sign them, the rebase button stays unavailable, and
the options are squash merging or dropping `required_signatures`.

## History before conventional commits

The check reads only the commits a pull request introduces. Older history,
such as the Neovim port's commits from before this rule, is never read, so it
needs no bypass and no rewrite.

## Applying it

```sh
rulesets/apply.sh neovim .github           # dry run
rulesets/apply.sh --apply neovim .github   # make the changes
```

The script also sets the repository to rebase merge only and to delete merged
branches. If a repository still has a ruleset named `master`, it is replaced in
place.

New ports start from the [template repository](https://github.com/kanagawa-community/template).
Rulesets are not copied with a template repository, so run the script for each
new port.

## After the first pull request

The required check name, `conventional-commits / check`, is the caller job id
followed by the job name in the reusable workflow. Confirm it matches the name
GitHub shows on a pull request before relying on it. A mismatch leaves pull
requests waiting for a check that never reports.
