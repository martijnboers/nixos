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
  };

  config = mkIf cfg.enable (
    let
      zones = [
        {
          name = "plebian.nl";
          serial = 5;
          records = ''
            ; Default A Records
            *		IN	A	65.109.132.206 
            @		IN	A	65.109.132.206

            ; Subdomains
            ns1     	IN      A       65.109.132.206 ; plebian is main ns domain

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
          serial = 5;
          records = ''
            ; Normal records
            @       IN      A       65.109.132.206
            *       IN      A       65.109.132.206

            ; Subdomains
            ns1     IN      A       65.109.132.206 ; boers.email fallback
            test    IN      A       127.0.0.1 

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
          serial = 5;
          records = ''
            ; Normal records
            @       IN      A       65.109.132.206

            ; Subdomains
          '';
        }
      ];

      mkBindMasterZoneEntry = name: {
        master = true;
        file = "/etc/bind/${name}.zone";
        extraConfig = ''
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
            value = mkBindMasterZoneEntry zone.name;
          }) zones
        );
      };
    }
  );
}
