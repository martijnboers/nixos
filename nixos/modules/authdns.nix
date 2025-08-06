# https://github.com/Mic92/dotfiles/blob/8af9de2f46a890b626a435b2da2cdf80e5317c48/machines/eve/modules/knot/default.nix#L41
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.hosts.authdns;
  rekkaken = {
    ipv4 = "46.62.135.158";
    ipv6 = "2a01:4f9:c013:98b::1";
  };
  shoryuken = {
    ipv4 = "157.180.79.166";
    ipv6 = "2a01:4f9:c013:c5fa::1";
  };

  tsigKeyName = "plebs4diamonds";

  zones = [
    {
      name = "plebian.nl";
      records = ''
        *           IN      A       ${shoryuken.ipv4}
        *           IN      AAAA    ${shoryuken.ipv6}
        @           IN      A       ${shoryuken.ipv4}
        @           IN      AAAA    ${shoryuken.ipv6}

        headscale   IN      A       ${rekkaken.ipv4}
        headscale   IN      AAAA    ${rekkaken.ipv6}

        protonmail2._domainkey  IN CNAME protonmail2.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
        protonmail3._domainkey  IN CNAME protonmail3.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
        protonmail._domainkey   IN CNAME protonmail.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
        @           IN      MX      10 mail.protonmail.ch.
        @           IN      MX      20 mailsec.protonmail.ch.
        @           IN      TXT     "v=spf1 include:_spf.protonmail.ch ~all"
        @           IN      TXT     "protonmail-verification=32708d22ad3e171f23afdebe270278d6d914d5d3"
        _dmarc      IN      TXT     "v=DMARC1; p=quarantine"
      '';
    }
    {
      name = "boers.email";
      records = ''
        *       IN      A       ${shoryuken.ipv4}
        *       IN      AAAA    ${shoryuken.ipv6}
        @       IN      A       ${shoryuken.ipv4}
        @       IN      AAAA    ${shoryuken.ipv6}

        protonmail2._domainkey  IN CNAME protonmail2.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
        protonmail3._domainkey  IN CNAME protonmail3.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
        protonmail._domainkey   IN CNAME protonmail.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
        @                       IN      MX      10 mail.protonmail.ch.
        @                       IN      MX      20 mailsec.protonmail.ch.
        @                       IN      TXT     "v=spf1 include:_spf.protonmail.ch ~all"
        @                       IN      TXT     "protonmail-verification=cb21de1e06a960ace5877daf0cf9b22426961ae4"
        _dmarc                  IN      TXT     "v=DMARC1; p=quarantine"
      '';
    }
    {
      name = "noisesfrom.space";
      records = ''
        @       IN      A       ${shoryuken.ipv4}
        @       IN      AAAA    ${shoryuken.ipv6}
      '';
    }
  ];

  mkZoneFile =
    zoneInfo:
    pkgs.writeText "${zoneInfo.name}.zone" ''
      @ 3600 IN SOA ns1.${zoneInfo.name}. hostmaster.${zoneInfo.name}. (
        1 
        7200       
        3600       
        86400      
        3600       
      )

      $TTL 300
      @   IN  NS  ns1.${zoneInfo.name}.
      @   IN  NS  ns2.${zoneInfo.name}.

      ns1 IN  A   ${rekkaken.ipv4}
      ns2 IN  A   ${shoryuken.ipv4}
      ns1 IN  AAAA   ${rekkaken.ipv6}
      ns2 IN  AAAA   ${shoryuken.ipv6}

      ${zoneInfo.records}
    '';

in
{
  options.hosts.authdns = {
    enable = lib.mkEnableOption "Authoritative DNS for own domains (using Knot)";
    master = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether this server is the master";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];

    age.secrets.tsigkey = {
      file = ../../secrets/tsigkey.age;
      owner = "knot";
      group = "knot";
    };

    services.knot = {
      enable = true;
      keyFiles = [ config.age.secrets.tsigkey.path ];
      settings = {
        server = {
          listen = [
            "0.0.0.0@53"
            "::@53"
          ];
        };

        remote = [
          {
            id = "rekkaken";
            address = [ rekkaken.ipv4 ];
            key = tsigKeyName;
          }
          {
            id = "shoryuken";
            address = [ shoryuken.ipv4 ];
            key = tsigKeyName;
          }
        ];

        acl = [
          {
            id = "allow-transfers-from-slave";
            remote = [ "shoryuken" ];
            action = "transfer";
          }
          {
            id = "allow-notifies-from-master";
            remote = [ "rekkaken" ];
            action = "notify";
          }
        ];

        policy = [
          {
            id = "default";
            algorithm = "RSASHA256";
            ksk-size = 4096;
            zsk-size = 2048;
          }
        ];

        template = [
          {
            id = "primary-template";
            dnssec-signing = true;
            notify = [ "shoryuken" ];
            acl = [ "allow-transfers-from-slave" ];
            zonefile-sync = "-1";
            zonefile-load = "difference-no-serial";
            serial-policy = "dateserial";
            journal-content = "all";
            semantic-checks = "on";
          }
          {
            id = "secondary-template";
            master = [ "rekkaken" ];
            acl = [ "allow-notifies-from-master" ];
            zonefile-sync = "-1";
            zonefile-load = "difference-no-serial";
            serial-policy = "dateserial";
            journal-content = "all";
            semantic-checks = "on";
          }
        ];

        zone = lib.map (zoneInfo: {
          domain = zoneInfo.name;
          file = mkZoneFile zoneInfo;
          template = if cfg.master then "primary-template" else "secondary-template";
        }) zones;
      };
    };
  };
}
