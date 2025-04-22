{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.trap;
in
{
  options.hosts.trap = {
    enable = mkEnableOption "honeytrap + containers";
  };

  config = mkIf cfg.enable {
    virtualisation = {
      oci-containers.containers = {
        changedetection-io-webdriver = {
          image = "honeytrap/honeytrap:latest";
          environment = {
            EXAMPLE = "1";
          };
          ports = [
            "127.0.0.1:8022:8022"
          ];
          # volumes = [
          #   "/somefile:/somefile"
          # ];
          extraOptions = [ "--network=bridge" ];
        };
      };
    };
  };
}
