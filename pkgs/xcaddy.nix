# https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
{
  pkgs,
  plugins,
  stdenv,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  pname = "caddy";
  # https://github.com/NixOS/nixpkgs/issues/113520
  version = "latest";
  dontUnpack = true;

  nativeBuildInputs = [pkgs.git pkgs.go pkgs.xcaddy];

  configurePhase = ''
    export GOCACHE=$TMPDIR/go-cache
    export GOPATH="$TMPDIR/go"
  '';

  meta.mainProgram = "xcaddy";

  buildPhase = let
    pluginArgs = lib.concatMapStringsSep " " (plugin: "--with ${plugin}") plugins;
  in ''
    runHook preBuild
    ${pkgs.xcaddy}/bin/caddy build "${version}" ${pluginArgs}
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mv xcaddy $out/bin
    runHook postInstall
  '';
}
