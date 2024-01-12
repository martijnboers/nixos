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
    services.caddy.virtualHosts."noisesfrom.space".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.vaultwarden.config.rocketPort}
      remote_ip 100.64.0.0/10 # headscale subnet
    '';
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      backupDir = "/var/lib/bitwarden_rs/backup"; # todo include into borg
      config = {
        domain = "https://noisesfrom.space";
        signupsAllowed = false;
        invitationsAllowed = false;
        rocketPort = 3011;
        websocketEnabled = false;
      };
    };
  };
}
