{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.hosts.desktop;
in
{
  options.hosts.desktop = {
    enable = mkEnableOption "Base desktop";
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      TERM = "xterm-kitty";
      BROWSER = "librewolf";
    };

    boot.supportedFilesystems = [ "nfs" ];

    fileSystems =
      let
        mkNfsShare = name: {
          "/mnt/${name}" = {
            device = "hadouken.machine.thuis:/${name}";
            fsType = "nfs";
            options = [
              "rsize=1048576" # bigger read+write sizes
              "wsize=1048576" # good for bigger files
              "x-systemd.automount" # lazyloading, solves tailscale chicken&egg
              "_netdev" # this makes the .mount unit require network-online.target
            ];
          };
        };
      in
      lib.attrsets.mergeAttrsList (
        map mkNfsShare [
          "music"
          "share"
          "notes"
        ]
      );

    # Enable networkingmanager
    networking.networkmanager.enable = true;

    # Enable opengpl
    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };

    programs.dconf.enable = true; # used for stylix

    # Yubikey
    programs.yubikey-touch-detector.enable = true;
    services.yubikey-agent.enable = true;
    # for smartcard support
    services = {
      pcscd.enable = true;
      udev.packages = [ pkgs.yubikey-personalization ];
    };

    # Access QMK without sudo
    hardware.keyboard.qmk.enable = true;

    # Enable sound with pipewire.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
