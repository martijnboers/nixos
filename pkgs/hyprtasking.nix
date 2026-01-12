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
    rev = "ff1c503904d1b6fba23358f6e2a36e3fbfdbddf1";
    hash = "sha256-zuHBXJhCjwVdt4LozBKsXmina6A7umt0vPHwAmmA6x0=";
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
