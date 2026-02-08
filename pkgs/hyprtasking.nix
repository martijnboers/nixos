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
    rev = "2cec7b23a66265165cd414bf75773bae3c0747c8";
    hash = "sha256-w9zAHfLcQGCVzYjORpMZueSRgTo7OLXiEN1bGFTlVAc=";
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
