{
  lib,
  slstatus,
  writeText,
  conf ? null,
  settings ? { },
  configHeader ? "",
  upstreamSrc ? ../../upstream/slstatus,
  patchesDir ? ../../patches/slstatus,
}:
let
  cSettings = import ../lib/c-settings.nix { inherit lib; };
  readPatches = import ../lib/patches.nix { inherit lib; };
  patchFiles = readPatches patchesDir;
  asFile =
    name: value:
    if builtins.isPath value || lib.isDerivation value then value else writeText name value;
  headerFile = cSettings.resolveHeader {
    inherit writeText settings configHeader;
  };
  configFile = asFile "config.h" conf;
in
# The Nixpkgs package has no parameter for the source or the host header.
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
      cp ${headerFile} host.h
      # config.mk defines CPPFLAGS, so pass -DSPREAD_HOST_HEADER through the compiler wrapper.
      export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:+$NIX_CFLAGS_COMPILE }-DSPREAD_HOST_HEADER"
    '';
    passthru = builtins.removeAttrs (previous.passthru or { }) [ "updateScript" ];
    meta = previous.meta // {
      homepage = "https://github.com/SpreadZhao/spreadless";
      description = "slstatus maintained as an ordered patch series";
    };
  })
