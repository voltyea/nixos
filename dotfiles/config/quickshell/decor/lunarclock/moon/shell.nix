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
  ];

  nativeBuildInputs = [
    pkgs.qt6.wrapQtAppsHook
      pkgs.makeWrapper
  ];

  shellHook = ''
    export QT_PLUGIN_PATH="$PWD/build/:${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}"
    export QML_IMPORT_PATH="$PWD/build/:${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}"
    setQtEnvironment=$(mktemp)
    random=$(openssl rand -base64 20 | sed "s/[^a-zA-Z0-9]//g")
    makeShellWrapper "$(type -p sh)" "$setQtEnvironment" "''${qtWrapperArgs[@]}" --argv0 "$random"
    sed "/$random/d" -i "$setQtEnvironment"
    source "$setQtEnvironment"
    '';
}
