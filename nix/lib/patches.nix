{ lib }:
directory:
let
  collectPatches =
    dir:
    let
      entries = if builtins.pathExists dir then builtins.readDir dir else { };
      names = lib.sort builtins.lessThan (builtins.attrNames entries);
    in
    lib.concatMap (
      name:
      let
        path = dir + "/${name}";
        type = entries.${name};
      in
      if type == "directory" then
        collectPatches path
      else if type == "regular" && lib.hasSuffix ".patch" name then
        [ path ]
      else
        [ ]
    ) names;
in
collectPatches directory
