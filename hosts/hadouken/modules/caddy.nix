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
    rev = "a0dece7da8c56976e3c887b6c7019db2925a65ab";
  };
in {
  options.hosts.caddy = {
    enable = mkEnableOption "Caddy base";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      package = pkgs.callPackage ../../../pkgs/xcaddy.nix {
        plugins = ["github.com/caddy-dns/cloudflare" "github.com/corazawaf/coraza-caddy/v2"];
      };

      globalConfig = ''
        servers {
            metrics
        }
        order coraza_waf first
      '';
      virtualHosts."plebian.nl" = {
        serverAliases = ["boers.email"];
        extraConfig = ''
          root * ${plebianRepo}/
          encode zstd gzip
          file_server
        '';
      };
      virtualHosts."immich.thuis".extraConfig = ''
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
