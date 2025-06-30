{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.changedetection;
in
{
  options.hosts.changedetection = {
    enable = mkEnableOption "Changedetection.io";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."detection.thuis".extraConfig = ''
      import headscale
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString config.services.changedetection-io.port}
      }
      respond 403
    '';

    # Docker is not added by default but required for headless chrome
    virtualisation.docker.enable = true;
    # already running dns on host + not used in systemd params...
    virtualisation.podman.defaultNetwork.settings.dns_enabled = lib.mkForce false;

    services.changedetection-io = {
      enable = false; # https://github.com/NixOS/nixpkgs/pull/419713
      behindProxy = true;
      datastorePath = "/mnt/zwembad/app/changedetection";
      baseURL = "https://detection.thuis";
      playwrightSupport = true;
    };

    systemd.timers = {
      restart-changedetection = {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };

    systemd.services = {
      restart-changedetection = {
        # https://github.com/dgtlmoon/changedetection.io/wiki/Playwright-content-fetcher#playwright-memory-leak
        description = "Restart changedetection.io playwright memory leak";
        serviceConfig = {
          ExecStart =
            let
              restart = pkgs.writeShellScriptBin "restart-changedetection" ''
                ps -C changedetection u|grep -v PID|awk '$6 > 240000 {print $2};'|while read pid
                do
                  kill -9 $pid
                  ${pkgs.systemd}/bin/systemctl restart changedection.service
                done
              '';
            in
            lib.getExe restart;
        };
      };
    };
  };
}
