{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.coredns;
in {
  options.hosts.coredns = {
    enable = mkEnableOption "CoreDNS server enable";
  };

  config = mkIf cfg.enable {
    services.coredns.enable = true;

    networking.firewall.allowedTCPPorts = [53];
    networking.firewall.allowedUDPPorts = [53];

    services.coredns.config = ''
      .:53 {
        log
        errors
        . {
          forward . 9.9.9.9
          cache
        }
        hadouken.plebian.local {
          template IN A {
            answer "{{ .Name }} 0 IN A 192.168.1.156"
          }
        }
        glassdoor.plebian.local {
          template IN A {
            answer "{{ .Name }} 0 IN A 192.168.1.114"
          }
        }
        router.plebian.local {
          template IN A {
            answer "{{ .Name }} 0 IN A 192.168.1.1"
          }
        }
      }
    '';
  };
}
