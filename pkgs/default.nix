{ pkgs, ... }:
{
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix { };
  mailrise = pkgs.callPackage ./mailrise.nix { };
  dnscrypt = pkgs.callPackage ./dnscrypt.nix { };
  fluid-calendar = pkgs.callPackage ./fluid-calendar.nix { };
  tormon-exporter = pkgs.callPackage ./tormon-exporter.nix { };
}
