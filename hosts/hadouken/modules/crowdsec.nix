{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.crowdsec;
in {
  options.hosts.crowdsec = {
    enable = mkEnableOption "Crowdsourced banlists and patterns";
  };

  config = mkIf cfg.enable {
    services.crowdsec-firewall-bouncer = {
      enable = true;
      settings = {
        api_url = config.services.crowdsec.settings.api.server.listen_uri;
      };
    };
    services.crowdsec = {
      settings = {
        api.server = {
          listen_uri = "127.0.0.1:8765";
        };
      };
    };
  };
}
