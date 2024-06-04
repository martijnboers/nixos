{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.thuis.desktop;
in {
  options.thuis.desktop = {
    enable = mkEnableOption "Enable default desktop packages + configuration";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      firefox
      kitty
      ungoogled-chromium
      libsForQt5.kdeconnect-kde
      libsForQt5.kompare # diff viewer
      libsForQt5.kate
      wl-clipboard # wayland clipboard manager
      obsidian
      vlc
      cinny-desktop # matrix client
      kooha # record screen wayland

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
