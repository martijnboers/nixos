{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hosts.kde;
in {
  imports = [./desktop.nix];

  options.hosts.kde = {
    enable = mkEnableOption "Support KDE desktop";
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.displayManager = {
      # Enable automatic login for the user.
      autoLogin.enable = true;
      autoLogin.user = "martijn";

      #       Start in hyprland
      sddm = {
        enable = true;
        wayland.enable = true;
        settings.General.DisplayServer = "x11-user"; # rootless X11
      };
    };

    environment.plasma6.excludePackages = with pkgs.libsForQt5; [
      elisa
      khelpcenter
      konsole
    ];

    # Configure window manager
    services.desktopManager.plasma6.enable = true;

    networking.firewall = {
      allowedTCPPortRanges = [
        {
          from = 1714; # Kde connect
          to = 1764;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 1714; # Kde connect
          to = 1764;
        }
      ];
    };
  };
}
