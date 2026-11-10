#!/usr/bin/env bash
# Take the preview screenshots of a port from real application windows. The
# application runs in a headless sway (Wayland) or in a rootful Xwayland inside
# it (X11), so no window opens on your screen. grim or ImageMagick captures it,
# frame-window.sh draws the window frame, and finish-previews.sh builds the
# showcase and social preview. See docs/PREVIEWS.md.
#
# Usage: scripts/capture-windows.sh [port-dir]   (default: the current directory)
#
# The port commits only scripts/window.sh, which this script sources. It sets:
#   name      the application name as it should read, used as the frame title
#   frame     "bar" (default): title bar and frame; "plain": frame without a title
#             bar, for windows that draw their own; "none": no frame, for whole
#             desktops such as a window manager
#   x11       "yes" for X11 applications, which run in Xwayland
#   size      "WIDTHxHEIGHT" of the window; "listing" (default) fits a terminal
#             that runs the shared session
#   wait      seconds to wait before the capture (default 5)
# and defines launch <variant>, which prints the command that starts the window.
# Optional: setup and cleanup run once; capture <variant> <png> replaces the
# whole capture, for ports that need more than one window. These are available:
#   $root $work $here   the port, a scratch folder, this folder
#   $demo               a copy of the port with one timestamp, for listings
#   $session            the command that runs session.sh in $demo: append the variant
#   $font               the shared terminal font
#   start_sway <config> start a headless sway with extra config lines, sets $socket
#   stop_display        stop sway and Xwayland
#
# Requires: sway, grim, magick, rsync, fontconfig, the FiraCode Nerd Font Mono
# font, Xwayland for X11 ports, and what the port's windows need.
set -euo pipefail

if [[ $# -gt 1 ]]; then
  echo "usage: $0 [port-dir]" >&2
  exit 2
fi
root="$(cd "${1:-.}" && pwd)"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run on its own, the script has none of the files it needs beside it. Fetch
# them and run again, as render-previews.sh does.
if [[ ! -f "$here/finish-previews.sh" ]]; then
  command -v git >/dev/null || { echo "git is required" >&2; exit 1; }
  bootstrap="$(mktemp -d)"
  trap 'rm -rf "$bootstrap"' EXIT
  git clone --quiet --depth 1 "${KANAGAWA_GITHUB_URL:-https://github.com/kanagawa-community/.github}" "$bootstrap"
  KANAGAWA_BOOTSTRAP="$bootstrap" exec bash "$bootstrap/scripts/capture-windows.sh" "$root"
fi
[[ -f "$root/scripts/window.sh" ]] || { echo "$root/scripts/window.sh not found" >&2; exit 1; }
for tool in sway grim magick rsync fc-match; do
  command -v "$tool" >/dev/null || { echo "$tool is required" >&2; exit 1; }
done
font="FiraCode Nerd Font Mono"
[[ $(fc-match -f '%{family}' "$font") == *"$font"* ]] || { echo "font not installed: $font" >&2; exit 1; }

work="$(mktemp -d)"
pids=()
stop_display() {
  if [[ ${#pids[@]} -gt 0 ]]; then
    kill "${pids[@]}" 2>/dev/null || true
    wait "${pids[@]}" 2>/dev/null || true
  fi
  pids=()
}
trap 'declare -F cleanup >/dev/null && cleanup; stop_display; rm -rf "$work" ${KANAGAWA_BOOTSTRAP:+"$KANAGAWA_BOOTSTRAP"}' EXIT

# The listing shows the port's own files, copied into a fixed home directory
# with one timestamp, so only the file names and sizes change between renders.
demo="$work/home/kanagawa-community/$(basename "$root")"
mkdir -p "$demo"
rsync -a --exclude=.git --filter=":- .gitignore" "$root"/ "$demo"/
mkdir -p "$demo/.git"
find "$demo" -exec touch -h -d '2026-11-07 11:13' {} +
session="env HOME=$work/home USER=kanagawa LC_ALL=C.UTF-8 LESS= LESSOPEN= bash $here/session.sh $demo"

# Start a headless sway with the given extra config lines, and set $socket.
start_sway() {
  printf 'output HEADLESS-1 resolution %s\ndefault_border none\n%s\n' "$resolution" "$1" >"$work/sway.conf"
  local before
  before=$(ls "$XDG_RUNTIME_DIR")
  env -u WAYLAND_DISPLAY -u DISPLAY WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 \
    WLR_RENDERER=pixman XDG_CONFIG_HOME="$work/config" sway -c "$work/sway.conf" >"$work/sway.log" 2>&1 &
  pids+=($!)
  socket=""
  for _ in $(seq 50); do
    sleep 0.2
    socket=$(comm -13 <(echo "$before") <(ls "$XDG_RUNTIME_DIR") | grep -m1 -E '^wayland-[0-9]+$' || true)
    [[ -n $socket ]] && break
  done
  [[ -n $socket ]] || { echo "sway did not start; see its log:" >&2; cat "$work/sway.log" >&2; exit 1; }
}

# shellcheck source=/dev/null
source "$root/scripts/window.sh"
frame=${frame:-bar}
size=${size:-listing}
if [[ $size == listing ]]; then
  # One row per entry, plus the prompts, the padding and a tab or title bar.
  resolution="960x$((($(ls -A "$demo" | wc -l) + 12) * 19))"
else
  resolution=$size
fi

# The default capture: one window that fills the output.
if ! declare -F capture >/dev/null; then
  capture() {
    if [[ ${x11:-} == yes ]]; then
      command -v Xwayland >/dev/null || { echo "Xwayland is required" >&2; exit 1; }
      start_sway ""
      local display=:$((RANDOM % 100 + 100))
      # -noreset keeps the X resource database after xrdb disconnects.
      WAYLAND_DISPLAY=$socket Xwayland "$display" -noreset -geometry "$resolution" >/dev/null 2>&1 &
      pids+=($!)
      sleep 1.5
      DISPLAY=$display WAYLAND_DISPLAY='' bash -c "$(launch "$1")" >/dev/null 2>&1 &
      pids+=($!)
      sleep "${wait:-5}"
      DISPLAY=$display import -window root -crop "$resolution+0+0" +repage "$2"
    else
      start_sway "exec $(launch "$1")"
      sleep "${wait:-5}"
      WAYLAND_DISPLAY=$socket grim "$2"
    fi
    stop_display
  }
fi

mkdir -p "$root/assets/screenshots"
if declare -F setup >/dev/null; then setup; fi
for variant in wave dragon lotus; do
  shot="$root/assets/screenshots/$variant.png"
  capture "$variant" "$shot"
  mode=dark
  if grep -q "\"$variant\"" <(python3 -I -c 'import json,sys; v=json.load(open(sys.argv[1]))["variants"]; print([k for k in v if v[k]["appearance"]=="light"])' "$here/../palette.json"); then mode=light; fi
  case $frame in
    bar) bash "$here/frame-window.sh" "$shot" "$name" "$mode" ;;
    plain) bash "$here/frame-window.sh" "$shot" "" "$mode" ;;
    none) ;;
    *) echo "unknown frame: $frame" >&2; exit 1 ;;
  esac
done

bash "$here/finish-previews.sh" "$name" "$root"
