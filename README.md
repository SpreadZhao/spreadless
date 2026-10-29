# spreadless

`spreadless` is my personal repack of software from the suckless ecosystem.
It brings together the patches and defaults I use in my own setup.

For now, I only maintain two programs:

- **dwl**: a tiling Wayland compositor.
- **slstatus**: a small program that supplies system information to the status bar.

Both are packaged with Nix and have Home Manager modules, so you can build them
and adjust their settings from your Nix configuration.

## Build

```sh
git clone --recurse-submodules https://github.com/SpreadZhao/spreadless.git
cd spreadless
nix build .#spread-dwl .#spread-slstatus
```

The package and executable names are:

| Package | Executable |
| --- | --- |
| `spread-dwl` | `dwl` |
| `spread-slstatus` | `slstatus` |
| `spreadless-queue` | `spreadless-queue` |

Run either program with `nix run .#spread-dwl` or
`nix run .#spread-slstatus -- -s`. The caller supplies the graphical session,
status pipeline and external applications.

## Home Manager

Add one flake input, including its upstream submodules:

```nix
inputs.spreadless = {
  url = "git+https://github.com/SpreadZhao/spreadless?submodules=1";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Pass `inputs` through Home Manager's `extraSpecialArgs`, then configure the
programs independently:

```nix
{ inputs, ... }: {
  imports = [ inputs.spreadless.homeManagerModules.default ];

  wayland.windowManager.dwl = {
    enable = true;
    settings = {
      SDWL_FONT = "Noto Sans:size=14";
      SDWL_BAR_HPAD = 2;
      SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
    };
  };

  programs.slstatus = {
    enable = true;
    interval = 9000;
    settings.SLSTATUS_TEMP_COLOR_NORMAL = "6a9955";
    components = [
      { function = "cpu_perc"; format = "%s"; }
      { function = "cpu_temp"; format = "%s"; }
      { function = "network_icon"; format = "%s"; argument = "eth0"; }
      { function = "battery_icon"; format = "%s"; argument = "BAT0"; }
      { function = "datetime"; format = "%s"; argument = "%H:%M"; }
    ];
  };
}
```

`homeManagerModules.dwl` and `homeManagerModules.slstatus` are available for
individual imports. Importing a module leaves its program disabled until its
`enable` option is set. `overlays.default` provides `pkgs.spread-dwl` and
`pkgs.spread-slstatus`.

Use `wayland.windowManager.dwl.finalPackage` and
`programs.slstatus.finalPackage` in the caller's session launcher. XWayland is
enabled by default and can be disabled with
`wayland.windowManager.dwl.xwayland.enable = false`.

Settings accept booleans, numbers, strings and `{ raw = "..."; }` C expressions
or initializer lists. Each package receives one generated `host.h`. Direct
package overrides support `configHeader`; slstatus also accepts a complete
configuration through `conf`.

The [dwl reference](skills/spreadless/references/dwl.md) describes layouts,
bindings, borders, the status bar and tablet support. The
[slstatus reference](skills/spreadless/references/slstatus.md) describes native
battery, temperature and network components. slstatus writes newline-delimited
text with `-s`; dwl reads status lines from standard input and supports its
barcolors markup.

## Repository layout

| Path | Responsibility |
| --- | --- |
| `upstream/dwl/`, `upstream/slstatus/` | Read-only upstream submodules pinned to dwl 0.9 and slstatus 1.1 |
| `patches/dwl/`, `patches/slstatus/` | Independently numbered subsystem patch queues |
| `nix/packages/` | Package builds and program-specific dependencies |
| `nix/home-manager/` | Independent configuration modules and their combined import |
| `nix/lib/` | Ordered patch discovery and C settings serialization |
| `scripts/spreadless-queue` | Shared Git queue operations |
| `scripts/build/` | Program-specific queue compilation checks |
| `skills/spreadless/` | Maintenance rules and program references |
| `.worktree/dwl/`, `.worktree/slstatus/` | Temporary, ignored queue worktrees |

## Maintenance

Enter the shared development shell:

```sh
nix develop "path:$PWD"
spreadless-queue dwl checkout
spreadless-queue dwl status
spreadless-queue dwl build
# Update the owning subsystem commit and fold fixups.
spreadless-queue dwl verify
spreadless-queue dwl export
spreadless-queue dwl clean
```

Use `slstatus` in place of `dwl` for the other queue. Each command acts on the
selected program; both worktrees may be open at once. `--repo PATH` selects a
repository when running from elsewhere.

Each subsystem has one patch. Fold fixes, extensions and configuration changes
into its existing commit. Keep related code, declarations, configuration and
dedicated bindings together. Add a patch only for a new subsystem, after its
dependencies. Each queue starts with `0001-config.patch`, which initializes
tracked `config.h`; `config.def.h` remains unchanged.

Commit subjects use `type(module): English summary`. Export derives short names
such as `0003-bar.patch` from the module scope. Names start with a letter, use
one or two lowercase words separated by a hyphen, may include digits and contain
at most 24 characters. Export rejects invalid or duplicate scopes before
replacing patches.

The [spreadless skill](skills/spreadless/SKILL.md) documents fixup, autosquash,
upstream upgrades and cleanup. Edit workspace instructions in `flake.nix` and
skill sources in `skills/`; NAW generates `AGENTS.md`, `CLAUDE.md` and installed
skill links.

```sh
nix build --no-link .#spread-dwl .#spread-slstatus
nix flake check
```

Keep temporary validation scripts and fixtures outside the repository, and
remove them after use. Retain tests only when explicitly requested. Never run
Nix switch commands or activation scripts from the maintenance workflow.

Upstream sources retain their license notices. Community patch credits and
source links remain in patch headers and the program references.
