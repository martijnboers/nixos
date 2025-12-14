{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.acme;
  stepDir = "/var/lib/step-ca";
  rootCert = ../../../secrets/keys/plebs4platinum.crt;
  intermediateKeyPath = config.age.secrets.plebs4gold.path;
  stepCAPort = 4443;
in
{
  options.hosts.acme = {
    enable = mkEnableOption "Acme config";
  };

  config = mkIf cfg.enable {
    age.secrets.plebs4gold = {
      file = ../../../secrets/plebs4gold.age;
      owner = "step-ca";
      group = "step-ca";
      mode = "440";
    };

    services.step-ca = {
      enable = true;
      address = "0.0.0.0";
      port = stepCAPort;
      intermediatePasswordFile = intermediateKeyPath;

      settings = {
        root = rootCert;
        crt = "${stepDir}/intermediate_ca.crt";
        key = "${stepDir}/intermediate_ca_key";
        dnsNames = [ "acme.thuis" ];
        db = {
          type = "badger";
          dataSource = "${stepDir}/db";
        };
        authority = {
          provisioners = [
            {
              type = "ACME";
              name = "gitgetgot";
              forceCN = true;
            }
          ];
        };
      };
    };
  };
}
