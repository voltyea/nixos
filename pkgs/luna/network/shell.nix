let
pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  packages = with pkgs.qt6Packages; [
    qtbase
      qtdeclarative
  ];

  buildInputs = [
    pkgs.cmake
    pkgs.clang
    pkgs.pkg-config 
    pkgs.networkmanager
  ];

  nativeBuildInputs = [
    pkgs.qt6.wrapQtAppsHook
      pkgs.makeWrapper
  ];

  shellHook = ''
    export QML_IMPORT_PATH="$PWD/build/:${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}"
    '';
}
