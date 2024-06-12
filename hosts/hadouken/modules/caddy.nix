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
    rev = "79d4827e9ebc517a7e4b627e4ac1cfd8b0e07f34";
  };
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy with own websites loaded";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../../../pkgs/xcaddy.nix {
        plugins = ["github.com/caddy-dns/cloudflare"];
      };

      globalConfig = ''
        servers {
           metrics
        }
      '';

      virtualHosts."plebian.nl".extraConfig = ''
        root * ${plebianRepo}/
        encode zstd gzip
        file_server
      '';
      virtualHosts."doornappel.nl".extraConfig = ''
        respond "ok" 200
      '';
      virtualHosts."whichmarket.online".extraConfig = ''
        respond "👷🏻‍♂️"
      '';
      virtualHosts."immich.thuis.plebian.nl".extraConfig = ''
        tls internal
        @internal {
          remote_ip 100.64.0.0/10
        }
        handle @internal {
          reverse_proxy http://localhost:2283
        }
        respond 403
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
