#!/usr/bin/env bash
# Build the showcase and social preview images of a port from its three variant
# renders. Every port ends its preview step with this, so the stacking order and
# the sizes live in one place. See docs/PREVIEWS.md.
#
# Usage: scripts/finish-previews.sh <name> <port-dir>
#   <name> is the application name as it should read, such as "fish" or "Neovim".
#   Reads <port-dir>/assets/screenshots/{wave,dragon,lotus}.png and writes
#   <port-dir>/assets/showcase.png and <port-dir>/assets/social-preview.png.
#
# Requires: what compose-showcase.sh and social-preview.sh require.
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <name> <port-dir>" >&2
  exit 2
fi
name="$1"
assets="$2/assets"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
shots="$assets/screenshots"

bash "$here/compose-showcase.sh" "$shots/lotus.png" "$shots/dragon.png" "$shots/wave.png" "$assets/showcase.png"
bash "$here/social-preview.sh" "$name" "$assets/showcase.png" "$assets/social-preview.png"
