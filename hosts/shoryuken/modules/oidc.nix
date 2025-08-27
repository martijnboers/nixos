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
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."auth.boers.email" = {
      extraConfig = ''
        reverse_proxy http://localhost:1411
      '';
    };

    age.secrets.oidc = {
      file = ../../../secrets/oidc.age;
      owner = config.services.pocket-id.user;
    };

    services.pocket-id = {
      enable = true;
      settings = {
        MAXMIND_LICENSE_KEY_FILE = config.age.secrets.geoip.path;
	ENCRYPTION_KEY_FILE = config.age.secrets.oidc.path;
        APP_URL = "https://auth.boers.email";
        TRUST_PROXY = true;
      };
    };
  };
}
