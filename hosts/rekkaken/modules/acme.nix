{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.acme;
in
{
  options.hosts.acme = {
    enable = mkEnableOption "CA server";
  };

  config = mkIf cfg.enable {
    services.step-ca = {
      enable = false;
      address = "0.0.0.0";
      port = 5443;
      openFirewall = false; # do on headscale
      intermediatePasswordFile = config.age.secrets.intermediate-key.path;

      settings = builtins.fromJSON ''
      '';

    };

    age.secrets = {
      intermediate-key = {
        file = ../../../secrets/intermediate-key.age;
        # owner = "caddy";
      };
    };
  };
}
