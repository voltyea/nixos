{
  lib,
  stdenv,
  cmake,
  qt6,
  wrapQtAppsHook,
  pkg-config,
  networkmanager,
  glib,
  clang,
}:
stdenv.mkDerivation rec {
  pname = "luna-network";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [
    cmake
    clang
    wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
    pkg-config
    networkmanager
    glib
  ];
}
