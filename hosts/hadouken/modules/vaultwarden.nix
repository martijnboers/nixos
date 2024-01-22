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
      tls ${config.age.secrets.ca.path} ${config.age.secrets.key.path}
      reverse_proxy http://localhost:${toString config.services.vaultwarden.config.rocketPort}
    '';
    services.borgbackup.jobs.default.paths = ["/var/lib/bitwarden_rs/backup"];
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      backupDir = "/var/lib/bitwarden_rs/backup";
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
