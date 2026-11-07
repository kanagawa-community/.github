#!/usr/bin/env bash
# Render the social preview image of a port: the logo, "Kanagawa for <name>", the
# variant names and the showcase image, on the Wave background. GitHub shows it
# when the repository link is shared. See docs/PREVIEWS.md.
#
# Usage: scripts/social-preview.sh <name> <showcase.png> <output.png>
#   <name> is the application name as it should read, such as "fish" or "Neovim".
#
# The image is 1280x640, GitHub's recommended size. Everything stays inside the
# 80px border GitHub may crop (40pt on each side). Upload it by hand under
# Settings > General > Social preview in the port's repository.
#
# Requires: rsvg-convert, magick (ImageMagick), python3.
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 <name> <showcase.png> <output.png>" >&2
  exit 2
fi
name="$1"
showcase="$2"
output="$3"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
for tool in rsvg-convert magick python3; do
  command -v "$tool" >/dev/null || { echo "$tool is required" >&2; exit 1; }
done
[[ -f "$showcase" ]] || { echo "$showcase not found" >&2; exit 1; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# Colors come from the Wave variant of the shared palette.
python3 - "$root/palette.json" "$name" "$showcase" "$root/assets/branding/logo.png" >"$work/preview.svg" <<'PY'
import base64, json, sys
from xml.sax.saxutils import escape

palette, name, showcase, logo = sys.argv[1:5]
colors = json.load(open(palette))["variants"]["wave"]["colors"]
role = {use: c["hex"] for c in colors.values() for use in c["usage"]}
bg, fg, accent, muted = role["ui.bg"], role["ui.fg"], role["syn.fun"], role["syn.comment"]

def data_uri(path):
    return "data:image/png;base64," + base64.b64encode(open(path, "rb").read()).decode()

print(f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1280" height="640" viewBox="0 0 1280 640">
  <rect width="1280" height="640" fill="{bg}"/>
  <image href="{data_uri(logo)}" x="80" y="80" width="160" height="160"/>
  <g font-family="FiraCode Nerd Font" font-weight="bold" font-size="60">
    <text x="80" y="340" fill="{fg}">Kanagawa</text>
    <text x="80" y="410" fill="{accent}">for {escape(name)}</text>
  </g>
  <text x="80" y="470" font-family="FiraCode Nerd Font" font-size="26" fill="{muted}">Wave · Dragon · Lotus</text>
  <image href="{data_uri(showcase)}" x="520" y="80" width="680" height="480"/>
</svg>''')
PY

# Fewer colors keep the file under GitHub's 1 MB limit without visible banding.
rsvg-convert "$work/preview.svg" -o "$work/preview.png"
magick "$work/preview.png" -strip -define png:exclude-chunk=tIME -colors 256 "$output"

size="$(stat -c %s "$output")"
echo "$output: 1280x640, $size bytes"
if ((size > 1000000)); then
  echo "warning: larger than GitHub's 1 MB limit for social previews" >&2
fi
