#!/usr/bin/env bash
# screensaver: endless digital rain as Omarchy's idle screensaver (plain, with one red glitch long
# after it starts), running inside Omarchy's own screensaver window and timers — no service of its own.
#   Omarchy:         the takeover via the user override dir + the saver window rule
#   plain Hyprland:  nothing to take over; the programs only (`omk-screensaver --demo`)
#   no Hyprland:     the programs only
# Optional, off by default (--with-wall or OMK_WITH_WALL=1): the live hwdeck wall behind the rain
# (omk-deckwall) and the hourly rain pass over it (omk-rainpass + user timer + overlay rule).
#   modules/screensaver/install.sh [--undo] [--with-wall]
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
. "$HERE/../../lib/common.sh"
UNITS=$HOME/.config/systemd/user
with_wall=${OMK_WITH_WALL:-0}
for a in "$@"; do [[ $a == --with-wall ]] && with_wall=1; done

if [[ ${1:-} == --undo ]]; then
  act systemctl --user disable --now omk-rainpass.timer 2>/dev/null || true
  remove "$UNITS/omk-rainpass.timer" "$UNITS/omk-rainpass.service"
  act systemctl --user daemon-reload || true
  remove "$OMK_OVERRIDE_DIR/omarchy-screensaver" "$OMK_OVERRIDE_DIR/omarchy-launch-screensaver" \
         "${XDG_CONFIG_HOME:-$HOME/.config}/omk/screensaver-foot.ini"
  block_remove "$HYPR_DIR/hyprland.lua" rainpass --
  block_remove "$HYPR_DIR/hyprland.conf" rainpass "#"
  block_remove "$HYPR_DIR/hyprland.lua" screensaver --
  block_remove "$HYPR_DIR/hyprland.conf" screensaver "#"
  path_override_remove
  remove "$OMK_BIN/omk-screensaver" "$OMK_BIN/omk-deckwall" "$OMK_BIN/omk-rainpass"
  exit 0
fi

install_file "$HERE/omk-screensaver" "$OMK_BIN/omk-screensaver" 0755
flavour=$(hypr_flavour)
if [[ -z $flavour ]]; then
  say "  no Hyprland config: installed the program only; try: omk-screensaver --demo"
  exit 0
fi
# Omarchy's saver window gets its default 0.985 opacity: the rain's black would show dark grey.
case $flavour in
lua)  block_add "$HYPR_DIR/hyprland.lua" screensaver -- < "$HERE/screensaver.lua" ;;
conf) block_add "$HYPR_DIR/hyprland.conf" screensaver "#" < "$HERE/screensaver.conf" ;;
esac
if is_omarchy && [[ $flavour == lua ]]; then
  ensure_override_dir
  install_file "$HERE/omarchy-screensaver.user-override" "$OMK_OVERRIDE_DIR/omarchy-screensaver" 0755
  path_override_add
  say "  idle → Omarchy opens its screensaver → the rain (omarchy-launch-screensaver force runs it now)"
  say "  glyph size: Omarchy's saver font × OMK_SAVER_FONT_SCALE (1.25); the override reopens the saver terminal with it"
else
  say "  not Omarchy: no idle takeover; omk-screensaver --demo runs the rain in any terminal"
fi

if (( with_wall )); then
  for f in omk-deckwall omk-rainpass; do
    install_file "$HERE/$f" "$OMK_BIN/$f" 0755
  done
  case $flavour in
  lua)  block_add "$HYPR_DIR/hyprland.lua" rainpass -- < "$HERE/rainpass.lua" ;;
  conf) block_add "$HYPR_DIR/hyprland.conf" rainpass "#" < "$HERE/rainpass.conf" ;;
  esac
  install_file "$HERE/omk-rainpass.service" "$UNITS/omk-rainpass.service" 0644
  install_file "$HERE/omk-rainpass.timer" "$UNITS/omk-rainpass.timer" 0644
  act systemctl --user daemon-reload
  act systemctl --user enable --now omk-rainpass.timer
  if is_omarchy && [[ $flavour == lua ]]; then
    # the override hands the idle saver to the wall
    put "$OMK_OVERRIDE_DIR/omarchy-screensaver" 0755 <<'EOF'
#!/usr/bin/env bash
# omarchy-mac-kit-extras: user override, first in the session PATH (~/.local/share/omk/bin), so Omarchy's
# idle service runs omk-screensaver with the live hwdeck wall behind it (--wall). Remove this file
# (or ./install.sh --undo screensaver) to get Omarchy's own screensaver back.
exec "$HOME/.local/bin/omk-screensaver" --wall "$@"
EOF
    [[ -x $OMK_BIN/hwdeck ]] || say "  note: install the hwdeck and wall modules too, or the idle wall has nothing to show"
  fi
  say "  wall on: idle → the rain drains into the live hwdeck wall; hourly rain pass while a view is open"
  say "  try one now: omk-rainpass --force"
  say "  Touch Bar: touchbar-strip shows PROCESSING then REFRESHED after each pass with \"refresh_sign\": true"
fi
