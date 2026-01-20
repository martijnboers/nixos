{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.oidc;
in
{
  options.hosts.oidc = {
    enable = mkEnableOption "Provide OIDC";
    domain = mkOption {
      type = types.str;
      description = "Public endpoint";
    };
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts.${cfg.domain} = {
      extraConfig = ''
        reverse_proxy http://localhost:1411
      '';
    };

    age.secrets = {
      oidc = {
        file = ../../secrets/oidc.age;
        owner = config.services.pocket-id.user;
      };
      geoippocket = {
        file = ../../secrets/geoip.age;
        owner = config.services.pocket-id.user;
      };
    };

    services.pocket-id = {
      enable = true;
      settings = {
        MAXMIND_LICENSE_KEY_FILE = config.age.secrets.geoippocket.path;
        ENCRYPTION_KEY_FILE = config.age.secrets.oidc.path;
        APP_URL = "https://${cfg.domain}";
        TRUST_PROXY = true;
      };
    };
  };
}
