{
  lib,
  slstatus,
  writeText,
  conf ? null,
  configHeader ? "",
  upstreamSrc ? ../../upstream/slstatus,
  patchesDir ? ../../patches/slstatus,
}:
let
  readPatches = import ../lib/patches.nix { inherit lib; };
  patchFiles = readPatches patchesDir;
  asFile =
    name: value:
    if builtins.isPath value || lib.isDerivation value then value else writeText name value;
  headerFile = asFile "host.h" configHeader;
  configFile = asFile "config.h" conf;
in
# The Nixpkgs package has no parameter for the source or a forced header include.
(slstatus.override {
  conf = null;
  patches = patchFiles;
}).overrideAttrs
  (previous: {
    pname = "spread-slstatus";
    version = "1.1";
    src = upstreamSrc;
    preBuild = previous.preBuild + ''
      ${lib.optionalString (conf != null) "cp ${configFile} config.h"}
      # config.mk defines CPPFLAGS, so pass the header through the compiler wrapper.
      export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:+$NIX_CFLAGS_COMPILE }-include ${headerFile}"
    '';
    passthru = builtins.removeAttrs (previous.passthru or { }) [ "updateScript" ];
    meta = previous.meta // {
      homepage = "https://github.com/SpreadZhao/spreadless";
      description = "slstatus maintained as an ordered patch series";
    };
  })
