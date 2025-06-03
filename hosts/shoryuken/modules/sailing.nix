{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.sailing;
  suites = [
    {
      name = "prowlarr";
      port = 9696;
    }
    {
      name = "lidarr";
      port = 8686;
    }
  ];
in
{
  options.hosts.sailing = {
    enable = mkEnableOption "sailing";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = lib.lists.foldl (
      acc: suite:
      acc
      // {
        "${suite.name}.thuis".extraConfig = ''
          import headscale
          handle @internal {
            reverse_proxy http://127.0.0.1:${toString suite.port}
          }
          respond 403
        '';
      }
    ) { } suites;

    services = {
      prowlarr.enable = true;
      lidarr.enable = true;
    };
  };
}
