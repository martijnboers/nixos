{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.caddy;
  plebianRepo = builtins.fetchGit {
    url = "https://github.com/martijnboers/plebian.nl.git";
    rev = "968121cafdaffc23d11eff2b81532ba292a6d65a";
  };
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy with own websites loaded";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    # Allow network access when building
    # https://mdleom.com/blog/2021/12/27/caddy-plugins-nixos/#xcaddy
    nix.settings.sandbox = false;

    services.caddy = {
      enable = true;
      package = (pkgs.callPackage ../../../pkgs/custom-caddy.nix {
        plugins = [ "github.com/caddy-dns/cloudflare" ];
      });
      virtualHosts."plebian.nl".extraConfig = ''
        root * ${plebianRepo}/
        encode zstd gzip
        file_server
      '';
      virtualHosts."noisesfrom.space".extraConfig = ''
        respond "🦆"
      '';
    };

    age.secrets.caddy.file = ../../../secrets/caddy.age;

    systemd.services.caddy = {
      serviceConfig = {
        # Required to use ports < 1024
        AmbientCapabilities = "cap_net_bind_service";
        CapabilityBoundingSet = "cap_net_bind_service";
        EnvironmentFile = config.age.secrets.caddy.path;
        TimeoutStartSec = "5m";
      };
    };
  };
}
