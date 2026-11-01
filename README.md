# spreadless

`spreadless` is my personal repack of software from the suckless ecosystem.
It brings together the patches and defaults I use in my own setup.

For now, I only maintain two programs:

- **dwl**: a tiling Wayland compositor.
- **slstatus**: a small program that supplies system information to the status bar.

Both are packaged with Nix and have Home Manager modules, so you can build them
and configure `config.h` from your Nix configuration.

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
    fonts = [
      "Noto Sans:size=14"
      "Noto Sans CJK SC:size=14"
      "Symbols Nerd Font:size=14"
      "Noto Color Emoji:size=14"
    ];
    touchpad.scrollFactor = 0.35;
    modkey = "WLR_MODIFIER_LOGO";
    binds = {
      "MODKEY, XKB_KEY_Return" = ''spawn, {.v = (const char*[]){ "footclient", NULL }}'';
      "MODKEY, XKB_KEY_space" = ''spawn, {.v = (const char*[]){ "fuzzel", NULL }}'';
      "MODKEY, XKB_KEY_b" = "togglebar, {0}";
      "MODKEY, XKB_KEY_j" = "focusstack, {.i = +1}";
      "MODKEY, XKB_KEY_k" = "focusstack, {.i = -1}";
      "MODKEY, XKB_KEY_m" = "cyclelayout, {0}";
      "MODKEY, XKB_KEY_f" = "togglefullscreen, {0}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_f" = "togglefloating, {0}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_c" = "killclient, {0}";
      "MODKEY|WLR_MODIFIER_SHIFT, XKB_KEY_q" = "quit, {0}";
    };
  };

  programs.slstatus = {
    enable = true;
    interval = 9000;
    tempColors.normal = "6a9955";
    components = [
      { function = "cpu_perc"; format = "%s"; }
      { function = "cpu_temp"; format = "%s"; }
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

Each module renders a complete `config.h` at evaluation time and copies it into
the source tree before building. Direct package overrides accept `settings` or a
complete `config.h` through `conf`.

The [dwl reference](skills/spreadless/references/dwl.md) describes layouts,
bindings, borders, the status bar and tablet support. The
[slstatus reference](skills/spreadless/references/slstatus.md) describes native
battery and temperature components. slstatus writes newline-delimited text with
`-s`; dwl reads status lines from standard input and supports its barcolors markup.

## Repository layout

| Path | Responsibility |
| --- | --- |
| `upstream/dwl/`, `upstream/slstatus/` | Read-only upstream submodules pinned to dwl 0.9 and slstatus 1.1 |
| `patches/dwl/`, `patches/slstatus/` | Grouped `NN-group/NN-name.patch` capability queues |
| `nix/packages/` | Package builds and program-specific dependencies |
| `nix/home-manager/` | Independent configuration modules and their combined import |
| `nix/lib/` | Ordered patch discovery and `config.h` generators |
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
# Update the owning patch commit and fold fixups.
spreadless-queue dwl verify
spreadless-queue dwl export
spreadless-queue dwl clean
```

Use `slstatus` in place of `dwl` for the other queue. Each command acts on the
selected program; both worktrees may be open at once. `--repo PATH` selects a
repository when running from elsewhere.

Each program's queue is organized into contiguous functional groups
(`NN-group/`), with cohesive capability patches (`NN-name.patch`) inside each
group. Fold changes into the owning patch commit; add a new patch within the
appropriate group for a distinct mechanism, extension or bug fix after its
dependencies. Keep related code, declarations and `config.def.h` defaults
together. Do not track `config.h` in Git; Nix renders `config.h` at build time.

Commit subjects use `group/name: English summary` without a commit-type prefix.
Export derives paths such as `01-bar/01-status-bar.patch` from the `group/name`
scope. Both `group` and `name` start with a letter, use one or two lowercase
words separated by a hyphen, may include digits and contain at most 24
characters. Export rejects invalid or duplicate scopes and non-contiguous groups
before replacing patches.

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
