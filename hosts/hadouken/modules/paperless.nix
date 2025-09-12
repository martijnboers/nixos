{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.paperless;
in
{
  options.hosts.paperless = {
    enable = mkEnableOption "Paperless NGX";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts = {
      "paper.thuis".extraConfig = ''
        import headscale
        handle @internal {
           reverse_proxy http://127.0.0.1:${toString config.services.paperless.port}
        }
        respond 403
      '';
    };

    age.secrets.paperless = {
      file = ../../../secrets/paperless.age;
      owner = config.services.paperless.user;
    };

    services.paperless = {
      enable = true;
      passwordFile = config.age.secrets.paperless.path;
      database.createLocally = true;
      configureTika = true;
      domain = "paper.thuis";
      dataDir = "/mnt/zwembad/app/paperless";
    };
  };
}
