{
  description = "dwl and slstatus maintained as subsystem patch queues";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    naw = {
      url = "github:SpreadZhao/NAW";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      naw,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
      mkQueue =
        pkgs:
        pkgs.writeShellApplication {
          name = "spreadless-queue";
          runtimeInputs = with pkgs; [
            coreutils
            git
            gnumake
          ];
          text = builtins.readFile ./scripts/spreadless-queue;
        };
      workspace = naw.lib.mkWorkspace {
        inherit systems;
        skills.spreadless = ./skills/spreadless;
        targets = [
          "agents"
          "claude"
        ];
        instructions = ''
          # spreadless development

          Use the `spreadless` skill for patch queues, feature changes, configuration,
          and upstream upgrades. Read the reference for the selected program.

          - `upstream/dwl/` and `upstream/slstatus/` are read-only Git submodules. Advance
            their revisions only for an upstream upgrade. Author patches in
            `.worktree/PROGRAM/` and export to `patches/PROGRAM/`.
          - Maintain one patch per subsystem within each program. Fold changes into the
            owning patch; add a patch only for a new subsystem, after its dependencies.
            Keep related code and configuration together. The dwl `keys` patch owns all
            keyboard, mouse-button and scroll bindings, modifier keys and spawn commands.
            Apply it last, after the patches that define the binding functions.
          - `0001-config.patch` only initializes tracked `config.h`. Keep `config.def.h`
            unchanged throughout each series. Every commit must compile.
          - Subjects use `type(module): English summary`. Export names use the scope:
            `NNNN-module.patch`. Names start with a letter and contain one or two
            lowercase words, with digits allowed, and at most 24 characters.
          - Edit workspace instructions in `flake.nix` and skill sources in `skills/`.
            NAW generates `AGENTS.md`, `CLAUDE.md` and installed skill links.
          - Write repository documentation, comments, help text and commits in English.
          - Remove each temporary worktree with `spreadless-queue PROGRAM clean`.

          ## Nix Switch Policy

          - For any Nix-related work in this repository, never execute `switch`; the user performs that step manually.
          - This includes `nixos-rebuild switch`, `home-manager switch`, `nh os switch`, `nh home switch`, and any wrapper or update script that invokes `switch`, including through its default arguments.
          - Evaluation, builds, formatting, and other checks that do not activate the configuration are allowed. When a switch is needed, provide the command for the user to run instead of executing it.
          - Requests to change, update, fix, or rebuild Nix configuration do not authorize an automatic switch. This repository-wide rule takes precedence over any skill or workflow that recommends running `switch`.
          - Never execute activation scripts.

          ## Clean Delivery Policy

          - Deliver only the files, dependencies, configuration, and behavior needed for the requested result. Before finishing, actively review the working tree and clean up this task's temporary tests, fixtures, validation reports, logs, caches, intermediate outputs, and debug code or settings. Do not leave cleanup for the user.
          - Testing during development is encouraged, but temporary unit tests and other verification scripts belong outside the repository and must be removed after use. Keep tests in the delivered project only when the user explicitly asks to retain them. Remove test-only helpers, command-line options, and documentation references as well.
          - Prefer temporary, isolated environments such as `nix shell` or `nix develop` for tools needed only for testing. Remove packages and dependencies added solely for development, testing, or debugging from persistent configuration and profiles when they are not needed by the delivered result.
          - Stop temporary processes and services, undo temporary environment or configuration changes, and remove temporary files created for this task, including those outside the repository. Preserve anything that is part of the requested result.
          - Limit cleanup to changes and resources introduced by this task. Preserve the user's existing tools, data, tests, and unrelated modifications. Do not delete shared Nix Store contents or run broad garbage collection as a cleanup shortcut.
          - Cleanup must respect the Nix Switch Policy. If removing a live dependency or other temporary state requires a prohibited action, prepare the configuration change, report exactly what remains, and provide the manual command; do not execute `switch` or claim cleanup is complete.

          ## Final writing review

          After completing the work and checks, launch a separate writing-review agent.
          Ask it to read https://github.com/weijt606/anti-vibe-writing, including SKILL.md,
          the English patterns reference and final-pass checklist. Use its default clean
          style to review task-related documentation, comments, help text and prompts.
          The reviewer must not launch another reviewer. Preserve behavior, identifiers,
          commands, paths and license notices. Review its diff, rerun affected checks and
          finish cleanup before replying.
        '';
        packages =
          pkgs: with pkgs; [
            (mkQueue pkgs)
            clang-tools
            deadnix
            fcft
            git
            gnumake
            libdrm
            libinput
            libx11
            libxcb
            libxcb-wm
            libxkbcommon
            nixfmt
            pixman
            pkg-config
            ripgrep
            shellcheck
            shfmt
            statix
            tllist
            wayland
            wayland-protocols
            wayland-scanner
            wlroots_0_20
            xwayland
          ];
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          spread-dwl = pkgs.callPackage ./nix/packages/dwl.nix { };
          spread-slstatus = pkgs.callPackage ./nix/packages/slstatus.nix { };
          spreadless-queue = mkQueue pkgs;
        }
      );

      apps = forAllSystems (system: {
        spread-dwl = {
          type = "app";
          program = "${self.packages.${system}.spread-dwl}/bin/dwl";
          meta.description = "Run the customized dwl compositor";
        };
        spread-slstatus = {
          type = "app";
          program = "${self.packages.${system}.spread-slstatus}/bin/slstatus";
          meta.description = "Run slstatus with the maintained patch queue";
        };
      });

      homeManagerModules = {
        default = import ./nix/home-manager;
        dwl = import ./nix/home-manager/dwl.nix;
        slstatus = import ./nix/home-manager/slstatus.nix;
      };

      overlays.default = final: _: {
        spread-dwl = final.callPackage ./nix/packages/dwl.nix { };
        spread-slstatus = final.callPackage ./nix/packages/slstatus.nix { };
      };

      inherit (workspace) devShells;
      checks = forAllSystems (system: {
        inherit (self.packages.${system}) spread-dwl spread-slstatus spreadless-queue;
        inherit (workspace.checks.${system}) workspace;
      });
      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
