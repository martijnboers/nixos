{ pkgs, ... }:
{
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix { };
  mailrise = pkgs.callPackage ./mailrise.nix { };
  dnscrypt = pkgs.callPackage ./dnscrypt.nix { };
  tormon-exporter = pkgs.callPackage ./tormon-exporter.nix { };
  resume-hugo = pkgs.callPackage ./resume.nix { };
}
