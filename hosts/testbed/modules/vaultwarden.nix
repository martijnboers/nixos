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
    services.vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      backupDir = "/mnt/garage/Backup/vaultwarden";
      config = {
        domain = "https://noisesfrom.space";
        signupsAllowed = true; # set to false
        rocketPort = 3011;
        websocketEnabled = false;
      };
    };
  };
}
