{pkgs, ...}: {
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
  mailrise = pkgs.callPackage ./mailrise.nix {};
  dnscrypt = pkgs.callPackage ./dnscrypt.nix {};
  tormon-exporter = pkgs.callPackage ./tormon-exporter.nix {};
  smtp-to-storage = pkgs.callPackage ./smtp-to-storage/default.nix {};
}
