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
    wayland = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    hosts.desktop.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.displayManager = {
      # Enable automatic login for the user.
      autoLogin.enable = true;
      autoLogin.user = "martijn";

      sddm = {
        enable = true;
        wayland.enable = true;
      };

      defaultSession =
        if cfg.wayland
        then "plasma"
        else "plasmax11";
    };

    environment.plasma6.excludePackages = with pkgs.libsForQt5; [
      elisa
      khelpcenter
      konsole
    ];

    # Configure window manager
    services.desktopManager.plasma6.enable = true;
  };
}
