# https://www.sput.nl/internet/freedom/config.html
# https://s-n.me/building-a-nixos-router-for-a-uk-fttp-isp-the-basics
# https://www.jjpdev.com/posts/home-router-nixos/
{
  pkgs,
  lib,
  ...
}:
{
  services.pppd = {
    enable = true;
    peers = {
      peepee = {
        enable = true;
        autostart = true;
        config = ''
          # Standard PPPoE plugin over the 'wan6' VLAN interface
          plugin pppoe.so wan6

          # Interface name for the PPPoE link
          ifname peepee

          name "fake@freedom.nl"
          password "1234"

          # Automatically set the default IPv4 route via this link
          defaultroute
          # Use the DNS servers provided by the ISP for IPv4
          usepeerdns
          # No authentication needed for this ISP
          noauth
          # Do not assign a default IP if negotiation fails
          noipdefault

          # Enable IPv6 negotiation on the link
          +ipv6
          # Use the link-local address for IPv6 routing
          ipv6cp-use-ipaddr

          # Keep the connection alive
          persist
          # Retry indefinitely if connection fails
          maxfail 0

          # Negotiate a full 1500-byte MTU for the IP packets on the PPPoE link.
          # This maximizes throughput and fixes asymmetric speeds.
          mtu 1500
          mru 1500
        '';
      };
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false; # PPPoE handles the 'online' state.

    links = {
      "10-wan" = {
        matchConfig.MACAddress = "64:62:66:2f:37:ba";
        linkConfig.Name = "wan";
      };
      "20-lan" = {
        matchConfig.MACAddress = "64:62:66:2f:37:bb";
        linkConfig.Name = "lan";
      };
      "30-wifi" = {
        matchConfig.MACAddress = "64:62:66:2f:37:bc";
        linkConfig.Name = "wifi";
      };
      "40-opt1" = {
        matchConfig.MACAddress = "64:62:66:2f:37:bd";
        linkConfig.Name = "opt1";
      };
    };

    netdevs = {
      "10-wan6" = {
        netdevConfig = {
          Name = "wan6";
          Kind = "vlan";
        };
        vlanConfig = {
          Id = 6;
        };
      };
    };

    networks = {
      "10-wan" = {
        matchConfig.Name = "wan";
        linkConfig.MTUBytes = "1512";
        networkConfig = {
          VLAN = [ "wan6" ];
        };
      };

      "11-wan6" = {
        matchConfig.Name = "wan6";
        linkConfig.RequiredForOnline = "no";
      };

      "15-peepee" = {
        matchConfig.Name = "peepee";
        # This interface is managed externally, but we use it for IPv6.
        networkConfig = {
          DHCP = "ipv6";
          IPv6AcceptRA = true;
          ConfigureWithoutCarrier = "yes";
        };
        linkConfig.RequiredForOnline = "yes";

        ipv6AcceptRAConfig = {
          DHCPv6Client = true;
        };
        dhcpV6Config = {
          UseDelegatedPrefix = true; # Request a prefix for our LANs.
          UseAddress = false; # Don't assign an address to this interface.
          WithoutRA = "solicit"; # Start soliciting immediately (ISP sends no RAs).
        };
        # CRITICAL: ISP does not provide a default route via DHCPv6. Set it statically.
        routes = [
          {
            Gateway = "::";
            GatewayOnLink = true;
          }
        ];
      };

      "20-lan" = {
        matchConfig.Name = "lan";
        address = [ "10.10.0.1/23" ];
        networkConfig = {
          DHCPServer = "yes";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          PoolSize = 20;
        };
        dhcpPrefixDelegationConfig = {
          SubnetId = "0xc0de";
        };
      };

      "21-wifi" = {
        matchConfig.Name = "wifi";
        address = [ "10.10.2.1/24" ];
        networkConfig = {
          DHCPServer = "yes";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
        };
        dhcpPrefixDelegationConfig = {
          SubnetId = "0xbeef";
        };
      };

      "22-opt1" = {
        matchConfig.Name = "opt1";
        address = [ "10.10.3.1/24" ];
        networkConfig = {
          DHCPServer = "yes";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
        };
        dhcpPrefixDelegationConfig = {
          SubnetId = "0xb00f";
        };
        dhcpServerStaticLeases = [
          {
            MACAddress = "AA:BB:CC:11:22:33";
            Address = "10.30.0.2";
          }
        ];
      };
    };
  };

  environment.etc."ppp/ip-up".source = lib.getExe (
    pkgs.writeShellScriptBin "ppp-ip-up" ''
      set -eu
      if [ "$IFNAME" = "peepee" ]; then
        if [ -n "$DNS1" ]; then
          ${pkgs.systemd}/bin/resolvectl dns "$IFNAME" "$DNS1" "$DNS2"
          ${pkgs.systemd}/bin/resolvectl domain "$IFNAME" '~.'
        fi
      fi
    ''
  );
  environment.etc."ppp/ip-down".source = lib.getExe (
    pkgs.writeShellScriptBin "ppp-ip-down" ''
      set -eu
      if [ "$IFNAME" = "peepee" ]; then
        ${pkgs.systemd}/bin/resolvectl revert "$IFNAME"
      fi
    ''
  );
}
