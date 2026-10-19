# omarchy-mac-kit-extras

Optional extras for [Omarchy](https://github.com/basecamp/omarchy): a wall of live hardware
dashboards, a digital-rain screensaver (optionally handing over to that wall, with an hourly rain pass over
the screen — a pixel refresh for OLED and LCD panels that show the same picture for hours.

None of it is needed for anything else. It works on its own, or next to
[omarchy-mac-kit](https://github.com/pnshad/omarchy-mac-kit) (the Mac parts: Touch Bar, lid,
root helpers). Both use the same `omk` names, so either installer finds and undoes what the
other wrote.

| Module | What you get | Works on |
|---|---|---|
| `hwdeck` | [hwdeck](https://github.com/pnshad/hwdeck): full-screen terminal views of CPU, memory, thermal, network, power, battery (cloned at a pinned commit) | any Linux with a terminal |
| `wall` | those six views as a 3×2 floating grid, no border and no dimming | Hyprland (Lua config: Omarchy 4; a `.conf` twin for classic configs, untested) |
| `screensaver` | idle → endless digital rain inside Omarchy's own screensaver window; one column glitches red long after it starts (10 min, then every 4-10 min). Opt-in `--with-wall` / `OMK_WITH_WALL=1`: the rain drains away to reveal the live hwdeck wall, plus an hourly rain pass over the wall (pixel refresh) that ends on a red column; `omk-screensaver --demo` in any terminal | Omarchy (takeover); any terminal (demo); the wall and the rain pass need Hyprland |

Tested on Omarchy 4.0.4 (MacBookPro14,2). Nothing needs root.

## Install

```bash
git clone https://github.com/pnshad/omarchy-mac-kit-extras
cd omarchy-mac-kit-extras
less install.sh modules/*/install.sh   # they are short; read before you run
./install.sh --dry-run                  # what every module would do here; changes nothing
./install.sh                            # suggests modules for this machine, asks
./install.sh hwdeck wall screensaver    # or name them
./install.sh --undo screensaver         # reverse one
```

Installed by an older omarchy-mac-kit (its `wall` / `screensaver` modules)? This installer owns
them now: `./install.sh --undo wall` / `--undo screensaver` here removes the same files and
blocks (omarchy-mac-kit's own `--undo` for them still works too).

`hwdeck` is cloned and checked out at a pinned commit, verified after the clone
(`OMK_HWDECK_TAG` picks a release tag, which must point at the pinned commit). A checkout next to
this one is offered instead (default No: it is not checked against the pin).

## With a Touch Bar

[touchbar-strip](https://github.com/pnshad/touchbar-strip) (T1 MacBook Pros) can show a red
PROCESSING then a green REFRESHED after each rain pass: set `"refresh_sign": true` in its
config. Its `lock-rain` action (a short rain, then lock) uses this repo's `omk-rainpass`.

## Where things go

- programs: `~/.local/bin/omk-screensaver` (+ `omk-deckwall`, `omk-rainpass` with `--with-wall`), `~/.local/bin/hwdeck`
- Omarchy override: `~/.local/share/omk/bin/omarchy-screensaver` (first in Hyprland's PATH via a
  marked block, shared with omarchy-mac-kit)
- Hyprland: marked blocks `omk:hwdeck-grid`, `omk:screensaver`, `omk:rainpass` (wall only) (and `omk:path-override`) appended to
  `~/.config/hypr/hyprland.lua`; a backup is kept as `hyprland.lua.omk-backup`
- user units (only with `--with-wall`): `omk-rainpass.service` + `omk-rainpass.timer` (hourly; the pass runs only while an
  hwdeck view is open and the panel is on)

## Gotchas

- **Omarchy forces its own bin dir first in Hyprland's PATH**, so the screensaver override only
  wins from a user dir prepended at the end of `hyprland.lua` (the `path-override` block). Keep
  `~/.local/share/omk/bin` yours and not writable by anyone else: it runs ahead of Omarchy.
- **Omarchy's default window opacity (0.985 / 0.96) makes black look dark grey.** The rain windows
  get `opacity = "1.0 override 1.0 override"`. In foot, true black needs 24-bit colour; pass
  `-o colors-dark.background=000000` (foot 1.28 rejects a `[colors]` section on the command line).
- **`pkill -f` / `pgrep -f` over ssh match their own command line**: use `'[o]rg.omarchy.screensaver'`.

## Licence

MIT. See [CREDITS.md](CREDITS.md).
