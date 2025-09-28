{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.it-tools;
in
{
  options.hosts.it-tools = {
    enable = mkEnableOption "Development tools";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."tools.thuis".extraConfig = ''
      import headscale
      handle @internal {
        root * ${pkgs.it-tools}/lib/
        encode zstd gzip
        file_server
      }
      respond 403
    '';
  };
}
