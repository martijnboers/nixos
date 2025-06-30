{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.authdns;
in
{
  options.hosts.authdns = {
    enable = mkEnableOption "Authorative DNS for own domains";
    master = mkOption {
      type = types.bool;
      default = false;
      description = "should have dnsec keys";
    };
  };

  config = mkIf cfg.enable (
    let
      shoryken = "157.180.79.166";
      rekkaken = "46.62.135.158";

      zones = [
        {
          name = "plebian.nl";
          serial = 8;
          records = ''
            ; Default A Records
            *		IN	A	${shoryken}
            @		IN	A	${shoryken}

            ; Subdomains
            ns1     	IN      A       ${shoryken} 					;  plebian.nl is fallback
            headscale   IN      A       ${rekkaken} 					;  headscale runs on other vps

            ; CNAME Records
            protonmail2._domainkey.plebian.nl.	IN	CNAME	protonmail2.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch. 
            protonmail3._domainkey.plebian.nl.	IN	CNAME	protonmail3.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch.
            protonmail._domainkey.plebian.nl.		IN	CNAME	protonmail.domainkey.dvrrd4tde45wzezsahqogxqdpslvvh2xm6u6ldr3lksode54v6cua.domains.proton.ch. 

            ; MX Records
            @		IN	MX	20 mailsec.protonmail.ch.
            @		IN	MX	10 mail.protonmail.ch.

            ; TXT Records
            @		IN	TXT	"v=spf1 include:_spf.protonmail.ch ~all"
            @		IN	TXT	"protonmail-verification=32708d22ad3e171f23afdebe270278d6d914d5d3"
            _dmarc	IN	TXT	"v=DMARC1; p=quarantine"
          '';
        }
        {
          name = "boers.email";
          serial = 8;
          records = ''
            ; Normal records
            @       IN      A       ${shoryken}
            *       IN      A       ${shoryken}

            ; Subdomains
            ns1     IN      A       ${rekkaken} ; boers.email is main ns domain

            ; CNAME Records
            protonmail2._domainkey  IN      CNAME   protonmail2.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
            protonmail3._domainkey  IN      CNAME   protonmail3.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.
            protonmail._domainkey   IN      CNAME   protonmail.domainkey.d7ahwj43kdveifkw73bs5sfann4io5iv2i6xo6wcunii73igt26fa.domains.proton.ch.

            ; MX Records
            @       IN      MX      10 mail.protonmail.ch.
            @       IN      MX      20 mailsec.protonmail.ch.

            ; TXT Records
            @       IN      TXT     "v=spf1 include:_spf.protonmail.ch ~all"
            @       IN      TXT     "protonmail-verification=cb21de1e06a960ace5877daf0cf9b22426961ae4"
            _dmarc  IN      TXT     "v=DMARC1; p=quarantine" 
          '';
        }
        {
          name = "noisesfrom.space";
          serial = 8;
          records = ''
            ; Normal records
            @       IN      A       ${shoryken}
            ; Subdomains
          '';
        }
      ];

      mkBindMasterZoneEntry = name: {
        file = "/etc/bind/${name}.zone"; # might need chown
        master = true;
        slaves = [ shoryken ];
      };
      mkBindSlaveZoneEntry = name: {
        file = "/etc/bind/${name}.zone";
        master = false;
        masters = [ rekkaken ];
	extraConfig = ''
          inline-signing yes;
          dnssec-policy "default";
        '';
      };

    in
    {
      networking.firewall = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };

      environment.etc = (
        listToAttrs (
          map (zone: {
            name = "bind/${zone.name}.zone";
            value = {
              text = ''
                $TTL 1h
                @       IN      SOA     ns1.plebian.nl. noreply.boers.email. (
                	${toString zone.serial} ; serial 
                	3h              	; refresh
                	1h              	; retry
                	1w              	; expire
                	1h              	; negative cache ttl
                )

                ; NS Records
                @       IN      NS      ns1.plebian.nl.
                @       IN      NS      ns1.boers.email.

                ${zone.records}
              '';
              user = "named";
              group = "named";
              mode = "0644";
            };
          }) zones
        )
      );

      services.bind = {
        enable = true;
        zones = listToAttrs (
          map (zone: {
            name = zone.name;
            value = if cfg.master then mkBindMasterZoneEntry zone.name else mkBindSlaveZoneEntry zone.name;
          }) zones
        );
      };
    }
  );
}
