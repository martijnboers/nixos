{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.vaultwarden;
  backupDir = "/var/lib/vaultwarden/backup";
in
{
  options.hosts.vaultwarden = {
    enable = mkEnableOption "Enable vaultwarden";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."vaultwarden.thuis".extraConfig = ''
      import headscale
      import mtls

      handle @internal {
        reverse_proxy http://localhost:${toString config.services.vaultwarden.config.rocketPort}
      }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = [ backupDir ];
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      inherit backupDir;
      config = {
        domain = "https://vaultwarden.thuis";
        signupsAllowed = false;
        invitationsAllowed = false;
        rocketPort = 3011;
        websocketEnabled = false;
	experimentalClientFeatureFlags = "mutual-tls";
      };
    };
  };
}
