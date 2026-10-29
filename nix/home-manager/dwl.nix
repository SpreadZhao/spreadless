{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wayland.windowManager.dwl;
  cSettings = import ../lib/c-settings.nix { inherit lib; };
  header = cSettings.renderHeader cfg.settings;
in
{
  options.wayland.windowManager.dwl = {
    enable = lib.mkEnableOption "dwl";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../packages/dwl.nix { };
      description = "Base dwl package configured by this module.";
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf cSettings.valueType;
      default = { };
      example = {
        SDWL_FONT = "Noto Sans:size=14";
        SDWL_BAR_HPAD = 2;
        SDWL_STATUS_RPAD = 2;
        SDWL_TOUCHPAD_SCROLL_FACTOR = 0.35;
      };
      description = ''
        Compile-time `SDWL_*` macros supplied through one generated `host.h`.
        Booleans become `0` or `1`, numbers are C literals, and strings are quoted.
        Use `{ raw = "..."; }` for a single-line C expression or initializer list
        without quoting.
      '';
    };
    xwayland.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Build dwl with XWayland support.";
    };
    systemd.variables = lib.mkOption {
      type = lib.types.listOf (lib.types.strMatching "[A-Za-z_][A-Za-z0-9_]*");
      default = [
        "WAYLAND_DISPLAY"
        "DISPLAY"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "XDG_SESSION_DESKTOP"
        "PATH"
      ];
      description = "Environment variable names for the caller's session launcher to import into systemd and D-Bus.";
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = cfg.package.override {
        configHeader = header;
        enableXWayland = cfg.xwayland.enable;
      };
      description = "dwl package with the configured macros and XWayland setting.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.all (name: builtins.match "SDWL_[A-Z0-9_]+" name != null) (
          builtins.attrNames cfg.settings
        );
        message = "dwl settings must use SDWL_* macro names.";
      }
    ];
    home.packages = [ cfg.finalPackage ];
  };
}
