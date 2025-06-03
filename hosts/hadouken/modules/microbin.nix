{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.microbin;
in
{
  options.hosts.microbin = {
    enable = mkEnableOption "Selfhosted pastebin alterative";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."microbin.thuis".extraConfig = ''
      import headscale
      coraza_waf {
        load_owasp_crs
        directives `
          Include @coraza.conf-recommended
          SecRuleEngine On
        `
      }
      handle @internal {
        reverse_proxy http://localhost:${toString config.services.microbin.settings.MICROBIN_PORT}
      }
      respond 403
    '';

    age.secrets.microbin.file = ../../../secrets/microbin.age;

    services.microbin = {
      enable = true;
      passwordFile = config.age.secrets.microbin.path;
      settings = {
        MICROBIN_PUBLIC_PATH = "https://p.plebian.nl";
        MICROBIN_PORT = 8080;
        MICROBIN_HIDE_LOGO = true;
        MICROBIN_HIDE_HEADER = true;
        MICROBIN_EDITABLE = false;
        MICROBIN_HIDE_FOOTER = true;
        MICROBIN_READONLY = true;
        MICROBIN_GC_DAYS = 2;
        MICROBIN_ENABLE_BURN_AFTER = true;
        MICROBIN_DEFAULT_BURN_AFTER = 10;
        MICROBIN_DEFAULT_EXPIRY = "10min";
        MICROBIN_DISABLE_TELEMETRY = true;
        MICROBIN_LIST_SERVER = false;
      };
    };
  };
}
