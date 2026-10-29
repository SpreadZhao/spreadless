{
  lib,
  stdenv,
  fcft,
  installShellFiles,
  libdrm,
  libx11,
  libinput,
  libxcb,
  libxkbcommon,
  pixman,
  pkg-config,
  tllist,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_20,
  libxcb-wm,
  xwayland,
  writeText,
  enableXWayland ? true,
  configHeader ? "",
  upstreamSrc ? ../../upstream/dwl,
  patchesDir ? ../../patches/dwl,
}:

let
  headerFile =
    if builtins.isPath configHeader || lib.isDerivation configHeader then
      configHeader
    else
      writeText "host.h" configHeader;

  readPatches = import ../lib/patches.nix { inherit lib; };
  patchFiles = readPatches patchesDir;

in
stdenv.mkDerivation {
  pname = "spread-dwl";
  version = "0.9";

  src = upstreamSrc;
  patches = patchFiles;

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    fcft
    libdrm
    libinput
    libxcb
    libxkbcommon
    pixman
    tllist
    wayland
    wayland-protocols
    wlroots_0_20
  ]
  ++ lib.optionals enableXWayland [
    libx11
    libxcb-wm
    xwayland
  ];

  preBuild = ''
    export CPPFLAGS="''${CPPFLAGS:+$CPPFLAGS }-include ${headerFile}"
  '';

  outputs = [
    "out"
    "man"
  ];

  makeFlags = [
    "PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"
    "WAYLAND_SCANNER=wayland-scanner"
    "PREFIX=$(out)"
    "MANDIR=$(man)/share/man"
  ]
  ++ lib.optionals enableXWayland [
    ''XWAYLAND="-DXWAYLAND"''
    ''XLIBS="xcb xcb-icccm"''
  ];

  strictDeps = true;
  __structuredAttrs = true;

  passthru = {
    providedSessions = [ "dwl" ];
  };

  meta = {
    homepage = "https://codeberg.org/dwl/dwl";
    description = "Customized dwl build maintained from an ordered commit series";
    license = lib.licenses.gpl3Only;
    platforms = wayland.meta.platforms;
    mainProgram = "dwl";
  };
}
