{
  lib,
  gcc14Stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  hyprland,
}:
gcc14Stdenv.mkDerivation {
  pname = "hyprtasking";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "raybbian";
    repo = "hyprtasking";
    rev = "387faba1e3abeaa16e3c867d745e4dc61934cb45";
    hash = "sha256-8TOQw0z84hDS9ce0Vg329R4p8YBfhOVJWHAo85XuEEQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ]
  ++ hyprland.nativeBuildInputs;
  buildInputs = [ hyprland ] ++ hyprland.buildInputs;

  meta = with lib; {
    homepage = "https://github.com/raybbian/hyprtasking";
    description = "Tab overview";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
