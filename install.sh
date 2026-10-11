#!/usr/bin/env bash
# omarchy-mac-kit-extras installer: optional eye candy and a display pixel refresh for Omarchy.
#
#   ./install.sh                     menu: what this machine has, then pick modules
#   ./install.sh MODULE...           install those modules
#   ./install.sh --dry-run [MODULE...]   show what would happen (all modules when none given);
#                                    changes nothing and asks for nothing
#   ./install.sh --undo MODULE       reverse one module (also one the old omarchy-mac-kit
#                                    wall/screensaver modules installed: same files and blocks)
#   ./install.sh --list              the modules and what they need
#
# Everything runs as you; nothing here needs root. Read a module's install.sh before running
# it: they are short. No curl | bash anywhere. Works with or without omarchy-mac-kit.
set -euo pipefail
KIT=$(cd "$(dirname "$0")" && pwd)
. "$KIT/lib/common.sh"

MODULES="hwdeck wall screensaver"
what() {
  case $1 in
  hwdeck) echo "terminal hardware dashboards (any Linux); the wall and screensaver show them" ;;
  wall) echo "the hwdeck views as a 3x2 floating grid, no border or dimming (Hyprland)" ;;
  screensaver) echo "digital-rain screensaver + live hwdeck wall + hourly rain pass / pixel refresh (Omarchy; rain anywhere)" ;;
  esac
}
known() { [[ " $MODULES " == *" $1 "* ]]; }

detect() {
  local omarchy=no flavour
  is_omarchy && omarchy=yes
  flavour=$(hypr_flavour); flavour=${flavour:-none}
  say "This machine: $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "unknown ($(uname -s))")"
  say "  Omarchy: $omarchy · Hyprland config: $flavour"
  SUGGEST=" hwdeck"
  [[ $flavour != none ]] && SUGGEST+=" wall screensaver"
  return 0
}

list() {
  local m
  say "Modules (all run as you):"
  for m in $MODULES; do printf '  %-12s %s\n' "$m" "$(what "$m")"; done
}

run_module() {   # run_module MODULE [args...]
  local m=$1; shift
  known "$m" || die "unknown module: $m (./install.sh --list)"
  say ""
  say "== $m: $(what "$m")"
  OMK_DRY_RUN=$OMK_DRY_RUN bash "$KIT/modules/$m/install.sh" "$@"
}

undo=""; picks=()
while (( $# )); do
  case $1 in
  --dry-run) OMK_DRY_RUN=1; export OMK_DRY_RUN ;;
  --undo) undo=${2:-}; [[ -n $undo ]] || die "--undo needs a module"; shift ;;
  --list) list; exit 0 ;;
  -h|--help) sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  -*) die "unknown option $1" ;;
  *) picks+=("$1") ;;
  esac
  shift
done

if [[ -n $undo ]]; then
  run_module "$undo" --undo
  exit 0
fi

detect
if (( ${#picks[@]} == 0 )); then
  if dry; then
    say "Dry run of every module (nothing changes):"
    # shellcheck disable=SC2206
    picks=($MODULES)
  else
    say ""
    list
    say ""
    say "Suggested for this machine:${SUGGEST:- none}"
    read -r -p "Modules to install (space-separated, empty = suggested): " line
    # shellcheck disable=SC2206
    picks=(${line:-$SUGGEST})
  fi
fi
for m in "${picks[@]}"; do run_module "$m"; done
say ""
dry && say "Dry run: nothing was changed." || say "Done. Undo any module with: ./install.sh --undo <module>"
