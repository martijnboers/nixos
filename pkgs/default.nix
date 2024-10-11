{pkgs, ...}: {
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
  wazuh = pkgs.callPackage ./wazuh.nix {};
  mailrise = pkgs.callPackage ./mailrise.nix {};
  princexml = pkgs.callPackage ./princexml.nix {};
  dnscrypt-adguard = pkgs.callPackage ./dnscrypt.nix {};
}
