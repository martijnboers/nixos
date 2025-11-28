{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.forgejo;
  domain = "git.boers.email";
in
{
  options.hosts.forgejo = {
    enable = mkEnableOption "Synchronize zsh history files";
  };

  config = mkIf cfg.enable {
    services.openssh.settings.AcceptEnv = "GIT_PROTOCOL";

    services.forgejo = {
      enable = true;
      database.type = "postgres";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${domain}/";
          SSH_PORT = lib.head config.services.openssh.ports;
          HTTP_PORT = 5555;
        };
        service.DISABLE_REGISTRATION = true;
      };
    };
  };
}
