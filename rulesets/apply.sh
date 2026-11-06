#!/usr/bin/env bash
# Apply the shared main-branch ruleset and merge settings to repositories.
#
# Usage: rulesets/apply.sh [--apply] <repo>...
#   <repo> is a name inside kanagawa-community, such as "neovim" or ".github".
#
# Without --apply the script only prints what it would change.
set -euo pipefail

org="kanagawa-community"
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
apply=false

if [[ "${1:-}" == "--apply" ]]; then
  apply=true
  shift
fi

if [[ $# -eq 0 ]]; then
  echo "usage: $0 [--apply] <repo>..." >&2
  exit 2
fi

for repo in "$@"; do
  echo "== $org/$repo"

  # Update the existing ruleset, or create it. A ruleset still named "master"
  # from before the default branch rename is replaced in place so its old
  # bypass actors do not survive next to the new ruleset.
  id="$(gh api "repos/$org/$repo/rulesets" --jq '.[] | select(.name == "main" or .name == "master") | .id' | head -n1)"
  if [[ -n "$id" ]]; then
    method="PUT"
    endpoint="repos/$org/$repo/rulesets/$id"
    echo "ruleset: replace existing ruleset $id with 'main'"
  else
    method="POST"
    endpoint="repos/$org/$repo/rulesets"
    echo "ruleset: create 'main'"
  fi

  echo "settings: rebase merge only, delete merged branches"

  if [[ "$apply" == true ]]; then
    gh api --method "$method" "$endpoint" --input "$dir/main.json" --silent
    gh api --method PATCH "repos/$org/$repo" \
      -F allow_rebase_merge=true \
      -F allow_squash_merge=false \
      -F allow_merge_commit=false \
      -F delete_branch_on_merge=true \
      --silent
    echo "applied"
  else
    echo "dry run: pass --apply to make these changes"
  fi
done
