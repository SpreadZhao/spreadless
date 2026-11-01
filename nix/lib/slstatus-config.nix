{ lib }:
let
  defaultConfig = {
    interval = 1000;
    unknownStr = "n/a";
    maxLen = 2048;
    tempColors = {
      normal = "6a9955";
      warning = "e6e6aa";
      critical = "ff0000";
    };
    components = [
      {
        function = "datetime";
        format = "%s";
        argument = "%F %T";
      }
    ];
  };

  renderComponent =
    component:
    "\t{ ${component.function}, ${builtins.toJSON component.format}, ${
      if component.argument == null then "NULL" else builtins.toJSON component.argument
    } },";

  renderConfig =
    cfg:
    let
      merged =
        defaultConfig // cfg // { tempColors = defaultConfig.tempColors // (cfg.tempColors or { }); };
      componentLines = lib.concatMapStringsSep "\n" renderComponent merged.components;
    in
    ''
      /* See LICENSE file for copyright and license details. */

      /* interval between updates (in ms) */
      const unsigned int interval = ${toString merged.interval};

      /* text to show if no value can be retrieved */
      static const char unknown_str[] = ${builtins.toJSON merged.unknownStr};

      /* temperature colors: normal, warning (>= 60C), critical (>= 80C) */
      const char *const temp_colors[3] = {
      	${builtins.toJSON merged.tempColors.normal},
      	${builtins.toJSON merged.tempColors.warning},
      	${builtins.toJSON merged.tempColors.critical},
      };

      /* maximum output string length */
      #define MAXLEN ${toString merged.maxLen}

      static const struct arg args[] = {
      	/* function format          argument */
      ${componentLines}
      };
    '';

  options = {
    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = defaultConfig.interval;
      description = "Refresh interval in milliseconds.";
    };
    unknownStr = lib.mkOption {
      type = lib.types.singleLineStr;
      default = defaultConfig.unknownStr;
      description = "Text shown when a component reading is unavailable.";
    };
    maxLen = lib.mkOption {
      type = lib.types.ints.positive;
      default = defaultConfig.maxLen;
      description = "Maximum status output buffer length in bytes.";
    };
    tempColors = {
      normal = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.tempColors.normal;
        description = "Hex color string for CPU temperatures below 60°C.";
      };
      warning = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.tempColors.warning;
        description = "Hex color string for CPU temperatures from 60°C to 79°C.";
      };
      critical = lib.mkOption {
        type = lib.types.singleLineStr;
        default = defaultConfig.tempColors.critical;
        description = "Hex color string for CPU temperatures at or above 80°C.";
      };
    };
    components = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            function = lib.mkOption {
              type = lib.types.singleLineStr;
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
      default = defaultConfig.components;
      description = "Status components in display order.";
    };
  };
in
{
  inherit defaultConfig options renderConfig;
}
