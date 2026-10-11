# Credits

omarchy-mac-kit-extras is MIT (see [LICENSE](LICENSE)), copyright pnshad.

| Project | Licence | How the extras use it | Shipped here? |
|---|---|---|---|
| [Omarchy](https://github.com/basecamp/omarchy) | MIT | a user override replaces its `omarchy-screensaver` command; calls its shell and lock commands; uses its Lua config API | no Omarchy code is copied |
| [hwdeck](https://github.com/pnshad/hwdeck) | MIT | the views on the wall, installed by the `hwdeck` module | no: cloned at a pinned commit |
| [omarchy-mac-kit](https://github.com/pnshad/omarchy-mac-kit) | MIT | the installer library (`lib/`) is a copy of the kit's | yes (same author) |
| [btop](https://github.com/aristocratos/btop) by Aristocratos | Apache-2.0 | hwdeck's `btop` style borrows its look; no code | no |
| [JetBrains Mono](https://github.com/JetBrains/JetBrainsMono) + [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) | OFL-1.1 / MIT | the rain's glyphs (configurable: `OMK_RAIN_FONT`) | no |
| Hyprland · foot · uwsm · jq · systemd | BSD-3 · MIT · MIT · MIT · LGPL-2.1 | runtime tools, called by name | no |

The rain is inspired by the digital rain of *The Matrix* (1999); no assets are used.
