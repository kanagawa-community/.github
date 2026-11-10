#!/usr/bin/env bash
# Put a window frame around a screenshot of a real application window: a title
# bar with three buttons and the title, rounded corners, a thin edge and a
# shadow, in the style of the frames that termframe draws for the terminal
# ports. The screenshot is changed in place. With an empty title there is no
# title bar, for windows that draw their own. See docs/PREVIEWS.md.
#
# Usage: scripts/frame-window.sh <screenshot.png> <title> <light|dark>
#
# Requires: magick (ImageMagick), and a sans-serif font that fontconfig finds.
set -euo pipefail

if [[ $# -ne 3 || ! $3 =~ ^(light|dark)$ ]]; then
  echo "usage: $0 <screenshot.png> <title> <light|dark>" >&2
  exit 2
fi
shot="$1"
title="$2"
command -v magick >/dev/null || { echo "magick is required" >&2; exit 1; }
[[ -f "$shot" ]] || { echo "$shot not found" >&2; exit 1; }

# The same colors as the termframe frames.
if [[ $3 == light ]]; then
  bar="#eef0f1" text="#4d4d4d" edge="#00000040"
else
  bar="#383837" text="#c0c0c0" edge="#00000080"
fi
w="$(magick identify -format '%w' "$shot")"
h="$(magick identify -format '%h' "$shot")"
bar_h=28
radius=10
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Title bar with the buttons and the title, then the screenshot below it.
if [[ -z $title ]]; then
  bar_h=0
  cp "$shot" "$work/window.png"
else
  magick -size "${w}x${bar_h}" "xc:$bar" \
    -fill "#ff5f56" -draw "circle 20,14 26,14" \
    -fill "#ffbd2e" -draw "circle 40,14 46,14" \
    -fill "#27c93f" -draw "circle 60,14 66,14" \
    -fill "$text" -font "$(fc-match -f '%{file}' 'sans:bold')" -pointsize 13 \
    -gravity center -annotate +0+0 "$title" "$work/bar.png"
  magick "$work/bar.png" "$shot" -append "$work/window.png"
fi
# Round the corners, draw the edge, and add the shadow on a transparent margin.
magick -size "${w}x$((h + bar_h))" xc:none -fill white \
  -draw "roundrectangle 0,0 $((w - 1)),$((h + bar_h - 1)) $radius,$radius" "$work/mask.png"
magick "$work/window.png" "$work/mask.png" -alpha off -compose CopyOpacity -composite \
  -fill none -stroke "$edge" -strokewidth 1 \
  -draw "roundrectangle 0,0 $((w - 1)),$((h + bar_h - 1)) $radius,$radius" "$work/rounded.png"
magick "$work/rounded.png" \( +clone -background black -shadow 40x12+0+6 \) +swap \
  -background none -layers merge +repage -bordercolor none -border 20 "$shot"
