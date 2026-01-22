{
  lib,
  llvmPackages,
  cmake,
  qt6,
  wrapQtAppsHook,
}:
llvmPackages.stdenv.mkDerivation rec {
  pname = "luna-network";
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
