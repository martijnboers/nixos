# /etc/nixos/exit-proxy.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.socks;
  fwmarkNumber = 10;
  routingTableId = "10";
in
{
  options.hosts.socks = {
    enable = mkEnableOption "SOCKS5 Exit Proxy (Isolated)";
    floatingIp = mkOption {
      type = types.str;
      description = "The Hetzner Floating IPv4 address to use for exiting traffic.";
    };
    tailscaleListenHost = mkOption {
      type = types.str;
      description = "The fully qualified Tailscale hostname of this VPS, where the proxy will listen.";
    };
    interface = mkOption {
      type = types.str;
      default = "eth0";
      description = "The main network interface to attach the Floating IP to (e.g., eth0, enp1s0).";
    };
    proxyPort = mkOption {
      type = types.port;
      default = 1080;
      description = "The port for the SOCKS5 proxy to listen on.";
    };
  };

  config = mkIf cfg.enable {
    networking.interfaces.${cfg.interface}.ipv4.addresses = [{
      address = cfg.floatingIp;
      prefixLength = 32;
    }];

    networking.localCommands = ''
      # Add the policy rule, but only if it doesn't already exist.
      if ! ip rule show | grep -q "fwmark ${toString fwmarkNumber}"; then
        ip rule add fwmark ${toString fwmarkNumber} table ${routingTableId} priority 32000
      fi

      # Add/replace the custom route.
      ip route replace default dev ${cfg.interface} src ${cfg.floatingIp} table ${routingTableId}

      # Add the DROP rule, but only if it doesn't already exist.
      iptables -t raw -C PREROUTING -d ${cfg.floatingIp} -j DROP 2>/dev/null || iptables -t raw -A PREROUTING -d ${cfg.floatingIp} -j DROP
    '';

    # ==> CREATE THE DEDICATED USER AND GROUP <==
    users.users.gost-proxy = {
      isSystemUser = true;
      group = "gost-proxy";
      description = "User for the gost proxy service";
    };
    # THIS IS THE MISSING LINE THAT FIXES THE ERROR.
    users.groups.gost-proxy = {};

    systemd.services.gost-proxy = {
      description = "GO Simple Tunnel (gost) SOCKS5 Exit Proxy";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-local-commands.service" "tailscale.service" ];
      wants = [ "network-local-commands.service" "tailscale.service" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.gost}/bin/gost -L 'socks5://${cfg.tailscaleListenHost}:${toString cfg.proxyPort}?so_mark=${toString fwmarkNumber}'
        '';
        User = "gost-proxy";
        Group = "gost-proxy";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
