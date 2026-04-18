{ pkgs, ... }:
{
  networking = {
    hostName = "hadouken";
    hostId = "1b936a2a";
  };

  imports = [
    ./modules/monitoring.nix
    ./modules/detection.nix
    ./modules/mastodon.nix
    ./modules/paperless.nix
    ./modules/microbin.nix
    ./modules/calendar.nix
    ./modules/database.nix
    ./modules/garage.nix
    ./modules/bincache.nix
    ./modules/storage.nix
    ./modules/matrix.nix
    ./modules/immich.nix
    ./modules/shares.nix
    ./modules/caddy.nix
    ./modules/atuin.nix
    ./modules/media.nix
  ];

  hosts.shares.enable = true;
  hosts.caddy.enable = true;
  hosts.media.enable = true;
  hosts.tailscale.enable = true;
  hosts.monitoring.enable = true;
  hosts.matrix.enable = true;
  hosts.mastodon.enable = true;
  hosts.microbin.enable = true;
  hosts.changedetection.enable = true;
  hosts.immich.enable = true;
  hosts.prometheus.enable = true;
  hosts.calendar.enable = true;
  hosts.database.enable = true;
  hosts.garage.enable = true;
  hosts.atuin.enable = true;
  hosts.paperless.enable = true;
  hosts.bincache.enable = true;
  hosts.nymvpn.enable = true;

  users = {
    groups.notes.members = [ "caddy" ];
  };

  systemd.services.loki = {
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
    serviceConfig.RestartSec = 10;
  };

  hosts.borg = {
    enable = true;
    repository = "ssh://gak69wyz@gak69wyz.repo.borgbase.com/./repo";
    paths = [ "/mnt/zwembad/app" ];
  };

  # Heat management intel cpu
  services.thermald = {
    enable = true;
    configFile =
      pkgs.writeText "thermal-conf.xml" # xml
        ''
          <?xml version="1.0"?>
          <ThermalConfiguration>
            <Platform>
              <Name>Intel NUC Power Limit</Name>
              <!-- 
                   We are defining a "Passive" trip point. 
                   When the CPU hits 80°C, thermald will begin limiting power
                   to keep it from ever reaching the 95°C panic zone.
              -->
              <ThermalZones>
                <ThermalZone>
                  <Type>package</Type>
                  <TripPoints>
                    <TripPoint>
                      <SensorType>package_temp</SensorType>
                      <Temperature>80000</Temperature> <!-- 80 degrees Celsius -->
                      <Type>Passive</Type>
                      <CoolingDevice>
                        <Type>rapl_controller</Type>
                        <SamplingPeriod>1</SamplingPeriod>
                        <!-- 
                             TargetState is in Microwatts. 
                             20000000 = 20 Watts. 
                             This keeps the i5-1240p in its most efficient window.
                        -->
                        <TargetState>20000000</TargetState> 
                      </CoolingDevice>
                    </TripPoint>
                  </TripPoints>
                </ThermalZone>
              </ThermalZones>
            </Platform>
          </ThermalConfiguration>
        '';
  };

  hosts.openssh = {
    enable = true;
    allowUsers = [
      "*@100.64.0.0/10"
      "*@10.30.0.0/24"
    ];
  };

  # Server defaults
  hosts.server.enable = true;

  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [
        "zwembad"
        "zolder"
      ];
    };

    # Silent Boot
    # https://wiki.archlinux.org/title/Silent_boot
    kernelParams = [
      "quiet"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
