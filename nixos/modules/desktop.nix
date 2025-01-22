{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.desktop;
in {
  options.hosts.desktop = {
    enable = mkEnableOption "Base desktop";
    wayland = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    environment.sessionVariables = {
      TERM = "xterm-kitty";
      BROWSER = "librewolf";
    };

    environment.systemPackages = with pkgs; [
      # support both 32- and 64-bit applications
      wineWowPackages.stable

      # winetricks (all versions)
      winetricks

      # native wayland support (unstable)
      wineWowPackages.waylandFull
    ];

    services.davfs2.enable = true;

    fileSystems."/mnt/music" = {
      device = "//hadouken.machine.thuis/music";
      fsType = "cifs";
      options = [
        "credentials=${config.age.secrets.smb.path}"
        "uid=1000"
        "gid=100"
        "x-systemd.automount" # lazyloading, solves tailscale chicken&egg
      ];
    };
    fileSystems."/mnt/misc" = {
      device = "//hadouken.machine.thuis/misc";
      fsType = "cifs";
      options = [
        "credentials=${config.age.secrets.smb.path}"
        "uid=1000"
        "gid=100"
        "x-systemd.automount"
      ];
    };
    fileSystems."/mnt/notes" = {
      device = "http://webdav.thuis/notes/";
      fsType = "davfs";
      options = [
        "uid=1000"
        "gid=100"
        "x-systemd.automount"
      ];
    };

    environment.etc."davfs2/secrets" = {
      text = "http://webdav.thuis/notes/ _ _";
      mode = "0600";
      user = "root";
      group = "root";
    };

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
    services.udev.packages = [pkgs.yubikey-personalization];
    programs.yubikey-touch-detector.enable = true;

    # Access QMK without sudo
    hardware.keyboard.qmk.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
