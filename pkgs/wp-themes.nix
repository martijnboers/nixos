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
    rev = "trunk";
    hash = "sha256-EE25HfISk40/1YQt3dzm8cwVFQuP0HxadV1emiaU96c=";
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
