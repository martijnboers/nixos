{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.hosts.desktop;
in {
  options.hosts.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      tray = true;
    };

    home.packages = with pkgs; [
      firefox
      kitty
      ungoogled-chromium
      libsForQt5.kdeconnect-kde
      libsForQt5.neochat
      libsForQt5.kompare
      wl-clipboard # wayland clipboard manager
      obsidian

      # music
      clementine
      spotify

      # theming
      nordic
      materia-kde-theme
      gimp
    ];
  };
}
