{
  config,
  ...
}:

let
  ipv6Prefix = config.hidden.wan_ips.thuis_ipv6;
  hadouken = {
    ipv4 = "10.30.0.2";
    ipv6 = "${ipv6Prefix}:b00f:4a21:bff:fe55:90f5";
  };
  tatsumaki = {
    ipv4 = "10.10.0.103";
    ipv6 = "${ipv6Prefix}:c0de:2e0:4cff:fe34:7c67";
  };
in
{
  networking = {
    firewall.enable = false;
    useNetworkd = true;
    nftables = {
      enable = true;
      tables = {
        firewall = {
          family = "inet";
          content = # bash
            ''
              set blocklist_v4 {
                type ipv4_addr
                flags interval
              }

              chain input {
                # -10, before tailscale injections
                type filter hook input priority filter -10; policy drop;

                # --- BASELINE STATEFUL RULES ---
                ct state invalid drop;
                ct state established,related accept;

                iifname "peepee" ip saddr @blocklist_v4 drop comment "Drop traffic from WAN matching dynamic IPv4 blocklist";
                iifname "lo" accept;

                # --- SERVICES ---
                iifname { "peepee", "lan", "wifi" } udp dport 51820 accept comment "Wireguard setup connections";
                iifname { "peepee", "lan", "wifi" } udp dport 41641 accept comment "Tailscale setup connections";

                iifname { "lan", "tailscale0" } tcp dport 22 ct state new limit rate 10/minute accept comment "Allow SSH management";
                iifname { "lan", "wifi", "tailscale0" } udp dport 53 accept comment "DNS";
                iifname { "lan", "wifi", "tailscale0" } tcp dport 53 accept comment "DNS";
                iifname { "lan", "wifi" } udp dport 67 accept comment "DHCP";

                # Allow IPv6 Neighbor Discovery and Ping 
                iifname { "lan", "wifi", "tailscale0", "opt1" } icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert, nd-router-solicit, echo-request } accept;

                iifname { "lan", "wifi", "tailscale0" } tcp dport { 80, 443 } accept comment "Websites hosted on router";

                # --- ISP SERVICE RULES (WAN) ---
                iifname "peepee" udp sport 547 udp dport 546 accept;
                iifname "peepee" icmpv6 type { echo-reply, destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept;
                iifname "peepee" icmp type echo-request limit rate 2/second accept;
              }

              chain forward {
                # -10, before tailscale injections
                type filter hook forward priority filter -10; policy drop;

                # --- BASELINE STATEFUL FORWARDING ---
                ct state invalid drop;
                ct state established,related accept;

                # Essential for HTTPS/Curl (Path MTU Discovery)
                meta l4proto ipv6-icmp icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, echo-request, echo-reply } accept;

                iifname "peepee" ip saddr @blocklist_v4 drop comment "Drop forwarded traffic from WAN matching dynamic IPv4 blocklist";
                oifname "peepee" tcp flags syn tcp option maxseg size set rt mtu;

                # --- INBOUND PORT FORWARDING RULES ---
                iifname "peepee" oifname "opt1" ip daddr ${hadouken.ipv4} meta l4proto { tcp, udp } th dport 22000 ct state new accept comment "Syncthing IPv4";
                iifname "peepee" oifname "opt1" ip6 daddr ${hadouken.ipv6} meta l4proto { tcp, udp } th dport 22000 ct state new accept comment "Syncthing IPv6";
                iifname "peepee" oifname "lan" ip daddr ${tatsumaki.ipv4} tcp dport 8333 ct state new accept comment "Bitcoin";
                iifname "peepee" oifname "lan" ip6 daddr ${tatsumaki.ipv6} tcp dport 8333 ct state new accept comment "Bitcoin";

                # --- GRANULAR INTER-LAN FORWARDING ---
                iifname { "lan", "opt1" } oifname { "lan", "opt1" } accept;
                iifname { "wifi" } oifname { "opt1" } tcp dport { 80, 443 } accept;
                iifname { "wifi", "opt1" } oifname { "wifi", "opt1" } udp dport 41641 accept comment "Allow Tailscale direct connections between WiFi and Opt1";
                iifname "lan" oifname "wifi" tcp dport { 80, 443 } accept comment "Allow LAN to access IoT device web UIs on WiFi";

                # --- INTERNET EGRESS RULES ---
                iifname { "lan", "wifi", "opt1", "tailscale0", "wg0" } oifname "peepee" accept;

                # --- TAILSCALE SUBNET ROUTING ---
                iifname { "lan", "wifi", "opt1" } oifname "tailscale0" accept;
                iifname "tailscale0" oifname { "lan", "wifi", "opt1" } accept;
              }
            '';
        };

        nat = {
          family = "ip";
          content = ''
            chain prerouting {
              type nat hook prerouting priority dstnat; policy accept;

              # --- IPV4 PORT FORWARDING (DNAT) ---
              iifname "peepee" tcp dport 22000 dnat to ${hadouken.ipv4};
              iifname "peepee" udp dport 22000 dnat to ${hadouken.ipv4};
              iifname "peepee" tcp dport 8333 dnat to ${tatsumaki.ipv4};
            }

            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;

              # --- OUTBOUND IPV4 NAT ---
              oifname "peepee" masquerade;
            }
          '';
        };
      };
    };
  };
}
