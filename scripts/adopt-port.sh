#!/usr/bin/env bash
# Check a port against the adoption checklist and, with --apply, finish its
# adoption: default branch, description, topics, baseline tag, and the shared
# ruleset. Organization maintainers run it after the repository has been
# transferred into kanagawa-community.
#
# Usage: scripts/adopt-port.sh [--apply] [--app NAME] [--description TEXT] <repo>
#
# Without --apply the script only reports what it would change.
set -euo pipefail

org="kanagawa-community"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apply=false
app=""
description=""
repo=""

usage() {
  echo "usage: $0 [--apply] [--app NAME] [--description TEXT] <repo>" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) apply=true ;;
    --app) app="${2:?--app needs a value}"; shift ;;
    --description) description="${2:?--description needs a value}"; shift ;;
    -*) usage ;;
    *) [[ -z "$repo" ]] || usage; repo="$1" ;;
  esac
  shift
done
[[ -n "$repo" ]] || usage

problems=0
ok()   { printf '  %-8s %s\n' "ok" "$1"; }
warn() { printf '  %-8s %s\n' "warn" "$1"; }
todo() { printf '  %-8s %s\n' "MISSING" "$1"; problems=$((problems + 1)); }
fix() {
  if [[ "$apply" == true ]]; then
    printf '  %-8s %s\n' "done" "$1"
  else
    printf '  %-8s %s\n' "would" "$1"
  fi
}
exists() { gh api "repos/$org/$repo/contents/$1" --silent 2>/dev/null; }

echo "== $org/$repo"

if ! gh api "repos/$org/$repo" --silent 2>/dev/null; then
  echo "$org/$repo not found. Transfer the repository into the organization first." >&2
  exit 1
fi

# Name: the application name in lowercase kebab-case. Renaming changes URLs, so
# this is only reported.
if [[ "$repo" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  ok "name is lowercase kebab-case"
else
  todo "name should be the application name in lowercase kebab-case (gh repo rename)"
fi

# Default branch.
current="$(gh api "repos/$org/$repo" --jq .default_branch)"
if [[ "$current" == "main" ]]; then
  ok "default branch is main"
else
  fix "rename default branch '$current' to main"
  if [[ "$apply" == true ]]; then
    gh api --method POST "repos/$org/$repo/branches/$current/rename" -f new_name=main --silent
    current="main"
  fi
fi

# Description.
existing="$(gh api "repos/$org/$repo" --jq '.description // ""')"
target="$description"
if [[ -z "$target" && -n "$app" ]]; then
  target="Community-maintained Kanagawa theme for $app"
fi
if [[ -n "$target" && "$existing" != "$target" ]]; then
  fix "set description to '$target'"
  if [[ "$apply" == true ]]; then
    gh api --method PATCH "repos/$org/$repo" -f description="$target" --silent
  fi
elif [[ -n "$existing" ]]; then
  ok "description is set"
else
  todo "description is empty (pass --app or --description)"
fi

# Topics.
have="$(gh api "repos/$org/$repo/topics" --jq '.names[]')"
missing=()
for topic in kanagawa theme "$repo"; do
  grep -qxF "$topic" <<<"$have" || missing+=("$topic")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  fix "add topics: ${missing[*]}"
  if [[ "$apply" == true ]]; then
    names="$( { echo "$have"; printf '%s\n' "${missing[@]}"; } | sed '/^$/d' | sort -u | jq -R . | jq -sc '{names: .}')"
    gh api --method PUT "repos/$org/$repo/topics" --input - --silent <<<"$names"
  fi
else
  ok "topics include kanagawa, theme, and $repo"
fi

# Required files.
have_commits=true
for path in README.md LICENSE cog.toml .github/workflows/commits.yml .github/workflows/assign.yml; do
  if exists "$path"; then
    ok "$path"
  else
    todo "$path is missing"
    [[ "$path" == ".github/workflows/commits.yml" ]] && have_commits=false
  fi
done

# Placeholders copied from the template and never replaced.
for path in README.md LICENSE cog.toml; do
  if exists "$path" && gh api "repos/$org/$repo/contents/$path" --jq .content | base64 -d | grep -q '{{'; then
    todo "$path still contains {{placeholders}}"
  fi
done

# Health files come from the organization .github repository.
for name in CODE_OF_CONDUCT.md SUPPORT.md SECURITY.md; do
  for path in "$name" ".github/$name"; do
    if exists "$path"; then
      warn "$path found; the organization-wide file is used instead"
    fi
  done
done

# Baseline tag, so cocogitto has a starting point.
tags="$(gh api "repos/$org/$repo/tags" --jq 'length')"
if [[ "$tags" -gt 0 ]]; then
  ok "tags exist"
else
  fix "create baseline tag 0.1.0 on $current"
  if [[ "$apply" == true ]]; then
    sha="$(gh api "repos/$org/$repo/commits/$current" --jq .sha)"
    gh api --method POST "repos/$org/$repo/git/refs" -f ref=refs/tags/0.1.0 -f sha="$sha" --silent
  fi
fi

# Ruleset and merge settings. The ruleset requires the commit check, so it is
# skipped until the workflow that reports it exists.
if [[ "$have_commits" == true ]]; then
  if [[ "$apply" == true ]]; then
    "$root/rulesets/apply.sh" --apply "$repo"
  else
    "$root/rulesets/apply.sh" "$repo"
  fi
else
  todo "ruleset skipped: add .github/workflows/commits.yml first, or pull requests would wait for a check that never runs"
fi

echo
if [[ "$problems" -gt 0 ]]; then
  echo "$problems item(s) need attention."
  exit 1
fi
echo "Checklist complete."
