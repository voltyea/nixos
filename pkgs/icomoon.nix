{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "icomoon";
  src = ./icomoon.ttf;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/fonts/ttf
    cp $src $out/share/fonts/ttf/
  '';
}
