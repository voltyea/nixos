{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "SF-Pro-Rounded-Medium";
  src = ./SF-Pro-Rounded-Medium.otf;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp $src $out/share/fonts/opentype/
  '';
}

