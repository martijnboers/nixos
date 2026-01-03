{ pkgs, ... }:

let
  glitch-soc-src = pkgs.fetchgit {
    url = "https://git.eisfunke.com/config/nixos.git";
    rev = "5657d42c65d02d9aed3d04adc0e8ae408b29112e";
    sha256 = "sha256-dhIUokqOz45nkxmRPYQjcucCh2iBeW+Pv0pyT+G+ev8=";
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
  rustfs = pkgs.callPackage ./rustfs.nix { };
  bw-secret-service = pkgs.callPackage ./secret-service.nix { };
  glitch-soc = pkgs.callPackage "${glitch-soc-src}/packages/mastodon" { };
}
