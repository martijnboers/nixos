{ pkgs, ... }:

let
  glitch-soc-src = pkgs.fetchgit {
    url = "https://git.eisfunke.com/config/nixos.git";
    rev = "5cf6c6d43195517057a29bb2d535721cb4bb64de";
    sha256 = "sha256-WAlBG/mt4TAWAQMevsRB98/R+Krd5hFcF68BvzoRyqI=";
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
  glitch-soc = pkgs.callPackage "${glitch-soc-src}/packages/mastodon" { };
}
