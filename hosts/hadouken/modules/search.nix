{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.search;
in
{
  options.hosts.search = {
    enable = mkEnableOption "SearXNG";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."search.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.whoogle-search.port}
      }
      respond 403
    '';

    services.whoogle-search = {
      enable = true;
      port = 5015;
    };
  };
}
