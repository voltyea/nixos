{
  lib,
  stdenv,
  cmake,
  qt6,
  wrapQtAppsHook,
}:
stdenv.mkDerivation rec {
  pname = "luna-moon";
  version = "1.0";

  src = ./.;

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtdeclarative
  ];
}
