{ pkgs, ... }:
{
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix { };
  smtp-gotify = pkgs.callPackage ./smtp-gotify.nix { };
  dnscrypt = pkgs.callPackage ./dnscrypt.nix { };
  fluid-calendar = pkgs.callPackage ./fluid-calendar.nix { };
  tormon-exporter = pkgs.callPackage ./tormon-exporter.nix { };
}
