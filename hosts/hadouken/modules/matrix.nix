{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.matrix;
in
{
  options.hosts.matrix = {
    enable = mkEnableOption "Matrix chat federation";
  };

  config = mkIf cfg.enable {
    age.secrets.synapse = {
      file = ../../../secrets/synapse.age;
      owner = "matrix-synapse";
      group = "matrix-synapse";
    };

    services.matrix-synapse = {
      enable = true;
      dataDir = "/mnt/zwembad/app/synapse";
      extraConfigFiles = [ config.age.secrets.synapse.path ];
      settings = {
        server_name = "boers.email";
        public_baseurl = "https://boers.email";
        enable_registration = false;
	dynamic_thumbnails = true;
      };
      settings.listeners = [
        {
          port = 5553;
          bind_addresses = [ "0.0.0.0" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = true;
            }
          ];
        }
      ];
    };
  };
}
