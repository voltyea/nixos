{
  symlinkJoin,
  makeWrapper,
  quickshell,
}:
symlinkJoin {
  name = "luna";
  version = quickshell.version;
  paths = [quickshell];
  nativeBuildInputs = [makeWrapper];
  postBuild = ''
    makeWrapper $out/bin/quickshell $out/bin/luna
  '';
  meta.mainProgram = "luna";
}
