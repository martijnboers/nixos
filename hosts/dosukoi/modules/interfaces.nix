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
          plugin pppoe.so
          wan6
          ifname peepee
          name "fake@freedom.nl"
          password "1234"

          # pppd handles IPv4 routing and DNS
          defaultroute
          usepeerdns

          noauth
          noipdefault
          +ipv6
          ipv6cp-use-ipaddr
          persist
          maxfail 0
        '';
      };
    };
  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;
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
        networkConfig = {
          DHCP = "ipv6";
          IPv6AcceptRA = true;
          ConfigureWithoutCarrier = "yes";
        };
        ipv6AcceptRAConfig = {
          DHCPv6Client = true;
        };
        dhcpV6Config = {
          UseDelegatedPrefix = true;
          UseAddress = false;
          WithoutRA = "solicit";
        };
        routes = [
          {
            Gateway = "::";
            GatewayOnLink = true;
          }
        ];
      };

      # LAN interfaces are fully dynamic for IPv6.
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
      };
      "30-wifi" = {
        matchConfig.Name = "wifi";
        address = [ "10.20.0.1/24" ];
        networkConfig = {
          DHCPServer = "yes";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          PoolSize = 20;
        };
      };
      "40-opt1" = {
        matchConfig.Name = "opt1";
        address = [ "10.30.0.1/24" ];
        networkConfig = {
          DHCPServer = "yes";
          IPv6SendRA = "yes";
          DHCPPrefixDelegation = "yes";
        };
        dhcpServerStaticLeases = [
          {
            MACAddress = "AA:BB:CC:11:22:33";
            Address = "10.30.0.10";
          }
        ];
      };
    };
  };

  networking.nat = {
    enable = true;
    internalInterfaces = [
      "lan"
      "wifi"
      "opt1"
    ];
    externalInterface = "peepee";
  };

  environment.etc."ppp/ip-up".source = lib.getExe (
    pkgs.writeShellScriptBin "ppp-ip-up" ''
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
      if [ "$IFNAME" = "peepee" ]; then
        ${pkgs.systemd}/bin/resolvectl revert "$IFNAME"
      fi
    ''
  );
}
