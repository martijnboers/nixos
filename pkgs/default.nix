{pkgs, ...}: {
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
  wazuh = pkgs.callPackage ./wazuh.nix {};
}
