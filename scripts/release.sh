#!/usr/bin/env bash
# Prepare a release pull request for a port. It updates CHANGELOG.md for the new
# version and opens a pull request titled "chore(release): <version>", with a
# commit signed by your own key. When that pull request is merged, the port's
# release workflow tags the merge commit and publishes the GitHub release with the
# changelog section as its notes.
#
# Usage: scripts/release.sh [--apply] [--version X.Y.Z] <repo>
#
# Without --version the next version comes from the conventional commits since
# the latest tag, so the first release of a port needs --version. Without
# --apply the script only shows the version and the new changelog section.
#
# Requires: gh, cog (cocogitto), npx, and git with commit signing set up.
set -euo pipefail

org="kanagawa-community"
apply=false
version=""
repo=""

usage() {
  echo "usage: $0 [--apply] [--version X.Y.Z] <repo>" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) apply=true ;;
    --version) version="${2:?--version needs a value}"; shift ;;
    -*) usage ;;
    *) [[ -z "$repo" ]] || usage; repo="$1" ;;
  esac
  shift
done
[[ -n "$repo" ]] || usage

for tool in gh cog npx git; do
  command -v "$tool" >/dev/null || { echo "$tool is required" >&2; exit 1; }
done
if [[ -n "$version" && ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "version must look like 1.2.3, got '$version'" >&2
  exit 2
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "== $org/$repo"
branch="$(gh api "repos/$org/$repo" --jq .default_branch)"
git clone --quiet --branch "$branch" "https://github.com/$org/$repo.git" "$work/repo"
cd "$work/repo"

if [[ -z "$version" ]]; then
  if [[ -z "$(git tag --list)" ]]; then
    echo "no tags yet: pass --version for the first release" >&2
    exit 1
  fi
  out="$(cog bump --auto --dry-run 2>&1)" || { echo "$out" >&2; exit 1; }
  version="$(printf '%s\n' "$out" | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' | head -n1 || true)"
  if [[ -z "$version" ]]; then
    echo "no commits since the last tag need a new version" >&2
    exit 1
  fi
fi

if git rev-parse -q --verify "refs/tags/$version" >/dev/null; then
  echo "$version is already tagged" >&2
  exit 1
fi
echo "version: $version"

# Tag locally so cog includes the new version in the changelog. The tag is never
# pushed: the release workflow creates it when the pull request is merged.
git -c tag.gpgSign=false tag "$version"
{
  printf '# Changelog\n\n'
  cog changelog | sed 's/^#### /### /'
} >CHANGELOG.md
npx --yes prettier@3.9.10 --write CHANGELOG.md >/dev/null

echo "changelog section:"
awk -v v="$version" '/^## /{ if (found) exit; if (index($0, "[" v "]")) found=1 } found' CHANGELOG.md | sed 's/^/  /'

if [[ "$apply" != true ]]; then
  echo "dry run: pass --apply to open the release pull request"
  exit 0
fi

# Commit with your own signing key and push: the ruleset requires signed commits,
# and commits made through the API with a personal token are not signed.
release_branch="chore/release-$version"
git checkout -q -b "$release_branch"
git add CHANGELOG.md
git commit -q -S -m "chore(release): $version"
git push -q origin "$release_branch"

gh pr create --repo "$org/$repo" --base "$branch" --head "$release_branch" \
  --title "chore(release): $version" \
  --body "Updates CHANGELOG.md for $version. Merging this pull request tags the merge commit and publishes the GitHub release, using the $version section of the changelog as its notes.

Edit CHANGELOG.md on this branch first if an entry needs rewording."
