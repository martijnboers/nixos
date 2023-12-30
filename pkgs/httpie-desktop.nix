{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
}: let
  pname = "httpie-desktop";
  version = "2023.3.6";
  name = "${pname}-${version}";

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  src = fetchurl {
    url = "https://github.com/httpie/desktop/releases/download/v${version}/HTTPie-${version}.AppImage";
    hash = "sha256-AHD3ZbVzfMQtYpTW3Fu6Iyo41/8B4HKZFfNUWabLCOM=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit name src;
  };

  meta = with lib; {
    description = "HTTPie Desktop Client";
    homepage = "https://httpie.io/";
    license = licenses.bsd3;
    platforms = ["x86_64-linux"];
  };

  linux = appimageTools.wrapType2 rec {
    inherit pname version src meta;

    multiArch = false; # no 32bit needed
    extraPkgs = appimageTools.defaultFhsEnvArgs.multiPkgs;

    extraInstallCommands = ''
      mv $out/bin/{${name},${pname}}
      install -m 444 -D ${appimageContents}/httpie.desktop $out/share/applications/httpie.desktop
      install -m 444 -D ${appimageContents}/httpie.png $out/share/icons/hicolor/512x512/apps/httpie.png
      substituteInPlace $out/share/applications/httpie.desktop --replace 'Exec=AppRun' 'Exec=${pname}'
    '';
  };
in
  linux
