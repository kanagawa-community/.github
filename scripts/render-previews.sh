#!/usr/bin/env bash
# Render the preview images of a terminal port: assets/screenshots/<variant>.png,
# then assets/showcase.png and assets/social-preview.png. See docs/PREVIEWS.md.
#
# Usage: scripts/render-previews.sh [port-dir]
#   From a port, without a checkout of this repository:
#   bash <(curl -fsSL https://raw.githubusercontent.com/kanagawa-community/.github/main/scripts/render-previews.sh)
#   port-dir defaults to the current directory.
#
# The port describes only how to produce its output, in <port-dir>/scripts/preview.sh,
# which this script sources. It sets:
#   name             the application name as it should read, such as "fish"
#   capture VARIANT OUT
#                    write the colored output for one variant to the file OUT
#   setup            optional, runs once before the first capture
#   cleanup          optional, runs on exit
# They can use $root (the port), $work (a temporary directory) and $here (this
# directory). Everything else lives here: termframe turns each capture into an
# SVG with a theme built from the palette, rsvg-convert makes the PNG, and
# finish-previews.sh builds the showcase and the social preview.
#
# Requires: termframe, rsvg-convert, magick, python3, fontconfig, the FiraCode
# Nerd Font, and whatever the port's capture needs.
set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [port-dir]" >&2
  exit 2
fi
root="$(cd "${1:-.}" && pwd)"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run on its own, for example with bash <(curl -fsSL .../render-previews.sh), the
# script has none of the files it needs beside it. Fetch them and run again.
if [[ ! -f "$here/finish-previews.sh" ]]; then
  command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
  bootstrap="$(mktemp -d)"
  trap 'rm -rf "$bootstrap"' EXIT # exec below drops it once the clone succeeded
  git clone --quiet --depth 1 "${KANAGAWA_GITHUB_URL:-https://github.com/kanagawa-community/.github}" "$bootstrap"
  KANAGAWA_BOOTSTRAP="$bootstrap" exec bash "$bootstrap/scripts/render-previews.sh" "$root"
fi
[[ -f "$root/scripts/preview.sh" ]] || { echo "$root/scripts/preview.sh not found" >&2; exit 1; }
for tool in termframe rsvg-convert magick python3 fc-match; do
  command -v "$tool" >/dev/null || { echo "$tool is required" >&2; exit 1; }
done

work="$(mktemp -d)"
trap 'declare -F cleanup >/dev/null && cleanup; rm -rf "$work" ${KANAGAWA_BOOTSTRAP:+"$KANAGAWA_BOOTSTRAP"}' EXIT

# shellcheck source=/dev/null
source "$root/scripts/preview.sh"

# The config names the font but ships no [[fonts]] entry for it, so termframe
# would fall back to generic metrics and the glyphs would drift apart.
cp "$here/../config/termframe.toml" "$work/termframe.toml"
font=$(sed -n 's/^family = \["\([^"]*\)".*/\1/p' "$work/termframe.toml")
# fc-match never fails: for a missing font it returns another one.
[[ $(fc-match -f '%{family}' "$font") == *"$font"* ]] || { echo "font not installed: $font" >&2; exit 1; }
cat >>"$work/termframe.toml" <<EOF

[[fonts]]
family = "$font"
license = { type = "SIL Open Font License 1.1", link = "https://github.com/ryanoasis/nerd-fonts/blob/master/LICENSE" }
files = ["$(fc-match -f '%{file}' "$font:weight=regular")", "$(fc-match -f '%{file}' "$font:weight=bold")"]
EOF

mkdir -p "$root/assets/screenshots" "$work/tf/termframe/themes"
if declare -F setup >/dev/null; then setup; fi

for variant in wave dragon lotus; do
  theme="$work/tf/termframe/themes/kanagawa-$variant.toml"
  python3 -I "$here/termframe-theme.py" "$here/../palette.json" "$variant" >"$theme"
  mode=dark
  if grep -q '"light"' "$theme"; then mode=light; fi
  capture "$variant" "$work/$variant.raw"
  # Drop trailing blank lines, then size the window to the output.
  sed -e :a -e '/^[[:space:]]*$/{$d;N;ba' -e '}' "$work/$variant.raw" >"$work/$variant.ansi"
  [[ -s "$work/$variant.ansi" ]] || { echo "capture gave no output for $variant" >&2; exit 1; }
  cols=$(python3 -I -c 'import re,sys; print(max(len(re.sub(r"\x1b\[[0-9;]*m","",l.rstrip("\n").rstrip())) for l in open(sys.argv[1])))' "$work/$variant.ansi")
  rows=$(wc -l <"$work/$variant.ansi")
  XDG_CONFIG_HOME="$work/tf" termframe --config "$work/termframe.toml" \
    --theme "kanagawa-$variant" --mode "$mode" --title "$(basename "$root")" \
    --width "$cols" --height "$((rows + 1))" --timeout 20 \
    --output "$work/$variant.svg" -- cat "$work/$variant.ansi"
  rsvg-convert --zoom 2 "$work/$variant.svg" -o "$root/assets/screenshots/$variant.png"
done

bash "$here/finish-previews.sh" "$name" "$root"
