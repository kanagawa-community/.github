#!/usr/bin/env bash
# The terminal session from docs/PREVIEWS.md, run inside a real terminal window
# by capture-windows.sh: the 16 colors and a listing of the port, each after the
# shared prompt. It shows no shell highlighting, so it suits any terminal.
#
# Usage: session.sh <directory> <variant>
cd "$1" || exit 1
variant=$2
prompt() {
  printf '\e[32mkanagawa\e[0m@\e[34m%s\e[0m \e[33m%s\e[0m\n\xe2\x9d\xaf ' "$variant" "~${PWD#"$HOME"}"
}
for cmd in 'fastfetch -l none -s colors' 'eza -alF --icons --group-directories-first --no-user'; do
  prompt
  printf '%s\n' "$cmd"
  eval "$cmd"
done
prompt
sleep 600
