{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hosts.n8n;
in {
  options.hosts.n8n = {
    enable = mkEnableOption "Enable workflow automation";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."events.thuis.plebian.nl".extraConfig = ''
      tls internal
      @internal {
        remote_ip 100.64.0.0/10
      }
      handle @internal {
        reverse_proxy http://127.0.0.1:${toString config.services.n8n.settings.port}
      }
      respond 403
    '';

    services.n8n = {
      enable = true;
      webhookUrl = "events.thuis.plebian.nl";
      settings.port = 5678;
    };
  };
}
