# dwl

## Subsystem ownership

| Module | Responsibility |
| --- | --- |
| `config` | Initial tracked copy of the upstream configuration |
| `keys` | Shared bindings, modifier key, application and script commands |
| `bar` | Rendering on all outputs, fonts, padding, status input and markup, bar bindings |
| `theme` | Root, bar and border color defaults and macros |
| `layout` | Layout algorithms, cycling, default master ratio and dedicated bindings |
| `rules` | Application matching and floating window geometry |
| `input` | Keyboard, mouse, touchpad, cursor size and primary-selection input policy |
| `tablet` | Tablet protocol, output mapping and pointer emulation |
| `focus` | Focus policy and focus after moving clients between outputs |
| `tags` | Tag scrolling under the pointer and its axis bindings |
| `border` | Focused, unfocused and fullscreen border widths |

## Packaging

dwl uses a standalone Nix derivation with wlroots 0.20 and optional XWayland
support. Queue checks always compile with XWayland enabled. `configHeader` is
injected through `CPPFLAGS -include`; keep this packaging separate from
slstatus. Home Manager options are under `wayland.windowManager.dwl`.

## Configuration and behavior

The Home Manager module installs `wayland.windowManager.dwl.finalPackage`.
`package` selects the base derivation; `finalPackage` is that package with
`settings` and `xwayland.enable` applied. XWayland is enabled by default. The
caller supplies the login entry, session lifecycle and status producer, and uses
`systemd.variables` to import session variables into systemd and D-Bus.

`settings` accepts `SDWL_*` macro names. Booleans become `0` or `1`, numbers are
emitted as C literals, strings are quoted, and `{ raw = "..."; }` supplies a
single-line C expression or initializer list. Empty settings use `config.h`
defaults. All settings enter through one generated `host.h`, passed with
`CPPFLAGS -include`. For direct package builds, `configHeader` accepts C header
text, a Nix path to a header, or a derivation that produces one.

`SDWL_TOUCHPAD_SCROLL_FACTOR` defaults to `1.0` and scales finger scrolling only.
Mouse wheel events keep their original delta. Display layouts can be applied by
startup commands using a Wayland output management client.

By default, focused windows have a white border 2 logical pixels wide.
Unfocused windows have no visible border. `SDWL_BORDERPX` and
`SDWL_UNFOCUSED_BORDERPX` set the visible border widths for focused and
unfocused windows (defaults: `2` and `0`). Windows reserve the larger width in
both states so focus changes leave the content size and position unchanged.
With the defaults, unfocused windows retain a transparent margin 2 logical
pixels wide. Fullscreen windows have no border or reserved margin.
`SDWL_SEL_BORDER`, `SDWL_NORM_BORDER` and `SDWL_URG_BORDER` set the border
colors. Urgent windows also have no border when unfocused with the default
widths.

The default tiled layout gives two tiled windows equal widths on each output.
With more windows, the master area occupies half the width and the stack shares
the other half. `Super+H` and `Super+L` adjust this ratio for the selected output.
`Super+Shift+H` sets it to 50%. `Super+I` increases the number of windows
assigned to the master area; `Super+D` decreases it.

`Super+M` cycles through Tile (`[]=`), Monocle (`[M]`) and Deck (`[D]`) on the
selected output. `Super+F` toggles fullscreen for the focused window;
`Super+Shift+F` toggles floating. `Super+A` moves the focused tiled window to
the front of the tiling order. If it is already first, the next tiled window
takes its place.

`Super+J` and `Super+K` select the next or previous window. `Super+,` and
`Super+.` select the adjacent output. `Super+Shift+,` and `Super+Shift+.` move
the focused window to that output and keep keyboard focus on it.

`Super+1` through `Super+9` select tags. Adding Ctrl toggles a tag in the view;
adding Shift assigns the focused window to that tag; adding both toggles the
window's membership. `Super+Tab` returns to the previous tag view. `Super+0`
views all tags, and `Super+Shift+0` assigns the focused window to all tags.

`Super+left mouse button` drags a window, and `Super+right mouse button` resizes
it. Both operations make the window floating.

`Super+mouse wheel up` switches to the previous tag; `Super+mouse wheel down`
switches to the next on the output under the pointer. Tags wrap at either end,
including empty tags. If multiple tags are selected, the whole selection moves
by one tag.

## Status bar

`Super+B` shows or hides the bar on the selected output. Left-clicking a tag
selects it; right-clicking toggles it in the view. With Super held, left-clicking
assigns the focused window to the tag, and right-clicking toggles its membership.

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
`^bg()` restore `SDWL_NORM_FG` and `SDWL_NORM_BG`, respectively. Invalid markers
appear as ordinary text. Markup applies only to status text and does not
contribute to its width or click area.

```text
^fg(ffc66d)23^fg(3181a7)41^fg()
```

`SDWL_FONT` selects the primary font, which defaults to `Noto Sans:size=14`.
`SDWL_FONT_FALLBACKS` is a comma-separated list of C strings, supplied through
the Home Manager module's `raw` interface. Its defaults are Noto Sans CJK SC,
Symbols Nerd Font and Noto Color Emoji, all at `size=14`.

`SDWL_BAR_HPAD` sets the padding on each side of tags, layout symbols and window
titles. `SDWL_STATUS_RPAD` sets the status text's right padding. Both default to
2 logical pixels and follow the output scale. Bar height follows the font.

## Tablet configuration

`SDWL_TABLET_RULES` is a comma-separated list of `{ "device", "output" }` pairs.
Rules match the exact input device name. The full tablet area maps to the named
output. If no rule matches, or the named output is absent from the layout, the
tablet maps to the whole layout. The compositor sends pen pressure and tilt
through tablet-v2 and emulates pointer input for clients without tablet support.
Tablet pad shortcuts can use keyboard events through input-remapper.

This implementation adapts the community
[tablet-input patch](https://codeberg.org/dwl/dwl-patches/src/branch/main/patches/tablet-input)
to dwl 0.9 and wlroots 0.20.

## Desktop tools

`Super+Return` opens a Foot client. `Super+Shift+Return` opens one with the
`dropdown-foot` app ID. `Super+Space` opens fuzzel.

`Super+Shift+L` locks with swaylock. `Super+Ctrl+Shift+L` runs
`$SCRIPT_HOME/dwl/dwl_lock.sh` to lock and turn off the displays.

`Super+Shift+A` runs `$SCRIPT_HOME/util/screenshot.sh`;
`Super+Ctrl+Shift+A` runs it with `-o`.
`Super+Shift+V` runs `$SCRIPT_HOME/util/clipboard_history.sh`, and `Super+Z`
launches shmooz. `SCRIPT_HOME` defaults to `$HOME/scripts`. The caller supplies
these scripts and applications.

`Super+Shift+C` closes the focused window, and `Super+Shift+Q` exits dwl.
`Super+Ctrl+F1` through `Super+Ctrl+F12` select Linux virtual terminals.
Dedicated keys adjust volume and display brightness or toggle speaker and
microphone mute.

Windows with app IDs `swayimg-pin` and `satty` open as floating windows.
