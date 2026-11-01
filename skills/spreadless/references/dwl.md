# dwl

## Patch ownership

| Group | Patch | Responsibility |
| --- | --- | --- |
| `01-bar` | `bar/status-bar` | Per-output bar rendering (`drwl.h`), fonts, padding, click targets and bounded newline status reader |
| `01-bar` | `bar/barcolors` | Status text `^fg(RRGGBB)` and `^bg(RRGGBB)` color markup |
| `01-bar` | `bar/usable-area` | Bar geometry refresh before arranging layers and client usable areas |
| `01-bar` | `bar/scene-cleanup` | Scene output teardown before destroying monitor layers and bar buffers |
| `02-window` | `window/deck-layout` | Deck (`[D]`) layout and 50% default master ratio |
| `02-window` | `window/cycle-layout` | Layout cycling across non-null layouts |
| `02-window` | `window/float-rules` | Application matching and monitor-relative floating window geometry |
| `02-window` | `window/focus` | Focus policy (`sloppyfocus = 0`) and focus retention when moving clients across outputs |
| `02-window` | `window/border` | Focused, unfocused and fullscreen border widths with fixed client content size |
| `03-input` | `input/numlock` | NumLock activation on keyboard initialization |
| `03-input` | `input/pointer-config` | Separate touchpad and mouse libinput natural-scrolling and acceleration settings |
| `03-input` | `input/scroll-factor` | Touchpad finger scroll delta scaling (`touchpad_scroll_factor`) |
| `03-input` | `input/primary-selection` | Primary-selection toggle (`enable_primary_selection`) |
| `03-input` | `input/cursor-size` | Configurable XCursor size (`cursor_size`) |
| `03-input` | `input/tablet` | Tablet-v2 pen input, pointer emulation, cursor shapes and `TabletRule` output mapping |
| `04-monitor` | `monitor/restore-monitor` | Window output ownership and restoration of tags and floating geometry after output reconnection |
| `04-monitor` | `monitor/cascade-restore` | Preservation of original output ownership and saved geometry across cascading disconnections |
| `04-monitor` | `monitor/output-move` | Floating and saved window geometry offset updates when an active output moves in the layout |

Feature patches touch `dwl.c` and declare minimal defaults in `config.def.h` so
every commit in the queue compiles standalone. `config.h` is not tracked in Git.

## Packaging

dwl uses a standalone Nix derivation with wlroots 0.20 and optional XWayland
support. Queue checks always compile with XWayland enabled. `nix/lib/dwl-config.nix`
renders a complete `config.h` copied into the source tree during `preBuild`.
Home Manager options are under `wayland.windowManager.dwl`.

## Configuration and behavior

The Home Manager module installs `wayland.windowManager.dwl.finalPackage`.
`package` selects the base derivation; `finalPackage` is that package with the
generated `config.h` and `xwayland.enable` applied. XWayland is enabled by
default. The caller supplies the login entry, session lifecycle and status
producer, and uses `systemd.variables` to import session variables into systemd
and D-Bus.

`nix/lib/dwl-config.nix` defines options for all `config.h` fields:
- Appearance and bar: `sloppyfocus`, `bypassSurfaceVisibility`, `borderpx`,
  `unfocusedBorderpx`, `snap`, `cursorSize`, `enablePrimarySelection`, `showbar`,
  `topbar`, `barHpad`, `statusRpad`, `fonts`, `rootcolor`, `fullscreenBg`,
  `colors.{norm,sel,urg}.{fg,bg,border}`, `tags` and `logLevel`.
- Window, layout and monitor rules: `rules` (matching `appId` and `title`,
  with `tags`, `isFloating`, `monitor`, `floatW`, `floatH` and `floatY`),
  `layouts` and `monrules`.
- Input devices: `xkbRules`, `repeatRate`, `repeatDelay`, `numlockOn`,
  `touchpad` (`scrollFactor`, `tapToClick`, `tapAndDrag`, `dragLock`,
  `naturalScrolling`, `disableWhileTyping`, `leftHanded`,
  `middleButtonEmulation`, `scrollMethod`, `clickMethod`, `sendEventsMode`,
  `accelProfile`, `accelSpeed` and `buttonMap`), `mouse` (`naturalScrolling`,
  `accelProfile` and `accelSpeed`) and `tabletRules` (`{ name, output }` pairs).
- Bindings: `modkey`, `binds`, `buttons` and `axes`.

`binds` maps `"mod, keysym"` attribute names (for example,
`"MODKEY, XKB_KEY_Return"` or `"0, XKB_KEY_XF86AudioMute"`) to `"func, arg"` C
initializers (such as `''spawn, SHCMD("fuzzel")''` or `"focusstack, {.i = +1}"`),
emitting `{ ${key}, ${action} },` entries in `keys[]`. `buttons` takes
`"mod, button, func, arg, click"` strings for `buttons[]`, and `axes` takes
`"mod, dir, func, arg"` strings for `axes[]` (or emits `{0},` when empty). Direct
package overrides accept `settings` or a complete `config.h` through `conf`.

## Output reconnection

Windows remember their output by connector name, such as `DP-1`. If an output
disconnects, its windows move to an available output and return when the original
output is enabled again. Windows keep their tags, and the output's selected tag
view is restored. Floating windows retain their size and position relative to the
output as output profiles move it. Keyboard and mouse moves update the window's
remembered output.

This implementation adapts the community
[restore-monitor patch](https://codeberg.org/dwl/dwl-patches/src/branch/main/patches/restore-monitor)
by Eldar Yusupov and 6z7y to dwl 0.9 and wlroots 0.20.

## Status bar

The caller sends newline-delimited status text to standard input, for example
with `slstatus -s`. Every output shows the latest complete line. Each
line can contain up to 1023 bytes, including markup but excluding the newline.
Overlong lines are discarded and the previous status is preserved.
The startup command receives no status information; it starts with standard
input closed.

The bar supports the community
[barcolors syntax](https://codeberg.org/dwl/dwl-patches/src/branch/main/patches/barcolors)
by Kerberoge. `^fg(RRGGBB)` sets the foreground and `^bg(RRGGBB)` sets the
background. Colors use six hexadecimal digits without a `#` prefix. `^fg()` and
`^bg()` restore `colors.norm.fg` and `colors.norm.bg`, respectively. Invalid
markers appear as ordinary text. Markup applies only to status text and does not
contribute to its width or click area.

```text
^fg(ffc66d)23^fg(3181a7)41^fg()
```

## Tablet configuration

`tabletRules` is a list of `{ name, output }` mappings. Rules match the exact
input device name. The full tablet area maps to the named output. If no rule
matches, or the named output is absent from the layout, the tablet maps to the
whole layout. The compositor sends pen pressure and tilt through tablet-v2 and
emulates pointer input for clients without tablet support. Tablet pad shortcuts
can use keyboard events through input-remapper.

This implementation adapts the community
[tablet-input patch](https://codeberg.org/dwl/dwl-patches/src/branch/main/patches/tablet-input)
to dwl 0.9 and wlroots 0.20.
