{
  networking.useNetworkd = true;
  networking.nftables = {
    enable = true;
    tables.firewall = {
      family = "inet";
      content = ''
        chain input {
          type filter hook input priority filter; policy drop;

          ct state established,related accept;
          iifname "lo" accept;

          # --- THE FINAL, CRITICAL FIX FOR DHCPv4 ---
          # This explicitly allows DHCP requests from your LANs to the router.
          iifname { "lan", "wifi", "opt1" } udp dport 67 accept;
          iifname { "lan", "wifi", "opt1" } accept;

          # --- The CRITICAL RULE FOR DHCPv6 (must be kept) ---
          # This allows the ISP's DHCPv6 server to reply to your router.
          iifname "peepee" udp sport 547 udp dport 546 accept;

          # --- Standard ICMP/ICMPv6 Rules ---
          iifname "peepee" icmpv6 type { echo-reply, destination-unreachable, packet-too-big, time-exceeded, parameter-problem, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert } accept;
          iifname "peepee" icmp type echo-request accept;
        }

        chain forward {
          type filter hook forward priority filter; policy drop;
          ct state established,related accept;
          iifname { "lan", "wifi", "opt1" } oifname "peepee" accept;
        }
      '';
    };
  };
}
