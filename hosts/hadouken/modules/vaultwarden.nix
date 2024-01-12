{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.vaultwarden;
in {
  options.hosts.vaultwarden = {
    enable = mkEnableOption "Enable vaultwarden";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."vaultwarden.thuis.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.vaultwarden.config.rocketPort}
    '';
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      backupDir = "/var/lib/bitwarden_rs/backup"; # todo include into borg
      config = {
        domain = "https://vaultwarden.thuis.plebian.nl";
        signupsAllowed = false;
        invitationsAllowed = false;
        rocketPort = 3011;
        websocketEnabled = false;
      };
    };
  };
}
