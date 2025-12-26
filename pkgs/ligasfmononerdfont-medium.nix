{pkgs}:
pkgs.stdenv.mkDerivation {
  name = "LigaSFMonoNerdFont-Medium";
  src = ./LigaSFMonoNerdFont-Medium.otf;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp $src $out/share/fonts/opentype/
  '';
}
