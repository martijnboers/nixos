{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.adguard;
in {
  options.hosts.adguard = {
    enable = mkEnableOption "Adguard say no to ads";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."dns.thuis".extraConfig = ''
         tls internal
         @internal {
           remote_ip 100.64.0.0/10
         }
         handle @internal {
           reverse_proxy http://localhost:${toString config.services.adguardhome.port}

           handle_path /dns-query/* {
              reverse_proxy http://127.0.0.1:${toString config.services.adguardhome.settings.tls.port_dns_over_tls}
           }
         }
      respond 403
    '';

    services.adguardhome = {
      enable = true;
      mutableSettings = false;
      allowDHCP = false;
      host = "127.0.0.1"; # for webgui but using caddy reverse proxy

      settings = {
        dns = {
          ratelimit = 0;
          bind_hosts = ["0.0.0.0"]; # this can bind to tailscale
          upstream_dns = [
            "https://security.cloudflare-dns.com/dns-query"
            "https://dns.quad9.net/dns-query"
          ];
          allowed_clients = [
            "100.64.0.0/10"
          ];
          use_http3_upstreams = true;
          upstream_mode = "parallel";
          bootstrap_dns = ["9.9.9.9" "208.67.222.222"];
          protection_enabled = true;
          enable_dnssec = true; # make it harder to tamper
          # serve_plain_dns = false; # only allow dns over tls
          blocked_hosts = ["version.bind" "id.server" "hostname.bind"];
          cache_size = 4194304;
        };
        tls = {
          enabled = false;
          server_name = "dns.thuis";
          port_https = 0; # 0 is disabled
          port_dns_over_tls = 853;
          force_https = false;
          allow_unencrypted_doh = true; # caddy does this
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
