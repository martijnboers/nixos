{pkgs, ...}: {
  httpie-desktop = pkgs.callPackage ./httpie-desktop.nix {};
}
