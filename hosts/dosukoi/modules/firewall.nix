# /etc/nixos/firewall.nix
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
          content = ''
            chain input {
              type filter hook input priority filter; policy drop;

              # --- BASELINE STATEFUL RULES ---
              ct state established,related accept;
              iifname "lo" accept;

              # --- WIREGUARD VPN SERVER ACCESS ---
              iifname "peepee" udp dport 51820 accept comment "Allow WireGuard VPN connections";

              # --- TRUSTED ACCESS TO ROUTER ---
              iifname { "lan", "wifi", "opt1", "tailscale0", "wg0" } udp dport 67 accept;
              iifname { "lan", "wifi", "opt1", "tailscale0", "wg0" } accept;

              # --- ISP SERVICE RULES (WAN) ---
              iifname "peepee" udp sport 547 udp dport 546 accept;
              iifname "peepee" icmpv6 type { echo-reply, destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept;
              iifname "peepee" icmp type echo-request accept;
            }

            chain forward {
              type filter hook forward priority filter; policy drop;

              # --- BASELINE STATEFUL FORWARDING ---
              ct state established,related accept;
              oifname "peepee" tcp flags syn tcp option maxseg size set rt mtu;

              # --- INBOUND PORT FORWARDING RULES ---
              iifname "peepee" oifname "opt1" ip daddr ${hadouken.ipv4} tcp dport { 22000, 32400 } ct state new accept comment "Allow Plex and Syncthing (TCP) to Hadouken over IPv4";
              iifname "peepee" oifname "opt1" ip daddr ${hadouken.ipv4} udp dport 22000 ct state new accept comment "Allow Syncthing (UDP) to Hadouken over IPv4";
              iifname "peepee" oifname "opt1" ip6 daddr ${hadouken.ipv6} tcp dport { 22000, 32400 } ct state new accept comment "Allow Plex and Syncthing (TCP) to Hadouken over IPv6";
              iifname "peepee" oifname "opt1" ip6 daddr ${hadouken.ipv6} udp dport 22000 ct state new accept comment "Allow Syncthing (UDP) to Hadouken over IPv6";

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
              iifname "peepee" tcp dport { 22000, 32400 } dnat to ${hadouken.ipv4};
              iifname "peepee" udp dport 22000 dnat to ${hadouken.ipv4};
            }

            chain postrouting {
              type nat hook postrouting priority srcnat; policy accept;

              # --- OUTBOUND IPV4 NAT ---
              # The existing masquerade rule will automatically handle NAT for the WireGuard clients.
              oifname "peepee" masquerade;
            }
          '';
        };
      };
    };
  };
}
