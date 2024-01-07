{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.resilio;
in {
  options.hosts.resilio = {
    enable = mkEnableOption "Resilio syncing seed";
  };

  config = mkIf cfg.enable {
    users.users.martijn.extraGroups = ["rslsync"];

    services.resilio = {
      enable = true;
      deviceName = "hadouken";
      enableWebUI = true;
      httpLogin = "martijn";
      httpPass = builtins.readFile config.age.secrets.resilio.path;
      httpListenPort = "9001";
    };
  };
}
