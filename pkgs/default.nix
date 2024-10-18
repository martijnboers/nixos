{pkgs, ...}: {
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
  wazuh = pkgs.callPackage ./wazuh.nix {};
  mailrise = pkgs.callPackage ./mailrise.nix {};
  princexml = pkgs.callPackage ./princexml.nix {};
  dnscrypt = pkgs.callPackage ./dnscrypt.nix {};
  tormon-exporter = pkgs.callPackage ./tormon-exporter.nix {};
}
