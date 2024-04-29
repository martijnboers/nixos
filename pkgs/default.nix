{pkgs, ...}: {
  httpie-desktop = pkgs.callPackage ./httpie-desktop.nix {};
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
}
