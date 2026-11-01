{ lib }:
let
  raw = lib.types.submodule {
    options.raw = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "C expression or initializer list emitted without quoting.";
    };
  };
  valueType = lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.singleLineStr
    raw
  ];
  render =
    value:
    if builtins.isBool value then
      (if value then "1" else "0")
    else if builtins.isAttrs value then
      value.raw
    else
      builtins.toJSON value;
  renderHeader =
    settings:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "#undef ${name}\n#define ${name} ${render value}") settings
    )
    + lib.optionalString (settings != { }) "\n";
in
{
  inherit valueType renderHeader;
  resolveHeader =
    {
      writeText,
      settings ? { },
      configHeader ? "",
    }:
    if builtins.isPath configHeader || lib.isDerivation configHeader then
      configHeader
    else
      writeText "host.h" (
        renderHeader settings
        + configHeader
        + lib.optionalString (configHeader != "" && !lib.hasSuffix "\n" configHeader) "\n"
      );
  mkSettingsOption =
    {
      example,
      description,
    }:
    lib.mkOption {
      type = lib.types.attrsOf valueType;
      default = { };
      inherit example description;
    };
  mkPrefixAssertion =
    {
      prefix,
      program,
      settings,
    }:
    {
      assertion = lib.all (name: builtins.match "${prefix}_[A-Z0-9_]+" name != null) (
        builtins.attrNames settings
      );
      message = "${program} settings must use ${prefix}_* macro names.";
    };
}
