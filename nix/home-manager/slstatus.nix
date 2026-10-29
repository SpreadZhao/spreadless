{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.slstatus;
  cSettings = import ../lib/c-settings.nix { inherit lib; };
  header = cSettings.renderHeader cfg.settings;
  conf = ''
    const unsigned int interval = ${toString cfg.interval};
    static const char unknown_str[] = "-";
    #define MAXLEN 1024
    static const struct arg args[] = {
      ${lib.concatMapStringsSep "\n" (
        component:
        "{ ${component.function}, ${builtins.toJSON component.format}, ${
          if component.argument == null then "NULL" else builtins.toJSON component.argument
        } },"
      ) cfg.components}
    };
  '';
in
{
  options.programs.slstatus = {
    enable = lib.mkEnableOption "slstatus";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../packages/slstatus.nix { };
      description = "Base slstatus package configured by this module.";
    };
    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 9000;
      description = "Refresh interval in milliseconds.";
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf cSettings.valueType;
      default = { };
      example.SLSTATUS_TEMP_COLOR_NORMAL = "6a9955";
      description = ''
        Compile-time SLSTATUS_* macros written to host.h. Booleans become 0 or 1,
        strings are quoted, and { raw = "..."; } supplies a C expression.
      '';
    };
    components = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            function = lib.mkOption {
              type = lib.types.strMatching "[a-zA-Z_][a-zA-Z0-9_]*";
              description = "slstatus component function, such as cpu_perc or datetime.";
            };
            format = lib.mkOption {
              type = lib.types.singleLineStr;
              description = "Printf format containing one %s placeholder.";
            };
            argument = lib.mkOption {
              type = lib.types.nullOr lib.types.singleLineStr;
              default = null;
              description = "Component argument; null supplies the C NULL argument.";
            };
          };
        }
      );
      default = [
        {
          function = "datetime";
          format = "%s";
          argument = "%F %T";
        }
      ];
      description = "Status components in display order.";
    };
    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = cfg.package.override {
        inherit conf;
        configHeader = header;
      };
      description = "slstatus package with the configured components, interval and macros.";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.components != [ ];
        message = "slstatus requires at least one component.";
      }
      {
        assertion = lib.all (name: builtins.match "SLSTATUS_[A-Z0-9_]+" name != null) (
          builtins.attrNames cfg.settings
        );
        message = "slstatus settings must use SLSTATUS_* macro names.";
      }
    ];
    home.packages = [ cfg.finalPackage ];
  };
}
