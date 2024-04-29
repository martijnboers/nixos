{pkgs, ...}: {
  httpie-desktop = pkgs.callPackage ./httpie-desktop.nix {};
  xcaddy = pkgs.callPackage ./xcaddy.nix {
    plugins = ["github.com/caddy-dns/cloudflare"];
  };
}
