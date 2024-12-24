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

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Make it possible to detect printers
    services.avahi = {
      enable = true;
      openFirewall = true;
    };

    # Get SMTP endpoint for proton
    services.protonmail-bridge.enable = true;

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
