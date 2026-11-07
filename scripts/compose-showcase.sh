#!/usr/bin/env bash
# Stack the three variant renders of a port into one showcase image: Lotus at the
# back, Dragon in the middle and Wave in front. Each window sits a fifth of its
# width to the right and a quarter of its height below the one behind it, on a
# transparent background. The output has no timestamp, so the same inputs always
# give the same file. See docs/PREVIEWS.md.
#
# Usage: scripts/compose-showcase.sh <lotus.png> <dragon.png> <wave.png> <output.png>
#
# Requires: magick (ImageMagick). The three images must be the same size.
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "usage: $0 <lotus.png> <dragon.png> <wave.png> <output.png>" >&2
  exit 2
fi
lotus="$1"
dragon="$2"
wave="$3"
output="$4"

command -v magick >/dev/null || { echo "magick is required" >&2; exit 1; }
for file in "$lotus" "$dragon" "$wave"; do
  [[ -f "$file" ]] || { echo "$file not found" >&2; exit 1; }
done

size="$(magick identify -format '%wx%h' "$wave")"
for file in "$lotus" "$dragon"; do
  [[ "$(magick identify -format '%wx%h' "$file")" == "$size" ]] || {
    echo "$file is not $size like $wave" >&2
    exit 1
  }
done

w="${size%x*}"
h="${size#*x}"
dx=$((w / 5))
dy=$((h / 4))
magick -size "$((w + 2 * dx))x$((h + 2 * dy))" xc:none \
  "$lotus" -geometry +0+0 -composite \
  "$dragon" -geometry "+${dx}+${dy}" -composite \
  "$wave" -geometry "+$((2 * dx))+$((2 * dy))" -composite \
  -strip -define png:exclude-chunk=tIME \
  "$output"
