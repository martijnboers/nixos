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

    services.davfs2.enable = true;
    boot.supportedFilesystems = [ "nfs" ];

    fileSystems."/mnt/music" = {
      device = "hadouken.machine.thuis:/music";
      fsType = "nfs";
      options = [
        "rsize=1048576" # bigger read+write sizes
        "wsize=1048576" # good for bigger files
        "x-systemd.automount" # lazyloading, solves tailscale chicken&egg
        "noauto"
      ];
    };
    fileSystems."/mnt/misc" = {
      device = "hadouken.machine.thuis:/share";
      fsType = "nfs";
      options = [
        "rsize=1048576" # bigger read+write sizes
        "wsize=1048576" # good for bigger files
        "x-systemd.automount"
        "noauto"
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
      source = config.age.secrets.dav-notes.path;
      mode = "0600";
      user = "root";
      group = "root";
    };

    age.secrets = {
      dav-notes.file = ../../secrets/dav-notes.age;
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
