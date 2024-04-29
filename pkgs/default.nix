{pkgs, ...}: {
  httpie-desktop = pkgs.callPackage ./httpie-desktop.nix {};
  adguard-exporter = pkgs.callPackage ./adguard-exporter.nix {};
  xcaddy = pkgs.callPackage ./xcaddy.nix {
    plugins = ["github.com/caddy-dns/cloudflare"];
  };
}
