{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.pingvin;
in
{
  options.hosts.pingvin = {
    enable = mkEnableOption "Pingvin share";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "pingvin.thuis".extraConfig = ''
        import headscale
        coraza_waf {
          load_owasp_crs
          directives `
            Include @coraza.conf-recommended
            SecRuleEngine On
          `
        }
        handle @internal {
           reverse_proxy http://127.0.0.1:${toString config.services.pingvin-share.frontend.port}
        }
        respond 403
      '';
    };

    services.pingvin-share = {
      enable = true;
      frontend.port = 2386;
      backend.port = 2387;
      dataDir = "/mnt/zwembad/games/pingvin";
    };
  };
}
