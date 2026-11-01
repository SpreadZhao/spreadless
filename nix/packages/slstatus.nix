{
  lib,
  slstatus,
  writeText,
  settings ? { },
  conf ? null,
  upstreamSrc ? ../../upstream/slstatus,
  patchesDir ? ../../patches/slstatus,
}:
let
  slstatusConfig = import ../lib/slstatus-config.nix { inherit lib; };
  readPatches = import ../lib/patches.nix { inherit lib; };
  patchFiles = readPatches patchesDir;
  resolvedConf = if conf != null then conf else slstatusConfig.renderConfig settings;
  configFile =
    if builtins.isPath resolvedConf || lib.isDerivation resolvedConf then
      resolvedConf
    else
      writeText "slstatus-config.h" resolvedConf;
in
(slstatus.override {
  conf = null;
  patches = patchFiles;
}).overrideAttrs
  (previous: {
    pname = "spread-slstatus";
    version = "1.1";
    src = upstreamSrc;
    preBuild = (previous.preBuild or "") + ''
      cp ${configFile} config.h
    '';
    passthru = builtins.removeAttrs (previous.passthru or { }) [ "updateScript" ];
    meta = previous.meta // {
      homepage = "https://github.com/SpreadZhao/spreadless";
      description = "slstatus maintained as an ordered patch series";
    };
  })
