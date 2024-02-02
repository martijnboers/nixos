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
            {
              domain = "vaultwarden.thuis.plebian.nl";
              answer = "100.64.0.2";
            }
            {
              domain = "atuin.thuis.plebian.nl";
              answer = "100.64.0.2";
            }
            {
              domain = "dns.thuis.plebian.nl";
              answer = "100.64.0.2";
            }
            {
              domain = "transmission.thuis.plebian.nl";
              answer = "100.64.0.5";
            }
          ];
        };
        filters = [
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt";
            name = "https://github.com/FadeMind/hosts.extras";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts";
            name = "https://github.com/FadeMind/hosts.extras";
          }
          {
            enabled = true;
            url = "https://v.firebog.net/hosts/static/w3kbl.txt";
            name = "https://firebog.net/about";
          }
          {
            enabled = true;
            url = "https://v.firebog.net/hosts/static/w3kbl.https://firebog.net/about";
            name = "https://github.com/FadeMind/hosts.extras";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt";
            name = "https://github.com/matomo-org/referrer-spam-list";
          }
          {
            enabled = true;
            url = "https://adaway.org/hosts.txt";
            name = "https://adaway.org";
          }
          {
            enabled = true;
            url = "https://someonewhocares.org/hosts/zero/hosts";
            name = "https://someonewhocares.org/";
          }
          {
            enabled = true;
            url = "https://v.firebog.net/hosts/Easyprivacy.txt";
            name = "https://firebog.net/";
          }
          {
            enabled = true;
            url = "https://v.firebog.net/hosts/Prigent-Ads.txt";
            name = "https://firebog.net/";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts";
            name = "https://github.com/FadeMind/hosts.extras";
          }
          {
            enabled = true;
            url = "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt";
            name = "https://frogeye.fr";
          }
          {
            enabled = true;
            url = "https://v.firebog.net/hosts/AdguardDNS.txt";
            name = "AdGuardDNS";
          }
          {
            enabled = true;
            url = "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt";
            name = "https://github.com/DandelionSprout/adfilt";
          }
          {
            enabled = true;
            url = "https://osint.digitalside.it/Threat-Intel/lists/latestdomains.txt";
            name = "https://digitalside.it";
          }
          {
            enabled = true;
            url = "https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt";
            name = "https://disconnect.me/";
          }
          {
            enabled = true;
            url = "https://v.firebog.net/hosts/Prigent-Crypto.txt";
            name = "https://firebog.net/";
          }
          {
            enabled = true;
            url = "https://phishing.army/download/phishing_army_blocklist_extended.txt";
            name = "https://phishing.army";
          }
          {
            enabled = true;
            url = "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt";
            name = "https://github.com/Ultimate-Hosts-Blacklist/quidsup_notrack_trackers";
          }
          {
            enabled = true;
            url = "https://zerodot1.gitlab.io/CoinBlockerLists/hosts_browser";
            name = "https://gitlab.com/ZeroDot1/CoinBlockerLists";
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
