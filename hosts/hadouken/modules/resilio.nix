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
    resilio = {
      enable = true;
      deviceName = "hadouken";
      enableWebUI = true;
      users.users.martijn.extraGroups = ["rslsync"];
      httpLogin = "martijn";
      httpPass = builtins.readFile config.age.secrets.resilio.path;
      httpListenPort = "9001";
    };
  };
}
