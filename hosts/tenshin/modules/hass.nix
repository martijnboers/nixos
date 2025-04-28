{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.hosts.hass;
in
{
  options.hosts.hass = {
    enable = mkEnableOption "Home assistant server";
  };

  config = mkIf cfg.enable {
    services.caddy.virtualHosts."hass.thuis".extraConfig = ''
        tls {
          issuer internal { ca tenshin }
        }
        @internal {
         remote_ip 100.64.0.0/10
        }
        handle @internal {
          reverse_proxy http://127.0.0.1:${toString config.services.home-assistant.config.http.server_port}
        }
      respond 403
    '';
    services.borgbackup.jobs.default.paths = [ config.services.home-assistant.configDir ];
    services.home-assistant = {
      enable = true;
      extraPackages =
        python3Packages: with python3Packages; [
          ibeacon-ble # don't use the bluetooth stuff...
          numpy
          pyturbojpeg
          gtts
          aiohttp-fast-zlib
        ];
      extraComponents = [
        "shelly"
        "apprise"
      ];
      config = {
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [
            "127.0.0.1"
          ];
        };
        notify = {
          name = "hass";
          platform = "apprise";
          url = "!secret gotify";
        };
        automation = [
          {
            alias = "Wasmachine klaar";
            triggers = [
              {
                type = "power";
                device_id = "4e2fe9e41d51fef74c47a77827ae6b1e";
                entity_id = "2515f0aab67ddf77f97860da984cee3c";
                domain = "sensor";
                trigger = "device";
                above = 0;
                below = 3;
                for = {
                  hours = 0;
                  minutes = 5;
                  seconds = 0;
                };
              }
            ];
            actions = [
              {
                action = "notify.hass";
                data = {
                  message = "Wasmachine klaar";
                };
              }
            ];
            mode = "single";
          }
          {
            alias = "Droger klaar";
            triggers = [
              {
                type = "power";
                device_id = "8d55ba928bdfe0dd6f80841b5fa97e35";
                entity_id = "584786a29162e17c035e79cc87570908";
                domain = "sensor";
                trigger = "device";
                above = 0;
                below = 3;
                for = {
                  hours = 0;
                  minutes = 5;
                  seconds = 0;
                };
              }
            ];
            actions = [
              {
                action = "notify.hass";
                data = {
                  message = "Droger klaar";
                };
              }
            ];
            mode = "single";
          }
          {
            alias = "Waterfontein";
            triggers = [
              {
                type = "power";
                device_id = "4d6a9602129c08b32761b464a1ab3679";
                entity_id = "889328ee0f23a43b93ce17d55d018866";
                domain = "sensor";
                trigger = "device";
                above = 0;
                below = 1;
                for = {
                  hours = 0;
                  minutes = 5;
                  seconds = 0;
                };
              }
            ];
            actions = [
              {
                action = "notify.hass";
                data = {
                  message = "Otto booped fontein";
                };
              }
            ];
            mode = "single";
          }
        ];
        homeassistant = {
          name = "Thuis";
          unit_system = "metric";
          temperature_unit = "C";
        };
      };
    };
  };
}
