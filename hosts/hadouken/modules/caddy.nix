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
    rev = "b07146995f7b227ef7692402374268f0457003aa";
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
        plugins = ["github.com/caddy-dns/cloudflare" "github.com/corazawaf/coraza-caddy/v2" "github.com/darkweak/souin/plugins/caddy"];
      };

      globalConfig = ''
        servers {
            metrics
        }
        # https://docs.souin.io/docs/middlewares/caddy/
        cache {
            ttl 100s
            stale 3h
            default_cache_control public, s-maxage=100
        }
        order coraza_waf first
      '';
      virtualHosts."plebian.nl" = {
        serverAliases = ["boers.email"];
        extraConfig = ''
          cache { ttl 1h }
          root * ${plebianRepo}/
          encode zstd gzip
          file_server
        '';
      };
      virtualHosts."resume.plebian.nl" = {
        serverAliases = ["resume.boers.email"];
        extraConfig = ''
          cache { ttl 48h }
          root * ${pkgs.resume-hugo}/
          encode zstd gzip
          file_server
        '';
      };
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
