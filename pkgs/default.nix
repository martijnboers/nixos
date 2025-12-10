{ pkgs, ... }:

let
  glitch-soc-src = pkgs.fetchgit {
    url = "https://git.eisfunke.com/config/nixos.git";
    rev = "58f6a1ca9a1a9a7c6716cb91fb34432258c5fbb4";
    sha256 = "sha256-WtuNWILJ/DX5nKcNt7eivqJoOay0JxOKtAF0Rvl6Ecs=";
  };
in
{
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix { };
  smtp-gotify = pkgs.callPackage ./smtp-gotify.nix { };
  dnscrypt = pkgs.callPackage ./dnscrypt.nix { };
  fluid-calendar = pkgs.callPackage ./fluid-calendar.nix { };
  tormon-exporter = pkgs.callPackage ./tormon-exporter.nix { };
  wvkbd-desktop = pkgs.callPackage ./wvkbd.nix { };
  karlender-dev = pkgs.callPackage ./karlender.nix { };
  geonet = pkgs.callPackage ./geonet.nix { };
  ladder = pkgs.callPackage ./ladder.nix { };
  unaware = pkgs.callPackage ./unaware.nix { };
  hyprtasking = pkgs.callPackage ./hyprtasking.nix { };
  bw-secret-service = pkgs.callPackage ./secret-service.nix { };
  glitch-soc = pkgs.callPackage "${glitch-soc-src}/packages/mastodon" { };
}
