{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.wayland.windowManager.dwl;
  dwlConfig = import ../lib/dwl-config.nix { inherit lib; };
in
{
  options.wayland.windowManager.dwl = {
    enable = lib.mkEnableOption "dwl";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../packages/dwl.nix { };
      description = "Base dwl package configured by this module.";
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
        enableXWayland = cfg.xwayland.enable;
        conf = dwlConfig.renderConfig {
          inherit (cfg)
            sloppyfocus
            bypassSurfaceVisibility
            borderpx
            unfocusedBorderpx
            snap
            cursorSize
            enablePrimarySelection
            showbar
            topbar
            barHpad
            statusRpad
            fonts
            rootcolor
            fullscreenBg
            colors
            tags
            logLevel
            rules
            layouts
            monrules
            xkbRules
            repeatRate
            repeatDelay
            numlockOn
            touchpad
            mouse
            tabletRules
            modkey
            binds
            buttons
            axes
            ;
        };
      };
      description = "dwl package built with the generated config.h and XWayland setting.";
    };
  }
  // dwlConfig.options;

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.finalPackage ];
  };
}
