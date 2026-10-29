{ lib }:
let
  raw = lib.types.submodule {
    options.raw = lib.mkOption {
      type = lib.types.singleLineStr;
      description = "C expression or initializer list emitted without quoting.";
    };
  };
  render =
    value:
    if builtins.isBool value then
      (if value then "1" else "0")
    else if builtins.isAttrs value then
      value.raw
    else
      builtins.toJSON value;
in
{
  valueType = lib.types.oneOf [
    lib.types.bool
    lib.types.int
    lib.types.float
    lib.types.singleLineStr
    raw
  ];
  renderHeader =
    settings:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: value: "#define ${name} ${render value}") settings
    )
    + "\n";
}
