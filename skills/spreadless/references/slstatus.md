# slstatus

## Patch ownership

| Group | Patch | Responsibility |
| --- | --- | --- |
| `01-battery` | `battery/state-buffer` | Power supply status buffer size fix for 12-character state strings |
| `01-battery` | `battery/battery-icon` | Battery percentage and state icon component (`battery_icon`) |
| `02-temperature` | `temperature/cpu-temp` | CPU sensor discovery, caching, temperature icons and threshold colors (`cpu_temp`) |

## Packaging

slstatus uses the Nixpkgs build definition through `override` and `overrideAttrs`.
`nix/lib/slstatus-config.nix` renders a complete `config.h` copied into the
source tree during `preBuild`. Home Manager options are under
`programs.slstatus`. The unconfigured package displays the upstream
date-and-time component and refreshes every second.

## Configuration and behavior

- `battery_icon` takes a battery device name. It prints the percentage followed
  by a state icon: a charging or discharging level, full battery, not charging,
  or unknown state. Missing or invalid readings use `unknownStr` (`n/a` by
  default).
- `cpu_temp` accepts a sensor path, such as
  `/sys/class/hwmon/hwmon0/temp1_input`. With `null` in Home Manager or `NULL`
  in C, it finds the first readable `temp1_input` from `coretemp`, `k10temp`,
  `zenpower` or `cpu_thermal`. It caches that path and repeats discovery on the
  next refresh after a failed reading. It rounds to the nearest degree before
  choosing the thermometer icon and color, then emits barcolors markup. The
  color changes at 60°C and 80°C using `tempColors.{normal,warning,critical}`
  (`temp_colors[3]` in `config.h`).

For direct package configuration, `settings` accepts `interval`, `unknownStr`,
`maxLen`, `tempColors` and `components`, and `conf` accepts full `config.h`
contents or a file. The Home Manager module renders `config.h` from these
options and passes it through `conf`.

The battery icons adapt the community [icons patch](https://tools.suckless.org/slstatus/patches/icons/)
by sewn. The series also includes the upstream
[battery state buffer fix](https://git.suckless.org/slstatus/commit/98769dfed7266b5a9959162e03bee1ddfaf5ecb4.html).
Upstream's ISC license and notices remain in `upstream/slstatus/LICENSE`.
