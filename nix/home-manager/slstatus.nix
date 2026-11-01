{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.slstatus;
  slstatusConfig = import ../lib/slstatus-config.nix { inherit lib; };
in
{
  options.programs.slstatus = {
    enable = lib.mkEnableOption "slstatus";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../packages/slstatus.nix { };
      description = "Base slstatus package configured by this module.";
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = cfg.package.override {
        conf = slstatusConfig.renderConfig {
          inherit (cfg)
            interval
            unknownStr
            maxLen
            tempColors
            components
            ;
        };
      };
      description = "slstatus package built with the generated config.h.";
    };
  }
  // slstatusConfig.options;

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.components != [ ];
        message = "slstatus requires at least one component.";
      }
    ];
    home.packages = [ cfg.finalPackage ];
  };
}
