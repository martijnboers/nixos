{ pkgs, ... }:

{
  systemd.services.blocklist = {
    description = "High-performance IP blocklist service (Shell version)";

    path = [
      pkgs.curl
      pkgs.gnugrep
      pkgs.gnused
      pkgs.coreutils # for sort, tr
      pkgs.nftables
      pkgs.iprange
    ];

    after = [
      "network-online.target"
      "nftables.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig.User = "root";

    script = # bash
      ''
        #!${pkgs.stdenv.shell}
        set -e 
        echo "Starting nftables blocklist update..."

        IPV4_URLS=(
          "https://iplists.firehol.org/files/firehol_level2.netset"
          "http://cinsscore.com/list/ci-badguys.txt"
          "https://iplists.firehol.org/files/spamhaus_drop.netset"
          "https://iplists.firehol.org/files/iblocklist_ciarmy_malicious.netset"
          "https://iplists.firehol.org/files/dshield.netset"
          "https://iplists.firehol.org/files/blocklist_de.ipset"
          "https://iplists.firehol.org/files/tor_exits.ipset"
          "https://gist.githubusercontent.com/martijnboers/7c98a97df2bc68944a05d2e80299fdaa/raw/6c07ef4dccf6cbf778293a20e35cda608cd87688/gistfile1.txt"
        )

        TMP_IPV4_LIST_RAW="/tmp/blocklist_v4_raw.txt"
        TMP_IPV4_LIST_CLEAN="/tmp/blocklist_v4_clean.txt"
        TMP_NFT_COMMAND_FILE="/tmp/blocklist_command.nft"

        rm -f "$TMP_IPV4_LIST_RAW" "$TMP_IPV4_LIST_CLEAN" "$TMP_NFT_COMMAND_FILE"

        echo "Fetching and preparing IPv4 lists..."

        for url in "''${IPV4_URLS[@]}"; do
          SINGLE_URL_TMP=$(mktemp)
          curl -sS -f -L "$url" -o "$SINGLE_URL_TMP"
          LINE_COUNT=$(LC_ALL=C grep -cE '^[0-9./]+$' "$SINGLE_URL_TMP" || true)
          printf "  - Found %'d IPs/CIDRs in %s\n" "$LINE_COUNT" "$(basename "$url")"
          cat "$SINGLE_URL_TMP" >> "$TMP_IPV4_LIST_RAW"
          rm -f "$SINGLE_URL_TMP"
        done

        echo "Filtering, sorting, and optimizing IPs... This may take a moment."
        # 1. grep: Keep only valid-looking lines from the combined raw file.
        # 2. sort -u: Remove exact duplicates.
        # 3. iprange --optimize: Merge overlapping ranges to produce a perfect, conflict-free list.

        RAW_COUNT=$(LC_ALL=C grep -cE '^[0-9./]+$' "$TMP_IPV4_LIST_RAW" || true)
        printf "Total unique IPs/CIDRs before optimization: %'d\n" "$RAW_COUNT"

        grep -E '^[0-9./]+$' "$TMP_IPV4_LIST_RAW" | sort -u | iprange --optimize > "$TMP_IPV4_LIST_CLEAN"

        FINAL_COUNT=$(LC_ALL=C wc -l < "$TMP_IPV4_LIST_CLEAN")
        printf "Total IPs/CIDRs after optimization: %'d\n" "$FINAL_COUNT"
        echo "Preparation complete."

        if [ -s "$TMP_IPV4_LIST_CLEAN" ]; then
          echo "Updating IPv4 nftables set using a single, file-based transaction..."
          
          echo "flush set inet firewall blocklist_v4" > "$TMP_NFT_COMMAND_FILE"
          echo -n "add element inet firewall blocklist_v4 { " >> "$TMP_NFT_COMMAND_FILE"
          cat "$TMP_IPV4_LIST_CLEAN" | tr '\n' ',' | sed 's/,$//' >> "$TMP_NFT_COMMAND_FILE"
          echo " }" >> "$TMP_NFT_COMMAND_FILE"

          nft -f "$TMP_NFT_COMMAND_FILE"
          echo "IPv4 update complete."
        else
          echo "Warning: No valid IPs found after cleaning. No update was performed."
        fi

        rm -f "$TMP_IPV4_LIST_RAW" "$TMP_IPV4_LIST_CLEAN" "$TMP_NFT_COMMAND_FILE"
      '';
  };

  systemd.timers.blocklist = {
    description = "Periodically update nftables IP blocklists";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec = "6h";
      RandomizedDelaySec = "5min";
    };
  };
}
