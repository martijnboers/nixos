{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation rec {
  name = "mann";

  src = fetchFromGitHub {
    owner = "Automattic";
    repo = "themes";
    rev = "0dfbc4115ad521c68e5bc695997e3ffe918e2940";
    hash = "sha256-ILDIx0fjmmD3YHr03g1A85Z6AeLCSr5EpeVim6wNYeg=";
  };

  installPhase = "mkdir -p $out; cp -R mann $out/";

  meta = {
    description = "Free WordPress themes made by Automattic for WordPress.org and WordPress.com";
    homepage = "https://github.com/Automattic/themes/tree/trunk/mann";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [];
    platforms = lib.platforms.all;
  };
}
