{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "icomoon";
  src = ./icomoon.woff;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/fonts/woff
    cp $src $out/share/fonts/woff/
  '';
}

