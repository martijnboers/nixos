{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.fedifetcher;
in {
  options.hosts.fedifetcher = {
    enable = mkEnableOption "Fill in comments from federations that are not connected yet";
  };

  config = mkIf cfg.enable {
    age.secrets.fedifetcher.file = ../../../secrets/fedifetcher.age;

    systemd.services.fedifetcher = {
      description = "FediFetcher";
      wants = ["mastodon-web.service" "mastodon-wait-for-available.service"];
      after = ["mastodon-web.service" "mastodon-wait-for-available.service"];
      startAt = "*:0/10";

      serviceConfig = {
        Type = "oneshot";
        DynamicUser = true;
        StateDirectory = "fedifetcher";
        LoadCredential = "config.json:${config.age.secrets.fedifetcher.path}";
        ExecStart = "${lib.getExe pkgs.fedifetcher} --config=%d/config.json";
      };
    };
  };
}
