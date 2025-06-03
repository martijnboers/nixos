{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.atuin;
in
{
  options.hosts.atuin = {
    enable = mkEnableOption "Synchronize zsh history files";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."atuin.thuis".extraConfig = ''
      import headscale
      handle @internal {
         reverse_proxy http://localhost:${toString config.services.atuin.port}
      }
      respond 403
    '';
    services.atuin = {
      enable = true;
      openRegistration = false;
      port = 8965;
    };
  };
}
