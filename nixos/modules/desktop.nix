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
      DEFAULT_BROWSER = "librewolf";
    };

    users.users.martijn.extraGroups = [
      "wireshark"
      "networkmanager"
    ];

    networking = {
      networkmanager.enable = true;
      useDHCP = lib.mkDefault true; # desktops don't use networkd
    };

    # Wireshark
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };

    nixpkgs = {
      config = {
        permittedInsecurePackages = [
          "electron-32.3.3" # eol
          "libxml2-2.13.8" # CVE-2025-6021
          "libsoup-2.74.3" # gnome cves
        ];
      };
    };

    boot.supportedFilesystems = [ "nfs" ];

    fileSystems =
      let
        mkNfsShare = name: {
          "/mnt/${name}" = {
            device = "hadouken.machine.thuis:/${name}";
            fsType = "nfs";
            options = [
              # "rsize=1048576" # bigger read+write sizes
              # "wsize=1048576" # good for bigger files
              "rsize=32768" # Use smaller read/write sizes
              "wsize=32768" # Better performance over high-latency networks.
              "noatime" # Don't update file access times on read
              "tcp"
              "soft" # timeout instead of freezing
              "intr"
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

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;
      };
      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      keyboard.qmk.enable = true; # Access QMK without sudo
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
