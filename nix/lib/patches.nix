{ lib }:
directory:
let
  entries = if builtins.pathExists directory then builtins.readDir directory else { };
  names = lib.filter (name: lib.hasSuffix ".patch" name && entries.${name} == "regular") (
    builtins.attrNames entries
  );
in
map (name: directory + "/${name}") (lib.sort builtins.lessThan names)
