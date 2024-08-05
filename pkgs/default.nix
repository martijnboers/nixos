{pkgs, ...}: {
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
  wazuh = pkgs.callPackage ./wazuh.nix {};
  smtp-gotify = pkgs.callPackage ./smtp-gotify.nix {};
}
