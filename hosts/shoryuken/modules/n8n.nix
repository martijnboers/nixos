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
    services.caddy.virtualHosts."n8n.cloud.plebian.nl".extraConfig = ''
      reverse_proxy http://localhost:${toString config.services.n8n.settings.port}
    '';

    services.n8n = {
      enable = true;
      webhookUrl = "n8n.cloud.plebian.nl";
      settings = {
        port = 5678;
      };
    };
  };
}
