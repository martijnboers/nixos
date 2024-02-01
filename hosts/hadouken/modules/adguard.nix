{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.adguard;
in {
  options.hosts.adguard = {
    enable = mkEnableOption "Adguard say no to ads";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."dns.thuis.plebian.nl".extraConfig = ''
      tls internal
      reverse_proxy http://localhost:3000
    '';

    networking.firewall.allowedTCPPorts = [53];
    networking.firewall.allowedUDPPorts = [53];

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      allowDHCP = false;

      settings = {
        bind_host = "127.0.0.1";

        dns = {
          ratelimit = 0;
          bind_hosts = ["100.64.0.2"];
          bootstrap_dns = ["9.9.9.9" "208.67.222.222"];
          upstream_dns = ["9.9.9.9" "208.67.222.222"];
          protection_enabled = true;
          blocked_hosts = ["version.bind" "id.server" "hostname.bind"];
          cache_size = 4194304;
          rewrites = [
            {
              domain = "hadouken.plebian.local";
              answer = "192.168.1.156";
            }
          ];
        };
        filters = [
          {
            enabled = true;
            url = "https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt";
            name = "Disconnect.me SimpleAd";
          }
          {
            enabled = true;
            url = "https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt";
            name = "Disconnect.me SimpleTracking";
          }
          {
            enabled = true;
            url = "http://sysctl.org/cameleon/hosts";
            name = "sysctl";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/kevinle-1/Windows-telemetry-blocklist/master/windowsblock.txt";
            name = "Windows Telemetry BlockList";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts";
            name = "Unified hosts file with base extensions";
          }
        ];
        theme = "auto";
        users = [
          {
            name = "admin";
            password = "$2a$12$2.LYNDcUmLA/14My1r592.lNs32aWsF7q6g6RwdGG0BPF.cbyde/W";
          }
        ];
      };
    };
  };
}
