{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.hosts.authdns;
  tsigKeyName = "plebs4diamonds";

  rek = {
    ipv4 = config.hidden.wan_ips.rekkaken;
    ipv6 = config.hidden.wan_ips.rekkaken_6;
  };
  shor = {
    ipv4 = config.hidden.wan_ips.shoryuken;
    ipv6 = config.hidden.wan_ips.shoryuken_6;
  };

  protonBoilerplate = ''
    @           IN      MX      10 mail.protonmail.ch.
    @           IN      MX      20 mailsec.protonmail.ch.
    @           IN      TXT     "v=spf1 include:_spf.protonmail.ch ~all"
    _dmarc      IN      TXT     "v=DMARC1; p=quarantine"
  '';

  allZones = [
    {
      name = "plebian.nl";
      records = ''
        *           IN      A       ${shor.ipv4}
        *           IN      AAAA    ${shor.ipv6}
        @           IN      A       ${shor.ipv4}
        @           IN      AAAA    ${shor.ipv6}
        openpgpkey  IN      TXT     ""
        protonmail._domainkey   IN CNAME protonmail.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
        protonmail2._domainkey  IN CNAME protonmail2.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
        protonmail3._domainkey  IN CNAME protonmail3.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
        @           IN      TXT     "protonmail-verification=32708d22ad3e171f23afdebe270278d6d914d5d3"
      ''
      + protonBoilerplate;
    }
    {
      name = "boers.email";
      records = ''
        *           IN      A       ${shor.ipv4}
        *           IN      AAAA    ${shor.ipv6}
        @           IN      A       ${shor.ipv4}
        @           IN      AAAA    ${shor.ipv6}

        headscale   IN      A       ${rek.ipv4}
        headscale   IN      AAAA    ${rek.ipv6}
        derp-map    IN      A       ${rek.ipv4}
        derp-map    IN      AAAA    ${rek.ipv6}
        derp1       IN      A       ${shor.ipv4}
        derp1       IN      AAAA    ${shor.ipv6}
        derp2       IN      A       ${rek.ipv4}
        derp2       IN      AAAA    ${rek.ipv6}

        test  	    IN 	    TXT     "hi3"

        openpgpkey  		IN TXT   ""
        protonmail._domainkey   IN CNAME protonmail.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
        protonmail2._domainkey  IN CNAME protonmail2.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
        protonmail3._domainkey  IN CNAME protonmail3.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
        @                       IN      TXT     "protonmail-verification=cb21de1e06a960ace5877daf0cf9b22426961ae4"
      ''
      + protonBoilerplate;
    }
    {
      name = "noisesfrom.space";
      records = ''
        @       IN      A       ${shor.ipv4}
        @       IN      AAAA    ${shor.ipv6}
      '';
    }
  ];

  sourceZoneFiles = builtins.listToAttrs (
    map (zoneInfo: {
      name = zoneInfo.name;
      value = pkgs.writeText "${zoneInfo.name}.zone" ''
        $TTL 300
        @ 3600 IN SOA ns1.${zoneInfo.name}. hostmaster.${zoneInfo.name}. (
          1 	; Initial Serial
          7200 	; Refresh
          3600 	; Retry
          86400 ; Expire
          3600 	; Negative Cache TTL
        )
        @   IN  NS  	ns1.${zoneInfo.name}.
        @   IN  NS  	ns2.${zoneInfo.name}.
        ns1 IN  A   	${rek.ipv4}
        ns2 IN  A   	${shor.ipv4}
        ns1 IN  AAAA   	${rek.ipv6}
        ns2 IN  AAAA   	${shor.ipv6}
        ${zoneInfo.records}
      '';
    }) allZones
  );

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
            address = [ rek.ipv4 ];
            key = tsigKeyName;
          }
          {
            id = "shoryuken";
            address = [ shor.ipv4 ];
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

        policy = lib.mkIf cfg.master [
          {
            id = "default";
            algorithm = "ECDSAP256SHA256";
          }
        ];

        template = [
          {
            id = "primary-template";
            dnssec-signing = true;
            # https://www.knot-dns.cz/docs/3.3/singlehtml/#example-4
            zonefile-sync = -1;
            zonefile-load = "difference-no-serial";
            journal-content = "all";
            notify = [ "shoryuken" ];
            acl = [ "allow-transfers-from-slave" ];
            serial-policy = "dateserial";
          }
          {
            id = "secondary-template";
            master = [ "rekkaken" ];
            acl = [ "allow-notifies-from-master" ];
          }
        ];

        zone = lib.map (
          zoneInfo:
          if cfg.master then
            {
              domain = zoneInfo.name;
              template = "primary-template";
              file = sourceZoneFiles.${zoneInfo.name};
            }
          else
            {
              domain = zoneInfo.name;
              template = "secondary-template";
            }
        ) allZones;
      };
    };
  };
}
