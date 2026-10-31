# slstatus

## Patch ownership

| Group | Patch | Responsibility |
| --- | --- | --- |
| `01-config` | `config/init` | Initial tracked copy of the upstream configuration |
| `01-config` | `config/defaults` | Refresh interval, unknown-value text and output length defaults |
| `02-battery` | `battery/state-buffer` | Power supply status buffer size fix for 12-character state strings |
| `02-battery` | `battery/battery-icon` | Battery percentage and state icon component (`battery_icon`) |
| `03-temperature` | `temperature/cpu-temp` | CPU sensor discovery, caching, temperature icons and threshold colors (`cpu_temp`) |

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
- `cpu_temp` accepts a sensor path, such as
  `/sys/class/hwmon/hwmon0/temp1_input`. With `null` in Home Manager or `NULL`
  in C, it finds the first readable `temp1_input` from `coretemp`, `k10temp`,
  `zenpower` or `cpu_thermal`. It caches that path and repeats discovery on the
  next refresh after a failed reading. It rounds to the nearest degree before
  choosing the thermometer icon and color, then emits barcolors markup. The
  color changes at 60°C and 80°C. Set `SLSTATUS_TEMP_COLOR_NORMAL`,
  `SLSTATUS_TEMP_COLOR_WARNING` and `SLSTATUS_TEMP_COLOR_CRITICAL` to six-digit
  hexadecimal strings.

For direct package configuration, `conf` accepts full `config.h` contents or a
file. `configHeader` accepts header contents or a file containing `SLSTATUS_*`
definitions. The Home Manager `settings` option generates that header. Booleans
become `0` or `1`, numbers are emitted as written, strings are quoted, and
`{ raw = "..."; }` supplies a C expression.

The battery icons adapt the community [icons patch](https://tools.suckless.org/slstatus/patches/icons/)
by sewn. The series also includes the upstream
[battery state buffer fix](https://git.suckless.org/slstatus/commit/98769dfed7266b5a9959162e03bee1ddfaf5ecb4.html).
Upstream's ISC license and notices remain in `upstream/slstatus/LICENSE`.
