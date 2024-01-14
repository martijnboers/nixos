{pkgs, ...}: {
  httpie-desktop = pkgs.callPackage ./httpie-desktop.nix {};
  pgvecto-rs = pkgs.callPackage ./pgvecto-rs.nix {};
}
