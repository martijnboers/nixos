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

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.defaultSession =
      if cfg.wayland
      then "plasma"
      else "plasmax11";

    environment.plasma6.excludePackages = with pkgs.libsForQt5; [
      elisa
      khelpcenter
      konsole
    ];

    # Configure window manager
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
  };
}
