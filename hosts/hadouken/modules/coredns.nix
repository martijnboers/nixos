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
        errors
        forward . 8.8.8.8 8.8.4.4
        hosts {
          192.168.1.156  hadouken.plebian.local
          192.168.1.114  glassdoor.plebian.local
          192.168.1.1    router.plebian.local
          fallthrough
        }
      }
    '';
  };
}
