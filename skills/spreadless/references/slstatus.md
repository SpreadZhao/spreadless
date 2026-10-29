# slstatus

## Subsystem ownership

| Module | Responsibility |
| --- | --- |
| `config` | Initial tracked copy of the upstream configuration |
| `output` | Refresh interval, unknown-value text and output length |
| `battery` | Battery state parsing, percentage and state icons |
| `temperature` | CPU sensor discovery, temperature icons and colors |
| `network` | Default-route discovery and interface icons |

## Packaging

slstatus uses the Nixpkgs build definition through `override` and `overrideAttrs`.
`conf` replaces the build copy of `config.h`; `configHeader` enters through
`NIX_CFLAGS_COMPILE` because upstream `config.mk` defines `CPPFLAGS`. Home Manager
options are under `programs.slstatus`. The unconfigured package displays the
upstream date-and-time component and refreshes every nine seconds.

## Configuration and behavior

- `battery_icon` takes a battery device name. It prints the percentage followed
  by a state icon: a charging or discharging level, full battery, not charging,
  or unknown state. Missing or invalid readings use the configured text for
  unknown values (`-` with the Home Manager module).
- `cpu_temp` takes no argument (`null` in Home Manager, `NULL` in C). It scans
  hwmon for `coretemp`, `k10temp`, `zenpower` or `cpu_thermal` and reads the first
  readable `temp1_input`. It rounds to the nearest degree before choosing the
  thermometer icon and color, then emits barcolors markup. The color changes
  at 60°C and 80°C. Set `SLSTATUS_TEMP_COLOR_NORMAL`, `SLSTATUS_TEMP_COLOR_WARNING`
  and `SLSTATUS_TEMP_COLOR_CRITICAL` to six-digit hexadecimal strings.
- `network_icon` takes no argument. It uses the first main-table IPv4 default
  route, then tries IPv6 if no interface was found. A wireless sysfs entry selects
  the Wi-Fi icon; other interfaces use the wired icon. If neither route yields
  an interface, it uses the disconnected icon.

For direct package configuration, `conf` accepts full `config.h` contents or a
file. `configHeader` accepts header contents or a file containing `SLSTATUS_*`
definitions. The Home Manager `settings` option generates that header. Booleans
become `0` or `1`, numbers are emitted as written, strings are quoted, and
`{ raw = "..."; }` supplies a C expression.

The battery icons adapt the community [icons patch](https://tools.suckless.org/slstatus/patches/icons/)
by sewn. The series also includes the upstream
[battery state buffer fix](https://git.suckless.org/slstatus/commit/98769dfed7266b5a9959162e03bee1ddfaf5ecb4.html).
Upstream's ISC license and notices remain in `upstream/slstatus/LICENSE`.
