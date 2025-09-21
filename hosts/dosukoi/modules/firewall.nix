{
  ...
}:
{
  networking = {
    firewall.enable = false;
    useNetworkd = true;

    nftables = {
      enable = true;
      tables = {
        firewall = {
          family = "inet";
          content = ''
            chain input {
              type filter hook input priority filter; policy drop;

              ct state established,related accept;
              iifname "lo" accept;

              # Allow DHCPv4 from internal networks to the router.
              iifname { "lan", "wifi", "opt1", "tailscale0" } udp dport 67 accept;
              # Allow all other traffic (like DNS, SSH) from internal networks to the router.
              iifname { "lan", "wifi", "opt1", "tailscale0" } accept;

              # Allow DHCPv6 client traffic from the ISP.
              iifname "peepee" udp sport 547 udp dport 546 accept;

              # Allow essential ICMP/ICMPv6 from the WAN.
              iifname "peepee" icmpv6 type { echo-reply, destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept;
              iifname "peepee" icmp type echo-request accept;
            }

            chain forward {
              type filter hook forward priority filter; policy drop;

              ct state established,related accept;

              # Clamp TCP MSS on outgoing WAN packets to prevent MTU issues.
              oifname "peepee" tcp flags syn tcp option maxseg size set rt mtu;

              # Allow traffic from internal networks to be forwarded to the internet.
              iifname { "lan", "wifi", "opt1", "tailscale0" } oifname "peepee" accept;

              # Allow traffic between your LANs and Tailscale network.
              iifname { "lan", "wifi", "opt1" } oifname "tailscale0" accept;
              iifname "tailscale0" oifname { "lan", "wifi", "opt1" } accept;
            }
          '';
        };

        nat = {
          family = "ip"; # NAT is IPv4-specific.
          content = ''
            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;

              # If a packet is going out the WAN interface, masquerade it.
              # (i.e., change its source IP to the router's public IP).
              oifname "peepee" masquerade
            }
          '';
        };
      };
    };
  };
}
