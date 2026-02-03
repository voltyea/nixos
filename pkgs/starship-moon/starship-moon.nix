{
  lib,
  llvmPackages,
  cmake,
}:
llvmPackages.stdenv.mkDerivation rec {
  pname = "starship-moon";
  version = "0.1";

  src = ./.;

  nativeBuildInputs = [
    cmake
  ];

}
